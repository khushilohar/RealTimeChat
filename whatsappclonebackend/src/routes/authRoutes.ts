import { Router } from "express";
import { sendOtp,verifyOtp } from "../controllers/authControllers";
const authRouter = Router();

authRouter.post('/sendOtp', sendOtp);
authRouter.post('/verifyOtp', verifyOtp);

export default authRouter;