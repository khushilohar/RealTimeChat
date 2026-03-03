"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const http_1 = __importDefault(require("http"));
const db_mysql_1 = __importDefault(require("./config/db_mysql"));
const express_1 = __importDefault(require("express"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const server = http_1.default.createServer(app);
const PORT = process.env.PORT;
db_mysql_1.default.sync({ alter: true }).then(() => {
    console.log('MySQL synced');
});
server.listen(PORT, () => {
    console.log(`server running on port: ${PORT}`);
});
