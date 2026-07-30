# X5M Box32 runtime provenance

This component is selected only for an AArch64 NextOS host whose device tree
contains the tested `amlogic, s7d` compatible value. It is not a general
Box32 runtime for other devices or older distributions.

`box64` is Box64 built with `BOX32=ON` from upstream commit
`3ec5de03c786333ed8d5a51c5b35a8bd6e22b229`, plus a bounded downstream
patch to `src/custommmap.c`, `src/tools/box64stack.c` and the audited SDL2
wrapper declarations. The patch keeps guest-visible state below 4 GiB,
allows native Mali/DRM mappings above 4 GiB and incrementally exposes the
audited SDL imports used by the i386 loader. The exact downstream patch is
SHA-256
`4d1042b5fadd1a5ad16b47882c62d79aae12f10c450ede84b81bf079f3ef6ad7`.
Box32 v6 passed three repeated 256-cycle condition-variable stress runs. The
final scoped profile explicitly uses `BOX64_DYNAREC=1`,
`BOX64_DYNAREC_BIGBLOCK=0` and `BOX64_DYNAREC_SAFEFLAGS=2`; experimental eager
mode is excluded. On the real X5M it completed 11,034 gameplay frames and a
6,213-frame reopen, both RC0, with save create/update/reload, physical controls
and audio all passing.
Box64 is under the MIT license preserved in `licenses/Box64-MIT.txt`.

`native/libSDL2-2.0.so.0` is sdl2-compat 2.32.71
development source from upstream commit
`3e1fa90d301428ace65d5c8b371e93d2c59c3d65`, built as AArch64 against the
NextOS system SDL3. The embedded string `SDL-2.32.71-gacc2cc1` is retained as
a binary observation only: `acc2cc1` was the surrounding parent-tree revision
seen by CMake and is not an sdl2-compat upstream commit. Its zlib license is
preserved in `licenses/SDL2-compat-zlib.txt`.

Exact public runtime files:

| Path | Size | SHA-256 |
| --- | ---: | --- |
| `runtime/x5m/box64` | 25,720,640 | `48571604ccfb9399c6abba06349887d724dd23b5e8d80d4ac129c3acc39e405e` |
| `runtime/x5m/native/libSDL2-2.0.so.0` | 467,752 | `eae4f55286eb9f888302878fa18d6a9d21f61bee9e1678d0991fa25f6ac207d5` |
| `asm2_127_x86_box32` | 208,856 | `4c5b49ca7639ca7bbea4433793fb8defecd63c1ec304feb9703002a9000fc86d` |

The game library `libtasm2-x86.so` is proprietary and is not included. The
owner-data extractor creates it from the user's validated Android 1.2.7d APK.

The sdl2-compat bytes above remain frozen. The earlier i386 loader
with SHA-256
`fd6b48f4d89b1b9ff67af2cb34a67a4e61d7259eed34e52c781ff91a85481b8d`
is explicitly rejected because its lazy resolver entered C with incorrect
i386 stack alignment. The packaged `4c5b49...` loader corrects that ABI
boundary and is valid only with the exact scoped profile above. Corresponding
source integration, reinstall/update preservation and clean ARM regression
remain gates for the universal release as a whole.
