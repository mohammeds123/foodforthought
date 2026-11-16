// /api/volunteers — skills (multivalued) live in VOLUNTEER_SKILL, not a CSV column.
//
// import { Router } from 'express';
// import pool from '../db.js';
// import { requireRole } from '../middleware/auth.js';
// const router = Router();
//
// router.get('/me/skills', requireRole('volunteer'), async (req, res) => {
//   const [rows] = await pool.query(
//     'SELECT Skill FROM VOLUNTEER_SKILL WHERE Volunteer_ID = ?',
//     [req.session.account.volunteerId],
//   );
//   res.json(rows);
// });
//
// router.post('/me/skills', requireRole('volunteer'), async (req, res) => {
//   await pool.query(
//     'INSERT INTO VOLUNTEER_SKILL (Volunteer_ID, Skill) VALUES (?, ?)',
//     [req.session.account.volunteerId, req.body.skill],
//   );
//   res.status(201).json({ ok: true });
// });
//
// export default router;
