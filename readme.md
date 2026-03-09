# CookShare 🍳

> **Plataforma Integral de Gestión Gastronómica y Compra Inteligente.**
> Proyecto de Fin de Ciclo - Desarrollo de Aplicaciones Multiplataforma (DAM).

---

## 📝 Descripción del Proyecto
**CookShare** no es solo un recetario digital; es una solución completa para el ciclo de alimentación. La plataforma permite a los usuarios descubrir, gestionar y adaptar recetas de cocina profesional, integrando un sistema de **cálculo dinámico de raciones** y una **lista de la compra automatizada**. 

El proyecto destaca por aplicar una arquitectura limpia y escalable, enfocada en la experiencia de usuario y la integridad de los datos.

## 🚀 Stack Tecnológico

### Backend
* **Lenguaje:** Java 21 
* **Framework:** Spring Boot 3+
* **Persistencia:** Spring Data JPA (Hibernate)
* **Seguridad:** Spring Security & JWT
* **Documentación:** Swagger / OpenAPI 3

### Frontend
* **Framework:** Flutter (Dart)
* **Arquitectura:** Clean Architecture

### Infraestructura y Datos
* **Base de Datos:** MySQL / SQL Server
* **Control de Versiones:** Git (GitHub)

---

## ✨ Funcionalidades Principales

### 👨‍🍳 Gestión de Recetas
* **Recetario Dinámico:** CRUD completo de recetas con soporte multimedia.
* **Algoritmo de Escalado:** Recálculo automático de cantidades de ingredientes basado en el número de comensales.
* **Privacidad:** Control granular sobre recetas públicas o privadas.

### 🛒 Lista de la Compra Inteligente
* **Sincronización:** Añadir ingredientes directamente desde una receta.
* **Inventario:** Gestión de artículos manuales y control de productos adquiridos.

### 👥 Componente Social
* **Feed Global:** Exploración de recetas compartidas por la comunidad.
* **Sistema de Favoritos:** Zona personalizada de recetas guardadas.
* **Perfiles de Usuario:** Gestión de perfiles y autoría de contenido.

---

## 🏗️ Estructura del Repositorio
```text
/
├── backend/          # API REST con Spring Boot y Java 21
├── app/       # Aplicación móvil en Flutter
├── docs/             # Documentación técnica, diagramas y memoria
└── README.md         # Presentación del proyecto
