# Silent Hill 2 Remake — First-Person Camera + Dynamic Head-Tracking Mod

Mod de cámara en primera persona para **Silent Hill 2 Remake (PC)** con **seguimiento dinámico de cabeza (`head_bn`)** integrado sobre [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) y `UltraPlusExtensions`.

## Características

1. **Ajuste de offset en primera persona (`CameraFPP_P`):**
   - Los 5 `TargetOffset` (`X=10.0, Y=0.0, Z=6.0`) están ajustados para posicionar la cámara en perspectiva en primera persona al nivel de la cabeza de James sin recortes internos.
2. **Seguimiento dinámico de cabeza (`game_overrides.lua`):**
   - Ancla el `SpringArm` del personaje (`SHCharacterPlay_BP_C`) dinámicamente al hueso `head_bn` del esqueleto (`Mesh`) para acompañar el movimiento real de la cabeza al esquivar, recibir golpes o atacar cuerpo a cuerpo.
   - Oculta el hueso `head_bn` y `DLCSkinStaticMesh` durante el juego para evitar obstrucciones visuales.
   - Sincroniza la rotación libre de la cámara desde `char.View` en ambos ejes (**horizontal `Yaw` y vertical `Pitch`**) desactivando `bUsePawnControlRotation` y `bInheritPitch/Yaw/Roll`.
   - **Transición automática en cinemáticas:** restaura el padre original (`View`), las rotaciones relativas y la visibilidad de la cabeza automáticamente al entrar en cinemáticas y vuelve a activarlo al salir.
   - **Atajo manual (`F11`):** permite activar o desactivar el seguimiento de cabeza en tiempo real dentro del juego.

## Estructura incluida

```text
SHProto/
├── Content/
│   └── Paks/
│       └── ~mods/
│           ├── CameraFPP_P.pak
│           ├── CameraFPP_P.ucas
│           └── CameraFPP_P.utoc
└── Binaries/
    └── Win64/
        └── ue4ss/
            └── Mods/
                └── UltraPlusExtensions/
                    └── Scripts/
                        └── game_overrides.lua
```

## Requisitos e instalación

1. Tener instalado **UE4SS** y el mod **Ultra+ (`UltraPlusExtensions`)** en `SILENT HILL 2\SHProto\Binaries\Win64\ue4ss\Mods\UltraPlusExtensions\`.
2. Copiar la carpeta `SHProto` de este repositorio directamente sobre la carpeta raíz de tu instalación de Silent Hill 2 Remake *(por ejemplo `D:\Steam\steamapps\common\SILENT HILL 2\`)*, reemplazando `game_overrides.lua` cuando te lo pida *(se recomienda hacer una copia de seguridad de tu `game_overrides.lua` previo)*.
3. Inicia el juego normalmente. Usa **`F11`** si deseas alternar el head-tracking manualmente en cualquier momento.
