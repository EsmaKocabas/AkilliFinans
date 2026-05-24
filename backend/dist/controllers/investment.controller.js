import { db } from '../config/db.js';
export class InvestmentController {
    static async getPortfolio(req, res, next) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
            }
            const investmentsRes = await db.query("SELECT * FROM investments WHERE user_id = $1;", [userId]);
            const investments = investmentsRes.rows;
            const totalInvestmentValue = investments.reduce((sum, item) => sum + parseFloat(item.amount), 0);
            // Calculate allocation percentages
            const allocation = investments.map(item => ({
                assetType: item.asset_type,
                symbol: item.symbol,
                amount: parseFloat(item.amount),
                ratio: totalInvestmentValue > 0 ? parseFloat((parseFloat(item.amount) / totalInvestmentValue).toFixed(2)) : 0
            }));
            res.status(200).json({
                status: 'success',
                data: {
                    totalInvestment: totalInvestmentValue,
                    allocation
                }
            });
        }
        catch (error) {
            next(error);
        }
    }
    static getSuggestions(req, res, next) {
        try {
            // Mock suggestions matching frontend requirements
            const suggestions = [
                {
                    title: 'Düşük riskli fon sepeti',
                    subtitle: 'Beklenen yıllık getiri: %28',
                    icon: 'lightbulb_outline'
                },
                {
                    title: 'Altın ağırlığını %5 artır',
                    subtitle: 'Volatiliteyi dengelemek için',
                    icon: 'trending_up'
                },
                {
                    title: 'Acil durum fonu oluştur',
                    subtitle: '3 aylık gider hedefleniyor',
                    icon: 'shield'
                }
            ];
            res.status(200).json({
                status: 'success',
                data: suggestions
            });
        }
        catch (error) {
            next(error);
        }
    }
    static async executeTrade(req, res, next) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Unauthorized', message: 'User not authenticated.' });
            }
            const { assetType, action, symbol, amount } = req.body;
            if (!assetType || !action || !symbol || !amount) {
                return res.status(400).json({
                    error: 'ValidationError',
                    message: 'assetType, action (al/sat), symbol, and amount are required.'
                });
            }
            const value = parseFloat(amount);
            if (isNaN(value) || value <= 0) {
                return res.status(400).json({ error: 'ValidationError', message: 'Amount must be a positive number.' });
            }
            // Query user
            const userRes = await db.query("SELECT * FROM users WHERE id = $1;", [userId]);
            if (userRes.rows.length === 0) {
                return res.status(404).json({ error: 'NotFoundError', message: 'User not found.' });
            }
            const currentUser = userRes.rows[0];
            const currentBudget = parseFloat(currentUser.budget);
            // Mock unit prices for Hisse shares
            let tradeCost = value; // Default is monetary amount for fon, altin, gumus
            if (assetType === 'hisse') {
                const sharePrice = 300.00; // Simulated share price for THYAO
                tradeCost = value * sharePrice;
            }
            const isBuy = action.toLowerCase() === 'al';
            if (isBuy) {
                // Check if user has enough budget
                if (currentBudget < tradeCost) {
                    return res.status(400).json({
                        error: 'InsufficientFunds',
                        message: `Yetersiz bakiye. Bu işlem için ₺${tradeCost.toFixed(2)} gerekiyor. Mevcut bakiye: ₺${currentBudget.toFixed(2)}`
                    });
                }
                // Deduct budget
                await db.query("UPDATE users SET budget = budget - $1 WHERE id = $2;", [tradeCost, userId]);
                // Insert or update investments
                await db.query(`INSERT INTO investments (user_id, asset_type, symbol, amount)
           VALUES ($1, $2, $3, $4)
           ON CONFLICT (user_id, symbol)
           DO UPDATE SET amount = investments.amount + $4;`, [userId, assetType, symbol.toUpperCase(), tradeCost]);
            }
            else {
                // Selling: Check if user owns enough of this asset
                const invRes = await db.query("SELECT amount FROM investments WHERE user_id = $1 AND UPPER(symbol) = $2;", [userId, symbol.toUpperCase()]);
                if (invRes.rows.length === 0 || parseFloat(invRes.rows[0].amount) < tradeCost) {
                    return res.status(400).json({
                        error: 'InsufficientPortfolioAmount',
                        message: `Satmak istediğiniz miktarda (${symbol}) portföyünüzde bulunmamaktadır.`
                    });
                }
                // Add to budget
                await db.query("UPDATE users SET budget = budget + $1 WHERE id = $2;", [tradeCost, userId]);
                // Deduct from investments
                const deductRes = await db.query("UPDATE investments SET amount = amount - $1 WHERE user_id = $2 AND UPPER(symbol) = $3 RETURNING amount;", [tradeCost, userId, symbol.toUpperCase()]);
                const newAmount = parseFloat(deductRes.rows[0].amount);
                if (newAmount <= 0) {
                    await db.query("DELETE FROM investments WHERE user_id = $1 AND UPPER(symbol) = $2;", [userId, symbol.toUpperCase()]);
                }
            }
            // Record a transaction for audit
            const refCode = 'INV-' + Math.random().toString(36).substring(2, 8).toUpperCase();
            const dateStr = 'Bugün, ' + new Date().toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
            await db.query(`INSERT INTO transactions (user_id, title, category, amount, merchant, payment_method, date, reference_code)
         VALUES ($1, $2, 'Yatırım', $3, 'Akıllı Yatırım Portföyü', 'Hesaptan Bakiye', $4, $5);`, [userId, `${symbol.toUpperCase()} ${isBuy ? 'Alımı' : 'Satımı'}`, isBuy ? -tradeCost : tradeCost, dateStr, refCode]);
            // Create Investment Trade Notification
            await db.query(`INSERT INTO notifications (user_id, title, message, type)
         VALUES ($1, $2, $3, 'investment');`, [
                userId,
                `Yatırım İşlemi: ${symbol.toUpperCase()}`,
                `₺${Math.round(tradeCost)} tutarında '${symbol.toUpperCase()}' ${isBuy ? 'alımı' : 'satımı'} başarıyla gerçekleşti.`
            ]);
            // Query final budget
            const budgetRes = await db.query("SELECT budget FROM users WHERE id = $1;", [userId]);
            const finalBudget = parseFloat(budgetRes.rows[0].budget);
            // Check Budget Warning Threshold after buying
            if (finalBudget < 5000 && isBuy) {
                await db.query(`INSERT INTO notifications (user_id, title, message, type)
           VALUES ($1, 'Bütçe Uyarısı', $2, 'warning');`, [
                    userId,
                    `Toplam bütçeniz kritik seviye olan ₺5.000 altına düştü! Güncel bütçe: ₺${Math.round(finalBudget)}`
                ]);
            }
            res.status(200).json({
                status: 'success',
                message: `${symbol} ${isBuy ? 'alım' : 'satım'} işlemi gerçekleştirildi.`,
                data: {
                    assetType,
                    symbol,
                    amount: value,
                    tradeCost,
                    remainingBudget: finalBudget
                }
            });
        }
        catch (error) {
            next(error);
        }
    }
}
