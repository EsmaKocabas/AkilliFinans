import { Router } from 'express';
import { authRouter } from './auth.routes.js';
import { userRouter } from './user.routes.js';
import { transactionRouter } from './transaction.routes.js';
import { mapRouter } from './map.routes.js';
import { investmentRouter } from './investment.routes.js';
import notificationRouter from './notification.routes.js';

const router = Router();

router.use('/auth', authRouter);
router.use('/users', userRouter);
router.use('/', transactionRouter);
router.use('/map', mapRouter);
router.use('/investments', investmentRouter);
router.use('/notifications', notificationRouter);

export { router as apiRouter };
