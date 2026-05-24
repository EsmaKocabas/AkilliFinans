import { Router } from 'express';
import { NotificationController } from '../controllers/notification.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';

const router = Router();

// Apply authMiddleware to all notification routes
router.use(authMiddleware);

router.get('/', NotificationController.getNotifications);
router.put('/read-all', NotificationController.markAllAsRead);
router.put('/:id/read', NotificationController.markAsRead);

export default router;
