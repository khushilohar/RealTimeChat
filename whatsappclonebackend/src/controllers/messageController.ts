import { Request, Response } from 'express';
import { Op } from 'sequelize';
import Message from '../models/Message';
import User from '../models/User';

// Get conversation between current user and another user
export const getConversation = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const contactId = parseInt(Array.isArray(req.params.contactId) ? req.params.contactId[0] : req.params.contactId, 10);
    if (isNaN(contactId)) {
      return res.status(400).json({ error: 'Invalid contact ID' });
    }

    const limit = Math.min(parseInt(req.query.limit as string, 10) || 50, 100);
    const before = req.query.before ? parseInt(req.query.before as string, 10) : undefined;

    const whereClause: any = {
      [Op.or]: [
        { sender_id: userId, receiver_id: contactId },
        { sender_id: contactId, receiver_id: userId },
      ],
    };

    if (before) {
      whereClause.created_at = { [Op.lt]: new Date(before) };
    }

    const messages = await Message.findAll({
      where: whereClause,
      order: [['created_at', 'DESC']],
      limit,
      include: [
        { model: User, as: 'sender', attributes: ['id', 'name', 'profile_pic'] },
      ],
    });

    // Mark messages as read if current user is receiver
    await Message.update(
      { is_read: true },
      {
        where: {
          receiver_id: userId,
          sender_id: contactId,
          is_read: false,
        },
      }
    );

    res.json(messages.reverse());
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
};

// Send a message via HTTP (fallback if socket not used)
export const sendMessage = async (req: Request, res: Response) => {
  try {
    const senderId = (req as any).user.id;
    const { receiverId, message, messageType = 'text' } = req.body; // removed mediaUrl

    if (!receiverId || !message) {
      return res.status(400).json({ error: 'receiverId and message are required' });
    }

    const newMessage = await Message.create({
      sender_id: senderId,
      receiver_id: receiverId,
      message,
      message_type: messageType,
      // mediaUrl removed
    });

    // Emit via socket (if socket instance available)
    const io = req.app.get('socketio');
    if (io) {
      const receiverSocketId = await getReceiverSocketId(receiverId);
      if (receiverSocketId) {
        io.to(receiverSocketId).emit('new_message', {
          ...newMessage.toJSON(),
          sender: { id: senderId },
        });
      }
    }

    res.status(201).json(newMessage);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to send message' });
  }
};

// Helper to get socket id from Redis
async function getReceiverSocketId(userId: number): Promise<string | null> {
  const redis = (await import('../config/redis')).redis;
  return redis.get(`socket:${userId}`);
}