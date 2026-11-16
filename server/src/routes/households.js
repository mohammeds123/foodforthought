// /api/households — staff CRUD + dietary needs (REQUIRES).
//
// import { Router } from 'express';
// import pool from '../db.js';
// import { requireRole } from '../middleware/auth.js';
// const router = Router();
//
// router.get('/', requireRole('staff'), async (req, res) => {
//   const [rows] = await pool.query(
//     'SELECT Household_ID, Contact_Name, Phone, Email, Household_Size FROM HOUSEHOLD',
//   );
//   res.json(rows);
// });
//
// router.post('/:id/needs', requireRole('staff'), async (req, res) => {
//   await pool.query(
//     'INSERT INTO REQUIRES (Household_ID, Need_Name) VALUES (?, ?)',
//     [req.params.id, req.body.needName],
//   );
//   res.status(201).json({ ok: true });
// });
//
// export default router;
