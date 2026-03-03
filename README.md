# 1. Introduction

This document provides comprehensive technical documentation for the backend service of a WhatsApp-like chat application. The system handles user authentication via OTP, real-time messaging using WebSockets, and persistent storage of messages and user data. It is built with Node.js, Express, Socket.io, MySQL (via Sequelize), Redis, and Twilio for SMS.


# 2. Tech Stack

Runtime: Node.js
Framework: Express.js
Real-time Communication: Socket.io
Database: MySQL with Sequelize ORM
Caching/Session Store: Redis (ioredis)
Authentication: JWT (JSON Web Tokens)
SMS Service: Twilio
Language: TypeScript


# 3. Project Structure

#### src/
#### ├── config/
#### │   ├── db_mysql.ts          # Sequelize MySQL connection
#### │   ├── redis.ts              # Redis client
#### │   └── twilio.ts             # Twilio client configuration
#### ├── controllers/
#### │   ├── authControllers.ts    # OTP send/verify logic
#### │   ├── messageController.ts  # Message retrieval & sending (HTTP)
#### │   └── userControllers.ts    # User profile & status endpoints
#### ├── middleware/
#### │   ├── auth.ts               # JWT authentication middleware
#### │   └── socketMiddleware.ts   # Socket.io authentication & setup
#### ├── models/
#### │   ├── User.ts               # User model
#### │   └── Message.ts            # Message model
#### ├── routes/
#### │   ├── authRoutes.ts         # Authentication routes
#### │   ├── messageRoutes.ts      # Message routes
#### │   └── userRouters.ts        # User routes
#### ├── utils/
#### │   └── generateOtp.ts        # OTP generator
#### ├── socket/
#### │   └── socketHandler.ts      # Socket event handlers
#### └── server.ts                 # Entry point


# 4. Environment Variables
### Server
PORT=8000

### MySQL Database
DB_NAME=whatsapp_clone
DB_USER=root
DB_PASSWORD=yourpassword
DB_HOST=localhost

### Redis
REDIS_URL=redis://localhost:6379

### Twilio
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1234567890

### JWT
JWT_SECRET=your_super_secret_key

# 5. Setup Instructions

Prerequisites

Node.js (v16+)
MySQL server
Redis server
Twilio account (for SMS)

Installation

Clone the repository.
Run npm install to install dependencies.
Create a MySQL database (e.g., whatsapp_clone).
Start Redis and MySQL services.
Configure environment variables as above.
Run npm run dev for development or npm start for production.

Database Sync

