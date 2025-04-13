FROM --platform=linux/amd64 node:23-slim

WORKDIR /app
COPY app.js ./

RUN npm install express

CMD ["node", "app.js"]