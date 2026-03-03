import { Request, Response } from 'express';
import User from '../models/User';
import {redis} from '../config/redis';

// Get all users (for new chat)
export const getAllUsers = async (req: Request, res: Response) => {
  try {
    const users = await User.findAll({
      attributes: ['id', 'phone_number', 'name', 'profile_pic'],
      order: [['name', 'ASC']],
    });
    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
};

// Get current user profile
export const getCurrentUser = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const user = await User.findByPk(userId, {
      attributes: ['id', 'phone_number', 'name', 'profile_pic', 'is_verified'],
    });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { name, profilePic } = req.body;
    
    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    await user.update({
      name: name || user.name,
      profile_pic: profilePic || user.profile_pic,
    });

    res.json({
      id: user.id,
      phoneNumber: user.phone_number,
      name: user.name,
      profilePic: user.profile_pic,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
};

export const deleteAccount = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    await user.destroy();
    res.json({ message: 'Account deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to delete account' });
  }
};

export const logOut = async (req: Request, res: Response) => {
  try {
    // For JWT, we can't truly log out on the server side, but we can instruct the client to delete the token
    const authHeader = req.headers.authorization;
    const token = authHeader?.split(" ")[1];
    if (token) {
      await redis.setex(`blacklist:${token}`, 180000, "blacklisted"); // 3000 minutes = 50 hr
    }
    res.json({ message: 'Logged out successfully' });
    // is_active = False in sql
    await User.update({ is_active: false }, { where: { id: (req as any).user.id } });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to log out' });
  }
};

// Optional: You can track online users by storing socket IDs in Redis. For example, when a user connects, set a key online:userId with socket ID and expiry. On disconnect, remove it. Then other users can query status via REST or socket.
export const getUserStatus = async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const online = await redis.exists(`online:${userId}`);
    res.json({ online: online === 1 });
  } catch (error) {
    res.status(500).json({ error: 'Failed to get status' });
  }
};