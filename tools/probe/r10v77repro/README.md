# r10v77 — adversarial verification of r10earl77 (§ pkgScopedPortAnyDirVar77)

**VERDICT: ACCEPT AS SHIPPED.** `/tmp/r10earl77.patch` is unchanged; no
`.verified.patch` exists because nothing needed fixing. **MEASUREMENT-ONLY
directory.** The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the judge.
BASE `a1da916`. `results/*.csv` was READ ONLY and is untouched; **no row was
converted**.

Every headline number of the pass reproduced bit-for-bit in fresh worktrees
with binaries this verifier built and froze itself — see `GATES_V77.txt`,
including the two build md5s (`ce2ee168…` pristine, `437c2360…` patched),
`679/50/2` u2r both modes, **0 differing rows on both corpora** (status AND
dump column), byte movers `0/1358` and `3/956`, and the head going
`11664 / 11404 → 90 / 90`, one head each.

## 1. Breaking the law — 10 purpose-built arms, 0 regressions

`varm.sh` builds each arm with Surelog (golden) and with BOTH frozen binaries
in BOTH views, runs the official `uhdm-cmp` on each of the four ours-databases,
and censuses all five. `v77sig.cpp` reads **every** `Nets`/`Variables`/
`Array_nets` entry of every `module_inst`, `gen_scope`, `interface_inst`,
`program` and `package`; `v77port.cpp` reads every PORT with the fields
`ports::Compare` actually reads. **The payload carries every judge-visible
field including TYPESPEC PRESENCE and drops the span; span presence is scored
on its own line.** `vfield.py` then adjudicates, FIELD BY FIELD, every cell
whose payload changed.

| arm | what it attacks |
|---|---|
| `v1_dirtype77.sv` | 18 written type shapes × in/out + 5 inout shapes; 3 instances (2 driven, 1 UNDRIVEN); signed, multi-dim, parameterised-width, scalar, typedef-of-typedef, imported-bare, `$unit`, 2-state, enum, packed struct, `var`, `wire`, `reg` |
| `v2_homes77.sv` | the SAME leaf in module scope, generate-for ×3, generate-if taken **and untaken**, NESTED generate ×2, an INSTANCE ARRAY ×3, an interface and a **program** |
| `v3_types77.sv` | cross-package typedef chains, packed-array-of-typedef, UNPACKED struct typedef, `$unit`, a port **DEFAULT VALUE**, parameterised width |
| `v4_ref77.sv` | `ref` ports (slang-uhdm reports "unsupported constructs: port direction", rc=4, on BOTH binaries — no regression is possible there) |
| `v5_nonansi77.sv` | NON-ANSI everything, incl. a module-LOCAL typedef and a non-ANSI body declaration typed by a scoped typedef |
| `v6_ifmp77.sv` | interface ports and **modports as controls** beside the shape |
| `v7_edge77.sv` | the arm's NEIGHBOURS: a package `reg` typedef, a `$unit` typedef **spelled scoped**, a **TOP-LEVEL** module carrying the shape, real/2-state package typedefs |
| `v8_multiname77.sv` | the SHARED-TYPE-SYNTAX trap: several port names in ONE declaration item, spelled bare and spelled scoped, ANSI and non-ANSI |
| `v9_hosts77.sv` | a **bind** instance, an UNPACKED-ARRAY package typedef port, `default_nettype none` |
| `v10_drive77.sv` | drivenness and connection shape: a **multiply-driven inout** on a `tri`, a CONSTANT actual, an EXPRESSION actual, a part-select actual, and ALL-UNCONNECTED |

**Result, `ARM_SCORES.txt`: across the 10 arms plus the pass's own `g1/g2/g3`
and the two earlier-pass arms `r10earl43repro/a1_earl43.sv` and
`r10earl44repro/a1_earl44.sv`, in BOTH views and BOTH censuses — 48 scored
readings — `AWAY-GOLDEN` is 0 EVERYWHERE and no field verdict is ever
`AWAY-GOLDEN`.** Every cell the law moves moves TO golden, in every home
(module scope, gen-for, gen-if, nested gen, instance array, program, bind,
top level), in every direction (`input`, `output`, `inout`), with and without
`wire`/`var`, ANSI and non-ANSI, driven, multiply driven and undriven.

Two structural traps were tested and did NOT bite:
* **shared type syntax** — the second name of `input h77::v8_t h_pka, h_pkb`
  becomes a variable and the second name of the BARE imported item stays a net,
  both matching golden;
