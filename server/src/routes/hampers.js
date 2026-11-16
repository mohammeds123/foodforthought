// /api/hampers — staff builds a hamper; MySQL does the work.
//
// import { Router } from 'express';
// import pool from '../db.js';
// import { requireRole } from '../middleware/auth.js';
// const router = Router();
//
// router.post('/', requireRole('staff'), async (req, res) => {
//   const { householdId } = req.body;
//   const staffId = req.session.account.staffId;
//   try {
//     await pool.query('CALL sp_build_hamper(?, ?)', [householdId, staffId]);
//     res.status(201).json({ ok: true });
//   } catch (err) {
//     // Procedure SIGNALs 'Short on: Dairy' → return 400 with that text
//     res.status(400).json({ error: err.sqlMessage });
//   }
// });
//
// export default router;
