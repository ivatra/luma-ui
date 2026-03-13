FROM node:18-alpine

LABEL maintainer="ivatra <ivatra@yandex.ru>"
LABEL description="Luma UI - Build Accessible Apps 10x faster"

WORKDIR /app

# Установить pnpm
RUN npm install -g pnpm

# Скопировать files
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json tsconfig.json vitest.config.ts ./

# Скопировать workspaces
COPY packages ./packages
COPY docs ./docs
COPY playground ./playground
COPY example ./example
COPY test ./test

# Установить зависимости
RUN pnpm install --frozen-lockfile

# Собрать проект
RUN pnpm build && pnpm docs:build

# Expose port
EXPOSE 3000

# Env vars
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Запустить сервер
CMD ["pnpm", "serve:docs"]
