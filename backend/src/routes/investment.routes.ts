import { Router } from 'express';
import { InvestmentController } from '../controllers/investment.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';

const router = Router();

// Protect all investment routes
router.use(authMiddleware);

router.get('/portfolio', InvestmentController.getPortfolio);
router.get('/suggestions', InvestmentController.getSuggestions);
router.post('/trade', InvestmentController.executeTrade);

export { router as investmentRouter };
