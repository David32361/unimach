# Logo de UniMatch

Identidad: dos formas redondeadas entrelazadas que sugieren una U, conexión y
un corazón. Tono principal de la app: rosa frambuesa `#B83A55`.

- `unimatch-logo.png`: original generado con transparencia; conservar como fuente.
- `unimatch-icon.png`: exportación sobre fondo claro para iconos y presentación.
- `../scripts/export_brand_assets.py`: exporta tamaños de Android, Flutter y Web.

Para regenerar los tamaños, instalar Pillow y ejecutar desde la raíz:

```powershell
python scripts/export_brand_assets.py
```

Se preserva la ilustración del original; las exportaciones solo cambian el tamaño,
los márgenes seguros y el fondo del icono. Android incluye versiones legacy,
adaptativas y monocromáticas para iconos temáticos de Android 13 o posterior.

## Generación

Creado el **29 de octubre de 2026** con la herramienta integrada de generación
de imágenes. No se utilizó la API mediante CLI ni una clave API del usuario.

Prompt inicial:

> Use case: logo-brand. Asset type: production logo symbol and Android launcher foreground for UniMatch, a university student dating and shared-interest app. Create ONE polished distinctive flat geometric emblem: two rounded interlocking U-shaped forms that together suggest a heart and a welcoming connection. Uncluttered, contemporary, balanced, broad smooth strokes, readable at 24px, refined negative space. Solid deep raspberry rose #B83A55 only. Transparent background with real alpha, no background tile, no mockup, no shadow, no gradients, no texture, no watermark. No typography, no letters as text, no wordmark. Center the emblem in a square image, emblem occupying about 65% of the square width and height, with generous even transparent padding for safe Android adaptive icon cropping. Crisp vector-like contours rendered as high-resolution PNG.

Prompt final de refinamiento:

> Polish this UniMatch logo for production. Keep the same heart-shaped interlocking-U silhouette and the same centered layout. Make it a perfectly flat solid raspberry #B83A55 emblem with smooth antialiased contours. Remove all stray red speckles, ragged pixels, accidental hairlines, gradients and texture. The two rounded forms must have clean intentional negative-space separation; refine the small lower-right junction cleanly. Fully transparent background, no black backdrop, no text, no mockup. Keep a large even transparent margin around all sides for an adaptive app icon. Output one square transparent PNG logo.
