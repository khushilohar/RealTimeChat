import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { getConversation, sendMessage } from '../controllers/messageController';

const messageRouter = Router();

// messageRouter.use(authenticate);

messageRouter.get('/conversation/:contactId',authenticate, getConversation);
messageRouter.post('/',authenticate, sendMessage); // optional HTTP send

export default messageRouter;