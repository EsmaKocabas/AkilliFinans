import { db } from '../config/db.js';
export class TransactionController {
    static async getTransactions(req, res, next) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
            }
            const { category, search } = req.query;
            let query = "SELECT * FROM transactions WHERE user_id = $1";
            const params = [userId];
            let paramIndex = 2;
            if (category) {
                query += ` AND LOWER(category) = LOWER($${paramIndex++})`;
                params.push(category);
            }
            if (search) {
                query += ` AND (LOWER(title) LIKE $${paramIndex} OR LOWER(merchant) LIKE $${paramIndex})`;
                params.push(`%${search.toLowerCase()}%`);
                paramIndex++;
            }
            query += " ORDER BY id DESC;";
            const txsRes = await db.query(query, params);
            // Map DB snake_case columns back to camelCase for Flutter frontend expectations
            const data = txsRes.rows.map(row => ({
                id: parseInt(row.id),
                user_id: parseInt(row.user_id),
                title: row.title,
                category: row.category,
                amount: parseFloat(row.amount),
                merchant: row.merchant,
                paymentMethod: row.payment_method,
                date: row.date,
                referenceCode: row.reference_code
            }));
            res.status(200).json({
                status: 'success',
                results: data.length,
                data
            });
        }
        catch (error) {
            next(error);
        }
    }
    static async createTransaction(req, res, next) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
            }
            const { title, category, amount, merchant, paymentMethod } = req.body;
            if (!title || !category || amount === undefined || !merchant) {
                return res.status(400).json({ error: 'ValidationError', message: 'Title, category, amount, and merchant are required.' });
            }
            const txAmount = parseFloat(amount);
            // Verify user exists and update budget
            const userUpdateRes = await db.query("UPDATE users SET budget = budget + $1 WHERE id = $2 RETURNING budget;", [txAmount, userId]);
            if (userUpdateRes.rows.length === 0) {
                return res.status(404).json({ error: 'NotFoundError', message: 'User not found.' });
            }
            const newBudget = parseFloat(userUpdateRes.rows[0].budget);
            const refCode = 'TXN-' + Math.random().toString(36).substring(2, 8).toUpperCase();
            const dateStr = 'Bugün, ' + new Date().toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
            // Insert transaction record
            const insertRes = await db.query(`INSERT INTO transactions (user_id, title, category, amount, merchant, payment_method, date, reference_code)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING *;`, [userId, title.trim(), category.trim(), txAmount, merchant.trim(), paymentMethod || 'Kart', dateStr, refCode]);
            const newTx = insertRes.rows[0];
            // Create Transaction Notification
            const cleanAmount = Math.round(Math.abs(txAmount));
            const txDirection = txAmount > 0 ? 'yüklendi' : 'harcandı';
            await db.query(`INSERT INTO notifications (user_id, title, message, type)
         VALUES ($1, $2, $3, 'transaction');`, [
                userId,
                category === 'Gelir' ? 'Para Yükleme' : 'Ödeme Gerçekleşti',
                `₺${cleanAmount} tutarında '${title}' işlemi başarıyla ${txDirection}.`
            ]);
            // Check Budget Warning Threshold
            if (newBudget < 5000 && txAmount < 0) {
                await db.query(`INSERT INTO notifications (user_id, title, message, type)
           VALUES ($1, 'Bütçe Uyarısı', $2, 'warning');`, [
                    userId,
                    `Toplam bütçeniz kritik seviye olan ₺5.000 altına düştü! Güncel bütçe: ₺${Math.round(newBudget)}`
                ]);
            }
            res.status(201).json({
                status: 'success',
                message: 'Transaction recorded and budget updated.',
                data: {
                    id: parseInt(newTx.id),
                    user_id: parseInt(newTx.user_id),
                    title: newTx.title,
                    category: newTx.category,
                    amount: parseFloat(newTx.amount),
                    merchant: newTx.merchant,
                    paymentMethod: newTx.payment_method,
                    date: newTx.date,
                    referenceCode: newTx.reference_code
                },
                userBudget: newBudget
            });
        }
        catch (error) {
            next(error);
        }
    }
    static async getDashboardStats(req, res, next) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
            }
            // Query current budget from users
            const userRes = await db.query("SELECT budget FROM users WHERE id = $1;", [userId]);
            if (userRes.rows.length === 0) {
                return res.status(404).json({ error: 'NotFoundError', message: 'User not found.' });
            }
            const totalAsset = parseFloat(userRes.rows[0].budget);
            // Query Income
            const incomeRes = await db.query("SELECT COALESCE(SUM(amount), 0) as income FROM transactions WHERE user_id = $1 AND amount > 0;", [userId]);
            const income = parseFloat(incomeRes.rows[0].income);
            // Query Expense
            const expenseRes = await db.query("SELECT COALESCE(SUM(ABS(amount)), 0) as expense FROM transactions WHERE user_id = $1 AND amount < 0;", [userId]);
            const expense = parseFloat(expenseRes.rows[0].expense);
            const savings = income - expense;
            // Query category breakdown for pie chart
            const categoryRes = await db.query(`SELECT category, COALESCE(SUM(ABS(amount)), 0) as total 
         FROM transactions 
         WHERE user_id = $1 AND amount < 0 
         GROUP BY category;`, [userId]);
            const categories = {
                'Market': 0,
                'Fatura': 0,
                'Ulaşım': 0
            };
            categoryRes.rows.forEach(row => {
                const catName = row.category;
                const totalVal = parseFloat(row.total);
                categories[catName] = totalVal;
            });
            res.status(200).json({
                status: 'success',
                data: {
                    totalAsset,
                    income,
                    expense,
                    savings,
                    categoryDistribution: categories
                }
            });
        }
        catch (error) {
            next(error);
        }
    }
}
