const { Pool } = require('pg');

const pool = new Pool({
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'loadbalancer_demo',
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT || 5432,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

const initDB = async () => {
    try {
        await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        server_id VARCHAR(50)
      )
    `);

        await pool.query(`
      CREATE TABLE IF NOT EXISTS requests_log (
        id SERIAL PRIMARY KEY,
        server_id VARCHAR(50) NOT NULL,
        endpoint VARCHAR(100) NOT NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ip_address VARCHAR(45)
      )
    `);

        console.log('Database tables initialized');
    } catch (err) {
        console.error('Database initialization error:', err);
    }
};

initDB();

module.exports = { pool };