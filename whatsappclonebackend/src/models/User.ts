import { DataTypes,Model, Optional } from "sequelize";
import sequelize from "../config/db_mysql";

interface UserAttributes {
  id: number;
  phone_number: string;
  name?: string;
  profile_pic?: string;
  is_verified: boolean;
  is_active: boolean;
  created_at?: Date;
  updated_at?: Date;
}
interface UserCreationAttributes extends Optional<UserAttributes, 'id' | 'is_verified' | 'is_active' | 'created_at' | 'updated_at'> {}

class User extends Model<UserAttributes, UserCreationAttributes> implements UserAttributes {
  public id!: number;
  public phone_number!: string;
  public name?: string;
  public profile_pic?: string;
  public is_verified!: boolean;
  public is_active!: boolean;
  public readonly created_at!: Date;
  public readonly updated_at!: Date;
}

User.init(
  {
    id: {
      type: DataTypes.INTEGER.UNSIGNED,
      autoIncrement: true,
      primaryKey: true,
    },
    phone_number: {
      type: DataTypes.STRING(20),
      allowNull: false,
      unique: true,
    },
    name: {
      type: DataTypes.STRING(100),
    },
    profile_pic: {
      type: DataTypes.STRING(255),
    },
    is_verified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    updated_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    tableName: 'users',
    timestamps: false,
    underscored: true,
  }
);

export default User;