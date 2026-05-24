import dotenv from 'dotenv';
import { app } from './app.js';
import { initializeDatabase } from './config/db.js';

dotenv.config();

const PORT = process.env.PORT || 5001;

async function startServer() {
  await initializeDatabase();
  
  app.listen(PORT, () => {
    console.log(`🚀 Akıllı Finans Backend sunucusu başlatıldı!`);
    console.log(`📡 Dinlenen adres: http://localhost:${PORT}`);
    console.log(`⚙️ Çalışma modu: ${process.env.NODE_ENV || 'development'}`);
  });
}

startServer();
