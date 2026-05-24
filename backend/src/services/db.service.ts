import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';

dotenv.config();

// Define interface models
export interface User {
  id: number;
  full_name: string;
  email: string;
  password_hash: string;
  budget: number;
}

export interface DemandPoint {
  point_id: number;
  latitude: number;
  longitude: number;
  transaction_volume: number;
  user_id: number;
}

export interface AtmCandidate {
  candidate_id: number;
  location_name: string;
  latitude: number;
  longitude: number;
  setup_cost: number;
}

export interface Transaction {
  id: number;
  user_id: number;
  title: string;
  category: string;
  amount: number;
  merchant: string;
  paymentMethod: string;
  date: string;
  referenceCode: string;
}

export interface Investment {
  user_id: number;
  assetType: string; // 'fon' | 'hisse' | 'altin' | 'gumus'
  symbol: string;
  amount: number;
}

export class DbService {
  // Resolve absolute paths
  private static getPath(envVar: string, fallback: string): string {
    const relativePath = process.env[envVar] || fallback;
    return path.resolve(process.cwd(), relativePath);
  }

  private static USERS_PATH = DbService.getPath('USERS_CSV_PATH', 'src/analytics/veri/users.csv');
  private static DEMAND_POINTS_PATH = DbService.getPath('DEMAND_POINTS_CSV_PATH', 'src/analytics/veri/demand_points.csv');
  private static ATM_CANDIDATES_PATH = DbService.getPath('ATM_CANDIDATES_CSV_PATH', 'src/analytics/veri/atm_candidates.csv');
  private static TRANSACTIONS_PATH = path.resolve(process.cwd(), 'src/analytics/veri/transactions.csv');
  private static INVESTMENTS_PATH = path.resolve(process.cwd(), 'src/analytics/veri/investments.csv');

  // Helper to read CSV lines
  private static readCSV(filePath: string): string[][] {
    if (!fs.existsSync(filePath)) {
      return [];
    }
    const content = fs.readFileSync(filePath, 'utf-8');
    return content
      .split('\n')
      .map(line => line.trim())
      .filter(line => line.length > 0)
      .map(line => {
        // Simple CSV splitter, doesn't handle complex quoted commas, but works perfectly for our auto-generated data
        return line.split(',');
      });
  }

  // Helper to write CSV
  private static writeCSV(filePath: string, headers: string[], rows: string[][]): void {
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    const content = [
      headers.join(','),
      ...rows.map(row => row.join(','))
    ].join('\n') + '\n';
    fs.writeFileSync(filePath, content, 'utf-8');
  }

  // --- USERS ---
  public static getUsers(): User[] {
    const data = this.readCSV(this.USERS_PATH);
    if (data.length <= 1) return []; // Only header or empty
    const headers = data[0];
    return data.slice(1).map(row => ({
      id: parseInt(row[headers.indexOf('id')] || '0'),
      full_name: row[headers.indexOf('full_name')] || '',
      email: row[headers.indexOf('email')] || '',
      password_hash: row[headers.indexOf('password_hash')] || '',
      budget: parseFloat(row[headers.indexOf('budget')] || '0')
    }));
  }

  public static saveUsers(users: User[]): void {
    const rows = users.map(u => [
      u.id.toString(),
      u.full_name,
      u.email,
      u.password_hash,
      u.budget.toString()
    ]);
    this.writeCSV(this.USERS_PATH, ['id', 'full_name', 'email', 'password_hash', 'budget'], rows);
  }

  // --- DEMAND POINTS ---
  public static getDemandPoints(): DemandPoint[] {
    const data = this.readCSV(this.DEMAND_POINTS_PATH);
    if (data.length <= 1) return [];
    const headers = data[0];
    return data.slice(1).map(row => ({
      point_id: parseInt(row[headers.indexOf('point_id')] || '0'),
      latitude: parseFloat(row[headers.indexOf('latitude')] || '0'),
      longitude: parseFloat(row[headers.indexOf('longitude')] || '0'),
      transaction_volume: parseInt(row[headers.indexOf('transaction_volume')] || '0'),
      user_id: parseInt(row[headers.indexOf('user_id')] || '0')
    }));
  }

  // --- ATM CANDIDATES ---
  public static getAtmCandidates(): AtmCandidate[] {
    const data = this.readCSV(this.ATM_CANDIDATES_PATH);
    if (data.length <= 1) return [];
    const headers = data[0];
    return data.slice(1).map(row => ({
      candidate_id: parseInt(row[headers.indexOf('candidate_id')] || '0'),
      location_name: row[headers.indexOf('location_name')] || '',
      latitude: parseFloat(row[headers.indexOf('latitude')] || '0'),
      longitude: parseFloat(row[headers.indexOf('longitude')] || '0'),
      setup_cost: parseFloat(row[headers.indexOf('setup_cost')] || '0')
    }));
  }

