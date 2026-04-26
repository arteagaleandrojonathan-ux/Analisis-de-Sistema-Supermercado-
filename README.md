# Analisis-de-Sistema-Supermercado-
Este sistema lo armé pensando en que una base de datos no solo debe guardar información, sino también aplicar reglas y lógica de negocio. Modelé toda la estructura para controlar el flujo completo de la mercadería: desde que se le compra a un proveedor, pasa por el almacén, se vende al cliente (ya sea en la tienda o por delivery), hasta cómo se manejan las devoluciones o las mermas (productos dañados o vencidos).

Utilicé Base de Datos MySQL, Modelado: ERwin Data Modeler, Lenguaje:SQL Estructurado

Diseñé la base de datos dividiéndola en 6 niveles jerárquicos para asegurar que el sistema sea escalable y evitar redundancias en los datos.
En lugar de dejarle todo el trabajo a la programación, apliqué restricciones avanzadas (`CONSTRAINTS`, `CHECK`, `UNIQUE`, `FOREIGN KEY`) directamente en el código SQL. Por ejemplo, el sistema por sí solo bloquea que se registre una merma con cantidad negativa o que un cupón de descuento supere su límite máximo de usos.

