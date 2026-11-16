import 'dotenv/config';
import express from 'express';
import session from 'express-session';
import pool from './db.js';

const app = express();

app.use(express.json());
app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
  }),
);

// Setup check: Express can reach MySQL when this returns 200.
app.get('/api/health', async (req, res) => {
  await pool.query('SELECT 1');
  res.status(200).json({ ok: true });
});

// When a route file is uncommented and exports a router, mount it here:
// import authRouter from './routes/auth.js';
// import donationsRouter from './routes/donations.js';
// import inventoryRouter from './routes/inventory.js';
// import householdsRouter from './routes/households.js';
// import hampersRouter from './routes/hampers.js';
// import fulfillmentsRouter from './routes/fulfillments.js';
// import volunteersRouter from './routes/volunteers.js';
// import shiftsRouter from './routes/shifts.js';
// import lookupsRouter from './routes/lookups.js';
// app.use('/api/auth', authRouter);
// app.use('/api/donations', donationsRouter);
// app.use('/api/inventory', inventoryRouter);
// app.use('/api/households', householdsRouter);
// app.use('/api/hampers', hampersRouter);
// app.use('/api/fulfillments', fulfillmentsRouter);
// app.use('/api/volunteers', volunteersRouter);
// app.use('/api/shifts', shiftsRouter);
// app.use('/api/lookups', lookupsRouter);

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server listening on http://localhost:${port}`);
});
