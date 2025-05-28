const express = require('express');
const os = require('os');
const { pool } = require('../config/database');

const router = express.Router();
const SERVER_ID = process.env.SERVER_ID || os.hostname();

// Log requests middleware
router.use((req, res, next) => {
    const logRequest = async () => {
        try {
            await pool.query(
                'INSERT INTO requests_log (server_id, endpoint, ip_address) VALUES ($1, $2, $3)',
                [SERVER_ID, req.originalUrl, req.ip]
            );
        } catch (err) {
            console.error('Failed to log request:', err);
        }
    };
    logRequest();
    next();
});

// Get all users
router.get('/users', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
        res.json({
            users: result.rows,
            server: SERVER_ID,
            total: result.rows.length
        });
    } catch (err) {
        res.status(500).json({ error: err.message, server: SERVER_ID });
    }
});

// Create user
router.post('/users', async (req, res) => {
    const { name, email } = req.body;

    if (!name || !email) {
        return res.status(400).json({ error: 'Name and email are required', server: SERVER_ID });
    }

    try {
        const result = await pool.query(
            'INSERT INTO users (name, email, server_id) VALUES ($1, $2, $3) RETURNING *',
            [name, email, SERVER_ID]
        );
        res.status(201).json({
            user: result.rows[0],
            server: SERVER_ID,
            message: 'User created successfully'
        });
    } catch (err) {
        res.status(500).json({ error: err.message, server: SERVER_ID });
    }
});

// Get server statistics
router.get('/stats', async (req, res) => {
    try {
        const userCount = await pool.query('SELECT COUNT(*) FROM users');
        const requestCount = await pool.query('SELECT COUNT(*) FROM requests_log WHERE server_id = $1', [SERVER_ID]);
        const recentRequests = await pool.query(
            'SELECT endpoint, COUNT(*) as count FROM requests_log WHERE server_id = $1 AND timestamp > NOW() - INTERVAL \'1 hour\' GROUP BY endpoint',
            [SERVER_ID]
        );

        res.json({
            server: SERVER_ID,
            total_users: parseInt(userCount.rows[0].count),
            requests_handled: parseInt(requestCount.rows[0].count),
            recent_requests: recentRequests.rows,
            timestamp: new Date().toISOString()
        });
    } catch (err) {
        res.status(500).json({ error: err.message, server: SERVER_ID });
    }
});

module.exports = router;