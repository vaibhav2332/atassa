FROM node:20-slim

WORKDIR /app
COPY package*.json ./

# Install git so npm can fetch git-based dependencies
RUN apt-get update && apt-get install -y git

RUN npm install && npm install -g pm2
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
