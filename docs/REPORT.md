# Reporte de desarrollo

## 1. Introduccion

Cuando empece esta prueba vi un proyecto con buena base tecnica, pero tambien con bastante codigo heredado y algunas piezas que ya no representaban el flujo real de la aplicacion. Mi objetivo fue convertir esa base en un MVP funcional, coherente y facil de explicar.

Aunque ya tenia experiencia con Flutter y arquitectura por capas, esta prueba me obligo a cerrar un flujo completo con Firebase Auth, Firestore, Storage, reglas de seguridad y una capa de datos que ademas debia convivir con la integracion previa de `NewsAPI`. El foco estuvo en terminar el recorrido de extremo a extremo sin romper la estructura del repositorio.

## 2. Aprendizaje

Durante la prueba reforce varios puntos practicos:

- modelado de articulos en Firestore sin romper la interfaz heredada
- coordinacion entre Firestore, Storage y Auth para publicar articulos
- arranque correcto de Flutter cuando Firebase debe inicializarse antes del resto
- convivencia entre una fuente propia de datos y una fuente externa como `NewsAPI`
- documentacion del contrato entre backend y frontend
- uso responsable de herramientas de IA como acelerador, sin delegar el criterio tecnico

Los recursos principales fueron la documentacion oficial de Flutter y Firebase, la documentacion interna del repositorio y la propia lectura del codigo existente para distinguir que partes seguian activas y cuales eran ya legado.

## 3. Metodologia de trabajo y uso de IA

Durante el desarrollo me apoye en herramientas de IA para acelerar algunas tareas de ejecucion, sobre todo:

- generacion inicial de fragmentos de codigo
- generacion y ajuste de tests
- redaccion o mejora de parte de la documentacion
- uso de Google Stitch como apoyo para proponer y mejorar interfaces

Quiero dejar claro que ese apoyo no sustituyo mi criterio tecnico. Todo lo generado fue siempre supervisado por mi, contrastado con mis conocimientos y revisado dentro del contexto real del proyecto.

La metodologia seguida fue siempre la misma:

- Planificar
- Desarrollar
- Revisar
- Testear
- Iterar

En la practica eso significo:

- entender primero el estado real del repositorio antes de tocar piezas importantes
- decidir el flujo y el contrato de datos antes de implementar
- desarrollar cambios pequenos y verificables
- revisar el codigo generado o modificado para asegurar coherencia con la arquitectura
- testear tanto con pruebas automatizadas como con comprobaciones manuales
- iterar despues de cada hallazgo hasta dejar la funcionalidad estable

La IA me sirvio para ganar velocidad mecanica en algunas partes del trabajo, pero las decisiones, la integracion final, la revision critica y la validacion del resultado fueron responsabilidad mia.

## 4. Trabajo realizado

### Funcionalidad principal

- Backend preparado con esquema, reglas e indices para articulos en Firebase.
- Frontend Android conectado a Firebase con inicializacion real del proyecto.
- Flujo completo de articulos propios:
  - listado desde Firestore
  - detalle por `articleId`
  - creacion de articulo
  - seleccion de miniatura con `image_picker`
  - subida a Firebase Storage
  - guardado de metadatos en Firestore
  - archivado de articulos
- Recuperacion de `NewsAPI` como fuente complementaria del listado principal.

### Estado actual del listado principal

El listado principal combina dos fuentes:

- Firestore para los articulos publicados desde la app
- `NewsAPI` para titulares externos

Los articulos propios tienen prioridad en el listado y las noticias externas usan IDs sinteticos `newsapi:*`, lo que permite que el detalle y `Saved Articles` sigan funcionando tambien en ese caso.

## 5. Decisiones tecnicas

Las decisiones mas importantes fueron estas:

- Mantener la separacion por capas ya marcada por el proyecto para no mezclar UI, logica y acceso a datos.
- Usar el `document id` de Firestore como identificador canonico de los articulos propios.
- Guardar `thumbnailPath` en vez de una URL publica para respetar el requisito de Firebase Storage.
- Crear primero el documento y subir despues la miniatura, ya que la ruta en Storage depende del `articleId`.
- Revertir el documento si falla la subida de imagen para evitar articulos huerfanos.
- Mantener autenticacion anonima como solucion de MVP para publicar sin construir una pantalla completa de login.
- Recuperar `NewsAPI` como apoyo del listado principal para que la app siga mostrando contenido real aunque haya pocos articulos propios.

## 6. Retos encontrados

