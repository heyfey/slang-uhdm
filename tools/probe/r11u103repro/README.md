# r11u103 — the definition table's file-scope half is keyed at entry, and a body nobody elaborates still fills its children's ports

**Two gated laws in one batch. LAW A is pass 100's R0: a nested definition
takes the BARE key from a same-named file-scope module, and that module
loses its definition. LAW B is pass 100's R2: a module reached only through
a body that no instance walk elaborates has no ports in its def view. LAW B
runs on three roads, and each road has its own switch.**

**LAW A § `caNestedModFileScopeKeyAtEntry103`.** Our collection keys `defs`
on the bare name. When the walk reaches a nested `innermod` before the
file-scope one, the file-scope `work@innermod` finds its key taken and is
dropped along with its subtree. LAW A replays the collection walk in the
same order, keyed the way golden keys it. It enters every file-scope module
that an instance reaches and the table lacks. The first instance it meets is
the representative. A definition-only half (its own switch) offers the same
module to `addDefOnlyModule` again once the rekey has freed the key. This
covers a module that is unreferenced under `--top`, or reached only from a
non-taken generate branch.

**LAW B § `caUnelabBodyChildPorts103`.** Take a definition whose
representative sits under a body the instance walk never enters. LAW B puts
it in `unrefDefs`, so the write-phase fallback fills its port phase. That
fallback keeps its `!filled` guard. The three roads are:

* **F**: under an `addDefOnlyModule` root.
* **NI**: under slang's implicit nested instance, which r11u99's B2 declines
  to elaborate.
* **NP**: under a nested shell that r11u101 minted.

Two refusals keep the base shell as it is: a library-unit definition, and an
interface-ported one. Each refusal is its own switch.

Base `04a01cc6`. Pins per `SUPPORT_MATRIX.md`:

