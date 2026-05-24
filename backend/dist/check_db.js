import pg from 'pg';
const connectionString = "postgresql://neondb_owner:npg_WZM0CajyLBN5@ep-cold-shadow-anc8l94f-pooler.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require";
const client = new pg.Client({
    connectionString,
});
async function main() {
    try {
        await client.connect();
        console.log("Connected to Neon DB successfully!");
        const userRes = await client.query("SELECT * FROM users LIMIT 1;");
        console.log("Sample user row:", userRes.rows[0]);
    }
    catch (err) {
        console.error("Connection failed:", err.message);
    }
    finally {
        await client.end();
    }
}
main();
