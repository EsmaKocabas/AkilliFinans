import { db } from '../config/db.js';
import { PythonService } from '../services/python.service.js';
import { calculateHaversineDistance } from '../utils/distance.js';
export class MapController {
    static async getAtms(req, res, next) {
        try {
            const candidatesRes = await db.query("SELECT * FROM atm_candidates ORDER BY candidate_id;");
            const data = candidatesRes.rows.map(row => ({
                candidate_id: row.candidate_id,
                location_name: row.location_name,
                latitude: parseFloat(row.latitude),
                longitude: parseFloat(row.longitude),
                setup_cost: parseFloat(row.setup_cost),
                cash_capacity: row.cash_capacity ? parseFloat(row.cash_capacity) : 0
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
    static async getNearbyAtms(req, res, next) {
        try {
            const { lat, lng } = req.query;
            if (!lat || !lng) {
                return res.status(400).json({
                    error: 'ValidationError',
                    message: 'Latitude (lat) and longitude (lng) query parameters are required.'
                });
            }
            const userLat = parseFloat(lat);
            const userLng = parseFloat(lng);
            if (isNaN(userLat) || isNaN(userLng)) {
                return res.status(400).json({
                    error: 'ValidationError',
                    message: 'Latitude and longitude must be valid numbers.'
                });
            }
            const candidatesRes = await db.query("SELECT * FROM atm_candidates;");
            const nearby = candidatesRes.rows.map(atm => {
                const atmLat = parseFloat(atm.latitude);
                const atmLng = parseFloat(atm.longitude);
                const distance = calculateHaversineDistance(userLat, userLng, atmLat, atmLng);
                return {
                    candidate_id: atm.candidate_id,
                    location_name: atm.location_name,
                    latitude: atmLat,
                    longitude: atmLng,
                    setup_cost: parseFloat(atm.setup_cost),
                    distance // distance in meters
                };
            });
            // Sort by distance ascending
            nearby.sort((a, b) => a.distance - b.distance);
            res.status(200).json({
                status: 'success',
                results: nearby.length,
                data: nearby
            });
        }
        catch (error) {
            next(error);
        }
    }
    static async optimizeAtms(req, res, next) {
        try {
            const { kumeSayisi } = req.body;
            const clusters = kumeSayisi ? parseInt(kumeSayisi) : 5;
            if (isNaN(clusters) || clusters < 1 || clusters > 50) {
                return res.status(400).json({
                    error: 'ValidationError',
                    message: 'kumeSayisi must be a number between 1 and 50.'
                });
            }
            console.log(`🧠 ATM Optimizasyonu tetiklendi (K-Means küme sayısı: ${clusters}). Python betiği çağrılıyor...`);
            const result = await PythonService.runAtmOptimization(clusters);
            res.status(200).json(result);
        }
        catch (error) {
            console.error('❌ Optimizasyon hatası:', error);
            next(error);
        }
    }
}
