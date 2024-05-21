###################
# BUILD FOR LOCAL DEVELOPMENT
###################
# Base image
FROM node:19.5.0-alpine AS development
LABEL MAINTAINER="Carolldsk <carolldsk@gmail.com"

# Create app directory
WORKDIR /home/node/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure copying both package.json AND package-lock.json (when available).
# Copying this first prevents re-running npm install on every code change.
COPY --chown=node:node package*.json ./

# Install app dependencies using the `npm ci` command instead of `npm install`
RUN npm ci

# Bundle app source
COPY --chown=node:node . .

# Use the node user from the image (instead of the root user)
USER node



###################
# PRODUCTION
###################

# Base image
FROM node:19.5.0-alpine AS production
LABEL MAINTAINER="Carolldsk <carolldsk@gmail.com"


# create folders and perm
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

# Create app directory
WORKDIR /home/node/app

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

USER node

# Install app dependencies
RUN npm install express

# Bundle app source
COPY --chown=node:node . .

# Copy the .env
COPY .env ./

ENV PORT=3000
# Expose the port on which the app will run
EXPOSE 3000

# Creates a "dist" folder with the production build
RUN npm run build


# Start the server using the production build
CMD ["npm", "run", "start:prod"]



