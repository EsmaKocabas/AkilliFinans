import { Router } from 'express';
import { MapController } from '../controllers/map.controller.js';
const router = Router();
router.get('/atms', MapController.getAtms);
router.get('/nearby', MapController.getNearbyAtms);
router.post('/optimize', MapController.optimizeAtms);
export { router as mapRouter };
