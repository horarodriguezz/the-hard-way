# Stack

## Decisión

The Hard Way es una aplicación de escritorio hecha con **Flutter** y **Dart**,
con persistencia local en **SQLite**.

| Capa | Elección |
|---|---|
| Lenguaje | Dart 3 |
| UI | Flutter (desktop: Linux primero, luego Windows y macOS) |
| Estado | Riverpod |
| Persistencia | SQLite vía `drift` |
| Componentes base | `shadcn_ui` o `forui`, con un sistema de diseño propio encima |
| Canvas | `InteractiveViewer` + `CustomPainter` para las aristas |
| Layout del árbol | Propio, o un paquete como `graphview` |
| IA | Cliente HTTP propio con streaming (SSE) |

## Por qué Flutter

- **Iteración rápida.** El hot reload mantiene el estado: se puede pulir la
  estética del canvas sin perder el nodo en el que se está trabajando.
- **Canvas natural.** Todo es un widget que se puede transformar y animar; pan,
  zoom y nodos posicionados libremente son simples de construir.
- **Desktop y, a futuro, mobile.** La misma base de código sirve para una
  versión móvil.
- **Buen soporte en Linux,** impulsado por Canonical (el instalador de Ubuntu y
  el App Center están hechos en Flutter).
- **Dart encaja con el modelo de datos.** Las sealed classes y el pattern
  matching modelan los tipos de bloque como una unión discriminada exhaustiva.

## Alternativas evaluadas

| Opción | Por qué no |
|---|---|
| Electron / Tauri | Descartadas de entrada: el objetivo incluye que construir la app sea un desafío nativo. |
| C# + Avalonia | Muy buena opción. Iteración más lenta: el hot reload de C# es limitado y el de XAML depende de paquetes de la comunidad. |
| C++ + Qt/QML | La mejor en texto seleccionable y canvas, pero C++ agrega mucha fricción y no hay SDK de IA. |
| Rust + GPUI | Documentación escasa y API inestable. |
| WPF / WinUI / SwiftUI | Atadas a un solo sistema operativo. |

## Decisiones derivadas

- **Diagramas sin Mermaid.** Mermaid es JavaScript y no tiene un renderer nativo
  bueno. La IA genera diagramas como un JSON propio de grafo (nodos y aristas)
  que se dibuja con el mismo motor del canvas.
- **Selección para abrir ramas.** Cada bloque va en su propia `SelectionArea`,
  de modo que una selección de texto se traduce directamente a un `Anchor`
  (`blockId` + `quote`).
- **Cliente de IA propio.** No hay SDK oficial de OpenAI ni de Anthropic para
  Dart. Una capa delgada propia evita depender de paquetes de la comunidad que
  pueden quedar sin mantenimiento.
- **Virtualización del canvas.** Solo se renderizan con contenido completo los
  nodos visibles; los lejanos se muestran colapsados.

## Riesgos conocidos

- Desktop no es el foco principal del ecosistema Flutter: atajos de teclado,
  menús contextuales, hover y comportamiento de ventanas requieren trabajo
  manual.
- El paquete oficial de Markdown fue discontinuado; hay que elegir una
  alternativa de la comunidad o renderizar los bloques con un parser propio.
