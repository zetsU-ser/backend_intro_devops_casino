#ETAPA DE CREACION
#Imagen
FROM node:20-alpine AS builder

#Directorio de trabajo
WORKDIR /app

COPY package*.json ./

#Instalar dependencias
RUN if [ -f package-lock.json ]; then \
      echo ">>> package-lock.json encontrado: usando npm ci (reproducible)"; \
      npm ci --omit=dev; \
    else \
      echo ">>> AVISO: package-lock.json NO encontrado, usando npm install --omit=dev"; \
      npm install --omit=dev; \
    fi

#Pasamos el codigo fuente al entorno de preparacion
COPY . .

#ETAPA DE EJECUCION
FROM node:20-alpine AS runtime

LABEL maintainer="curso-devops"
LABEL descripcion="Casino Backend - Node.js"

WORKDIR /app

#Se traen las dependencias y los directorios en preparacion
#Se le asigna la propiedad a usuario (node) y no (root)
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/package*.json ./
COPY --from=builder --chown=node:node /app/src ./src

#Se cambia a usuario sin privilegios 
USER node

#Comunicacion del docker 
EXPOSE 3000

#Comprobacion de estado mediante peticion HTTP interna
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:3000/livez',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["node", "src/server.js"]
