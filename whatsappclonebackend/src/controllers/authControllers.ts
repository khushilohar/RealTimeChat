import { Request,response,Response } from "express";
import User from "../models/User";
import { generateOtp } from "../utils/generateOtp";
import {redis} from "../config/redis";
import {client, twilioNumber} from "../config/twilio"
import dotenv from "dotenv";
import jwt from "jsonwebtoken";
dotenv.config();
const otp_expiry = process.env.OTP_EXPIRY;
export const sendOtp = async(req:Request,res:Response)=>{
    try{
        const {phone_number} = req.body;
        console.log("Received phone number:", phone_number);
        if (!phone_number){
            return res.status(400).json ({
                error:"phone number is required"
            });
        }
        const otp = generateOtp();
        // Store OTP in Redis with phone number as key
        await redis.setex(phone_number, otp_expiry!,otp);
        // Send SMS via Twilio
        await client.messages.create({
            body: `Your Whatsapp Verification Code is: ${otp}`,
            from: twilioNumber,
            to: phone_number
        });
        res.json({
            message:"OTP Sent Successfully"
        });
    } catch (error){
       console.error(error);
       res.status(500).json({
            error: "Failed to sent OTP"
       });
    }
};

export const  verifyOtp = async(req:Request, res:Response)=>{
    try{
        const {phone_number,otp,name} = req.body;
        if(!phone_number || !otp){
            return res.status(400).json({
                error: "phone number and otp are required"
            }); 
        }
        const storeOtp = await redis.get(phone_number);
        if (!storeOtp || storeOtp !== otp){
            return res.status(400).json({
                error: "Invalid or expire OTP"
            });
        }
        // OTP verified – delete it from Redis
        await redis.del(phone_number);
        let user = await User.findOne({where: {phone_number}});
        // let user = await User.findOne(phone_number);
        if(!user){
            user = await User.create({
                // Left -> User.ts, Right-> req.body
                phone_number: phone_number, 
                name: name, 
                is_verified: true,
                is_active: true,          
            });
        } else{
            await user.update({
                is_active: true,
                is_verified: true,
                name: name || user.name,
            });
        }
        //generate jwt token
        const token = jwt.sign(
            {
                id: user.id,
                phone_number: user.phone_number,
                name: user.name,
                profile_pic: user.profile_pic,
            },
            process.env.JWT_SECRET!,
            // {
                
            //     expire_in: '7d',

            // }
        );
        res.json({
            token,
            user: {
                id: user.id,
                phone_number: user.phone_number,
                name: user.name,
                profile_pic: user.profile_pic,
            }
        })
    } catch (error){
        console.error(error);
        res.status(500).json({
            error:"Verifications failled"
        });
    }
};