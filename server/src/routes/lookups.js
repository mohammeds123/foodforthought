// /api/lookups — dropdown data for the React screens (no writes).
//
// import { Router } from 'express';
// import pool from '../db.js';
// import { requireLogin } from '../middleware/auth.js';
// const router = Router();
//
// router.get('/dietary-needs', requireLogin, async (req, res) => {
//   const [rows] = await pool.query('SELECT Need_Name, Need_Type FROM DIETARY_NEED');
//   res.json(rows);
// });
//
// router.get('/food-items', requireLogin, async (req, res) => {
//   const [rows] = await pool.query('SELECT Item_ID, Item_Name, Food_Category FROM FOOD_ITEM');
//   res.json(rows);
// });
//
// router.get('/locations', requireLogin, async (req, res) => {
//   const [rows] = await pool.query('SELECT Location_ID, Location_Name FROM STORAGE_LOCATION');
//   res.json(rows);
// });
//
// export default router;
