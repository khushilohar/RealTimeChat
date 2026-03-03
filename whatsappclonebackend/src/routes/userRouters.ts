import { Router } from 'express';
import { getAllUsers, getCurrentUser, getUserStatus, logOut } from '../controllers/userControllers';
import { authenticate } from '../middleware/auth';

const userRouter = Router();

userRouter.get('/me', authenticate, getCurrentUser);
userRouter.get('/', authenticate, getAllUsers);
userRouter.get('/:userId/status', authenticate, getUserStatus);
userRouter.get('/logout', authenticate, logOut);

export default userRouter;