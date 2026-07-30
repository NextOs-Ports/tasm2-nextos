# Installation / Instalação

## English

### Required game data

**The Amazing Spider-Man 2 1.2.7d is not an APK-only game.** A complete
installation needs exactly four owner-supplied input files:

1. one Android APK with `versionName 1.2.7d`, `versionCode 12723` and package
   `com.gameloft.android.ANMP.GloftASHM`;
2. `main.12032.com.gameloft.android.ANMP.GloftASHM.obb`;
3. `patch.12438.com.gameloft.android.ANMP.GloftASHM.obb`;
4. `patch.12723.com.gameloft.android.ANMP.GloftASHM.obb`.

Do not unpack or modify the OBB files. An APK without the complete three-file
cache is insufficient.

### Directory layout

1. Extract `asm2.zip` at the storage root that contains the firmware's
   `ports/` directory.
2. Copy the APK and all three intact OBBs into
   `ports/asm2_127/gamedata/`.

The recommended layout is:

```text
ports/
└── asm2_127/
    └── gamedata/
        ├── your-1.2.7d-copy.apk
        ├── main.12032.com.gameloft.android.ANMP.GloftASHM.obb
        ├── patch.12438.com.gameloft.android.ANMP.GloftASHM.obb
        └── patch.12723.com.gameloft.android.ANMP.GloftASHM.obb
```

3. Launch **The Amazing Spider-Man 2** from Ports.
4. Let NXExtract validate and prepare all four inputs. The first preparation
   processes more than 1 GiB and can take several minutes on old storage.
5. If the original legal screen appears, press one face/action button once.

NXExtract validates content rather than trusting external names. A renamed
supported input can still be recognized, but no missing APK or OBB can be
recreated. Wrong, incomplete, truncated or corrupt inputs are rejected before
the transactional install is published.

Internet access is not required. Updates preserve `gamedata`, saves,
preferences and cache.

## Português

### Dados obrigatórios do jogo

**The Amazing Spider-Man 2 1.2.7d não é um jogo de APK único.** A instalação
completa exige exatamente quatro arquivos fornecidos pelo proprietário:

1. um APK Android com `versionName 1.2.7d`, `versionCode 12723` e pacote
   `com.gameloft.android.ANMP.GloftASHM`;
2. `main.12032.com.gameloft.android.ANMP.GloftASHM.obb`;
3. `patch.12438.com.gameloft.android.ANMP.GloftASHM.obb`;
4. `patch.12723.com.gameloft.android.ANMP.GloftASHM.obb`.

Não abra, extraia ou modifique os OBBs. O APK sem o cache completo de três
arquivos não é suficiente.

### Organização das pastas

1. Extraia `asm2.zip` na raiz do armazenamento que contém a pasta `ports/`.
2. Copie o APK e os três OBBs intactos para
   `ports/asm2_127/gamedata/`.

A organização recomendada é:

```text
ports/
└── asm2_127/
    └── gamedata/
        ├── sua-copia-1.2.7d.apk
        ├── main.12032.com.gameloft.android.ANMP.GloftASHM.obb
        ├── patch.12438.com.gameloft.android.ANMP.GloftASHM.obb
        └── patch.12723.com.gameloft.android.ANMP.GloftASHM.obb
```

3. Abra **The Amazing Spider-Man 2** pelo menu Ports.
4. Aguarde o NXExtract validar e preparar os quatro arquivos. A primeira
   preparação processa mais de 1 GiB e pode levar vários minutos em
   armazenamento antigo.
5. Se a tela legal original aparecer, pressione uma vez um botão frontal/de
   ação.

O NXExtract valida o conteúdo em vez de confiar no nome externo. Um insumo
suportado renomeado ainda pode ser reconhecido, mas nenhum APK ou OBB ausente
pode ser recriado. Dados errados, incompletos, truncados ou corrompidos são
rejeitados antes da publicação transacional.

Internet não é necessária. Atualizações preservam `gamedata`, saves,
preferências e cache.
