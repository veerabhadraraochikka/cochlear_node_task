import express, { type Express, type Request, type Response } from 'express';
import { createServer } from 'http';
import os from 'os';
export const PORT = 80;

const app: Express = express();

// Middleware to parse JSON bodies
app.use(express.json());
const server = createServer(app);

const results = Object.values(os.networkInterfaces())
    .flat()
    .filter(({ family, internal }) => family === "IPv4" && !internal)
    .map(({ address }) => address)

// Start the server and listen on the specified port
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Server IP address: ${results}`);
});

app.get('/hello', (req: Request, res: Response) => {
    res.status(200).send(`OK - ${results}:${PORT}`);
});

