// /api/donations — staff records a donation, then its inventory lots.
//
// import { Router } from 'express';
// import pool from '../db.js';
// import { requireRole } from '../middleware/auth.js';
// const router = Router();
//
// router.post('/', requireRole('staff'), async (req, res) => {
//   const { dateReceived, donationType, fundAmount, donorId } = req.body;
//   const [result] = await pool.query(
//     `INSERT INTO DONATION (Date_Received, Donation_Type, Fund_Amount, Donor_ID, Staff_ID)
//      VALUES (?, ?, ?, ?, ?)`,
//     [dateReceived, donationType, fundAmount, donorId, req.session.account.staffId],
//   );
//   // Then INSERT INVENTORY_LOT rows with Lot_Line_No 1, 2, ... for that Donation_ID.
//   res.status(201).json({ donationId: result.insertId });
// });
//
// export default router;
