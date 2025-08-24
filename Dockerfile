# FROM node:14

# WORKDIR /App

# COPY package*.json ./
# RUN npm install
# COPY . .
# EXPOSE 3000

# FROM

# CMD ["npm", "start"]


# Build stage
# Build stage
FROM node:16-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage - using nginx alpine for serving static files
FROM nginx:alpine

# Copy built files to nginx html directory
COPY --from=builder /app/build /usr/share/nginx/html

# Create a simple nginx config for React apps
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]