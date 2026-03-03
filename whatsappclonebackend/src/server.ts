import http from "http";
import sequelize from "./config/db_mysql";
import express from "express";
import dotenv from "dotenv";
import cors from "cors";                     
import authRouter from "./routes/authRoutes";
import userRouter from "./routes/userRouters";
import messageRouter from "./routes/messageRoutes"; 

dotenv.config();
const app = express();

app.use(
    cors({
        origin: ["http://10.0.2.2:8000", "http://localhost:3000"],
        credentials: true,
    })
);                            
app.use(express.json());

app.use('/auth', authRouter);
app.use('/user', userRouter);
app.use('/message', messageRouter);           

const server = http.createServer(app);
const PORT = process.env.PORT || 8000;

sequelize.sync()
  .then(() => {
    console.log('MySQL synced');
    server.listen(PORT, () => {
      console.log(`Server running on port: ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Database connection failed:', err);
  });