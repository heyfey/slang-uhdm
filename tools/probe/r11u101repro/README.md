# r11u101 — every one-level nested module definition is published, ported or not, under its own scoped key

**TWO GATED LAWS AND ONE SPLIT-OFF FACE, ONE BATCH. The brief's LAW A is
pass 98's R0 (a nested module with a port or a parameter). The brief's LAW B
is pass 98's verifier residue RV2 (two outers declaring nested modules of the
same name). The shadow face is RV2's special case: the losing entry of the
collision is a FILE-SCOPE module. It gets its own switch.**

**LAW A § `caNestedModPortedDefShell101`.** A module declared inside a
module that has a port or a parameter gets a full def view
`work@<outer>::<inner>`. We build the shell the way `addDefOnlyModule`
builds an unreferenced file-scope module, and under the same admission rule:
every parameter has a default and there is no interface port.
**LAW B § `caNestedModDefKeyScoped101`.** A nested definition that lost a
bare-name collision in the `defs` table is re-entered under its scoped key,
together with the subtree that was dropped with it.
**SHADOW (`R11U101_NESTSHADOW_OFF`).** This is the same two roads when the
bare name also names a FILE-SCOPE definition. The switch drops only this
face.

Base commit `e29d5182`. Pins per `SUPPORT_MATRIX.md`: slang upstream
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 at
`~/git-repos/Surelog/build/bin/surelog` (the canonical golden producer that
`scripts/verify_golden.py` names), and uhdm2rtlil corpus v0.68.

| binary | md5 | image | what |
|---|---|---|---|
| pristine | `c566d68304a691a704d2d4f80493ad79` | 23356600 B | built in this pass's worktree at `e29d5182`. **Byte-identical to the OPS pin.** |
| law | `1b79bf536de130c3c2640e68519803b9` | 23367272 B | this patch |
| pad control | `7d70ad11cf8403503ae860a7fbac7453` | 23373016 B | pristine plus a 16 KB initialised array, with NO law code (§6). Never committed. |

Both sweep binaries were frozen with `chmod 555` at immutable paths before
any sweep. Every `cmds.txt` was audited by absolute binary path (§5):
**0 name the main tree**. `src/ParamEmit.cpp`, `src/EmitHelpers.h`,
`src/ExprEmit.cpp` and `src/ModuleEmit.cpp` are **untouched**. The patch's
only production file is `src/UhdmExporter.cpp`, the definition table.
`results/*.csv` were never written.

---

## 1. THE WITNESSES AT `e29d5182`

We re-ran them with this pass's own binaries. `uhdm-cmp` line counts are
shown, with the first head (`grep -c '^LHS:'` = 1 each). The cells come from
the positional slot scorer `slot101.py`: one slot per object and attribute,
keyed `(field, index)` from the design root, with vpiFullName and spans
excluded.

| arm | pristine | law | the cells at the base |
|---|---|---|---|
| `r11u99repro/grid/w23_modinnerport` | **444** | **0** | `GOLD-ONLY uhdmallModules[2] gold=module_inst:work@sub::innermod` (30 gold-only slots in all) |
| `r11u99repro/grid/w24_modinnerparam` | **446** | **0** | `GOLD-ONLY uhdmallModules[2] gold=module_inst:work@sub::innermod` (30) |
| `grid/x09_rv2twoouters` — **RV2 REBUILT** (`amod` holding `innermod`, `bmod` holding `innermod`) | **390** | **0** | `WRONG uhdmallModules[3] gold=work@bmod::innermod ours=work@dut`, `GOLD-ONLY uhdmallModules[4] gold=work@dut` |

The RV2 witness was **not committed** by pass 98. It is rebuilt here from
the brief's text. At the base, ours lists
`[work@amod, work@amod::innermod, work@bmod, work@dut]` and golden lists
`[work@amod, work@amod::innermod, work@bmod, work@bmod::innermod, work@dut]`.
`bmod::innermod` is silently dropped, and every slot after it shifts. On the
law binary all three arms reach slot score **all-OK** (138/138, 138/138 and
113/113) and a display-free sectioned dump distance of **0**.

