# CookShare 🍳

> **Ecosistema Multiplataforma para la Gestión de Recetas y Compra Inteligente.**
> Proyecto de Fin de Ciclo - Desarrollo de Aplicaciones Multiplataforma (DAM).
> IES San Mamede — Noelia Freire Amarelo — 2º DAM 2025/2026

---

## 📝 Descripción del Proyecto

**CookShare** es una solución integral diseñada para optimizar el ciclo de alimentación doméstica. La plataforma permite a los usuarios descubrir, gestionar y adaptar recetas, integrando un sistema de **cálculo dinámico de raciones** y una **lista de la compra automatizada** sincronizada con un inventario básico.

El proyecto destaca por la implementación de **Inteligencia Artificial** para facilitar la entrada de datos y una arquitectura limpia que garantiza la escalabilidad y seguridad de la información.

---

## 🚀 Stack Tecnológico

### Backend
- **Lenguaje:** Java 21 (LTS)
- **Framework:** Spring Boot 3.5
- **Persistencia:** Spring Data JPA (Hibernate)
- **Seguridad:** Spring Security + JWT (JJWT 0.12.3)
- **Documentación:** Swagger / OpenAPI 3

### Frontend
- **Framework:** Flutter (Dart)
- **Arquitectura:** Clean Architecture

### Infraestructura e Innovación
- **Base de Datos:** MySQL 8.x
- **IA:** Google Gemini API (Video-to-Recipe)
- **Control de Versiones:** Git + GitHub (Feature Branch Workflow)

---

## ✨ Funcionalidades Principales

### 👨‍🍳 Gestión de Recetas e IA
- **Video-to-Recipe (IA):** Extracción automática de ingredientes y pasos de elaboración a partir de archivos de vídeo mediante Google Gemini.
- **Recetario Dinámico:** CRUD completo de recetas con soporte multimedia.
- **Algoritmo de Escalado:** Recálculo automático de cantidades basado en el número de comensales — operación local en Flutter sin llamada al servidor.
- **Privacidad:** Control sobre recetas públicas (compartidas con la comunidad) o privadas.

### 🛒 Compra Inteligente e Inventario
- **Lista de la Compra Automatizada:** Generación de listas cruzando los ingredientes de las recetas con el inventario del usuario.
- **Gestión de Inventario:** Control del estado de los ingredientes en la despensa con cuatro estados: en despensa, lo tengo, no lo tengo, añadir a la lista de la compra.

### 👥 Componente Social
- **Feed Global:** Exploración de recetas públicas compartidas por otros usuarios (paginado).
- **Sistema de Favoritos:** Guardado de recetas de terceros en una zona personalizada.
- **Perfiles de Usuario:** Gestión de identidad, perfiles y autoría de contenido.

---

## 🏗️ Estructura del Repositorio

```
/
├── backend/      # API REST con Spring Boot y Java 21
│   └── src/
│       └── main/java/com/cookshare/backend/
│           ├── config/        # Configuración de Spring y CORS
│           ├── controller/    # Controladores REST
│           ├── dto/           # Objetos de transferencia de datos
│           ├── entity/        # Entidades JPA (7 entidades)
│           ├── exception/     # Manejo de excepciones
│           ├── repository/    # Repositorios Spring Data
│           ├── security/      # JWT y configuración de seguridad
│           └── service/       # Lógica de negocio
├── app/          # Aplicación móvil desarrollada en Flutter
│   └── lib/
│       ├── config/            # Constantes y configuración
│       ├── models/            # Modelos de datos
│       ├── screens/           # Pantallas de la app
│       ├── services/          # Servicios HTTP
│       └── widgets/           # Widgets reutilizables
├── docs/         # Memoria final (PDF) y documentación técnica
└── README.md     # Presentación del proyecto
```

---

## 📦 Estado del desarrollo

### ✅ Completado
- Modelo de datos completo — 7 entidades JPA con todas sus relaciones
- Repositorios Spring Data para todas las entidades
- DTOs de autenticación (RegisterDTO, LoginDTO, SessionDTO)
- JwtService — generación, validación y lectura de tokens JWT
- SecurityConfig + JwtFilter — seguridad stateless con JWT
- UserService — lógica de registro y login con BCrypt
- AuthController — endpoints POST /api/auth/register y /api/auth/login
- CorsConfig — configuración de CORS para Flutter web
- Flutter — pantalla de autenticación completa (login + registro)
- Flutter — conexión con la API REST funcionando
- Flutter — almacenamiento seguro del JWT con SecureStorage

### ⏳ Pendiente
- Implementación de CU-03 a CU-18
- Feed de recetas (pantalla principal)
- Video-to-Recipe con Google Gemini
- Inventario y lista de la compra
- Perfiles de usuario
