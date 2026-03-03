import twilio from "twilio";
import dotenv from "dotenv";
import { error } from "node:console";
dotenv.config();
const acSid = process.env.TWILIO_ACCOUNT_SID;
const twilioToken = process.env.TWILIO_AUTH_TOKEN;
export const twilioNumber = process.env.TWILIO_PHONE_NUMBER;
if (!acSid || !twilioToken || !twilioNumber){
    throw new Error("All twilio are required");
}
export const client = twilio(acSid,twilioToken); 
