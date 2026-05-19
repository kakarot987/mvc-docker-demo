# ==================== STAGE 1: BUILDER ====================
# Build stage with Node.js to compile React app (Frontend)
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files (package-lock.json may be absent; use glob)
COPY package*.json ./

# Install dependencies reproducibly
# Use npm ci when a lockfile exists; falls back to npm install if not present
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copy source code
COPY . .

# Build the React app
RUN npm run build

# ==================== STAGE 2: RUNTIME ====================
# Optimized runtime stage with Nginx to serve React app
FROM nginx:alpine

# Copy nginx configuration
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/

# Copy built React app from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Ensure the built assets and nginx runtime dirs are owned by nginx user
# Create cache/run dirs with correct ownership so nginx can start as root and drop privileges
RUN mkdir -p /var/cache/nginx/client_temp /var/run && \
    chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/run || true

# Note: we run the default nginx entrypoint as root so the master process can manage worker
# processes and create runtime dirs. nginx will drop privileges to the 'nginx' user for workers.

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:3000/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]




