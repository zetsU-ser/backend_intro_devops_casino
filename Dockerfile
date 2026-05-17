#ETAPA DE CREACION
#Imagen
FROM node:20-alpine AS builder

#Directorio de trabajo
WORKDIR /app

COPY package.json ./
#Se omite dev para instalar solo dependencias necesarias
RUN npm install --omit=dev && npm cache clean --force

#Pasamos el codigo fuente y persistencia al entorno de preparacion
COPY src ./src
COPY db ./db

#ETAPA DE EJECUCION
FROM node:20-alpine AS runtime

#Variables de entorno
ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /app

#Se traen las dependencias y los directorios en preparacion
#Se le asigna la propiedad a usuario (node) y no (root)
COPY --from=builder --chown=node:node /app/package.json ./package.json
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/src ./src
COPY --from=builder --chown=node:node /app/db ./db

#Comunicacion del docker 
EXPOSE 3000

#Comprobacion de estado mediante peticion HTTP interna
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3000/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

#Se cambia a usuario sin provilegios 
USER node

CMD ["node", "src/server.js"]

