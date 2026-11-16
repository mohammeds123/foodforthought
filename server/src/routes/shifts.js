// /api/shifts — staff schedule; volunteer sign-up / confirm.
//
// import { Router } from 'express';
// import pool from '../db.js';
// import { requireRole } from '../middleware/auth.js';
// const router = Router();
//
// router.post('/', requireRole('staff'), async (req, res) => {
//   const { shiftDate, startTime, endTime, duty } = req.body;
//   // INSERT INTO SHIFT ... then immediately CALL sp_confirm_shift for the first volunteer
//   // so the shift is never stored with zero SIGN_UP rows.
// });
//
// router.post('/:shiftId/signup', requireRole('volunteer'), async (req, res) => {
//   await pool.query('CALL sp_confirm_shift(?, ?)', [
//     req.session.account.volunteerId,
//     req.params.shiftId,
//   ]);
//   res.status(201).json({ ok: true });
// });
//
// export default router;
