import express from 'express';
import cors from 'cors';
import { apiRouter } from './routes/index.js';
import { errorHandler } from './middlewares/error.middleware.js';
const app = express();
// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Rota Kaydı (Prefixed with /api)
app.use('/api', apiRouter);
// Sağlık kontrolü (Healthcheck)
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok', timestamp: new Date() });
});
// Bilinmeyen Rotalar için 404 Handler
app.use((req, res, next) => {
    res.status(404).json({ error: 'Not Found', message: `${req.originalUrl} route not found.` });
});
// Merkezi Hata Yakalayıcı (Global Error Handler)
app.use(errorHandler);
export { app };
