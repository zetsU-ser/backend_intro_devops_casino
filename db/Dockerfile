FROM postgres:16-alpine

LABEL maintainer="vidal-casino-devops"
LABEL descripcion="PostgreSQL Database - Vidal Casino"

# Embeber el script de inicialización de la base de datos
COPY init.sql /docker-entrypoint-initdb.d/01-init.sql

EXPOSE 5432
