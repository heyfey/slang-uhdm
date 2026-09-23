# r11u105 — the top namesake, the program namesake and the interface namesake keep their keys

**Three gated laws in one batch, all on the definition table in
`src/UhdmExporter.cpp`. They extend pass 102's entry re-key
(§ `caDefKeyScopedAtEntry103`) to the roads it did not enter.**

* **LAW A § `caTopNamesakeKeyAtEntry105`** (pass 102's R0). This is the TOP
  road. Take a file-scope module that is itself a TOP and is declared AFTER
  the module whose subtree holds its nested twin. It lost its bare key during
  collection. Pass 102's replay enters only what an INSTANCE reaches, never a
  root, so the root is entered and merged the same way.
* **LAW B § `caProgramNamesakeKeyAtEntry105`** (pass 102's R1). This covers a
  file-scope PROGRAM that shares a nested module's name. It runs on two roads,
  each with its own switch:
  * **UNINST**: the uninstantiated `progTops` entry.
  * **INST**: an instantiated program that `visit103` reaches.
* **LAW C § `caIfaceNamesakeKeyAtEntry105`**. This is the same collision for a
  file-scope INTERFACE. The golden grid (question 3) found it, the same entry
  rule fixes it, and it has its own switch.

Base `17b06e3d`. Pins per `SUPPORT_MATRIX.md`:

* slang upstream `7d61e0ad1`
* UHDM v1.87
* Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog` (`0445655ee7`)
* uhdm2rtlil corpus v0.68

| binary | md5 | image |
|---|---|---|
| pristine (this worktree, `-j 2`) | `4de902181d322e61e932d5a79eebd9c7` (**= the OPS pin** and the main tree's `build/slang-uhdm`) | 23394848 B |
| law (this patch) | `b8e8c23a6916473019f14f514584f349`. The final comment edits leave the md5 unchanged: `law2` = `lawx`. The patch applied to a FRESH `17b06e3d` worktree rebuilds to the same md5. | 23400800 B |
| pad control (pristine + `volatile char[16384]`, NEVER committed) | `b565165376d56607cb472fa6eb33fdea` | 23411288 B |

The only production file is `src/UhdmExporter.cpp`, the definition table.
This pass did **not** touch `src/ModuleEmit.cpp`, `src/ExprEmit.cpp`,
`src/EmitHelpers.h` or `src/ParamEmit.cpp` (the sister pass's ground). It
never wrote `results/*.csv`. It did not edit the landed laws or their
switches (§4).

---

## 1. THE WITNESSES AT `17b06e3d` (`evidence/WITNESS105.txt`)

`k03` and `k14` were not committed by pass 102's verifier. They are rebuilt
here from the brief's text.

* **`k03`**: `dut` instantiates `sub`, and `sub` holds a nested `innermod`.
  A file-scope `innermod (input [3:0] a, output [3:0] b)` is declared AFTER
  `dut`. It is a top that nothing instantiates.
* **`k14`**: a file-scope `program innermod` sits beside `module sub`, which
  holds a nested `module innermod`. `dut` instantiates `sub`.

| arm | pris rc / `uhdm-cmp` / cells / distsec | law rc / `uhdm-cmp` / cells / distsec |
|---|---|---|
| `k03` | **139 (SEGFAULT)**, no database | 0 / **0** / OK 174 / **0** |
| `k14` | 0 / 179 (1 head) / OK 88, GOLD-ONLY 9 (`uhdmallPrograms[0]` and its subtree) / 15 | 0 / **0** / OK 97 / **0** |
| `x15` (RV1, **FENCED**) | 0 / 527 / WRONG 10, GOLD-ONLY 50, OURS-ONLY 78 / 84 | identical, **same bytes** (`f04ba3f80857`) |
| `b15` (carried) | 0 / 0 / OK 178 / 0 | same bytes |
| `b12`, `b14` (pass 102's witnesses) | 0 / 0 / OK 133, OK 178 / 0 | same bytes |
| `a14` (RV1 × pass 102 LAW A) | 0 / 55 / 65 | same bytes |

The k03 segfault, from the pristine binary under gdb:

```
emitPorts ← emitModuleDefPorts ← emitInstance ← exportDesign
```

The top's first instance walk reaches `if (!defMap[&def].filled)`
(`src/ModuleEmit.cpp:11243`). That calls `emitModuleDefPorts`, which reads
`defMap[&def].mod` (`:6195`). It is a default-constructed `DefInfo` because
`defs` never held the definition, so `mod` is null.

## 2. THE DECODE, IN THE PINNED SOURCES

**Golden keys every table on the scoped name from the start.**
`~/git-repos/Surelog/src/DesignCompile/ResolveSymbols.cpp` files entries by
kind:

| declaration | line | call |
|---|---|---|
| module | `:168-201` | `addModuleDefinition(fullName)`; each nested module gets `addModuleDefinition(StrCat(fullName, "::", name))` at `:198` |
| program | `:136-138` | `addProgramDefinition(fullName)`, a SEPARATE table |
| interface | `:205-212` (the default case) | `addModuleDefinition(fullName)` |

Then:

* `CompileDesign.cpp:203` and `:230-232` merge the module map and the
  program map by those names.
* `UhdmWriter.cpp:5043-5069` writes the program map as `AllPrograms`.

A file-scope `work@innermod` can never collide with `work@sub::innermod`,
whatever its kind. Golden lists both in every arm of §3.

**Ours keys `defs` on the bare name and re-keys only after collection.**
r11u99 LAW B1 does that re-key. Collection runs in this order:

1. The tops, in SOURCE order (`orderedTops`, `defs.emplace(name, inst)` at
   `src/UhdmExporter.cpp:4876`), each followed by `collectDefs` of its body.
2. The uninstantiated interfaces (`:5072`, `if (defs.count(...)) continue`).
3. The uninstantiated programs (`progTops`, `:5016`).

The nested implicit instance under `dut` → `sub` takes `innermod` first, so
three things are dropped:

* **a TOP declared later** (LAW A). Its `defs.emplace` fails and its body is
  never collected. Pass 102's replay (`root103`) only WALKS a root and never
  enters it, so the top has no `DefInfo`. With a port, it segfaults (above).
  Without one (k02), the def view is simply missing, 438 `uhdm-cmp` lines.
* **a program** (LAW B). Uninstantiated, it vanishes from `uhdmallPrograms`
  (k14). Instantiated, it loses its `DefInfo` and segfaults exactly like
  LAW A (k17).
* **an interface** (LAW C). It vanishes from `uhdmallInterfaces` (k19, k20).

Every one of these was dropped only because r11u99's re-key had not yet freed
the bare key. **The rule** is the same enter-and-merge that pass 102 applies
to an instantiated module:

* **LAW A.** In `root103` (`src/UhdmExporter.cpp:5431`), enter the root as its
  own representative. That is exactly what an entry-keyed collection picks.
  Then `mergeSub103` its body under the re-keyed keys.
* **LAW B UNINST** (`:5485`). Mirror the `progTops` entry: `unrefDefs` +
  `uninstProgDefs`, then the merge, then walk the body.
* **LAW B INST** (`:5364`, in `visit103`) and **LAW C INST** (`:5380`, in
  `visit103`). Enter the instance exactly like pass 102's `FILEKEY` enters a
  module.
* **LAW C UNINST** (`:5502`). Mirror the uninstantiated-interface producer
  with `createDefault`.

Every law requires three things of the entry: it is file-scope, the bare key
is ABSENT from `defs`, and some nested definition carries that bare name
(`nestedNames103`). A top that PRECEDES its nested twin in source order took
the key at collection and never reaches this rule (`k01`).

**Golden writes nothing on a miss.** Every entry the laws add is one golden
lists. The judge and the distance check this on every arm, including the
fifteen arms whose pristine run is a segfault with no slot to score. Pass
102's library guard, its two refusals and its interface-port admission are
untouched.

## 3. THE GOLDEN GRID (`grid/`, 36 arms; `evidence/GRID105.txt`)

Every arm records `golden_rc` and `ours_rc`. The golden is built once per
arm by the pinned Surelog (`rr103.sh`). Every `golden_rc` is 0. The table
shows `uhdm-cmp` lines `pris → law`; SEGV means pristine rc 139. Every law
arm ends at slot cells all-OK and distsec 0, except the rows marked
pre-existing.

| face | arms | pris → law |
|---|---|---|
| **LAW A**, top namesake AFTER | `k03` ported, `k04` own child, `k05` param, `k06` child shared with `dut`, `k07` two outers, `k10` outer is itself the first top, `k11` child holding its own nested module, `k12` plus an unrelated later top, `k33` top instantiates the outer, `k37` two nested names and two late tops | **SEGV → 0** (all ten) |
| | `k02` portless | 438 → **0** |
| **LAW B** UNINST | `k14`, `k16` declared after, `k22` two outers | 179 / 179 / 224 → **0** |
| | `k15` ported, `k23` ported with the outer as top | 222 / 100 → **8**, the pre-existing ported-program `vpiNetType` face (control `k26`: 8 → 8 on BOTH binaries) |
| **LAW B** INST | `k17`, `k40` instantiated twice | **SEGV → 0**. `k40`'s distsec 24 is the control `k42`'s 24, equal on both binaries: golden writes the second program instance without its `initial`. The judge is blind to it and it is pre-existing. |
| **LAW C** | `k19`, `k27` after, `k28` ported + modport, `k20` instantiated, `k29` passed to an interface port | 180 / 180 / 218 / 259 / 545 → **0** |
| **LAW A × B / C** | `k38` the late top instantiates a program namesake, `k39` late top + uninstantiated program namesake, `k41` the late top instantiates an interface namesake | **SEGV → 0** |
| controls | `k01` top BEFORE, `k08` nested twin ported (no implicit instance), `k09` instantiated after (pass 102), `k18` program without namesake, `k25` interface without namesake, `k35` outer reached only via non-taken generate | 0 → 0, **bytes identical** |
| | package namesake `k21` and its control `k24` | 8 → 8 both (a pre-existing package-parameter `ref_typespec` face; a package is a separate namespace in both tools) |
| | `k26`, `k42` | pre-existing, bytes identical |

The law binary repeated on the grid is byte-identical (36/36).

## 4. THE GATES — five switches, each droppable alone (`evidence/SWITCHES105.txt`)

| switch | face | arms it returns (lawx → tag) |
|---|---|---|
| `R11U105_OFF=1` | all | the 26 law arms. **Every arm of all ten grids (338) is byte-identical to pristine, database and rc.** |
| `R11U105_TOPKEY_OFF=1` | LAW A | k02–k07, k10–k12, k33, k37, **k38**, **k39**, **k41** |
| `R11U105_PROGKEY_OFF=1` | LAW B UNINST | k14–k16, k22, k23, k39 |
| `R11U105_PROGINST_OFF=1` | LAW B INST | k17, k40 |
| `R11U105_IFACEKEY_OFF=1` | LAW C (both halves) | k19, k20, k27–k29 |
| `R11U105_NETDBG=1` | the trace, OUTSIDE every gate | — |

**Why k38 and k41 fall under LAW A's switch.** Their program or interface
namesake is instantiated INSIDE the late top. LAW A's subtree merge enters
it, exactly as an entry-keyed `collectDefs` would. `k39` needs both LAW A and
LAW B UNINST.

**Every other grid reads 0 movers vs law under every tag.** Each switch
returns its arms to the exact pristine bytes and rc. The only exceptions are
arms another law also covers.

**The landed switches still work, identically on both binaries.** This is
measured over the pass-102, pass-98 and pass-100 grids. Each switch's pris
and law columns match, and pris+switch vs lawx+switch has 0 movers:

| landed switch | arms it moves |
|---|---|
| `R11U103_OFF` | 39 |
| `R11U103_FILEKEY_OFF` | 16 |
| `R11U103_FILEKEY_DEFONLY_OFF` | 2 |
| `R11U103_UNELAB_F_OFF` | 12 |
| `R11U103_UNELAB_NI_OFF` | 6 |
| `R11U103_UNELAB_NP_OFF` | 5 |
| `R11U103_UNELAB_LIB_OFF` | 1 |
| `R11U103_UNELAB_IFACE_OFF` | 1 |
| `R11U99_OFF` | 40 |
| `R11U101_OFF` | 22 |
| `R11U99_NESTNAME_OFF` | 36 |

**MOVED-WRONG 0 / AWAY 0, per slot and per entry** (`evidence/SLOTS105.txt`,
pris → law):

| grid | arms | SLOT MOVED-WRONG | GAINED | ENTRY AWAY | CLOSER | distsec pris → law |
|---|---|---|---|---|---|---|
| r11u105 | 36 (21 with a pristine db) | **0** | 198 | **0** | 14 | 346 → 52 (= the pre-existing controls) |
| r11u103 / v11u93 / r11u101 / r11u99 / r11u98 / r11v98 / r11u95 / r11v95 / r11u93 | 39 / 39 / 25 / 27 / 20 / 31 / 35 / 31 / 55 | **0** | 0 | **0** | 0 | unchanged, **bytes identical** |

The fifteen pristine-segfault arms have no pristine slot, since an invented
entry has no slot to lose. The judge and the whole-dump distance vs golden
score them: every one reads `uhdm-cmp` 0 and distsec 0, except k40, whose 24
is its control's.

Two controls back the scorer:

* **Positive control.** The law binary with `R11U99_NESTNAME_OFF=1` reads
  **SLOT MOVED-WRONG=597, ENTRY AWAY=31** (distsec 1279 → 2028) on the r11u99
  grid. That is pass 102's number exactly.
* **Calibration.** Golden vs golden, over two independent pinned-Surelog
  regenerations of this grid: **35 arms, 0 non-OK, distsec 0**.

## 5. THE CENSUS — golden first, then ours, then the source (`evidence/CENSUS105.txt`)

**Database census** (`ct105cen.cpp` + `cen105.py`). It covers every
golden-cache database the sweeps' `cmds.txt` name, and every `slang.uhdm`.
`NAMESAKE` is a nested `work@<outer>::X` together with a file-scope `X` of
kind MOD, TOP, PROG or IFACE: the superset of all three laws.

| corpus | databases | NAMESAKE-GOLD | NAMESAKE-OURS (pris = law) | ENTRY-GOLD-ONLY |
|---|---|---|---|---|
| surelog | 2492 | **0** + 5 seed cells | **0** + 3 seed | **0** + 2 seed, plus one fenced row's refused top, identical on both binaries |
| uhdm2rtlil | 3358 | **0** + 5 seed | **0** + 3 seed | **0** + 2 seed |

The seeds are the positive control: `k03` (TOP + MOD), `k14` and `k17`
(PROG), and `k19` (IFACE). Every one is flagged.

**Source trace** (`cellcen105.py`, the LAW binary, the harness's own argv,
3 workers, fenced tests never dispatched):

| corpus | arms | TOPKEY | PROGKEY | IFACEKEY | NAMESAKE superset |
|---|---|---|---|---|---|
| surelog | 1583 | 2 | 4 | 4 | 10 |
| uhdm2rtlil | 1752 | 2 | 4 | 4 | 10 |

**Every hit is a SEED**: k03, k14, k17, k19 and k20, each in both modes. The
six `rc=-11` replays segfault identically on the pristine binary (replayed):

* surelog: `Rggen`/tf, `Tnoc` both modes
* uhdm2rtlil: `rp32_r5p_degu_soc_top`/tf, `rp32_r5p_mouse_soc_top`/tf,
  `rp32_soc_vfriendly`/tf

None of them has a database.

**PREDICTED MOVERS, by name (`evidence/PREDICT105.txt`): NONE from the laws.**
The uhdm2rtlil byteverify was read before that file was written, and it reads
0 movers regardless. The surelog prediction was written before the patched
surelog sweep was read. It expected only the UVM family's documented
nondeterminism. **The three laws are corpus-invisible.**

## 6. THE CORPUS GATES (`evidence/GATES105.txt`, `evidence/MOVERS105.txt`)

1. **Build.** See the table at the top: pristine = pin = main tree.
2. **Goldens.** Law: `23 PASS / 0 FAIL`. `/bin/false`: `0 / 23`.
3. **uhdm2rtlil, both modes.** All 1742 rows are byte-identical to
   `results/golden_uhdm2rtlil.csv`, and ct8rows PASS vs
   `gate_uhdm2rtlil.csv`. Both binaries read `788 EQ / 16 NE / 67 REJECT` in
   both modes. byteverify: **MOVERS 0 / 1608**, PATH_SETS_IDENTICAL,
   SELFCHECK 1607/1608.
4. **Surelog `--mode both`.** Status equals `results/golden_surelog.csv`:
   `474/9` and `469/8`, and every other count is equal. **No row converts.**
   Only two kinds of row differ from the committed file, and the set is the
   same on BOTH binaries:
   * `Earlgrey_0_1`: the blank dump column, in both modes.
   * `LowMemLib` and `LowMemPkg` testflags: the detail text, which embeds the
     workdir.
5. **byteverify surelog `SELFCHECK=1`.** **MOVERS 4 / 960**, all predicted:
   `MiniAmiq` and `SeqDriver`, in both modes.
   * Each one reads **4 order-blind lines**, one `UINT` + `vpiDecompile`
     line-number pair. This is the documented class.
   * Each has 0 trace sites.
   * **Positive control:** the PRISTINE binary re-run 3× on the sweep argv
     never repeats its own hash. Pristine vs pristine reads the same 4-line
     class.

**cmds.txt audit.** Surelog has 1531 `slang:` lines and uhdm2rtlil 1742 per
workdir. Every one names that workdir's frozen binary. **0 name the main
tree.**

**The seven conversion rows** are all CMP_EQUAL in both modes, and
`Scoreboard`/tf is `SLANG_REJECT`, as committed.

**Canaries.**

* `canaries.sh`: `ok=50 changed=2` on surelog. The two are Earlgrey's blank
  column, and pristine reads the same.
* `canaries.sh`: `ok=8` on u2r testflags and `ok=16` on both modes.
* `ctcan2.sh`: PASS on both corpora.
* `canaudit.sh`: `audited=29 UNCOVERED=0 FENCE-BREACH=0`, PASS.

**Protected databases, law vs pristine, all SAME:**

```
SVSwitch           4842211c4030  both modes   (HARD pin)
YosysVerx          6ccda350c24a  both modes   (HARD pin)
InterfaceModPort   59a365f3ce2c  both modes
Earlgrey_0_1       8bdf25272e08 default / 59d0ee6d10c3 testflags
BlackParrotComplex e3e354129d5a default / 73a10e8217e5 testflags
YosysOldOr         d68e0796d62c  both modes
```

## 7. THE WIDE BOUNDARY (`bnd105.sh` over ALL of `tools/probe`; `evidence/BOUNDARY105.txt`)

```
BOUNDARY listed=4518 processed=4518 moved=23 rc-or-db-anomalies=15
PROCESSED==LISTED
```

| arms | verdict |
|---|---|
| 11 MOVED + 15 RC-DIFF, all `r11u105repro/grid/*` | **THE LAWS.** The set equals the grid's pris → law mover set. The RC-DIFF arms are the pristine segfaults, rc 139 → 0. |
| `r10buvm22`, `r10uvm154`, `r10uvm185/grid185` | **The ADDRESS-DERIVED UINT** (r11u95's R2). Only 8-digit `UINT`/`vpiDecompile` values move, by +4192. **16 KB-PAD POSITIVE CONTROL:** the pad binary moves the SAME cells by exactly **+16384**, and nothing else moves. |
| `r10uvm117`, `r10uvm130`, `r10uvm196/grid196`, `r10v109`, `r10v117`, `r10v130`, `r10v144`, `r10v196/arms`, `r10v209/arms` | **NONDETERMINISM.** Each reads 0 order-blind lines. For `r10uvm130` and `r10v144`, where pristine happened to repeat itself once, 5× repeats per binary show every binary, including pad and `R11U105_OFF`, drawing the others' hashes. |

All 12 non-law movers carry **0** `R11U105` trace lines. One arm,
`r10v226/arms/b13_modportproc`, segfaults on BOTH binaries (the same rc, so
it is not an anomaly).

## 8. RESIDUES (ranked)

1. **R0: pass 102's residues stand.**
   * **R2**, now R0: the def-view content of an unelaborated leaf under a
     parameter override folds to the override's width. This is the content
     emitter's ground.
   * **R3**: the definition view drops a net-decl-assign net with a
     strength.

   Neither is in this pass's definition-table ground.
2. **The ported uninstantiated program's port net carries an extra
   `vpiNetType`** (`k15`, `k23`, control `k26`: 8 lines, 2 OURS-ONLY slots).
   This is pre-existing, general to every ported uninstantiated program, and
   the program cousin of pass 100's R1 (`b09`).
3. **The package parameter's `ref_typespec`** (`k21`, control `k24`, 8
   lines). This is pre-existing and unrelated to namesakes.
4. **Golden omits the `initial` of a program's SECOND instance** (`k40`,
   control `k42`: 13 OURS-ONLY slots, distsec 24). The judge is blind to it.
   It is a golden quirk and is not chased.
5. **RV1, still FENCED** (`x15` 527, `a14` 55; bytes identical).
6. **Unmeasured roads.** Nested PROGRAMS or INTERFACES inside a module
   (`nestedNames103` records every nested definition, but only the
   module-in-module shape was gridded). And a program namesake that is
   unreferenced under an explicit `--top` (the base writes no program
   there at all).

## 9. THE DELIVERABLE AND HOW TO RE-RUN

The patch is a `git diff` vs `17b06e3d`. Its surface is `src/UhdmExporter.cpp`
plus `tools/probe/r11u105repro/`.

```bash
# grids: this pass's + the nine committed control grids, copied into $G (rr103.sh writes into arm dirs)
G=/tmp/<scratch> REPO=. bash tools/probe/r11u105repro/runall105.sh - gold          # goldens once
G=/tmp/<scratch> REPO=. bash tools/probe/r11u105repro/runall105.sh <pristine> pris
G=/tmp/<scratch> REPO=. bash tools/probe/r11u105repro/runall105.sh <law> law2
G=/tmp/<scratch> REPO=. BIN=<law> bash tools/probe/r11u105repro/switches105.sh               # R11U105 tags
G=/tmp/<scratch> REPO=. BIN=<bin> P103=1 PFX=<p|l> GRIDS="..." bash tools/probe/r11u105repro/switches105.sh  # landed tags
(cd $G && bash tools/probe/r11u103repro/cmpgrid103.sh pris law2 <grid>...)
python3 tools/probe/r11u101repro/slot101.py move pris law2 $G/<grid>/*/
python3 tools/probe/r11u101repro/secmove101.py pris law2 $G/<grid>/*/
# census: database (golden first) and source
g++ -O2 -std=c++17 tools/probe/r11u105repro/ct105cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct105cen
python3 tools/probe/r11u105repro/cen105.py ./ct105cen <scratch> <sweep-workdir> --seed <arm-dir>:<tag> ...
python3 tools/probe/r11u105repro/cellcen105.py <repo> surelog|uhdm2rtlil <LAW> <out.tsv> --seed <grid arm dir> ...
# boundary + attribution
bash tools/probe/r11u105repro/bnd105.sh <pristine> <law> <outdir> tools/probe
BND=<outdir> PRIS=<pristine> LAW=<law> bash tools/probe/r11u105repro/attr105.sh <arm-dir>
```

Evidence:
`evidence/{PREDICT105,WITNESS105,GRID105,SLOTS105,SWITCHES105,CENSUS105,GATES105,MOVERS105,BOUNDARY105}.txt`.
