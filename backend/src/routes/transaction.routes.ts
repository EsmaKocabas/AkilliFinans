import { Router } from 'express';
import { TransactionController } from '../controllers/transaction.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';

const router = Router();

// Protect all transaction/dashboard routes
router.use(authMiddleware);

router.get('/transactions', TransactionController.getTransactions);
router.post('/transactions', TransactionController.createTransaction);
router.get('/dashboard/stats', TransactionController.getDashboardStats);

export { router as transactionRouter };