  // --- TRANSACTIONS ---
  public static getTransactions(): Transaction[] {
    if (!fs.existsSync(this.TRANSACTIONS_PATH)) {
      // Seed default transactions if not exists
      this.seedDefaultTransactions();
    }
    const data = this.readCSV(this.TRANSACTIONS_PATH);
    if (data.length <= 1) return [];
    const headers = data[0];
    return data.slice(1).map(row => ({
      id: parseInt(row[headers.indexOf('id')] || '0'),
      user_id: parseInt(row[headers.indexOf('user_id')] || '0'),
      title: row[headers.indexOf('title')] || '',
      category: row[headers.indexOf('category')] || '',
      amount: parseFloat(row[headers.indexOf('amount')] || '0'),
      merchant: row[headers.indexOf('merchant')] || '',
      paymentMethod: row[headers.indexOf('paymentMethod')] || '',
      date: row[headers.indexOf('date')] || '',
      referenceCode: row[headers.indexOf('referenceCode')] || ''
    }));
  }

  public static saveTransactions(txs: Transaction[]): void {
    const rows = txs.map(t => [
      t.id.toString(),
      t.user_id.toString(),
      t.title,
      t.category,
      t.amount.toString(),
      t.merchant,
      t.paymentMethod,
      t.date,
      t.referenceCode
    ]);
    this.writeCSV(this.TRANSACTIONS_PATH, [
      'id', 'user_id', 'title', 'category', 'amount', 'merchant', 'paymentMethod', 'date', 'referenceCode'
    ], rows);
  }

  // --- INVESTMENTS ---
  public static getInvestments(): Investment[] {
    if (!fs.existsSync(this.INVESTMENTS_PATH)) {
      this.seedDefaultInvestments();
    }
    const data = this.readCSV(this.INVESTMENTS_PATH);
    if (data.length <= 1) return [];
    const headers = data[0];
    return data.slice(1).map(row => ({
      user_id: parseInt(row[headers.indexOf('user_id')] || '0'),
      assetType: row[headers.indexOf('assetType')] || '',
      symbol: row[headers.indexOf('symbol')] || '',
      amount: parseFloat(row[headers.indexOf('amount')] || '0')
    }));
  }

  public static saveInvestments(invs: Investment[]): void {
    const rows = invs.map(i => [
      i.user_id.toString(),
      i.assetType,
      i.symbol,
      i.amount.toString()
    ]);
    this.writeCSV(this.INVESTMENTS_PATH, ['user_id', 'assetType', 'symbol', 'amount'], rows);
  }

  // --- SEEDERS ---
  private static seedDefaultTransactions(): void {
    const defaults: Transaction[] = [
      {
        id: 1,
        user_id: 1,
        title: 'Market Alışverişi',
        category: 'Market',
        amount: -460.00,
        merchant: 'Çarşı Market Kadıköy',
        paymentMethod: 'Temassız Kart',
        date: 'Bugün, 10:45',
        referenceCode: 'TXN-MK8842'
      },
      {
        id: 2,
        user_id: 1,
        title: 'Maaş Ödemesi',
        category: 'Maaş',
        amount: 23000.00,
        merchant: 'Akilli Finans Ltd.',
        paymentMethod: 'EFT',
        date: 'Dün, 09:00',
        referenceCode: 'TXN-PAY001'
      },
      {
        id: 3,
        user_id: 1,
        title: 'Elektrik Faturası',
        category: 'Fatura',
        amount: -780.00,
        merchant: 'Şehir Dağıtım A.Ş.',
        paymentMethod: 'Otomatik Ödeme',
        date: 'Dün, 20:10',
        referenceCode: 'TXN-FT9910'
      },
      {
        id: 4,
        user_id: 1,
        title: 'Metro Bilet',
        category: 'Ulaşım',
        amount: -120.00,
        merchant: 'İstanbul Kart',
        paymentMethod: 'NFC',
        date: '1 Mayıs 2026, 07:52',
        referenceCode: 'TXN-METRO1'
      },
      {
        id: 5,
        user_id: 1,
        title: 'Dijital Yayın Aboneliği',
        category: 'Eğlence',
        amount: -89.00,
        merchant: 'Netflix',
        paymentMethod: 'Sanal Kart',
        date: '26 Nisan 2026, 03:05',
        referenceCode: 'TXN-SUB903'
      }
    ];
    this.saveTransactions(defaults);
  }

  private static seedDefaultInvestments(): void {
    const defaults: Investment[] = [
      { user_id: 1, assetType: 'fon', symbol: 'AFT', amount: 56205.00 },
      { user_id: 1, assetType: 'hisse', symbol: 'THYAO', amount: 37470.00 },
      { user_id: 1, assetType: 'altin', symbol: 'XAU/TRY', amount: 18735.00 },
      { user_id: 1, assetType: 'gumus', symbol: 'XAG/TRY', amount: 12490.00 }
    ];
    this.saveInvestments(defaults);
  }
}