On startup, Sequelize automatically syncs the models (creates tables if they don't exist). Ensure the database is created beforehand.

# 6. Database Schema

## User Model (users table)
  ###
    Column	                Type                        Attributes                  Description
    ------------- ----------------- ----------------------------- -----------------------------
    id	            INT UNSIGNED        PRIMARY KEY AUTO_INCREMENT               Unique user ID
    phone_number      STRING(20)	              NOT NULL, UNIQUE          User's phone number
    name             STRING(100)                                                   Display name
    profile_pic	     STRING(255)                                         URL to profile picture
    is_verified	         BOOLEAN	                 DEFAULT false    Phone verification status
    created_at	        DATETIME	     DEFAULT CURRENT_TIMESTAMP         Record creation time
    updated_at	        DATETIME	     DEFAULT CURRENT_TIMESTAMP             Last update time

## Message Model (messages table)
  ###
    Column	                   Type                          Attributes             Description
    --------------   -------------------       --------------------------  ----------------------
     id                INT UNSIGNED          PRIMARY KEY AUTO_INCREMENT       Unique message ID
     sender_id         INT UNSIGNED               NOT NULL, FOREIGN KEY    References users(id)
     receiver_id       INT UNSIGNED               NOT NULL, FOREIGN KEY    References users(id)
     message                   TEXT                            NOT NULL         Message content
     message_type              ENUM                      DEFAULT 'text'  text/image/video/audio
     is_read                BOOLEAN                       DEFAULT false     Read receipt status
     created_at            DATETIME           DEFAULT CURRENT_TIMESTAMP    Timestamp of message

## Relationships:

A user can have many sent messages (sender_id).
A user can have many received messages (receiver_id).


# 7. Authentication Flow

## OTP Generation & Verification
**Send OTP:** Client provides phone number. Server generates a 6-digit OTP, stores it in Redis with an expiry (e.g., 5 minutes), and sends via Twilio SMS.

**Verify OTP:** Client submits phone number and OTP. Server validates against Redis. If correct, user is created/updated and a JWT token is issued.

**Redis OTP Key Pattern:** otp:<phone_number> with value OTP and TTL.


## JWT Token
Generated upon successful OTP verification.
Contains payload: { id: userId, phone_number: string }.
Token is sent to client and must be included in Authorization: Bearer <token> header for protected endpoints.
Tokens can be blacklisted (logout) by storing in Redis with key blacklist:<token>.


# 8. API Endpoints
Base URL: http://localhost:8000 (or your deployed domain)

Authentication Routes (/auth)
-------------------------------
Method	   Endpoint	         Description	              Request Body	                                               Response
------- --------------- -----------------------  -----------------------------------------           -----------------------------------------
POST	   /sendOtp	        Send OTP to phone	{ "phone_number": "+1234567890" }	                     { "message": "OTP sent successfully" }
POST	   /verifyOtp	  Verify OTP & login	{ "phone_number": "+1234567890", "otp": "123456" }	     { "token": "jwt_token", "user": { ... } }


User Routes (/user)
-------------------------------
All endpoints require Authorization: Bearer <token> header.

Method	                   Endpoint	                        Description	                             Response
----------------  ----------------------------------  ----------------------------------------  --------------------------------------
GET	                        /me	                        Get current user profile	            { "id": 1, "phone_number": "...", ... }
GET	                        /	                        List all users (excluding self)	        [ { "id": 2, "name": "...", ... }, ... ]
GET	                        /:userId/status	            Get online status of a user	            { "userId": 2, "online": true }
GET	                        /logout	                    Invalidate current token	            { "message": "Logged out successfully" }

Message Routes (/message)
---------------------------------
All endpoints require Authorization: Bearer <token> header.

Method	            Endpoint	                    Description	                        Request Body	                    Response
---------------- ------------------------  ------------------------------------ ---------------------------------- ----------------------------
GET	                /conversation/:contactId	Get message history with a contact	        -	                         [ { "id": 1, "message": "...", ... } ]
POST	            /	                        Send a new message (HTTP fallback)	   { "receiverId": 2, "message":
                                                                                     "Hello", "messageType": "text" }	    { "id": 1, "message": "...", ... }

                                                                                     
# 9. Socket.io Events
Socket.io is used for real-time messaging. Connection requires authentication via token in handshake.

Connection:-

Auth: Client must provide token in handshake auth or query.
After authentication, the socket joins a room user:<userId> and stores mapping in Redis (socket:<userId> -> socket.id).

Emitted Events (Client to Server)
---------------------------------
Event	                    Data Structure	                                                    Description
------------        ------------------------------                                           ---------------------------
send_message	{ receiverId: number, message: string, messageType?: string }	            Send a message to another user.
typing	        { receiverId: number, isTyping: boolean }	                                Notify receiver about typing status.
mark_read	    { senderId: number }	                                                    Mark all messages from sender as read.

Received Events (Server to Client)
-----------------------------------
Event	                                        Data Structure	                                  Description
----------------------                     -------------------------                     -------------------------------
new_message	                        { id, sender_id, receiver_id, message, message_type,         Incoming message.
                                     created_at, sender: { id, name } }	                  
message_sent	                        Same as above	                                        Confirmation to sender.
typing	                            { senderId: number, isTyping: boolean }	                Typing indicator from another user.
messages_read	                    { readerId: number }	                                Notification that messages were read.
user_online	                                 userId	                                           Broadcast when user connects.
user_offline	                             userId	                                           Broadcast when user disconnects.
error	                                { message: string }	                                             Error event.


# 10. Middleware
Authentication Middleware (auth.ts)

Extracts token from Authorization header.
Verifies JWT and checks Redis blacklist.
Attaches decoded user to req.user.
Returns 401/403 on failure.

Socket Authentication (socketMiddleware.ts)

Intercepts socket connection, validates token via JWT.
Fetches user from database.
Stores userId in socket object and Redis mapping.
Sets up connection and disconnection handlers.


# 11. Redis Usage
Redis serves multiple purposes:

OTP Storage: Temporary OTP codes with expiry.
Token Blacklist: Invalidated tokens after logout.
Socket Mapping: socket:<userId> → socket.id for direct messaging.
Reverse Mapping: user:<socket.id> → userId for cleanup.
All Redis keys have appropriate TTLs to prevent stale data.


# 12. Error Handling
HTTP: Standard Express error middleware returns JSON with error or message field.
Socket: Errors are emitted to the client via error event.
Database: Sequelize validation errors are caught and returned appropriately.
Unhandled Rejections: Should be logged; production setup should include process-level handlers.


# 13. Deployment Considerations
Set up environment variables securely.
Enable CORS only for allowed origins (configured in server.ts).
Use HTTPS in production.
Configure Redis persistence if needed.
Use MySQL replication or clustering for scalability.
Monitor WebSocket connections with sticky sessions if using multiple nodes (or use Redis adapter for Socket.io).


# 14. Conclusion
------------------
This backend provides a solid foundation for a real-time chat application with authentication, messaging, and user management. The code is modular and can be extended with features like group chats, media uploads, and push notifications.

For any questions or contributions, please contact the development team.
