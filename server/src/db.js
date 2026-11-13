import 'dotenv/config';
import mysql from 'mysql2/promise';

// mysql2 pool used by Express routes. Credentials come from server/.env.
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
});

export default pool;
