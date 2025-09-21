const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 4000;

const upload = multer({ dest: '/data/uploads/' });

app.get('/api/healthz', (req, res) => {
  res.json({ status: 'ok' });
});

app.post('/api/upload', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).send('No file uploaded');
  const targetPath = path.join('/data', req.file.originalname);
  fs.renameSync(req.file.path, targetPath);
  res.json({ message: 'File uploaded', path: targetPath });
});

app.listen(port, () => console.log(`API listening on port ${port}`));