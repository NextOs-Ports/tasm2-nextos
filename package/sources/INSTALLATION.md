# Installation / Instalação

## English

Put one supported owner-input set in `ports/asm2_127/gamedata/`.

Supported Android container SHA-256 values:

- 1.2.7d universal: `4188a463432b921dfb767a3ddf316e970655789a7bdf806298757f45071a8c87`
- 1.2.7d universal: `2878fec3235a91a0487ee0a3ffdbcb5c534e0d052a573941a10489024b2b1868`
- 1.2.8d universal: `6211d194cb06c6cbb32c2491adef59554eef4d97763a2fbc1e4bbb52d9fcae9b`
- 1.2.8d ARM32-only installer: `42d1a3ac86708549fb425b8e36338ece56ea384fb2e30062c7a7da6ca34689e3`

For a loose APK, also supply either the intact companion cache ZIP
`23f3ef198f731fa1af0f2dfce4902e510dc4bf57edc3a3524e8986b2a4bcc770`
or these two intact OBBs:

1. `main.12032.com.gameloft.android.ANMP.GloftASHM.obb`
2. `patch.12723.com.gameloft.android.ANMP.GloftASHM.obb`

`patch.12438.com.gameloft.android.ANMP.GloftASHM.obb` is optional. The
self-contained installer already carries the two required expansions, but it
works only on ARM32/multilib systems. X5M requires a universal input containing
the x86 game library.

Do not unpack or modify OBBs or the cache ZIP. Start the game from Ports and
let NXExtract validate and prepare the set.

## Português

Coloque um conjunto pertencente ao usuário e suportado em
`ports/asm2_127/gamedata/`.

SHA-256 dos contêineres Android suportados:

- 1.2.7d universal: `4188a463432b921dfb767a3ddf316e970655789a7bdf806298757f45071a8c87`
- 1.2.7d universal: `2878fec3235a91a0487ee0a3ffdbcb5c534e0d052a573941a10489024b2b1868`
- 1.2.8d universal: `6211d194cb06c6cbb32c2491adef59554eef4d97763a2fbc1e4bbb52d9fcae9b`
- instalador 1.2.8d somente ARM32: `42d1a3ac86708549fb425b8e36338ece56ea384fb2e30062c7a7da6ca34689e3`

Para um APK solto, forneça também o cache ZIP intacto
`23f3ef198f731fa1af0f2dfce4902e510dc4bf57edc3a3524e8986b2a4bcc770`
ou estes dois OBBs intactos:

1. `main.12032.com.gameloft.android.ANMP.GloftASHM.obb`
2. `patch.12723.com.gameloft.android.ANMP.GloftASHM.obb`

`patch.12438.com.gameloft.android.ANMP.GloftASHM.obb` é opcional. O instalador
autocontido já traz as duas expansões obrigatórias, mas funciona somente em
ARM32/multilib. O X5M exige um insumo universal que contenha a biblioteca x86
do jogo.

Não abra, modifique nem extraia os OBBs ou o cache ZIP. Abra o jogo em Ports e
deixe o NXExtract validar e preparar o conjunto.
