// CyberForge Frontend Configuration
const CONFIG = {
    // API endpoint (auto-detect or fallback)
    API_URL: window.location.protocol + '//' + window.location.hostname + '/api',
    
    // WebSocket endpoint (future use)
    WS_URL: (window.location.protocol === 'https:' ? 'wss://' : 'ws://') + window.location.hostname + '/ws',
    
    // Rate limiting info
    RATE_LIMITS: {
        SUBMIT_FLAG: 5,  // per minute
        REGISTER: 10,     // per minute
        LOGIN: 10         // per minute
    },
    
    // UI settings
    UI: {
        TOAST_DURATION: 3000,
        REFRESH_INTERVAL: 30000  // 30 seconds
    }
};

// Export for use in main script
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}
