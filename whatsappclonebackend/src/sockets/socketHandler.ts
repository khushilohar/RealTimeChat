import { Server, Socket } from 'socket.io';
import {redis} from '../config/redis';
import Message from '../models/Message';
import User from '../models/User';

export const registerSocketHandlers = (io: Server, socket: Socket) => {
  const userId = (socket as any).userId; // set during authentication

  // Join a room for direct messaging (optional, but we'll use socket.to)
  socket.join(`user:${userId}`);

  // Handle sending a message
  socket.on('send_message', async (data) => {
    try {
      const { receiverId, message, messageType = 'text', mediaUrl } = data;

      // Save to database
      const newMessage = await Message.create({
        sender_id: userId,
        receiver_id: receiverId,
        message,
        message_type: messageType,
        // media_url: mediaUrl,
      });

      // Include sender info
      const messageWithSender = {
        ...newMessage.toJSON(),
        sender: { id: userId, name: socket.data.user?.name }, // optionally fetch
      };

      // Emit to receiver if online
      const receiverSocketId = await redis.get(`socket:${receiverId}`);
      if (receiverSocketId) {
        io.to(receiverSocketId).emit('new_message', messageWithSender);
      }

      // Also emit to sender's own clients (for multiple tabs)
      socket.emit('message_sent', messageWithSender);
    } catch (error) {
      console.error('Socket send_message error:', error);
      socket.emit('error', 'Failed to send message');
    }
  });

  // Typing indicator
  socket.on('typing', (data) => {
    const { receiverId, isTyping } = data;
    // Emit to receiver if online
    redis.get(`socket:${receiverId}`).then((receiverSocketId) => {
      if (receiverSocketId) {
        io.to(receiverSocketId).emit('typing', {
          senderId: userId,
          isTyping,
        });
      }
    });
  });

  // Mark messages as read
  socket.on('mark_read', async (data) => {
    const { senderId } = data; // the user whose messages we read
    await Message.update(
      { is_read: true },
      {
        where: {
          sender_id: senderId,
          receiver_id: userId,
          is_read: false,
        },
      }
    );
    // Notify sender that messages are read
    const senderSocketId = await redis.get(`socket:${senderId}`);
    if (senderSocketId) {
      io.to(senderSocketId).emit('messages_read', { readerId: userId });
    }
  });

  // Handle disconnection
  socket.on('disconnect', async () => {
    await redis.del(`socket:${userId}`);
    await redis.del(`user:${socket.id}`);
    // Optionally broadcast offline status
    socket.broadcast.emit('user_offline', userId);
  });
};