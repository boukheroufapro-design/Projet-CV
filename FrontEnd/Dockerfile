FROM node:22-alpine AS build
WORKDIR /src/FrontEnd

COPY FrontEnd/package.json FrontEnd/package-lock.json ./
RUN npm ci

COPY FrontEnd/ ./
RUN npm run build

FROM nginx:alpine AS runtime
COPY FrontEnd/nginx.conf /etc/nginx/templates/default.conf.template
COPY --from=build /src/FrontEnd/dist/FrontEnd/browser /usr/share/nginx/html
EXPOSE 8080
