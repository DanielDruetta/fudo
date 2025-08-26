# Fudo API

Aplicación Ruby con Rack que expone una API RESTful en JSON para autenticación y gestión de productos, usando Sidekiq para procesamiento asíncrono y Redis como almacenamiento en memoria. No utiliza Rails.

## Tecnologías utilizadas

- **Ruby** 3.3
- **Rack** (API HTTP)
- **Sidekiq** (trabajos en segundo plano)
- **Redis** (persistencia en memoria)
- **Docker & Docker Compose** (contenedores y orquestación)

## Cómo levantar el proyecto

1. Clona el repositorio y navega a la raíz del proyecto.
2. Ejecuta:

```bash
docker compose build

docker compose up
```

Esto levantará los servicios web, sidekiq y redis.

## Endpoints principales y ejemplos curl

### Autenticación

```bash
curl -X POST http://localhost:9292/auth \
  -H "Content-Type: application/json" \
  -H "Accept-Encoding: gzip" \
  -d '{"user":"admin","password":"secret"}' | gunzip
```

### Crear producto (asíncrono)

```bash
curl -X POST http://localhost:9292/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer valid-token" \
  -H "Accept-Encoding: gzip" \
  -d '{"name":"Producto de prueba"}' | gunzip
```


### Actualizar producto

```bash
curl -X PUT http://localhost:9292/products/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer valid-token" \
  -H "Accept-Encoding: gzip" \
  -d '{"name":"Producto actualizado"}' | gunzip
```

### Consultar productos

```bash
curl -X GET http://localhost:9292/products \
  -H "Authorization: Bearer valid-token" \
  -H "Accept-Encoding: gzip" | gunzip
```

### Descargar especificación OpenAPI

```bash
curl -H "Accept-Encoding: gzip" http://localhost:9292/openapi.yaml | gunzip
```

### Descargar archivo AUTHORS

```bash
curl http://localhost:9292/AUTHORS
```

## Testing

Este proyecto utiliza **RSpec** para pruebas.

### Ejecutar los tests

Ejecutar todos los tests mediante Docker:

```bash
docker compose run --rm web bundle exec rspec
```
