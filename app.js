const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

// Allow requests from any origin
app.use(cors());

app.get('/api/images', (req, res) => {
  const images = [
    {
      name: "Price: $3000",
      url: "https://storage665506.blob.core.windows.net/image/jacket.jpg"
    },
    {
      name: "Price: $40",
      url: "https://storage665506.blob.core.windows.net/image/trouser.jpg"
    }
  ];
  res.json(images);
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});