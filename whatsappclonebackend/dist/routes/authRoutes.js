"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const router = (0, express_1.Router)();
router.post('/sendOtp', sendOtp);
router.post('/verifyOtp', verifyOtp);
exports.default = router;
