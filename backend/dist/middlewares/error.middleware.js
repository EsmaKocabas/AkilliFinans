export function errorHandler(err, req, res, next) {
    console.error('❌ Hata Oluştu:', err);
    const statusCode = err.status || err.statusCode || 500;
    const message = err.message || 'Sunucu içi bir hata oluştu.';
    res.status(statusCode).json({
        error: err.name || 'InternalServerError',
        message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
}
