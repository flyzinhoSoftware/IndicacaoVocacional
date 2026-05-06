document.addEventListener('DOMContentLoaded', function() {
    if (window.$ && typeof window.$ === 'function') {
        try {
            window.$('.select2').select2({ width: '100%' });
        } catch (e) {
            console.warn('Select2 não está disponível.');
        }
    }
});
