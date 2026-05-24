import { db } from '../config/db.js';
export class NotificationController {
    static async getNotifications(req, res, next) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
            }
            const notifsRes = await db.query("SELECT id, title, message, type, is_read as \"isRead\", created_at as \"createdAt\" FROM notifications WHERE user_id = $1 ORDER BY id DESC;", [userId]);
            res.status(200).json({
                status: 'success',
                results: notifsRes.rows.length,
                data: notifsRes.rows
            });
        }
        catch (error) {
            next(error);
        }
    }
    static async markAsRead(req, res, next) {
        try {
            const userId = req.user?.id;
            const { id } = req.params;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
            }
            if (!id) {
                return res.status(400).json({ error: 'ValidationError', message: 'Notification ID is required.' });
            }
            const updateRes = await db.query("UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2 RETURNING id, is_read;", [parseInt(id), userId]);
            if (updateRes.rows.length === 0) {
                return res.status(404).json({ error: 'NotFoundError', message: 'Notification not found.' });
            }
            res.status(200).json({
                status: 'success',
                message: 'Notification marked as read.',
                data: updateRes.rows[0]
            });
        }
        catch (error) {
            next(error);
        }
    }
    static async markAllAsRead(req, res, next) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
            }
            await db.query("UPDATE notifications SET is_read = true WHERE user_id = $1;", [userId]);
            res.status(200).json({
                status: 'success',
                message: 'All notifications marked as read.'
            });
        }
        catch (error) {
            next(error);
        }
    }
}
