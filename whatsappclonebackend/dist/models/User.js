"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const sequelize_1 = require("sequelize");
const db_mysql_1 = __importDefault(require("../config/db_mysql"));
class User extends sequelize_1.Model {
}
User.init({
    id: {
        type: sequelize_1.DataTypes.INTEGER.UNSIGNED,
        autoIncrement: true,
        primaryKey: true,
    },
    phone_number: {
        type: sequelize_1.DataTypes.STRING(20),
        allowNull: false,
        unique: true,
    },
    name: {
        type: sequelize_1.DataTypes.STRING(100),
    },
    profile_pic: {
        type: sequelize_1.DataTypes.STRING(255),
    },
    is_verified: {
        type: sequelize_1.DataTypes.BOOLEAN,
        defaultValue: false,
    },
    is_active: {
        type: sequelize_1.DataTypes.BOOLEAN,
        defaultValue: true,
    },
    created_at: {
        type: sequelize_1.DataTypes.DATE,
        defaultValue: sequelize_1.DataTypes.NOW,
    },
    updated_at: {
        type: sequelize_1.DataTypes.DATE,
        defaultValue: sequelize_1.DataTypes.NOW,
    },
}, {
    sequelize: db_mysql_1.default,
    tableName: 'users',
    timestamps: false,
    underscored: true,
});
exports.default = User;