* **top-level modules** — `work@<defname>` is the def listing *and* the top
  instance; golden makes a top module's `input pkg::T` a `logic_var` and the
  patch matches it (`v7`'s `topleafG`, TO-GOLDEN, typespec included).

## 2. The corpus positive control for the SCOPED-SPELLING fence

`PackedArrayHighConn` (surelog, **CMP_EQUAL in both modes**) holds an
ELABORATED cell of exactly this shape — `work@dut.u_dio_pad / pok_i`, a NET
whose port typespec is `pad_pok_t` — and it did **not** move, because the
source spells it `import prim_pad_wrapper_pkg::*; (input pad_pok_t pok_i)`,
BARE. Had the law keyed on "a package typedef port" instead of "a SCOPED
spelling", this CMP_EQUAL row would have broken. The fence is load-bearing and
the corpus proves it.

## 3. Independent census on the real target

`v77sig`/`v77port` on Earlgrey's own databases, both modes, calibrated
golden-vs-golden first (ports 21809/21809, signals 41055/41055 in default):

| | TO-GOLDEN | AWAY | MOVED-WRONG | STILL-WRONG |
|---|---:|---:|---:|---:|
| signals, default | 1 | 0 | 0 | 4 |
| signals, testflags | 1 | 0 | 0 | 4 |
| ports, default | 1 | 0 | 0 | 6 |
| ports, testflags | 1 | 0 | 0 | 6 |

The one is `work@top_earlgrey.u_spi_device.u_fwmode / tx_data_i`; **every one
of its fields goes to golden** (`NET→VAR`, `logic_net→logic_var`, the flag set,
the typespec, and the port's `Low_conn` `ref_obj→logic_var`). Nothing else in
either database moved.

## 4. Corrections to the pass's write-up (none of them change the verdict)

1. **"exactly FOUR divergent signal cells in the whole Earlgrey design" is a
   FIVE.** `sig77.cpp`'s payload is container+kind only, so it is blind to a
   cell whose kind agrees and whose TYPESPEC does not:
   `work@top_earlgrey.u_hmac.u_sha2 / digest` is a `logic_net` on both sides,
   but golden's carries `logic_typespec / hmac_pkg::sha_word_t` and ours is
   ANONYMOUS. Pre-existing on both binaries, untouched by the law.
2. **The grid rows "g2 STILL-WRONG 0" and "g3 STILL-WRONG 1" are undercounts**
   from the same payload: with typespec presence and the net/var flag set in
   the payload they are 3 and 6. All pre-existing, all identical on both
   binaries (`vpiNetType` 1 vs golden's 0 on wire-keyword definition-listing
   ports; typespec-name qualification in bodies).
3. **`PREDICT_MOVERS.txt` STAGE 4 states the wrong mechanism.** Of its eight
   stage-3 rows it says seven are "DEFINITION listings … which this law does
   not touch". But `PackedArrayHighConn`'s row is the ELABORATED instance
   `work@dut.u_dio_pad`, refuted by the SCOPED-SPELLING fence (§2 above), and
   `TypedefInModulePort` / `ImportTypeOfPort` are TOP-LEVEL modules whose
   `work@top` key IS an elaborated instance — they did not move because their
   port is an OUTPUT, which pristine already emitted as a `logic_var`. The
   prediction's OUTCOME (exactly the two Earlgrey databases) is correct; only
   its reasoning is.
4. **Scoreboard/default "170 raw dump lines"** is not a durable number: this
   run measured 92, and the pristine binary differs from ITSELF (three runs,
   two distinct hashes, 0 sorted lines each time).
5. The README's "byte for byte the main tree's own `build/slang-uhdm`" was true
   when the main tree sat at a1da916; it has since advanced.

## 5. Residues this verification adds (ranked; R0 is unchanged and confirmed)

**R0 (confirmed verbatim)** — the `{TotalWidth{1'b1}}` UNDER-fold at
`prim_ram_2p_async_adv.sv:171` in `gen_secded`. The 90-line log this verifier
produced is id-normalised identical to the committed one, one head, both modes.

* **V1 — a package typedef written with the `reg` keyword.**
  `typedef reg [7:0] rg_t;` → `input`/`output pkg::rg_t`: golden `logic_var`,
  ours `logic_net`, BOTH directions, BOTH binaries. `makeVar`'s `regDecl` guard
  blocks the arm before the new disjunct is consulted, and Surelog's ladder
  never consults the keyword for a `paClass_scope` spelling. 0 corpus cells;
  reproduced on `v7_edge77.sv` (`g_reg`/`g_rego`).
* **V2 — a `$unit`-scope typedef SPELLED SCOPED.** `input $unit::uu_t x`:
  golden `logic_var` (with no typespec), ours `logic_net`, both directions.
  `pkgAliasPort` requires a *Package* parent scope, so a CompilationUnit
  typedef never reaches the arm even when written with `::`. 0 corpus cells;
  `v7_edge77.sv` (`g_unitsc`/`g_unitsco`).
* **V3 — typespec NAME qualification.** When the package typedef's own target
  is itself a typedef (typedef-of-typedef, cross-package forward,
  packed-array-of-typedef) or a bare `logic` scalar, our `logic_typespec` is
  named BARE (`fwd_t`) where golden names it `mid77::fwd_t`. **Pre-existing and
  symmetric** — the already-var OUTPUT twins carry it identically on the
  pristine binary — but it is what turns 5 of `g1`'s 20 moved cells and 6 of
  `v1`/`v3`'s into MOVED-WRONG once the payload carries the typespec.
* **V4 — R1 (the interface-port twin) reproduced independently.** Golden makes
  an interface's `input pkg::T` a `logic_var`; both binaries leave a net
  (`v2_homes77.sv work@topB.u_if/if_in`, `v6`, `g3`). The single `portBacked=
  true` call site is `ModuleEmit.cpp:7702`; the interface site
  (`ModuleEmit.cpp:27350`) passes `portBacked=false`, so the law cannot reach
  it. Recording, not widening — agrees with the pass.

## 6. Reproducing

```bash
g++ -O2 -std=c++17 v77sig.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o v77sig      # and v77port.cpp
bash varm.sh v1_dirtype77.sv <outdir>                  # needs the frozen bins
python3 vscore.py sig  <outdir>/{g,o,q}.sig
python3 vfield.py port <outdir>/{g,o,q}.port
```
