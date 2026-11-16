// /api/fulfillments — pickup / delivery attempts (disjoint subclasses).
//
// import { Router } from 'express';
// import pool from '../db.js';
// import { requireRole } from '../middleware/auth.js';
// const router = Router();
//
// router.post('/pickup', requireRole('staff'), async (req, res) => {
//   const { hamperId, scheduledDate, pickupTime, collectorType, proxyName } = req.body;
//   await pool.query('CALL sp_create_pickup(?, ?, ?, ?, ?)', [
//     hamperId, scheduledDate, pickupTime, collectorType, proxyName,
//   ]);
//   res.status(201).json({ ok: true });
// });
//
// router.post('/delivery', requireRole('staff'), async (req, res) => {
//   const { hamperId, scheduledDate, departureTime, arrivalTime, driverStaffId, driverVolunteerId } = req.body;
//   await pool.query('CALL sp_create_delivery(?, ?, ?, ?, ?, ?)', [
//     hamperId, scheduledDate, departureTime, arrivalTime, driverStaffId, driverVolunteerId,
//   ]);
//   res.status(201).json({ ok: true });
// });
//
// router.patch('/:id/pickup', requireRole('staff'), async (req, res) => {
//   await pool.query('CALL sp_record_pickup(?, ?)', [req.params.id, req.body.status]);
//   res.json({ ok: true });
// });
//
// export default router;
