# Build stage - Node 18 with better npm configuration
FROM node:18-alpine AS builder

WORKDIR /app

# Set npm configurations for better reliability
ENV NPM_CONFIG_TIMEOUT=300000
ENV NPM_CONFIG_REGISTRY=https://registry.npmjs.org/
ENV NPM_CONFIG_CACHE=/tmp/.npm

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies with retries and increased timeout
RUN npm config set fetch-timeout 600000 && \
    npm config set fetch-retries 3 && \
    npm ci --prefer-offline --no-audit || \
    (sleep 10 && npm ci --prefer-offline --no-audit) || \
    (sleep 30 && npm ci --no-audit)

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built files
COPY --from=builder /app/build /usr/share/nginx/html

# Simple nginx config
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]