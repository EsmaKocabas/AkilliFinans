import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { db } from '../config/db.js';

export class AuthController {
  public static async register(req: Request, res: Response, next: NextFunction) {
    try {
      const { fullName, email, password } = req.body;

      if (!fullName || !email || !password) {
        return res.status(400).json({ error: 'ValidationError', message: 'All fields are required.' });
      }

      // Check if user already exists in Neon DB
      const existingUserRes = await db.query(
        "SELECT * FROM users WHERE LOWER(email::text) = LOWER($1);",
        [email.trim()]
      );

      if (existingUserRes.rows.length > 0) {
        return res.status(409).json({ error: 'ConflictError', message: 'Email address already registered.' });
      }

      // Hash password
      const passwordHash = bcrypt.hashSync(password, 10);

      // Create new user in Neon DB
      const insertUserRes = await db.query(
        `INSERT INTO users (full_name, email, password_hash, budget, is_active, created_at)
         VALUES ($1, $2, $3, $4, true, NOW())
         RETURNING id, full_name, email, budget;`,
        [fullName.trim(), email.trim().toLowerCase(), passwordHash, 50000.00]
      );

      const newUser = insertUserRes.rows[0];

      // Create welcome notification
      await db.query(
        `INSERT INTO notifications (user_id, title, message, type)
         VALUES ($1, 'Hoş Geldiniz!', 'Akıllı Finans dünyasına adım attınız. Bütçenizi, harcamalarınızı ve yatırımlarınızı buradan takip edebilirsiniz.', 'success');`,
        [newUser.id]
      );

      // Create JWT token
      const JWT_SECRET = process.env.JWT_SECRET || 'supersecuresecret12345';
      const token = jwt.sign(
        { id: parseInt(newUser.id), email: newUser.email },
        JWT_SECRET,
        { expiresIn: (process.env.JWT_EXPIRES_IN || '7d') as any }
      );

      res.status(201).json({
        message: 'Registration successful.',
        token,
        user: {
          id: parseInt(newUser.id),
          fullName: newUser.full_name,
          email: newUser.email,
          budget: parseFloat(newUser.budget)
        }
      });
    } catch (error) {
      next(error);
    }
  }

  public static async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'ValidationError', message: 'Email and password are required.' });
      }

      // Query user from Neon DB
      const userRes = await db.query(
        "SELECT * FROM users WHERE LOWER(email::text) = LOWER($1);",
        [email.trim()]
      );

      if (userRes.rows.length === 0) {
        return res.status(401).json({ error: 'Unauthorized', message: 'Invalid email or password.' });
      }

      const user = userRes.rows[0];

      if (!bcrypt.compareSync(password, user.password_hash)) {
        return res.status(401).json({ error: 'Unauthorized', message: 'Invalid email or password.' });
      }

      // Create JWT token
      const JWT_SECRET = process.env.JWT_SECRET || 'supersecuresecret12345';
      const token = jwt.sign(
        { id: parseInt(user.id), email: user.email },
        JWT_SECRET,
        { expiresIn: (process.env.JWT_EXPIRES_IN || '7d') as any }
      );

      res.status(200).json({
        message: 'Login successful.',
        token,
        user: {
          id: parseInt(user.id),
          fullName: user.full_name,
          email: user.email,
          budget: parseFloat(user.budget)
        }
      });
    } catch (error) {
      next(error);
    }
  }

  public static async forgotPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const { email } = req.body;
      if (!email) {
        return res.status(400).json({ error: 'ValidationError', message: 'Email is required.' });
      }

      const userRes = await db.query(
        "SELECT * FROM users WHERE LOWER(email::text) = LOWER($1);",
        [email.trim()]
      );

      // For security, don't reveal if user exists or not, but return mock success
      res.status(200).json({
        message: 'If the email exists, a password reset link has been sent.'
      });
    } catch (error) {
      next(error);
    }
  }
}
