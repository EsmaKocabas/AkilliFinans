import jwt from 'jsonwebtoken';
export function authMiddleware(req, res, next) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
            error: 'Unauthorized',
            message: 'Access token is missing or invalid. Please login.'
        });
    }
    const token = authHeader.split(' ')[1];
    try {
        const JWT_SECRET = process.env.JWT_SECRET || 'supersecuresecret12345';
        const decoded = jwt.verify(token, JWT_SECRET);
        // Attach decoded user info to request
        req.user = {
            id: decoded.id,
            email: decoded.email
        };
        next();
    }
    catch (error) {
        return res.status(401).json({
            error: 'Unauthorized',
            message: 'Invalid or expired access token.'
        });
    }
}
