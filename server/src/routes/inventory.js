// /api/inventory — lots and low-stock report.
//
// import { Router } from 'express';
// import pool from '../db.js';
// import { requireRole } from '../middleware/auth.js';
// const router = Router();
//
// router.get('/lots', requireRole('staff'), async (req, res) => {
//   const [rows] = await pool.query(
//     `SELECT Donation_ID, Lot_Line_No, Item_ID, Location_ID, Quantity_On_Hand, Expiry_Date, Lot_Status
//      FROM INVENTORY_LOT`,
//   );
//   res.json(rows);
// });
//
// router.get('/low-stock', requireRole('staff'), async (req, res) => {
//   const [rows] = await pool.query('CALL sp_low_stock()');
//   res.json(rows[0]); // mysql2: first result set of a CALL
// });
//
// export default router;
