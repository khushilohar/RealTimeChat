import { Server } from 'socket.io';
import http from 'http';
import jwt from 'jsonwebtoken';
import {redis} from '../config/redis';
import User from '../models/User';
import { registerSocketHandlers } from './socketHandler';

export const configureSocket = (server: http.Server) => {
  const io = new Server(server, {
    cors: {
      origin: ["http://10.0.2.2:8000", "http://localhost:3000", "*"], // configure appropriately
      methods: ['GET', 'POST'],
    },
  });

  // Authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.query.token;
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { id: number };
      const user = await User.findByPk(decoded.id, { attributes: ['id', 'name', 'profile_pic'] });
      if (!user) {
        return next(new Error('User not found'));
      }

      // Attach user to socket object
      (socket as any).userId = user.id;
      socket.data.user = user;

      // Store mapping in Redis
      await redis.set(`socket:${user.id}`, socket.id, 'EX', 86400); // 24h expiry
      await redis.set(`user:${socket.id}`, user.id, 'EX', 86400);

      next();
    } catch (err) {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`User ${(socket as any).userId} connected`);
    // Broadcast online status
    socket.broadcast.emit('user_online', (socket as any).userId);

    registerSocketHandlers(io, socket);
  });

  return io;
};