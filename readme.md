# CookShare 🍳

> **Ecosistema Multiplataforma para la Gestión de Recetas y Compra Inteligente.**
> Proyecto de Fin de Ciclo - Desarrollo de Aplicaciones Multiplataforma (DAM).

---

## 📝 Descripción del Proyecto
**CookShare** es una solución integral diseñada para optimizar el ciclo de alimentación doméstica. La plataforma permite a los usuarios descubrir, gestionar y adaptar recetas, integrando un sistema de **cálculo dinámico de raciones** y una **lista de la compra automatizada** sincronizada con un inventario básico.

El proyecto destaca por la implementación de **Inteligencia Artificial** para facilitar la entrada de datos y una arquitectura limpia que garantiza la escalabilidad y seguridad de la información.

## 🚀 Stack Tecnológico

### Backend
* [cite_start]**Lenguaje:** Java 21 (LTS) [cite: 99]
* [cite_start]**Framework:** Spring Boot 3+ [cite: 99]
* [cite_start]**Persistencia:** Spring Data JPA (Hibernate) [cite: 100]
* [cite_start]**Seguridad:** Spring Security & JWT [cite: 100]
* [cite_start]**Documentación:** Swagger / OpenAPI 3 [cite: 110]

### Frontend
* [cite_start]**Framework:** Flutter (Dart) [cite: 97]
* **Arquitectura:** Clean Architecture (Pattern por capas)

### Infraestructura e Innovación
* [cite_start]**Base de Datos:** MySQL [cite: 102]
* **IA:** Google Gemini API (Procesamiento de vídeo y extracción de lenguaje natural)
* **Control de Versiones:** Git (GitHub)

---

## ✨ Funcionalidades Principales

### 👨‍🍳 Gestión de Recetas e IA
* **Video-to-Recipe (IA):** Extracción automática de ingredientes y pasos de elaboración a partir de archivos de vídeo mediante IA generativa.
* [cite_start]**Recetario Dinámico:** CRUD completo de recetas con soporte multimedia[cite: 89].
* [cite_start]**Algoritmo de Escalado:** Recálculo automático de cantidades basado en el número de comensales seleccionado[cite: 90].
* **Privacidad:** Control sobre recetas públicas (compartidas con la comunidad) o privadas.

### 🛒 Compra Inteligente e Inventario
* [cite_start]**Lista de la Compra Automatizada:** Generación de listas a partir de los ingredientes de las recetas seleccionadas[cite: 91].
* [cite_start]**Gestión de Inventario:** Control de artículos manuales y marcado de productos adquiridos[cite: 91].

### 👥 Componente Social
* **Feed Global:** Exploración de recetas compartidas por otros usuarios.
* **Sistema de Favoritos:** Guardado de recetas de terceros en una zona personalizada.
* **Perfiles de Usuario:** Gestión de identidad, perfiles y autoría de contenido.

---

## 🏗️ Estructura del Repositorio

```text
/
├── backend/      # API REST con Spring Boot y Java 21
├── app/          # Aplicación móvil desarrollada en Flutter
├── database/     # Scripts SQL y modelo Entidad-Relación
[cite_start]├── docs/         # Memoria final (PDF) y documentación técnica [cite: 95]
└── README.md     # Presentación del proyecto