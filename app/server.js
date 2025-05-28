const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const os = require('os');
require('dotenv').config();

const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 3000;
const SERVER_ID = process.env.SERVER_ID || os.hostname();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        server: SERVER_ID,
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// Server info endpoint to demonstrate load balancing
app.get('/server-info', (req, res) => {
    res.json({
        server_id: SERVER_ID,
        hostname: os.hostname(),
        platform: os.platform(),
        memory: {
            total: Math.round(os.totalmem() / 1024 / 1024) + 'MB',
            free: Math.round(os.freemem() / 1024 / 1024) + 'MB'
        },
        load_average: os.loadavg(),
        request_time: new Date().toISOString()
    });
});

// API routes
app.use('/api', apiRoutes);

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Load Balancer Demo API',
        server: SERVER_ID,
        endpoints: {
            health: '/health',
            server_info: '/server-info',
            api_users: '/api/users',
            api_stats: '/api/stats'
        }
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server ${SERVER_ID} running on port ${PORT}`);
});