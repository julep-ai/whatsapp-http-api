FROM node:18

# Chrome
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# npm packages
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm install

# App
WORKDIR /app
ADD ./src /app/src
ADD ./tsconfig.json /app
ADD ./nest-cli.json /app
ADD ./tsconfig.build.json /app
RUN npm run build

# Add rest of the files
ADD . /app

# Environment variables
ENV WHATSAPP_HOOK_ONMESSAGE=http://localhost/uri
ENV WHATSAPP_HOOK_ONSTATECHANGE=http://localhost/uri
ENV WHATSAPP_HOOK_ONACK=http://localhost/uri
ENV WHATSAPP_HOOK_ONADDEDTOGROUP=http://localhost/uri
ENV WHATSAPP_FILES_FOLDER=/tmp/whatsapp-files
ENV WHATSAPP_FILES_LIFETIME=180

ENV NODE_ENV=production
ENV PORT=80
ENV HOST=0.0.0.0

CMD npm run start:prod
