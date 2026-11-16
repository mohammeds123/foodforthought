// /api/auth — login, logout, whoami. Enable APP_ACCOUNT in 01_schema.sql first.
//
// import { Router } from 'express';
// import bcrypt from 'bcrypt';
// import pool from '../db.js';
// const router = Router();
//
// router.post('/login', async (req, res) => {
//   const { username, password } = req.body;
//   const [rows] = await pool.query(
//     'SELECT Username, Password_Hash, Role FROM APP_ACCOUNT WHERE Username = ?',
//     [username],
//   );
//   // bcrypt.compare, then req.session.account = { username, role }
// });
//
// router.post('/logout', (req, res) => { req.session.destroy(() => res.status(204).end()); });
// router.get('/me', (req, res) => res.json(req.session.account ?? null));
//
// export default router;
