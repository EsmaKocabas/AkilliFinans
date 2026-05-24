import { Response, NextFunction } from 'express';
import { AuthenticatedRequest } from '../middlewares/auth.middleware.js';
import { db } from '../config/db.js';

export class UserController {
  public static async getProfile(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
      }

      const userRes = await db.query("SELECT * FROM users WHERE id = $1;", [userId]);

      if (userRes.rows.length === 0) {
        return res.status(404).json({ error: 'NotFoundError', message: 'User not found.' });
      }

      const user = userRes.rows[0];

      res.status(200).json({
        user: {
          id: parseInt(user.id),
          fullName: user.full_name,
          email: user.email,
          budget: parseFloat(user.budget),
          riskAppetite: user.risk_appetite ? parseInt(user.risk_appetite) : 50
        }
      });
    } catch (error) {
      next(error);
    }
  }

  public static async updateProfile(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id;
      const { fullName, budget } = req.body;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
      }

      const userRes = await db.query("SELECT * FROM users WHERE id = $1;", [userId]);
      if (userRes.rows.length === 0) {
        return res.status(404).json({ error: 'NotFoundError', message: 'User not found.' });
      }

      let query = "UPDATE users SET ";
      const params: any[] = [];
      let paramIndex = 1;

      if (fullName) {
        query += `full_name = $${paramIndex++}, `;
        params.push(fullName.trim());
      }

      if (budget !== undefined) {
        query += `budget = $${paramIndex++}, `;
        params.push(parseFloat(budget));
      }

      // If nothing to update, return current profile
      if (params.length === 0) {
        const user = userRes.rows[0];
        return res.status(200).json({
          message: 'No changes provided.',
          user: {
            id: parseInt(user.id),
            fullName: user.full_name,
            email: user.email,
            budget: parseFloat(user.budget),
            riskAppetite: user.risk_appetite ? parseInt(user.risk_appetite) : 50
          }
        });
      }

      // Remove trailing comma and space, add WHERE clause
      query = query.slice(0, -2) + ` WHERE id = $${paramIndex} RETURNING id, full_name, email, budget;`;
      params.push(userId);

      const updateRes = await db.query(query, params);
      const updatedUser = updateRes.rows[0];

      res.status(200).json({
        message: 'Profile updated successfully.',
        user: {
          id: parseInt(updatedUser.id),
          fullName: updatedUser.full_name,
          email: updatedUser.email,
          budget: parseFloat(updatedUser.budget),
          riskAppetite: updatedUser.risk_appetite ? parseInt(updatedUser.risk_appetite) : 50
        }
      });
    } catch (error) {
      next(error);
    }
  }
}