---

## 2. THE DECODE, IN THE PINNED SOURCES

### 2a. Where golden's publication comes from: no header test, no instance

* `~/git-repos/Surelog/src/DesignCompile/ResolveSymbols.cpp:168-201`. The
  `paModule_declaration` case collects every `paModule_declaration` directly
  inside the outer. For each one it files
  `new ModuleDefinition(fd, subobject, StrCat(fullName, "::", name))`. It
  never looks at the inner header: ports, parameters and instance count
  are all irrelevant. The name it files under is already `work@sub::innermod`.
* `~/git-repos/Surelog/src/DesignCompile/CompileDesign.cpp:203` moves every
  file's module definitions into the design. `:350-352` compiles every
  `ModuleDefinition` in the design (`FunctorCompileModule`), whether or not
  anything instantiates it. That is why golden's shell is full: ports,
  parameters, `param_assign`s, nets and `cont_assign`s. This was measured on
  `x01`–`x05`, `w23` and `w24` (golden dumps in the grid run).
* `~/git-repos/Surelog/include/Surelog/Common/Containers.h:26-27` defines
  `ModuleNameModuleDefinitionMap` as a `std::map<std::string, …>`, so the
  listing is NAME-SORTED by the scoped name. Its key is the SCOPED name, so
  `work@amod::innermod` and `work@bmod::innermod` cannot collide.
  `~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:5104-5145` writes
  every `paModule_declaration` entry of that map with `writeModule`.
  `:5121-5131` parents a `::` name on its outer's `module_inst` (pass 98's
  B6).

### 2b. Why we publish nothing (LAW A) or only one of two (LAW B)

* `~/git-repos/slang/source/ast/Scope.cpp:1281-1308`
  (`handleNestedDefinition`) mints the implicit instance only for a nested
  module with no parameters, no ports and zero instances. It returns early
  on any of those. `~/git-repos/slang/source/ast/Compilation.cpp:486-501`
  reports unreferenced definitions for the ROOT scope only (it skips
  `std::get<1>(key) != root.get()`). So a ported or parameterized nested
  module reaches **no** `defs` producer at all.