* slang upstream `7d61e0ad1`
* UHDM v1.87
* Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog` (`0445655ee7`)
* uhdm2rtlil corpus v0.68

| binary | md5 | image |
|---|---|---|
| pristine (this worktree, `-j 2`) | `98cd461118148e66b6fa6083d6137034` (**= the OPS pin**) | 23367608 B |
| law (this patch) | `e7f4bfcaa17a47d0ea25eab08a5e33b7`. The patch applied to a FRESH `04a01cc6` worktree rebuilds to the same md5. | 23377800 B |
| pad control (pristine + `volatile char[16384]`, NEVER committed) | `e00ff4aefb4576dfac12b0aaa1bada12` | 23384040 B |

The only production file is `src/UhdmExporter.cpp`, the definition table
and its write-phase fallback. This pass did **not** touch
`src/ParamEmit.cpp`, `src/EmitHelpers.h`, `src/ExprEmit.cpp` or
`src/ModuleEmit.cpp`. It never wrote `results/*.csv`. It did not edit the
landed laws: r11u99's ten nested and interface laws, r11u101's LAW A, LAW B
and shadow face, and the verifier's library guard
§ `caNestedModLibUnusedNoDef101V`. Their switches still work.

---

## 1. THE WITNESSES AT `04a01cc6` (`evidence/WITNESS103.txt`)

`uhdm-cmp` lines are given with `heads` (`grep -c '^LHS:'`). The slot cells
come from `slot101.py score`, and the whole-dump distance is `slot101.py distsec`.

| arm | pris | law | pris cells (non-OK) | distsec pris → law |
|---|---|---|---|---|
| `v11u93/b12_shadowtopportless` | 458 (1 head) | **0** | GOLD-ONLY 18, WRONG 5, OURS-ONLY 7: `uhdmallModules[1] gold=work@innermod ours=work@sub`, and every later slot shifts | 18 → **0** |
| `v11u93/b14_rv2shadow3` | 616 | **0** | GOLD-ONLY 11: `uhdmallModules[5] gold=work@innermod` plus `work@dut`'s `ref_module u_f` `vpiActual` | 18 → **0** |
| `r11u101/x19_nestportchild` | 55 | **0** | GOLD-ONLY 11: `work@leaf/vpiPort[0]` and its subtree | 19 → **0** |
| `r11u101/x25_rv2childport` | 55 | **0** | GOLD-ONLY 11: `work@leaf/vpiPort[0]` | 19 → **0** |
| `v11u93/b23_childparamnodef` | 75 | **0** | GOLD-ONLY 11: `work@leafp/vpiPort[0]` | 19 → **0** |
| `v11u93/b15_bodyparamported` (carried) | 0 | 0 | all-OK (178) | 0 → 0, byte-identical |
| `r11u101/x15_shadowinst` (**RV1, FENCED**) | 527 | 527 | 10 WRONG / 50 GOLD-ONLY / 78 OURS-ONLY, all in `uhdmtopModules` | 84 → 84, **byte-identical** |
| `r11u101/x23`, `x24` (controls, pass-98 and file-scope roads) | 55, 55 | **0, 0** | GOLD-ONLY 11 each | 19 → **0** each |

## 2. THE DECODE, IN THE PINNED SOURCES

**Golden's two-entry listing (b12).** Golden lists
`[work@dut, work@innermod, work@sub, work@sub::innermod]`:

* The file-scope `work@innermod` hangs off the design and holds `f`.
* The nested `work@sub::innermod` hangs off `work@sub` and holds `n`.
* `work@dut`'s `ref_module work@innermod (u_f)` carries `vpiActual` → the
  file-scope def.

Each entry has its own shell. The key is scoped from the start:

* `~/git-repos/Surelog/src/DesignCompile/ResolveSymbols.cpp:168-201` files
  a file-scope module under `fullName` and a nested one under
  `StrCat(fullName, "::", name)`.
* `CompileDesign.cpp:200-206` merges every file's definitions by that name.
* `include/Surelog/Common/Containers.h:26-27` makes
  `ModuleNameModuleDefinitionMap` a name-keyed `std::map`.

So `work@innermod` and `work@sub::innermod` cannot collide.

Ours keys on the bare name (`collectDefs`, `src/EmitHelpers.h:2066`) and
re-keys only after collection (r11u99's LAW B1). `sub`'s implicit instance
comes first in the walk and takes `innermod`, so `dut`'s `u_f` finds the key
held. On pristine, this collision **SEGFAULTS** in every grid arm where
the dropped file-scope module has a port (six arms, §3: ported, instantiated
twice, owning a child, arrayed, parameterized, and x15's RV1 shape).

**The unelaborated roads (x19/x23/x24/x25/b23).** Golden compiles every
`ModuleDefinition` (`CompileDesign.cpp:349-352`, `FunctorCompileModule`),
instantiated or not. So `work@leaf`'s shell is the ordinary one:

* a `port` with `vpiDirection`
* `vpiLowConn` `ref_obj` → the port's `logic_net`
* `vpiTypedef` `ref_typespec` → `logic_typespec`
* for `b23`, the parameter `K` with an `int_typespec` and a `param_assign`
  holding only `vpiLhs`

This is the same shell every other def view has, and the one our write-phase
fallback writes (`src/UhdmExporter.cpp:7372`). Our port phase runs only when
the instance walk first reaches a definition, or in that fallback for
`unrefDefs`. A definition whose representative sits under a body the walk
never enters gets neither. Three kinds of body are never entered:

* an `addDefOnlyModule` `createDefault` root
* slang's implicit nested instance, which r11u99's B2 declines to elaborate
  (`src/ModuleEmit.cpp:14170` fills only that instance's OWN port phase)
* a shell that r11u101's LAW A minted

**Golden writes nothing on a miss: the two refusals.**

* **Library.** `UhdmWriter.cpp:5108-5118` drops a library-file definition
  that the elaborated tree does not use. A library `leaf` reached only
  through an unelaborated body (`b13_F_lib`) is an entry golden LACKS. The
  base already writes it (pre-existing). Filling its ports would widen an
  invented entry: judge 392 → 413, ENTRY AWAY 1, and the slot scorer is
  blind to it. It stays as the base writes it.
* **Interface port.** `b10_F_ifaceport`, filled, binds the interface port's
  `vpiLowConn` to the `interface_inst` where golden binds a `logic_net`, and
  it writes no `interface_typespec`. That is a guessed value, so the
  file-scope road's admission rule (no interface ports) is kept.

**`implicitNestedInst99` also matches r11u101's minted shell.** A
`createDefault` instance sits at its definition's location under its
definition's name (`src/ModuleEmit.cpp:2369`). So the road test checks the
definition-only root first. Without that ordering the NP road read as NI,
and its switch dropped nothing.

## 3. THE GOLDEN GRID (`grid/`, 39 arms; `evidence/GRID103.txt`)

Every arm records `golden_rc` and `ours_rc`. The golden is built once per
arm by the pinned Surelog (`rr103.sh`). The table shows `uhdm-cmp` lines
`pris → law`; SEGV means pristine rc 139.

| face | arms | pris → law |
|---|---|---|
| **LAW A**, instantiated file-scope namesake | `a02` ported, `a03` twice, `a04` own child, `a06` array, `a08` param override | **SEGV → 0** (all five) |
| | `a05` taken generate, `a09` two implicit outers, `a10` via a later module, `a13` under a common mid, `a15` `-v` library (a used library cell), `a17` namesake nested 2 deep | 510 / 548 / 508 / 508 / 461 / 430 → **0** |
| **LAW A**, def-only half | `a11` unreferenced under `--top`, `a12` non-taken generate only | 340 / 388 → **0** |
| **LAW A × road F** | `a16` file-scope instance inside a gen-only module | 502 → **0** |
| **LAW A × road NI** | `e01` | 587 → **0** |
| **road F** | `b01` in/out/inout, `b02` non-ANSI, `b04` param without default, `b05` chain, `b06` instance array, `b08` unreferenced top, `b11` unpacked port, `b12` + interface sibling | 127 / 61 / 75 / 55 / 55 / 55 / 87 / 55 → **0** |
| **road NI** | `c02` chain, `c05` two positional ports | 55 / 83 → **0** |
| **road NP** | `d02` chain | 55 → **0** |
| param-overridden leaf | `b03` (F), `c01` (NI), `d01` (NP), `d03` (NP) | 91 → **18** each |
| struct-typed port | `b09` (F) | 15 → 15 |
| **refusal** library | `b13_F_lib` | 392 → 392 (**bytes = pristine**) |
| **refusal** interface port | `b10_F_ifaceport` | 90 → 90 (**bytes = pristine**) |
| **RV1 × LAW A** (fenced face) | `a14_nestexplicit` | **SEGV → 55** |
| controls | `a01` (r11u101 shadow road, file-scope first), `a07` (ported nested, no collision at entry), `b07` (leaf also elaborated), `c03`/`c04` (NI leaf also elaborated after/before) | 0 / 0 / 0 / 8 / 0, **byte-identical** |

**The residues after the law are pre-existing faces the laws uncover. None
is a move away.**

* The `18` arms. The def-only content of a leaf whose representative
  carries a parameter override writes `'0` with `vpiSize` 6, where golden
  writes -1. This is WRONG on pristine too, 1 slot.
* `b09` is pass 100's R1, the extra `vpiNetType` on a struct-typed port net
  (caution d). It is recorded, not chased.
* `a14` is **x15's fenced RV1 face**. Its definition table now equals
  golden's four entries. The remaining 63 display-free lines are all in
  `uhdmtopModules`, where golden elaborates the file-scope body under `sub`'s
  written `innermod u_i ()`. The elaborated-name site is not edited.

## 4. THE GATES — seven switches, each droppable alone

| switch | face | arms it drops (lawx → tag) |
|---|---|---|
| `R11U103_OFF=1` | all | every law arm. **All 302 arms of the nine grids are byte-identical to pristine, every database and every rc.** |
| `R11U103_FILEKEY_OFF=1` | LAW A, instantiated half | a02–a06, a08–a10, a13–a17, e01, **b12**, **b14** |
| `R11U103_FILEKEY_DEFONLY_OFF=1` | LAW A, def-only half | a11, a12 |
| `R11U103_UNELAB_F_OFF=1` | road F | **x24**, a16, b01–b06, b08, b09, b11, b12 |
| `R11U103_UNELAB_NI_OFF=1` | road NI | **x23**, **x25**, c01, c02, c05, e01 |
| `R11U103_UNELAB_NP_OFF=1` | road NP | **x19**, **b23**, d01–d03 |
| `R11U103_UNELAB_LIB_OFF=1` | drops the library refusal | b13_F_lib (392 → 413, ENTRY AWAY 1) |
| `R11U103_UNELAB_IFACE_OFF=1` | drops the interface refusal | b10_F_ifaceport (90 → 4, one WRONG `vpiActual` slot) |
| `R11U103_NETDBG=1` | the trace, OUTSIDE every gate | — |

**MOVED-WRONG 0 / AWAY 0, per slot and per entry** (`evidence/SLOTS103.txt`,
pris → lawx):

| grid | arms | SLOT MOVED-WRONG | GAINED | ENTRY AWAY | CLOSER | distsec pris → law |
|---|---|---|---|---|---|---|
| r11u103 | 39 | **0** | 593 | **0** | 37 | 806 → 84 |
| r11u101 | 25 | **0** | 44 | **0** | 4 | 249 → 173 |
| v11u93 | 39 | **0** | 45 | **0** | 5 | 145 → 90 |
| r11u99 / r11u98 / r11v98 / r11u95 / r11v95 / r11u93 | 27 / 20 / 31 / 35 / 31 / 55 | **0** | 0 | **0** | 0 | unchanged, **bytes identical** |

The table has three controls:

* **Every switch tag reads MOVED-WRONG 0.** The only ENTRY AWAY anywhere is
  `lbof` (the library refusal dropped): `b13_F_lib`, which the slot scorer
  cannot see.
* **Positive control.** The law binary run with `R11U99_NESTNAME_OFF=1`,
  which drops pass 98's LANDED scoped name, reads **SLOT MOVED-WRONG=597,
  ENTRY AWAY=31** (distsec 1279 → 2028) on the r11u99 grid. This was
  measured on the pre-final build `law4`, which is byte-identical to lawx on
  all 302 arms.
* **Calibration.** Golden vs golden, over two independent pinned-Surelog
  regenerations: **78 paired arms, 0 non-OK slots, distsec 0**.

The law binary is byte-deterministic on a repeat (build `law4`, which is
byte-identical to lawx on all 302 arms): 103/103 databases of the three
moving grids.

## 5. THE CENSUS — golden first, then the roots, then the source (`evidence/CENSUS103.txt`)

**Database census** (`ct103cen.cpp` + `cen103.py`) over every golden-cache
database the pristine sweeps' `cmds.txt` name, and every `slang.uhdm`:

| corpus | goldens | ours | NAMESAKE-GOLD | NAMESAKE-OURS | ENTRY-GOLD-ONLY | PORTS-GOLD-ONLY |
|---|---|---|---|---|---|---|
| surelog | 1531 + 5 seeds | 960 + 5 | **0** + 2 seeds | 0 | **0** + 2 seeds | **0** + 3 seeds |
| uhdm2rtlil | 1742 + 5 | 1608 + 5 | **0** + 2 | 0 | **0** + 2 | **0** + 3 |

**Seeds.** The seeds are `b12` and `a11` (LAW A) and `x24`, `x23` and `x19`
(the three roads). They are dispatched exactly like corpus cells, and every
one is flagged. On the LAW sweeps the seeds' cells clear (ENTRY-GOLD-ONLY 0,
PORTS-GOLD-ONLY 0), and NAMESAKE-OURS matches NAMESAKE-GOLD.

**No corpus golden publishes a file-scope/nested namesake pair.** No paired
corpus cell has a golden entry that holds ports where ours holds none.

**Source trace** (`cellcen103.py`, the LAW binary, the harness's own argv,
FENCED never dispatched). Surelog runs 1581 arms and uhdm2rtlil 1750.

* `NAMESAKE` (LAW A's superset), `FILEKEY`, `FILEKEY-DEFONLY` and every
  `UNELAB` road read **0 on the corpus**. Every hit is a seed.
* The six `rc=-11` replay arms segfault with the base binary as well, as the
  verifier recorded: `Rggen`/testflags, `Tnoc` both modes, and
  `rp32_r5p_degu_soc_top`, `rp32_r5p_mouse_soc_top` and `rp32_soc_vfriendly`
  in testflags. None has a database in either sweep or in the committed CSVs.

**PREDICTED MOVERS, by name, before the patched sweeps were read: NONE from
the laws.** The only expected movers were the UVM family's documented
nondeterminism. **The laws are corpus-invisible.**

## 6. THE CORPUS GATES (`evidence/GATES103.txt`, `evidence/MOVERS103.txt`)

1. **Build.** See the table at the top: the pristine binary equals the pin,
   and the fresh-worktree rebuild reproduces the law md5.
2. **Goldens.** Law: `23 PASS / 0 FAIL`. `SLANG_UHDM=/bin/false`:
   `0 PASS / 23 FAIL`.
3. **uhdm2rtlil `--mode both`.** Every one of the 1742 rows is
   byte-identical to `results/golden_uhdm2rtlil.csv`. The testflags rows
   match `results/gate_uhdm2rtlil.csv` on 871/871, and law equals pristine.
   Both modes read `788 EQ / 16 NE / 67 SLANG_REJECT`. byteverify:
   `PATH_SETS_IDENTICAL (1608)`, **MOVERS 0 / 1608**, SELFCHECK 1607/1608.
4. **Surelog `--mode both`.** Status is identical to
   `results/golden_surelog.csv`: `default 474 EQ / 9 NE`,
   `testflags 469 EQ / 8 NE`, and every other count equal. **No row
   converts.** Only two kinds of row differ, and each shows on BOTH binaries:
   * `LowMemLib` and `LowMemPkg` testflags differ in detail TEXT only
     (`SURELOG_FAIL`, whose log line embeds the workdir).
   * `Earlgrey_0_1` reads a blank dump column in both modes, the documented
     `uhdm-dump` timeout draw. Its DATABASE pins hold.

   Law vs pristine differs only in the LowMem workdir text.
5. **byteverify surelog `SELFCHECK=1`.** `PATH_SETS_IDENTICAL (960)`,
   **MOVERS 3 / 960**, SELFCHECK 959/960. All three are the documented
   class, attributed order-blind:
   * `default/MiniAmiq` and `testflags/MiniAmiq`: 4 lines each, the
     `UINT`/`vpiDecompile` line-number pair.
   * `default/Scoreboard`: **0** lines, an order coin.

   All three carry 0 trace sites. **Positive control:** the PRISTINE binary
   re-run twice draws the LAW sweep's exact hashes for
   `testflags/MiniAmiq` (`27419f6011b4`) and `default/Scoreboard`
   (`e70775324004`).
   **The seven conversion rows are all CMP_EQUAL in both modes:**
   `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`, `SimpleUVM`, `Earlgrey_0_1`,
   `InterfaceModPort` and `Scoreboard`/default. `Scoreboard`/testflags is
   `SLANG_REJECT`, as committed.

**cmds.txt audit.** Surelog has 1531 `slang:` lines per workdir and
uhdm2rtlil 1742. Every one names that workdir's frozen binary. **0 name the
main tree.**

**Canaries.** This battery is copied from `r10uvm221repro`, the current
generation:

* `canaries.sh`: `ok=50 changed=2` on Surelog. The two changes are
  `Earlgrey_0_1`'s blank dump column, identical on pristine.
* `canaries.sh`: `ok=8` on uhdm2rtlil testflags and `ok=16` on both modes.
* `ctcan2.sh`: **PASS** on both corpora.
* `canaudit.sh`: `audited=29 UNCOVERED=0 FENCE-BREACH=0`, PASS.

The protected databases, law vs pristine, **all SAME**:

```
SVSwitch           4842211c4030  both modes   (HARD pin)
YosysVerx          6ccda350c24a  both modes   (HARD pin)
InterfaceModPort   59a365f3ce2c  both modes   (watched byte-for-byte)
Earlgrey_0_1       8bdf25272e08 default / 59d0ee6d10c3 testflags
BlackParrotComplex e3e354129d5a default / 73a10e8217e5 testflags
YosysOldOr         d68e0796d62c  both modes
```

## 7. THE WIDE BOUNDARY (`bnd103.sh` over ALL of `tools/probe`; `evidence/BOUNDARY103.txt`)

```
BOUNDARY listed=4480 processed=4480 moved=45 rc-or-db-anomalies=6
PROCESSED==LISTED
```

| arms | verdict |
|---|---|
| 25 MOVED + 6 RC-DIFF × `r11u103repro/grid/*` | **THE LAWS.** The RC-DIFF arms are the six pristine SEGFAULTS (a02–a04, a06, a08, a14), rc 139 → 0. |
| `r11u101repro/grid/{x19,x23,x24,x25}`, `v11u93repro/grid/{b12,b14,b23}` | **THE LAWS.** These are the brief's witnesses (§1). |
| `r11v58repro/grid/va22_deadnest` | **A LAW ARM (road F)**, trace 1: `deep` ← `mid` ← `if (0)`. Measured against the pinned golden it goes from **96 lines to CMP_EQUAL**, with SLOT MOVED-WRONG 0, GAINED 11, and distsec 23 → 4. It moves TOWARD golden. |
| `r10uvm117`, `r10uvm130`, `r10uvm203/grid203`, `r10v109`, `r10v117`, `r10v130`, `r10v144`, `r10v209/arms` | **NONDETERMINISM.** Pristine disagrees with itself (`SELF-NONDET`), and there are 0 order-blind lines. |
| `r10v196/arms` | **NONDETERMINISM**, drawn on the law side: 0 order-blind lines. Each binary, repeated 3×, draws the other's hash. |
| `r10buvm22`, `r10uvm154`, `r10uvm185/grid185` | **The ADDRESS-DERIVED UINT** (r11u95's R2). Only 8-digit `UINT`/`vpiDecompile` values move, by +12448. **16 KB-PAD POSITIVE CONTROL:** the pad binary moves the SAME cells by exactly **+16384** and nothing else. |

All the non-law movers carry **0** `R11U103` FILEKEY/UNELAB trace lines.
Of the 4480 arms, one segfaults on both binaries (same rc, so it is not an
anomaly).

## 8. RESIDUES (ranked)

1. **The def-view content of an unelaborated leaf whose representative
   carries a parameter override: R0.** It shows in `b03`, `c01`, `d01` and
   `d03`, 18 lines each. The body folds `'0` to the override's width
   (`vpiSize` 6 where golden writes -1). This is pre-existing: it is 1 WRONG
   slot on pristine as well. The whole content is emitted from the
   representative's elaborated body. The fix would emit a def-only
   representative, via `createDefault`, as the def view. That sits on the
   content emitter (ModuleEmit/ExprEmit ground).
2. **RV1, still FENCED.** It shows in `x15` (527) and in `a14`, where this
   pass turns a pristine SEGFAULT into 55 lines. The definition table now
   matches golden's. Golden elaborates the FILE-SCOPE body under an
   instantiation written inside `sub`.
3. **The interface-ported unelaborated child (`b10`, refused, 90).** Filled,
   it reads 4 lines, which is one `vpiLowConn` `vpiActual` kind and one
   missing `interface_typespec`. The def-only interface-port path is still
   unmeasured, so the file-scope admission rule is kept. Widening both roads
   together is the right unit (r11u101's residue 2 is the same boundary).
4. **The extra `vpiNetType` on a struct-typed port net** (`b09`, pass 100's
   R1). This is pre-existing and recorded.
5. **The library-unit leaf reached only through an unelaborated body**
   (`b13_F_lib`). Golden has NO such entry and the base binary writes one.
   That is a pre-existing invented entry, which this pass leaves exactly as
   the base writes it.

## 9. THE DELIVERABLE AND HOW TO RE-RUN

The patch is a `git diff` vs `04a01cc6`. Its surface is `src/UhdmExporter.cpp`
plus `tools/probe/r11u103repro/`.

```bash
# the grids (run on COPIES; rr103.sh writes into the arm dirs)
for g in r11u103repro v11u93repro r11u101repro r11u99repro r11u98repro r11v98repro r11u95repro r11v95repro r11u93repro; do
  cp -r tools/probe/$g/grid /tmp/g/$g; done
GRID=/tmp/g/<grid> bash tools/probe/r11u103repro/rr103.sh <binary> <tag>     # per grid; golden once per arm
LAW=<law> bash tools/probe/r11u103repro/switches103.sh /tmp/g/*              # every switch tag
bash tools/probe/r11u103repro/cmpgrid103.sh <tagA> <tagB> /tmp/g/<grid>...   # per-arm movers + totals
python3 tools/probe/r11u101repro/slot101.py move <tagA> <tagB> /tmp/g/<grid>/*/
python3 tools/probe/r11u101repro/secmove101.py <tagA> <tagB> /tmp/g/<grid>/*/
# census: database (golden first) and source
g++ -O2 -std=c++17 tools/probe/r11u103repro/ct103cen.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct103cen
python3 tools/probe/r11u103repro/cen103.py ./ct103cen <scratch> <sweep-workdir> --seed <arm-dir>:<tag> ...
python3 tools/probe/r11u103repro/cellcen103.py <repo> surelog|uhdm2rtlil <LAW> <out.tsv> --seed <arm-dir> ...
# boundary + attribution + same-binary repeat
bash tools/probe/r11u103repro/bnd103.sh <pristine> <law> <outdir> tools/probe
BND=<outdir> PRIS=<pristine> LAW=<law> bash tools/probe/r11u103repro/attr103.sh <arm-dir>
REPO=. python3 tools/probe/r11u103repro/selfrep103.py surelog <workdir> <scratch> <binary> 2 -- MiniAmiq/default ...
```

Evidence: `evidence/{WITNESS103,GRID103,SLOTS103,CENSUS103,GATES103,MOVERS103,BOUNDARY103}.txt`.
