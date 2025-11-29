const express = require('express');
const app = express();
app.get('/api/status', (req, res) => res.json({status: 'website ok'}));
app.listen(3000, () => console.log('Website ready'));