* `src/UhdmExporter.cpp` (`collectDefs`, `src/EmitHelpers.h:2037`, via
  `defs.emplace(std::string(child.getDefinition().name), …)`) builds `defs`
  keyed on the **bare** definition name. Pass 98's LAW B1 re-keys it to the
  scoped name only AFTER collection. When `amod::innermod` enters under
  `innermod`, `bmod::innermod` finds the key taken and is dropped, and its
  subtree is never walked. The same happens when a file-scope `innermod`
  takes the key first (r11u99's `w19`, which pass 98 listed as residue 2).
* `~/git-repos/slang/source/ast/Compilation.cpp:800-822`
  (`createDefinition`). Every elaborated body of an outer mints its OWN
  `DefinitionSymbol` for the nested declaration. The law therefore takes
  only the nested definition that lives in the outer's REPRESENTATIVE body
  (`defs`'s entry for the outer), so an outer instantiated twice still
  publishes each nested definition once (`x13`, `x21`).

### 2c. The law, at its one site

`src/UhdmExporter.cpp` holds the block right after pass 98's re-key
(`// ===== r11u101 LAW A + LAW B`). It walks `comp.getDefinitions()` and
keeps each definition whose `nestOuterDef99` outer is a file-scope module
and whose depth is exactly 1. Pass 98's § `caNestedModDeepNoDefView99` and
its module-in-module restriction stay the ground. It also requires that the
definition's body is the outer's representative body and that the scoped
key is still absent. Then:

* **B**: if an instance of it exists in that body (implicit or written,
  through taken generate blocks and instance arrays), it is re-entered under
  the scoped key and its subtree is re-collected with pass 98's keying.
* **A**: if no instance exists, the law mints
  `InstanceSymbol::createDefault` under `addDefOnlyModule`'s admission rule
  (all parameters defaulted, no `InterfacePort`). It marks the result
  `unrefDefs` (the write phase fills its ports) and `defOnlyDefs` (this
  listing is never elaborated), and re-collects the subtree.

**Golden writes nothing on a miss.** The shell's CONTENTS are golden's own
(§3). The two admission refusals are left as the base binary writes them.
Golden DOES publish those two shapes (`x04`, `x17`), but the file-scope
road refuses the same shapes and no measured mint exists for them (§8).

---

## 3. THE GOLDEN GRID (`grid/`, 25 arms)

`rr98.sh` regenerates golden per arm per tag with the pinned Surelog, and
every arm records both rc values (all `golden_rc=0 ours_rc=0`). The full
table is in `evidence/GRID101.txt`.

| arm | shape | pris | law | A-off | B-off | shadow-off |
|---|---|---|---|---|---|---|
| `x01_nestport` | ANSI output port (= w23) | 444 | **0** | 444 | 0 | 0 |
| `x02_nestparam` | parameter port (= w24) | 446 | **0** | 446 | 0 | 0 |
| `x03_nestportparam` | ports + a parameter that sizes them | 542 | **0** | 542 | 0 | 0 |
| `x05_nestnonansi` | NON-ANSI port list | 475 | **0** | 475 | 0 | 0 |
| `x08_nestparaminmid` | parameterized depth-1, portless depth-2 inside it (B4 keeps the depth-2 out) | 446 | **0** | 446 | 0 | 0 |
| `x13_rv2outertwice` | one outer instantiated TWICE; a portless and a ported nested | 412 | **0** | 412 | 0 | 0 |
| `x14_nestporttopouter` | the outer is itself the top | 284 | **0** | 284 | 0 | 0 |
| `x18_nestportclassouter` | outer class + ported nested with a class (pass-98 B3 stays) | 488 | **0** | 488 | 0 | 0 |
| `x21_outerparamported` | outer parameterized ×2 values | 812 | **0** | 812 | 0 | 0 |
| `x22_nestportunused` | the outer is never instantiated (a second top) | 306 | **0** | 306 | 0 | 0 |
| `x09_rv2twoouters` | **RV2** | 390 | **0** | 0 | 390 | 0 |
| `x10_rv2threeouters` | three outers instantiated in REVERSE name order | 460 | **0** | 0 | 460 | 0 |
| `x20_rv2child` | the dropped duplicate instantiates a file-scope `leaf` nothing else uses | 404 | **0** | 0 | 404 | 0 |
| `x11_rv2ported` | two outers, both nested PORTED (A alone) | 466 | **0** | 466 | 0 | 0 |
| `x12_rv2mixed` | `amod`'s portless, `bmod`'s ported | 424 | **0** | 424 | 0 | 0 |
| `x16_shadowport` | file-scope `innermod` + nested PORTED `innermod` | 472 | **0** | 472 | 0 | 472 |
| `x19_nestportchild` | ported nested instantiates a PORTED `leaf` | 499 | 55 | 499 | 55 | 55 |
| `x25_rv2childport` | dropped duplicate instantiates a PORTED `leaf` | 465 | 55 | 55 | 465 | 55 |
| `x15_shadowinst` | **THE FENCE ARM** (RV1): file-scope `innermod` + `sub` holding a nested `innermod` + `innermod u_i ()` in `sub` | 507 | 527 | 527 | 507 | 507 |
| `x04_nestparamnodef` | parameter with NO default — **admission refuses** | 430 | 430 | 430 | 430 | 430 |
| `x17_nestifaceport` | interface port — **admission refuses** | 490 | 490 | 490 | 490 | 490 |
| `x06_nestportinst` | CONTROL: ported nested EXPLICITLY instantiated | 0 | 0 | 0 | 0 | 0 |
| `x07_nestportdeep` | CONTROL: ported module at depth 2 (B4: no def) | 0 | 0 | 0 | 0 | 0 |
| `x23_implchildport` | CONTROL (pass-98 road): portless nested instantiates a PORTED `leaf` | 55 | 55 | 55 | 55 | 55 |
| `x24_genchildport` | CONTROL (file-scope road): non-taken generate reaches a module that instantiates a PORTED `leaf` | 55 | 55 | 55 | 55 | 55 |
| **total** | | **9772** | **1667** | 8128 | 3311 | 2119 |

With `R11U101_OFF=1` the grid total is **9772 — exactly pristine**. Every
database is byte-identical to pristine (§4).

**What the shell contains.** This is golden's, face by face, and ours now
matches it. Ports with `vpiLowConn` → net and a `ref_typespec` (`x01`,
`x03`, `x05`). Parameters with `param_assign` and an `int_typespec`
(`x02`, `x03`). Nets, `cont_assign`s and `vpiParent` = the outer def
(`x01`–`x05`). A nested class goes NOWHERE (`x18`: golden holds `Binner`
zero times, which is pass 98's B3). For all 16 converted arms plus
`w19`/`w23`/`w24`, the display-free whole-dump distance is **0**
(`slot101.py distsec`). The remaining full-text distance (20–80 lines per
arm) is entirely pass 98's residue 3, the `work@sub.work@sub::innermod.r`
vpiFullName display convention, which no `Compare` reads.

**`x19`/`x25` (55 lines left) are a PRE-EXISTING residue, not this law's.**
The head is `work@leaf`'s def view without its `port`. The same 55-line head
appears on the pristine binary for `x23` (pass 98's implicit road) and for
`x24` (the file-scope non-taken-generate road). Any module reached only
through a body that no instance walk elaborates never has its port phase
filled. This law's subtree inherits exactly that treatment. Both arms still
fall from 499 to 55 and from 465 to 55 lines.

**`x15` — THE FENCE ARM — rises 507 → 527, and that is the head MOVING, not
a regression.** At the base the first head is `uhdmallModules` (golden 4
entries, ours 3: `work@sub::innermod` missing). The law adds that entry, so
the listing matches golden in name and order. The head then moves to
`uhdmtopModules`, the fenced RV1 face: ours elaborates a second top
`work@innermod`, because golden elaborates the file-scope body under
`u_i` and slang does not. Read per slot: 10 slots GAINED
(`uhdmallModules[3]=work@sub::innermod` and its net), **0 moved wrong**.
Read per entry: the `work@sub::innermod` def view goes 16 → 0 and every
other entry is identical before and after. The two `uhdmtopModules` entries
stay at 38 + 44, and `work@sub`'s 2 lines (golden's `u_i` `vpiActual` →
file-scope `work@innermod`) are unchanged. The elaborated-name site is not
edited. This pass touches `defs` only. `R11U101_NESTSHADOW_OFF=1` returns
the arm to its base bytes (507).

---

## 4. THE GATES — three switches, each droppable alone

| switch | face | own grid total | r11u99 grid total |
|---|---|---|---|
| — (pristine) | — | 9772 | 4534 |
| — (law, all on) | — | **1667** | **3206** |
| `R11U101_OFF=1` | all | **9772** | **4534** |
| `R11U101_NESTPORT_OFF=1` | LAW A (ported/parameterized shell) | 8128 | 4096 |
| `R11U101_NESTKEY_OFF=1` | LAW B (collision re-entry) | 3311 | 3644 |
| `R11U101_NESTSHADOW_OFF=1` | the shadow face of both | 2119 | 3644 |
| `R11U101_NETDBG=1` | the trace, OUTSIDE every gate | — | — |

Every switch drops exactly the arms of its face (the per-arm columns in §3).
`R11U101_OFF=1` reproduces the pristine DATABASE **byte for byte on 218/218
buildable arms** of all seven grids (`evidence/CONTROLS101.txt`). With the
LAW A gate off and no trace, nothing is minted. The law binary is
byte-deterministic: 25/25 grid databases are identical on a repeat.

**The landed laws stay.** Pass 98's eight (`R11U99_*`) and pass 96's four
class laws and verifier guard (`R11U98_*`) are untouched code. Their grids
read their committed totals with byte-identical databases:

| grid | buildable | pris | law | law == pris bytes | movers |
|---|---|---|---|---|---|
| r11u99 | 25 | 4534 | 3206 | 22/25 | `w19`, `w23`, `w24` — **pass 98's residues R0 and 2, converted** |
| r11u98 | 20 | 159 | 159 | **20/20** | none |
| r11v98 | 30 | 1729 | 1729 | **30/30** | none |
| r11u95 | 35 | 72 | 72 | **35/35** | none |
| r11v95 | 30 | 522 | 522 | **30/30** | none |
| r11u93 | 53 | 185 | 185 | **53/53** | none |

### 4a. MOVED-WRONG 0 / AWAY 0, per slot and per entry, and the scorers can see one

`slot101.py move` scores every positional slot. `secmove101.py` scores the
display-free distance of every top-level entry (def view, top, package), so
a surplus in one entry can neither hide nor fake a move in another. Both
compare the pristine pair with the law pair against golden, per arm
(`evidence/SLOTS101.txt`):

| grid | arms | SLOT MOVED-WRONG | SLOT GAINED | ENTRY AWAY | ENTRY CLOSER | distsec pris → law |
|---|---|---|---|---|---|---|
| r11u101 | 25 | **0** | 886 | **0** | 24 | 1289 → 249 |
| r11u99 | 27 | **0** | 70 | **0** | 3 | 1392 → 1279 |
| r11u98 | 20 | **0** | 0 | **0** | 0 | 51 → 51 |
| r11v98 | 31 | **0** | 0 | **0** | 0 | 265 → 265 |
| r11u95 | 35 | **0** | 0 | **0** | 0 | 76 → 76 |
| r11v95 | 31 | **0** | 0 | **0** | 0 | 73 → 73 |
| r11u93 | 55 | **0** | 0 | **0** | 0 | 216 → 216 |

**Positive control.** The law binary run with `R11U99_NESTNAME_OFF=1` drops
pass 98's LANDED scoped name, a real pristine-right → wrong move. On the
r11u99 grid it reads **SLOT MOVED-WRONG=527** over 11 named arms (`w11` 30,
`w16` 49, `w28` 287, …) and **ENTRY AWAY=28** (distsec 1392 → 2028).
**Calibration**: golden vs golden (the two independent golden regenerations
of every arm, tags `pris` and `law2`) reads **0 non-OK slots and distsec 0
on all 48 paired arms**.

---

## 5. THE CORPUS GATES

1. **Build.** Pristine `c566d68304a691a704d2d4f80493ad79`, identical to the
   OPS pin. Law `1b79bf536de130c3c2640e68519803b9`. **Reproduced from the
   deliverable** on a FRESH `e29d5182` worktree (see §9).
2. **Goldens.** Law: `23 PASS / 0 FAIL`. `SLANG_UHDM=/bin/false`:
   `0 PASS / 23 FAIL`.
3. **uhdm2rtlil `--mode both`.** Law vs `results/golden_uhdm2rtlil.csv`:
   **PASS, every one of 1742 rows byte-identical**. Law testflags rows vs
   `results/gate_uhdm2rtlil.csv`: PASS, 871/871. Law vs pristine: PASS.
   Both modes read `788 EQ / 16 NE / 67 SLANG_REJECT`.
4. **Surelog `--mode both`.** Law vs `results/golden_surelog.csv`: status
   identical in both modes (`default 474 EQ / 9 NE`,
   `testflags 469 EQ / 8 NE`, and every other status count equal). Two
   rows differ, and only in the `detail` TEXT: `LowMemLib`/`LowMemPkg`
   testflags are `SURELOG_FAIL` on both sides, and their Surelog log line
   embeds the workdir path (`/tmp/m187base/…` vs this sweep's). The
   pristine sweep shows the same two, plus `Earlgrey_0_1`/testflags' dump
   column reading blank, the documented `uhdm-dump` timeout draw. **The
   law sweep's Earlgrey row matches the committed CSV exactly.**
   **No row converts. `results/*.csv` untouched.**
5. **byteverify `SELFCHECK=1`** against this pass's own pristine workdirs:
   * uhdm2rtlil: `PATH_SETS_IDENTICAL (1608)`, **`MOVERS: 0 / 1608`**,
     SELFCHECK 1607/1608.
   * Surelog: `PATH_SETS_IDENTICAL (960)`, `MOVERS: 5 / 960`, SELFCHECK
     959/960. **PREDICTED: NONE (§7). Every one is attributed**
     (`evidence/MOVERS101.txt`). `default/MiniAmiq`, `default/SeqDriver`,
     `default/SimpleUVM`, `testflags/MiniAmiq` and `testflags/SeqDriver`
     each show an order-blind dump delta of exactly **4 lines**, the
     `UINT`/`vpiDecompile` line-number pair of the converted UVM family.
     They carry **0** `module_inst`/`ref_module`/`class_defn`/name lines.
     **Positive control.** The SAME law binary, run twice more over the
     family, gives 4 self-movers (`MiniAmiq` both modes, `SimpleUVM`
     default, `SeqDriver` testflags). `Scoreboard`/default moved on the
     repeats and not in the sweep, so the family is per-invocation
     nondeterministic. **All seven conversion rows stay CMP_EQUAL in both
     modes:** `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`, `SimpleUVM`,
     `Earlgrey_0_1`, `InterfaceModPort` and `Scoreboard`/default.
     `Scoreboard`/testflags is `SLANG_REJECT`, exactly as committed.

**cmds.txt audit.** Surelog: 1531 `slang:` invocations per workdir, all
naming that workdir's frozen binary. uhdm2rtlil: 1742 per workdir, likewise.
**0 name the main tree.**

**Canaries.** `canaries.sh` reads `ok=52 changed=0 absent=0` (Surelog),
`ok=8` (gate testflags) and `ok=16` (both-mode uhdm2rtlil). `ctcan2.sh`
**PASS** twice. `canaudit.sh` reads `audited=29 UNCOVERED=0
FENCE-BREACH=0`. The protected databases, law vs pristine, byte for byte:

```
SVSwitch           4842211c4030  both modes   SAME  (HARD pin)
YosysVerx          6ccda350c24a  both modes   SAME  (HARD pin)
InterfaceModPort   59a365f3ce2c  both modes   SAME  (watched byte-for-byte)
Earlgrey_0_1       8bdf25272e08 default / 59d0ee6d10c3 testflags  SAME (the pins)
BlackParrotComplex e3e354129d5a default / 73a10e8217e5 testflags  SAME
YosysOldOr         d68e0796d62c  both modes   SAME
```

---

## 6. THE WIDE BOUNDARY (`bnd101.sh` over ALL of `tools/probe`)

```
BOUNDARY listed=4401 processed=4401 moved=31 rc-or-db-anomalies=0
PROCESSED==LISTED
```

Every mover is attributed by name (`evidence/BOUNDARY101.txt`, via
`attr101.sh`):

| arms | verdict |
|---|---|
| 19 × `r11u101repro/grid/*` | **THE LAWS.** This pass's own arms: the 19 the §3 trace predicts, and nothing else. |
| `r11u99repro/grid/{w19,w23,w24}` | **THE LAWS.** Pass 98's R0 and residue 2, converted (§1). |
| `r10uvm130`, `r10v109`, `r10v117`, `r10v130`, `r10uvm196/grid196`, `r10v209/arms` | **NONDETERMINISM.** The pristine binary disagrees with itself (`SELF-NONDET`), with 0 order-blind dump lines. |
| `r10buvm22`, `r10uvm154`, `r10uvm185/grid185` | **r11u95's residue R2, the ADDRESS-DERIVED UINT.** It is the same three arms that r11u95's and r11u99's READMEs name. The order-blind delta is only 8-digit `UINT`/`vpiDecompile` values (`23376985 → 23381145`, +4160). **16 KB-PAD POSITIVE CONTROL** (`evidence/PADCTL101.txt`): a pristine build carrying only `volatile char pad[16384]` moves the SAME cells by exactly **+16384** and nothing else. |

All 9 non-law movers carry **zero** `R11U101` trace lines, so they hold no
nested definition at all. One arm segfaults on BOTH binaries (same rc, so
not an anomaly).

---

## 7. THE CENSUS: A CONTROLLED ZERO, AND THE MOVERS PREDICTED BY NAME FIRST

**From the pristine databases, first** (`ct101cen.cpp`, `evidence/PREDICT101.txt`).
All 2568 databases of this pass's two pristine sweeps plus 3 controls:
`WITH-NESTDEF 2`, and both are the controls (`x09` → `work@amod::innermod`,
`w12` → `work@sub::innermod`). **No corpus database holds a published
nested definition**, which is LAW B's precondition. LAW A's population is
absent from a pristine database BY CONSTRUCTION (that is the bug), so it is
predicted from source.

**From source** (`cellcen101.py`, `evidence/CENSUS101.txt`). This replays
the harness's own `discover_*`/`translate`, runs the LAW binary with
`R11U101_NETDBG=1` over every test of both corpora in both modes, and never
dispatches FENCED. `R11U101NESTANY` is the superset: every definition
declared inside any other definition's body, any kind, any depth.

| corpus | arms | nestAny | law=A | law=A-DECLINE | law=B | shadow | PREDICTED MOVERS |
|---|---|---|---|---|---|---|---|
| surelog | 1573 + 6 seed (3 seeds × 2 modes) | 0 + 8 | 0 + 4 | 0 | 0 + 2 | 0 + 2 | **NONE** |
| uhdm2rtlil | 1742 + 6 seed | 0 + 8 | 0 + 4 | 0 | 0 + 2 | 0 + 2 | **NONE** |

**The zero is controlled.** The seeds `x01_nestport` → `LAWA-PORTSHELL`,
`x09_rv2twoouters` → `LAWB-KEYSCOPED` and `x16_shadowport` →
`LAWA-PORTSHELL shadow=1` are dispatched exactly like corpus tests, and each
comes back flagged. **The gap is explained from the committed CSV.** Three
arms per corpus read `rc=-11` under the census's `-o /dev/null` replay:
`Rggen`/testflags (`SURELOG_FAIL`) and `Tnoc` both modes (`SLANG_REJECT`),
and `rp32_r5p_degu_soc_top`, `rp32_r5p_mouse_soc_top` and
`rp32_soc_vfriendly` testflags (`SLANG_REJECT` in both modes). None has a
database to move, in the committed CSVs or in either of this pass's sweeps.

**Prediction vs sweeps.** Predicted zero. The uhdm2rtlil sweep moved 0. The
Surelog sweep moved the 5 UVM-family databases that the OPS brief declares
pristine-nondeterministic, and their class was proved by a same-binary
repeat (§5). **The laws are corpus-invisible, as the brief expected.**

---

## 8. RESIDUES (ranked)

1. **A DEF-ONLY BODY'S CHILD LOSES ITS DEF-VIEW PORTS: R0.** `x23` 55 and
   `x24` 55 on the PRISTINE binary, plus `x19` 55 and `x25` 55 on the law.
   The head is `work@leaf`'s def view with no `port`. A module reached only
   through a body that no instance walk elaborates is collected into `defs`
   but never has its port phase filled. This applies to pass 98's implicit
   nested instance (B2 suppresses its elaboration), to `addDefOnlyModule`'s
   subtree, and now to this law's subtree. The fix is ONE rule for all
   three roads: add the collected subtree to `unrefDefs`, which the write
   phase already guards with `!filled`. It spans the file-scope road, so
   it is its own pass. CORPUS-INVISIBLE.
2. **THE ADMISSION REFUSALS.** `x04_nestparamnodef` 430 (a parameter with
   NO default) and `x17_nestifaceport` 490 (an interface port). Golden
   publishes both shells. For `x04`, golden writes the `parameter` with a
   `param_assign` holding only `vpiLhs`. We refuse because the file-scope
   road refuses (`addDefOnlyModule`: all parameters defaulted, no interface
   ports) and a `createDefault` of either shape is unmeasured. Widening both
   roads together is the right unit.
3. **THE SHADOWING FAMILY, STILL FENCED (RV1).** `x15` 527: golden
   elaborates the FILE-SCOPE body under `sub`'s `innermod u_i ()`. We
   elaborate the nested one and publish the file-scope module as a second
   top. This pass closed the family's DEF-view cell and left the elaborated
   face byte-identical.
4. **THE NESTED DEF VIEW'S FULLNAMES** (pass 98's residue 3). This is
   display only, and it is the only remaining difference in every converted
   arm's full-text dump.

---

## 9. THE DELIVERABLE AND HOW TO RE-RUN

`/tmp/r11u101.patch` is `git diff` vs `e29d5182`. Its surface is
`src/UhdmExporter.cpp` plus `tools/probe/r11u101repro/`. It applies cleanly
to a fresh `e29d5182` worktree and rebuilds to the law md5 bit for bit.

```bash
# the grids (run on COPIES: rr98.sh writes into the arm dirs)
cp -r tools/probe/r11u101repro/grid /tmp/g101; cp -r tools/probe/r11u99repro/grid /tmp/g99
PRIS=<pristine> LAW=<law> bash tools/probe/r11u101repro/runall101.sh /tmp/g101 /tmp/g99 [control-grid copies...]
python3 tools/probe/r11u101repro/slot101.py score|distsec <gold.dump> <ours.dump> [--rows]
python3 tools/probe/r11u101repro/slot101.py move pris law2 /tmp/g101/*/         # SLOT MOVED-WRONG
python3 tools/probe/r11u101repro/secmove101.py pris law2 /tmp/g101/*/           # ENTRY AWAY
# the census (LAW binary: the trace lives in the patch)
python3 tools/probe/r11u101repro/cellcen101.py <repo> surelog|uhdm2rtlil <LAW> <out.tsv> \
    --seed tools/probe/r11u101repro/grid/x01_nestport \
    --seed tools/probe/r11u101repro/grid/x09_rv2twoouters \
    --seed tools/probe/r11u101repro/grid/x16_shadowport
# the pristine-database predictor
g++ -O2 -std=c++17 tools/probe/r11u101repro/ct101cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct101cen
find <pristine workdir> -name slang.uhdm | ./ct101cen
# the wide boundary + attribution
bash tools/probe/r11u101repro/bnd101.sh <pristine> <law> <outdir> tools/probe
BND=<outdir> PRIS=<pristine> LAW=<law> bash tools/probe/r11u101repro/attr101.sh <arm-dir>
R11U101_OFF=1 / R11U101_NESTPORT_OFF=1 / R11U101_NESTKEY_OFF=1 /
R11U101_NESTSHADOW_OFF=1 / R11U101_NETDBG=1  <binary> …
```

Evidence: `evidence/{GRID101,CONTROLS101,CELLS101,SLOTS101,CENSUS101,PREDICT101,GATES101,MOVERS101,BOUNDARY101,PADCTL101}.txt`.
