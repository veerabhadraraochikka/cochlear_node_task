import express, { Express } from 'express';
import { createServer } from 'http';
export const PORT = 80;

const app: Express = express();
// Middleware to parse incoming requests with JSON payloads
const server = createServer(app);

// Start the server and listen on the specified port
server.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

// Define a simple route
app.get('/hello', (req, res) => {
    res.status(200).send('OK');
});

