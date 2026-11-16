// Login and role checks. Mount these on routes; do not put SQL here.
//
// export function requireLogin(req, res, next) {
//   if (!req.session.account) return res.status(401).json({ error: 'Login required' });
//   next();
// }
//
// export function requireRole(...roles) {
//   return (req, res, next) => {
//     if (!req.session.account) return res.status(401).json({ error: 'Login required' });
//     if (!roles.includes(req.session.account.role)) {
//       return res.status(403).json({ error: 'Forbidden' });
//     }
//     next();
//   };
// }
//
// Roles from the spec: 'staff' | 'volunteer' | 'household' | 'donor'
// Example: router.post('/', requireRole('staff'), ...)
