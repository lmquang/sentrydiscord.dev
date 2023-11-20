# Use the official Node.js 14 image as the base image
FROM node:16 AS builder

ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm ci --production

# Copy the rest of the app's source code to the working directory
COPY . .

# Build the Next.js app
RUN npm run build

FROM node:16 AS runner
WORKDIR /app
ENV NODE_ENV production

COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]