import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error("❌ DATABASE_URL environment variable is missing!");
}

export const pool = new pg.Pool({
  connectionString,
});

// Helper to query db easily
export const db = {
  query: (text: string, params?: any[]) => pool.query(text, params),
};

export async function initializeDatabase() {
  try {
    console.log("⚙️ Neon Veritabanı tabloları kontrol ediliyor...");

    // 1. Transactions Tablosunu Oluştur
    await db.query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id SERIAL PRIMARY KEY,
        user_id BIGINT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount NUMERIC NOT NULL,
        merchant TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        date TEXT NOT NULL,
        reference_code TEXT NOT NULL
      );
    `);

    // 2. Investments Tablosunu Oluştur
    await db.query(`
      CREATE TABLE IF NOT EXISTS investments (
        user_id BIGINT NOT NULL,
        asset_type TEXT NOT NULL,
        symbol TEXT NOT NULL,
        amount NUMERIC NOT NULL,
        PRIMARY KEY (user_id, symbol)
      );
    `);

    // 3. Notifications Tablosunu Oluştur
    await db.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id SERIAL PRIMARY KEY,
        user_id BIGINT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    console.log("✅ Tablolar hazır.");

    // Seed Default Welcome Notification if empty
    const notifCountRes = await db.query("SELECT COUNT(*) FROM notifications;");
    if (parseInt(notifCountRes.rows[0].count) === 0) {
      console.log("🌱 Örnek bildirim verisi veritabanına ekleniyor...");
      await db.query(`
        INSERT INTO notifications (user_id, title, message, type, is_read)
        VALUES (1, 'Hoş Geldiniz!', 'Akıllı Finans dünyasına adım attınız. Bütçenizi, harcamalarınızı ve yatırımlarınızı buradan takip edebilirsiniz.', 'success', false);
      `);
    }

    // 3. Seed Default Transactions if empty
    const txCountRes = await db.query("SELECT COUNT(*) FROM transactions;");
    if (parseInt(txCountRes.rows[0].count) === 0) {
      console.log("🌱 Örnek harcama verileri veritabanına ekleniyor...");
      
      const defaultTxs = [
        [1, 'Market Alışverişi', 'Market', -460.00, 'Çarşı Market Kadıköy', 'Temassız Kart', 'Bugün, 10:45', 'TXN-MK8842'],
        [1, 'Maaş Ödemesi', 'Maaş', 23000.00, 'Akilli Finans Ltd.', 'EFT', 'Dün, 09:00', 'TXN-PAY001'],
        [1, 'Elektrik Faturası', 'Fatura', -780.00, 'Şehir Dağıtım A.Ş.', 'Otomatik Ödeme', 'Dün, 20:10', 'TXN-FT9910'],
        [1, 'Metro Bilet', 'Ulaşım', -120.00, 'İstanbul Kart', 'NFC', '1 Mayıs 2026, 07:52', 'TXN-METRO1'],
        [1, 'Dijital Yayın Aboneliği', 'Eğlence', -89.00, 'Netflix', 'Sanal Kart', '26 Nisan 2026, 03:05', 'TXN-SUB903']
      ];

      for (const tx of defaultTxs) {
        await db.query(`
          INSERT INTO transactions (user_id, title, category, amount, merchant, payment_method, date, reference_code)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8);
        `, tx);
      }
    }

    // 4. Seed Default Investments if empty
    const invCountRes = await db.query("SELECT COUNT(*) FROM investments;");
    if (parseInt(invCountRes.rows[0].count) === 0) {
      console.log("🌱 Örnek yatırım verileri veritabanına ekleniyor...");

      const defaultInvs = [
        [1, 'fon', 'AFT', 56205.00],
        [1, 'hisse', 'THYAO', 37470.00],
        [1, 'altin', 'XAU/TRY', 18735.00],
        [1, 'gumus', 'XAG/TRY', 12490.00]
      ];

      for (const inv of defaultInvs) {
        await db.query(`
          INSERT INTO investments (user_id, asset_type, symbol, amount)
          VALUES ($1, $2, $3, $4);
        `, inv);
      }
    }

    console.log("🚀 Neon Veritabanı kurulumu başarıyla tamamlandı!");
  } catch (err: any) {
    console.error("❌ Veritabanı başlatma hatası:", err.message);
  }
}
