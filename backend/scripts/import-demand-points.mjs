import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';
import dotenv from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const BACKEND_ROOT = path.resolve(__dirname, '..');

dotenv.config({ path: path.join(BACKEND_ROOT, '.env') });

const POINTS_CSV = path.join(BACKEND_ROOT, 'src/analytics/veri/demand_points.csv');
const USERS_CSV = path.join(BACKEND_ROOT, 'src/analytics/veri/users.csv');

/** Minimal RFC-style CSV parser (handles quoted fields with commas). */
function parseCsv(content) {
  const rows = [];
  let row = [];
  let field = '';
  let inQuotes = false;

  for (let i = 0; i < content.length; i++) {
    const ch = content[i];
    const next = content[i + 1];

    if (inQuotes) {
      if (ch === '"' && next === '"') {
        field += '"';
        i++;
      } else if (ch === '"') {
        inQuotes = false;
      } else {
        field += ch;
      }
      continue;
    }

    if (ch === '"') {
      inQuotes = true;
    } else if (ch === ',') {
      row.push(field);
      field = '';
    } else if (ch === '\n' || (ch === '\r' && next === '\n')) {
      row.push(field);
      field = '';
      if (row.some((cell) => cell.length > 0)) rows.push(row);
      row = [];
      if (ch === '\r') i++;
    } else {
      field += ch;
    }
  }

  if (field.length > 0 || row.length > 0) {
    row.push(field);
    rows.push(row);
  }

  const headers = rows[0];
  return rows.slice(1).map((values) => {
    const obj = {};
    headers.forEach((h, idx) => {
      obj[h.trim()] = (values[idx] ?? '').trim();
    });
    return obj;
  });
}

async function seedMissingUsers(client) {
  const rows = parseCsv(fs.readFileSync(USERS_CSV, 'utf-8'));

  const existing = await client.query('SELECT id FROM users');
  const existingIds = new Set(existing.rows.map((r) => Number(r.id)));

  const toInsert = rows.filter((row) => !existingIds.has(Number(row.id)));

  for (const row of toInsert) {
    await client.query(
      `INSERT INTO users (id, full_name, email, password_hash, budget, is_active)
       VALUES ($1, $2, $3, $4, $5, true)
       ON CONFLICT (id) DO NOTHING`,
      [
        Number(row.id),
        row.full_name,
        row.email.toLowerCase(),
        row.password_hash,
        parseFloat(row.budget),
      ]
    );
  }

  if (toInsert.length > 0) {
    await client.query(
      `SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 1))`
    );
  }

  console.log(
    toInsert.length === 0
      ? 'All users from CSV already exist in DB.'
      : `Seeded ${toInsert.length} users from users.csv.`
  );
  return toInsert.length;
}

async function importCustomerPoints(client) {
  const rows = parseCsv(fs.readFileSync(POINTS_CSV, 'utf-8'));

  for (const row of rows) {
    const userId = row.user_id ? Number(row.user_id) : null;
    await client.query(
      `INSERT INTO customer_points (point_id, latitude, longitude, transaction_volume, user_id)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (point_id)
       DO UPDATE SET
         latitude = EXCLUDED.latitude,
         longitude = EXCLUDED.longitude,
         transaction_volume = EXCLUDED.transaction_volume,
         user_id = EXCLUDED.user_id`,
      [
        Number(row.point_id),
        parseFloat(row.latitude),
        parseFloat(row.longitude),
        Number(row.transaction_volume),
        userId,
      ]
    );
  }

  return rows.length;
}

async function main() {
  const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
  const client = await pool.connect();

  try {
    await client.query('BEGIN');
    await seedMissingUsers(client);
    const count = await importCustomerPoints(client);
    await client.query('COMMIT');

    const stats = await client.query(
      `SELECT COUNT(*)::int AS total, COUNT(user_id)::int AS with_user_id FROM customer_points`
    );
    const { total, with_user_id } = stats.rows[0];
    console.log(`Imported/updated ${count} customer points.`);
    console.log(`Rows with user_id: ${with_user_id} / ${total}`);
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((err) => {
  console.error('Import failed:', err.message);
  process.exit(1);
});
