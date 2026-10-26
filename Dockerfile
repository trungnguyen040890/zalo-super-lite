# Build stage
FROM node:18-alpine AS builder

# Create app directory
WORKDIR /usr/src/app

COPY package*.json ./

# Cài đặt Git, Curl và công cụ Bun cần thiết cho môi trường Linux Alpine
RUN apk add --no-cache git curl bash && \
    curl -fsSL https://bun.sh | bash && \
    ln -s /root/.bun/bin/bun /usr/local/bin/bun

# Tiến hành cài đặt thư viện dự án và kích hoạt biên dịch lõi zca-js bằng Bun
RUN npm install && cd node_modules/zca-js && npm install && bun run build && cd ../..

COPY package*.json ./

# Install all dependencies (including devDependencies)
# Cài đặt công cụ Git cho hệ điều hành Alpine Linux rứt gọn
RUN apk add --no-cache git

RUN npm install && cd node_modules/zca-js && npm install && npm run build && cd ../..



# Copy source code
COPY . .

# Prune unnecessary files
RUN npm prune --production && \
    rm -rf node_modules/.cache && \
    rm -rf node_modules/.npm

# Production stage
FROM node:18-alpine

# Set working directory
WORKDIR /usr/src/app

# Set environment
ENV NODE_ENV production

# Create non-root user and set ownership
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    mkdir -p /usr/src/app && \
    chown -R nodejs:nodejs /usr/src/app

# Copy only necessary files from builder stage
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/package*.json ./
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/bin ./bin
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/public ./public
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/routes ./routes
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/views ./views
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/app.js ./

# Expose application port
EXPOSE 3000

# Switch to non-root user
USER nodejs

# Run the application
CMD [ "node", "./bin/www" ]
