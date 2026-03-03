import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/db_mysql';
import User from './User';

interface MessageAttributes {
  id: number;
  sender_id: number;
  receiver_id: number;
  message: string;
  message_type?: 'text' | 'image' | 'video' | 'audio';
  is_read: boolean;
  created_at: Date;
}

interface MessageCreationAttributes
  extends Optional<MessageAttributes, 'id' | 'message_type' | 'is_read' | 'created_at'> {}

class Message
  extends Model<MessageAttributes, MessageCreationAttributes>
  implements MessageAttributes
{
  public id!: number;
  public sender_id!: number;
  public receiver_id!: number;
  public message!: string;
  public message_type?: 'text' | 'image' | 'video' | 'audio';
  public is_read!: boolean;
  public readonly created_at!: Date;
}

Message.init(
  {
    id: {
      type: DataTypes.INTEGER.UNSIGNED,
      autoIncrement: true,
      primaryKey: true,
    },
    sender_id: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      references: {
        model: User,
        key: 'id',
      },
    },
    receiver_id: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      references: {
        model: User,
        key: 'id',
      },
    },
    message: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    message_type: {
      type: DataTypes.ENUM('text', 'image', 'video', 'audio'),
      defaultValue: 'text',
    },
    is_read: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    tableName: 'messages',
    timestamps: false,
    underscored: true,
  }
);

// Associations
User.hasMany(Message, { as: 'sentMessages', foreignKey: 'sender_id' });
User.hasMany(Message, { as: 'receivedMessages', foreignKey: 'receiver_id' });
Message.belongsTo(User, { as: 'sender', foreignKey: 'sender_id' });
Message.belongsTo(User, { as: 'receiver', foreignKey: 'receiver_id' });

export default Message;