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
* **Lenguaje:** Java 21
* **Framework:** Spring Boot 3.5
* **Persistencia:** Spring Data JPA (Hibernate)
* **Seguridad:** Spring Security + JWT (JJWT 0.12.3)
* **Documentación:** Swagger / OpenAPI 3

### Frontend
* **Framework:** Flutter (Dart)
* **Arquitectura:** Clean Architecture 

### Infraestructura e Innovación
* **Base de Datos:** MySQL 
* **IA:** Google Gemini API (Video-to-Recipe)
* **Control de Versiones:** Git + GitHub 

---

## ✨ Funcionalidades Principales

### 👨‍🍳 Gestión de Recetas e IA
* **Video-to-Recipe (IA):** Extracción automática de ingredientes y pasos de elaboración a partir de archivos de vídeo mediante Google Gemini.
* **Recetario Dinámico:** CRUD completo de recetas con soporte multimedia.
* **Algoritmo de Escalado:** Recálculo automático de cantidades basado en el número de comensales — operación local en Flutter sin llamada al servidor.
* **Privacidad:** Control sobre recetas públicas (compartidas con la comunidad) o privadas.

### 🛒 Compra Inteligente e Inventario
* **Lista de la Compra Automatizada:** Generación de listas cruzando los ingredientes de las recetas con el inventario del usuario.
* **Gestión de Inventario:** Control de artículos manuales y marcado de productos adquiridos.

### 👥 Componente Social
* **Feed Global:** Exploración de recetas públicas compartidas por otros usuarios (paginado).
* **Sistema de Favoritos:** Guardado de recetas de terceros en una zona personalizada.
* **Perfiles de Usuario:** Gestión de identidad, perfiles y autoría de contenido.

---

## 🏗️ Estructura del Repositorio
```text
/
├── backend/      # API REST con Spring Boot y Java 21
│   └── src/
│       └── main/java/com/cookshare/backend/
│           ├── config/        # Configuración de Spring
│           ├── controller/    # Controladores REST
│           ├── dto/           # Objetos de transferencia de datos
│           ├── entity/        # Entidades JPA
│           ├── exception/     # Manejo de excepciones
│           ├── repository/    # Repositorios Spring Data
│           ├── security/      # JWT y configuración de seguridad
│           └── service/       # Lógica de negocio
├── app/          # Aplicación móvil desarrollada en Flutter
├── docs/         # Memoria final (PDF) y documentación técnica
└── README.md     # Presentación del proyecto
```
