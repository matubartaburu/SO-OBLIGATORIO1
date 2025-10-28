# INVENTARIO CITADEL – Documentación

---

### Descripción general

El sistema permite gestionar un inventario de pinturas Citadel mediante un script en Bash.
Incluye control de usuarios, registro y venta de productos, filtrado por tipo y generación de reportes en formato CSV.

### Implementación

* Lenguaje: Bash
* Persistencia: archivos de texto (usuarios.txt, productos.txt, Datos/datos.CSV)
* Sesión: variable bool SESION_INICIADA y usuario_actual impiden operar sin login.
* Validaciones:

  * No se permiten usuarios repetidos ni contraseñas vacías.
  * Cantidad y precio deben ser >= 0.
  * No se puede vender más que el stock disponible.
* Reporte: se genera automáticamente en la carpeta Datos en formato CSV.

### Ejemplo de uso

1. Login: el sistema crea por defecto el usuario admin.
2. Ingresar producto:

   ```
   Tipo: contrast  
   Modelo: blood angels red  
   Cantidad: 50  
   Precio: 400
   ```

   Se guarda como
   ```
   CON - contrast - blood angels red - "descripcion breve" - 50 - 400
   ```
3. Vender producto: muestra la lista numerada, permite elegir cantidad y descuenta del stock.
   Si el stock llega a 0, el producto se elimina del inventario.
4. Filtrar: muestra productos por tipo.
5. Reporte: crea el archivo Datos/datos.CSV con los productos actuales.

### Ejemplo de salida final

```
CON - contrast  - blood angels red - Rojo intenso - 47 - $ 400
LAY - layer  - green - Verde brillante - 20 - $ 320
```