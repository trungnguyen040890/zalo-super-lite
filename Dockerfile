# Stage 1: Build stage
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./

# Cài đặt các công cụ hệ thống Linux rút gọn
RUN apk add --no-cache git curl bash && \
    curl -fsSL https://bun.sh | bash && \
    ln -s /root/.bun/bin/bun /usr/local/bin/bun

# Tiến hành cài đặt thư viện dự án và kích hoạt biên dịch lõi zca-js bằng Bun
RUN npm install && cd node_modules/zca-js && npm install && bun run build && cd ../..

# Sao chép toàn bộ mã nguồn còn lại
COPY . .

# Tối ưu hóa dung lượng production
RUN npm prune --production && \
    rm -rf node_modules/.cache && \
    rm -rf node_modules/.npm

# Stage 2: Runtime stage
FROM node:18-alpine

WORKDIR /usr/src/app

# Thiết lập user bảo mật tránh quyền root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    mkdir -p /usr/src/app && \
    chown -R nodejs:nodejs /usr/src/app

# Sao chép các tệp tin đã build từ Stage 1 sang
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/package*.json ./
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/bin ./bin
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/public ./public
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/routes ./routes
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/views ./views
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/app.js ./

USER nodejs

EXPOSE 3000

ENV PORT=3000

CMD ["node", "./bin/www"]