El primer reto fue el entorno Android. Antes de estabilizar el flujo funcional hubo que alinear JDK, Gradle, Kotlin y NDK para que la build fuera fiable.

Ese punto fue mas costoso de lo que parece en una prueba de este tipo, porque una parte del tiempo no estuvo en la funcionalidad sino en dejar el entorno consistente. Hubo que lidiar con:

- compatibilidad entre la version de Flutter y las versiones efectivas de Dart usadas por el proyecto
- alineacion entre JDK 17, Gradle y plugins Android para evitar fallos de compilacion
- necesidad de tener disponible la NDK correcta para que la build de Android no quedara en un estado inestable
- diferencias entre ejecutar la app en un dispositivo o emulador Android y ejecutar servicios locales de Firebase
- tiempos perdidos en validaciones del emulador, arranque del dispositivo virtual y ajustes del toolchain antes de poder probar con normalidad

En otras palabras, no fue solo "hacer correr Flutter", sino dejar cuadradas varias capas de versionado que, si no estan alineadas, bloquean la iteracion incluso cuando el codigo de aplicacion es correcto.

Otro reto importante fue diferenciar entre ejecutar la app en un emulador Android y soportar Firebase Emulator Suite. La app quedo funcionando contra un proyecto Firebase real, pero no se dejo como soporte oficial el uso de `useEmulator(...)` para Auth, Firestore y Storage.

Ese matiz fue importante porque al principio "emulador" podia referirse a dos cosas distintas:

- el emulador de Android donde corre la app
- los emuladores de Firebase para Auth, Firestore y Storage

Resolver la primera parte era necesario para desarrollar y probar en Android. La segunda ya implicaba una integracion adicional a nivel de bootstrap y configuracion de red que no estaba cerrada en el proyecto base, asi que la decision correcta para el MVP fue estabilizar primero la app contra Firebase real y dejar el soporte explicito para Firebase Emulator Suite como mejora posterior.

Tambien hubo un reto claro de consistencia entre Firestore y Storage. Como el articulo y la miniatura viven en sistemas distintos, habia que evitar estados parciales. La solucion fue publicar en dos pasos y borrar el documento si la subida de la imagen falla.

Por ultimo, reactivar `NewsAPI` sin romper el MVP exigio unificar ambas fuentes de datos con una logica clara de combinacion, IDs estables y resolucion de detalle para noticias externas.

## 7. Reflexion y siguientes pasos

La leccion principal fue que cerrar una funcionalidad no consiste solo en hacer que la pantalla pinte datos. Hacia falta dejar un contrato remoto claro, una capa de datos honesta, un arranque fiable y una documentacion alineada con el estado real del proyecto.

Tambien me resulto util no pelearme con el modelo heredado cuando no era necesario. Reaprovechar parte de la estructura previa de `NewsAPI` permitio iterar mas rapido y reducir refactor innecesario.

Si tuviera mas tiempo, los siguientes pasos naturales serian:

- anadir soporte explicito para Firebase Emulator Suite
- persistir `Saved Articles` entre reinicios
- incorporar una UI real de autenticacion
- distinguir visualmente articulos propios y noticias externas
- ampliar pruebas de integracion para el listado hibrido

## 8. Prueba del proyecto

La verificacion tecnica que deje cerrada en esta rama fue:

- `flutter analyze`
- `flutter test test/features/daily_news/data/repository/article_repository_impl_test.dart`

Ademas, `frontend/README.md` incluye una guia de prueba manual del flujo principal.

En cuanto a evidencia visual, el repositorio no incluye capturas ni videos versionados. Para una entrega final adjuntaria, como minimo, la pantalla principal, el detalle de un articulo propio, el detalle de una noticia externa y el flujo de creacion y publicacion.

## 9. Extras implementados

Como trabajo adicional sobre el minimo esperado, destacaria:

- listado hibrido Firestore + `NewsAPI`
- archivado de articulos en lugar de borrado duro en el flujo publico
- reversion del documento si falla la subida de la miniatura
- activacion anticipada de sesion anonima y mensajes de error claros cuando no esta disponible

Tambien dejo como artefactos utiles el esquema en `backend/docs/DB_SCHEMA.md` y la documentacion operativa en `frontend/README.md` y `backend/README.md`.

## 10. Cierre

El resultado final ya no es solo una interfaz conectada a datos de prueba. Es una app Android con lectura, detalle, guardado en sesion, creacion, publicacion y archivado de articulos, respaldada por Firebase y capaz de combinar contenido propio con titulares externos reales de forma consistente.
