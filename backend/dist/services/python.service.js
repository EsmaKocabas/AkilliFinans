import { spawn } from 'child_process';
import path from 'path';
import fs from 'fs';
import { db } from '../config/db.js';
export class PythonService {
    static SCRIPT_PATH = path.resolve(process.cwd(), 'src/analytics/wlp_motoru.py');
    static MUSTERI_CSV = path.resolve(process.cwd(), 'src/analytics/veri/demand_points.csv');
    static ATM_CSV = path.resolve(process.cwd(), 'src/analytics/veri/atm_candidates.csv');
    /**
     * Syncs the PostgreSQL customer_points and atm_candidates tables to CSVs
     * so the Python data science engine has the latest data.
     */
    static async syncDbToCsvFiles() {
        console.log("💾 Neon DB tabloları Python için geçici CSV dosyalarına yazılıyor...");
        // 1. Sync Customer Points -> demand_points.csv
        const customerPointsRes = await db.query("SELECT * FROM customer_points;");
        const cpHeaders = ['point_id', 'latitude', 'longitude', 'transaction_volume', 'user_id'];
        const cpRows = customerPointsRes.rows.map(r => [
            r.point_id.toString(),
            r.latitude.toString(),
            r.longitude.toString(),
            r.transaction_volume.toString(),
            r.user_id.toString()
        ]);
        const cpContent = [
            cpHeaders.join(','),
            ...cpRows.map(row => row.join(','))
        ].join('\n') + '\n';
        fs.writeFileSync(this.MUSTERI_CSV, cpContent, 'utf-8');
        // 2. Sync ATM Candidates -> atm_candidates.csv
        const atmCandidatesRes = await db.query("SELECT * FROM atm_candidates;");
        const atmHeaders = ['candidate_id', 'location_name', 'latitude', 'longitude', 'setup_cost'];
        const atmRows = atmCandidatesRes.rows.map(r => [
            r.candidate_id.toString(),
            r.location_name,
            r.latitude.toString(),
            r.longitude.toString(),
            r.setup_cost.toString()
        ]);
        const atmContent = [
            atmHeaders.join(','),
            ...atmRows.map(row => row.join(','))
        ].join('\n') + '\n';
        fs.writeFileSync(this.ATM_CSV, atmContent, 'utf-8');
        console.log("💾 CSV senkronizasyonu tamamlandı.");
    }
    static async runAtmOptimization(kumeSayisi = 5) {
        // Sync DB tables to local CSVs first
        await this.syncDbToCsvFiles();
        return new Promise((resolve, reject) => {
            if (!fs.existsSync(this.SCRIPT_PATH)) {
                return reject(new Error(`Python script not found at ${this.SCRIPT_PATH}`));
            }
            // Spawn python process
            const pythonProcess = spawn('python3', [
                this.SCRIPT_PATH,
                this.MUSTERI_CSV,
                this.ATM_CSV,
                kumeSayisi.toString()
            ]);
            let stdoutData = '';
            let stderrData = '';
            pythonProcess.stdout.on('data', (data) => {
                stdoutData += data.toString();
            });
            pythonProcess.stderr.on('data', (data) => {
                stderrData += data.toString();
            });
            pythonProcess.on('error', (err) => {
                reject(new Error(`Failed to start Python process: ${err.message}`));
            });
            pythonProcess.on('close', (code) => {
                if (code !== 0) {
                    reject(new Error(`Python script exited with code ${code}. Error: ${stderrData}`));
                }
                else {
                    try {
                        const result = JSON.parse(stdoutData.trim());
                        resolve(result);
                    }
                    catch (e) {
                        reject(new Error(`Failed to parse Python output as JSON: ${stdoutData}`));
                    }
                }
            });
        });
    }
}
