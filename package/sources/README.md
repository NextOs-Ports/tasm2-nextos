# The Amazing Spider-Man 2 1.2.7d — universal BYO-data port

**Language / Idioma:** [English](#english) · [Português](#português)

**Package release / Versão do pacote:** 1.1.3

This is an independent clean-room compatibility loader. It does not distribute
the APK, either native game library, OBB files, audio or other executable game
data. The catalogue includes one real gameplay screenshot captured from the
validated port.

## English

The loader preserves the original Android lifecycle on both supported routes:

- the original ARMv7 `libtasm2.so` runs natively through separate current
  NextOS and low-glibc PortMaster ARMHF loaders;
- the physically validated AArch64 NextOS X5M route (`amlogic,s7d` /
  Mali-G310) runs the original Android x86 library through a scoped Box32 host
  and `sdl2-compat`. The packaged compatibility SDL is private to that game
  process; the native NXExtract UI uses the firmware SDL2/KMSDRM stack.

The launcher negotiates resolution, SDL, GLES, controller data and memory
settings at runtime. ARMHF systems retain their native backend selection. The
KMSDRM variables required by the X5M are confined to its exact hardware route;
no audio backend is forced. Before startup the launcher holds a single-instance
lock, stops and confirms stale processes, validates the selected ELF,
interpreter, dependencies and packaged hashes, then runs the game in the
foreground. The original `RestartGame()` contract permits one controlled
relaunch.

### Compatibility

Physically validated:

- NextOS R2 on Mali-450, using the current NextOS ARMHF build;
- ArkOS on R36S / Mali-G31, using the low-glibc ARMHF build;
- NextOS on AArch64 X5M / Mali-G310 completed 11,034 gameplay frames and a
  6,213-frame reopen, both RC0, with save create/update/reload, physical
  controls and audio passing. This route requires the scoped Box64 profile
  `DYNAREC=1`, `BIGBLOCK=0`, `SAFEFLAGS=2`; experimental eager mode is not
  used.

The ARMHF route is also structured for PortMaster-class firmware that provides
an ARM hard-float runtime, SDL2 and GLES2/GLES3. Those additional firmware and
device combinations are compatible targets, not claims of physical testing.
The X5M runtime is intentionally rejected on other AArch64 SoCs.

### Install with your own Android data

1. Extract `asm2.zip` into the firmware's ports directory.
2. Put the exact Android 1.2.7d APK (`versionCode 12723`) in
   `asm2_127/gamedata/`.
3. Put the three matching OBB files there too. They may be loose files or
   members of one ZIP, and their external names do not matter.
4. Launch **The Amazing Spider-Man 2**.

NXExtract identifies content instead of trusting names. It validates the exact
APK and OBB hashes, rebuilds a standards-compliant runtime APK from the known
damaged source package, recovers both `libtasm2.so` and `libtasm2-x86.so`
through physical ZIP headers, creates the two offline shop catalogs and
validates all eight outputs before publishing them together.

The rebuilt APK stores its recovered members without compression. This keeps
the result byte-identical across firmware with different zlib versions while
the full 622-member CRC and SHA-256 verification still runs before publication.

An incomplete, wrong, truncated or corrupt input cannot replace working game
data. The owner's source files are never deleted. Updates publish only those
eight generated outputs, so saves, preferences and cache remain untouched.

The first clean run follows the original sequence: legal disclaimer, update
log, the native cloud-data notice, controls, progressive loading and gameplay.
The cloud notice does not mean the game must download data. Once completed,
those first-run screens are not repeated by the newly created profile.

### Controls

| Input | Action |
|---|---|
| Left stick | Move |
| Right stick | Camera |
| R2 | Jump / hold to swing |
| L2 | Special combo |
| X | Attack |
| B | Web |
| Y | Dodge |
| A | Confirm / next dialogue |
| Start | Pause |
| Select + Start | Save and exit |

On the very first run, the first face-button action is converted once into the
touch gesture required by the original legal disclaimer. Later actions remain
normal controller input.

## Português

O loader preserva o ciclo de vida Android original nas duas rotas suportadas:

- a `libtasm2.so` ARMv7 original executa nativamente por loaders separados para
  o NextOS atual e para sistemas ARMHF PortMaster com glibc baixa;
- a rota NextOS AArch64 X5M validada fisicamente (`amlogic,s7d` / Mali-G310)
  executa a biblioteca Android x86 original pelo host Box32 específico e pelo
  `sdl2-compat`. A SDL de compatibilidade empacotada fica restrita ao processo
  do jogo; a interface nativa do NXExtract usa a SDL2/KMSDRM do firmware.

O launcher negocia resolução, SDL, GLES, controles e memória durante a
execução. Sistemas ARMHF mantêm a seleção nativa de backend. As variáveis
KMSDRM exigidas pelo X5M ficam restritas à identificação exata desse aparelho;
nenhum backend de áudio é forçado. Antes de iniciar, o launcher trava uma única
instância, encerra e confirma processos residuais, valida ELF, interpretador,
dependências e hashes, e executa o jogo em primeiro plano.

### Compatibilidade

Validação física concluída no NextOS R2 com Mali-450 e no ArkOS/R36S com
Mali-G31. No NextOS/X5M com Mali-G310, a rota final completou 11.034 frames de
gameplay e 6.213 frames após reabrir, ambos RC0, com criação/atualização/carga
de save, áudio e controle físico aprovados. Ela exige o perfil Box64 restrito
`DYNAREC=1`, `BIGBLOCK=0`, `SAFEFLAGS=2`; o modo eager experimental não é
usado.
A rota ARMHF também foi estruturada
para firmwares da classe PortMaster que forneçam runtime ARM hard-float, SDL2 e
GLES2/GLES3; esses alvos adicionais são compatíveis, mas não são anunciados
como testes físicos. A rota X5M é recusada em outros SoCs AArch64.

### Instalação com seus próprios dados Android

1. Extraia `asm2.zip` na pasta de ports do sistema.
2. Coloque o APK Android 1.2.7d exato (`versionCode 12723`) em
   `asm2_127/gamedata/`.
3. Coloque também os três OBBs correspondentes. Eles podem estar soltos ou
   dentro de um ZIP; os nomes externos não importam.
4. Abra **The Amazing Spider-Man 2**.

O NXExtract reconhece conteúdo em vez de confiar em nomes. Ele valida os hashes
exatos, reconstrói um APK runtime normal a partir do pacote-fonte danificado,
recupera `libtasm2.so` e `libtasm2-x86.so` pelos headers físicos do ZIP, cria
os dois catálogos da loja offline e só publica os oito resultados depois da
validação completa.

O APK reconstruído armazena os membros recuperados sem compressão. Assim o
resultado permanece byte a byte idêntico entre firmwares com versões diferentes
de zlib, mantendo a verificação de CRC e SHA-256 dos 622 membros antes da
publicação.

Dados ausentes, de outra versão, truncados ou corrompidos não substituem uma
instalação funcional. Os arquivos-fonte do dono nunca são apagados. A
atualização troca somente os oito resultados gerados, preservando saves,
preferências e cache.

Na primeira execução, a primeira ação de botão frontal vira uma única vez o
toque exigido pelo disclaimer legal original. As ações seguintes permanecem
controles normais.

Uma instalação limpa segue a ordem original: termos, log de atualização, aviso
nativo de dados na nuvem, controles, carregamento progressivo e gameplay. O
aviso não significa que o jogo precise baixar seus dados e não reaparece após
o perfil novo concluir esse fluxo.

## Licenses / Licenças

The compatibility loader and its helpers are GPL-3.0. NXExtract and Box64 are
MIT; `sdl2-compat` uses the zlib license. Full texts and notices are under
`licenses/`. The adjacent corresponding-source archive reproduces all bundled
GPL/MIT/zlib components. The game and owner-supplied data remain separate
proprietary works of their respective rightsholders.
