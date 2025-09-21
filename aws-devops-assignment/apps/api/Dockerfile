FROM node:18-alpine
WORKDIR /app
COPY server.js .
RUN npm init -y && npm install express multer
VOLUME ["/data"]
EXPOSE 4000
CMD ["node", "server.js"]