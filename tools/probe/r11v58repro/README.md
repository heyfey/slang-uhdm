# r11v58 — ADVERSARIAL VERIFICATION of r11u58 (§ pkgElabPatMemberStamp58)

Base commit `cfcaecd5` (v1.87 pass 56).  Pins per `SUPPORT_MATRIX.md`: slang
upstream-master `7d61e0ad1`, UHDM v1.87, Surelog v1.87
(`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil corpus v0.68.  Every
golden here is a real Surelog v1.87 run; every arm records `golden_rc` AND
`ours_rc` (`rc58v.txt`); the judge is the official `uhdm-cmp`.

**VERDICT: ACCEPT WITH FIX.**  The law is real, the producer decode is right in
every line I could check against the pinned sources, and every headline number
reproduces bit-for-bit from my own builds.  Two faces of the gate were
pristine-right → patched-wrong on legal SV; both are fixed here, both with a
golden arm that fails before the fix and passes after, and neither fix costs a
single cell on any of the implementer's eight arms.

Binaries (all built `-j 2`, md5'd separately, `chmod 555` before any sweep):

| binary | md5 | what it is |
|---|---|---|
| `/tmp/v11u58_pris.bin` | `2fa585e9ec9f6ccea23c8fee77b6fa7f` | `cfcaecd5` pristine = the main tree's binary |
| `/tmp/v11u58_pat.bin` | `8e6071209329cff27b3589297d32d1fd` | `/tmp/r11u58.patch` as submitted |
| `/tmp/v11u58_fix2.bin` | `6c1de538ed7301d71a3d704c392123f3` | `/tmp/r11u58.verified.patch` (this directory's two fixes on top) |

Both submitted md5s are exactly the ones the implementer reported.

---

## 1. What reproduced, unchanged

* **The witness head at the base.**  `StructParamFuncBodyFieldCompare`,
  official `uhdm-cmp` on the golden-cache database: 1 head, 36 lines
  (`stdout`+`stderr`), LHS golden `constant @30:23` under
  `\_operation: 29:32..32:37` with `|vpiDecompile:64 |vpiSize:32` against RHS
  ours under `\_sys_func_call ($unsigned)` with `|vpiDecompile:64 |vpiSize:64`.
  Order-blind whole-dump residue vs its own golden: **345 golden-only / 339
  ours-only**.
* **The advance.**  Patched: 74 lines, 1 head, and the head OBJECT is now
  golden's folded `constant |vpiDecompile:63 |INT:63` against our `operation`
  inside a `\_range: 43:11..43:25` — the C3 / road-E family.  Residue
  **344/339**; the only new ours-only line is `uhdm-dump`'s own header naming
  the workdir.  Line count UP with a DIFFERENT head object is the allowed
  increase, not the falling-count trap.
* **The multiset reading, checked by count.**  `|vpiSize:64` at that indent:
  golden 4, pristine 4, patched 2; `|vpiSize:32`: golden 2, pristine 0, patched
  2; `|vpiSize:1024`: golden 1, pristine 0, patched 1.  The two "lost" 64s are
  scalar field lines our wrong 64s used to satisfy.
* **The producer decode**, line by line against the pinned Surelog v1.87
  (`0445655ee7`): the `::` split at `CompileExpression.cpp:884`, the package arm
  at `:891`, `expandPatternAssignment` at `:941`, `param->Rhs(rhs)` at `:942`;
  `m_parametersubstitution(true)` at `CommandLineParser.cpp:387` (the r11u54
  README's polarity really is backwards); `adjustOpSize`'s struct arm writing
  `cop->VpiSize(ncsize)` in place at `CompileHelper.cpp:5147-5155`;
  `adjustUnsized` touching only an unsized `'1` at `:5091-5112`; and the bail,
  `int shift = (csize - 1 - i); if (shift < 0 || shift >= 64) return result;`
  at `:5432-5435`, one statement AFTER the stamp at `:5421`.
* **`FuncStructVal`, 57 cells, by my own three-way read.**  Golden's ELAB
  listing really is in the flipped state (`XLEN` 32 against a DEF 64, …,
  `TvalEn` 1) — the r11u54 README's "golden leaves cva6_cfg at the compiled
  sizes" is wrong, and r11u58's correction is right.  Pristine and patched are
  **cell-for-cell identical to golden and to each other**: 0 movers.
* **`pred58.py`** re-run: **9 directories**, both witnesses in them.
* **Gates on the submitted patch**: goldens 23 PASS / 0 FAIL on both binaries
  and 0 PASS under `SLANG_UHDM=/bin/false`; u2r **785/19/67 both modes on both
  binaries**, all four joins PASS, byteverify **MOVERS 0 / 1608**; surelog
  **474/9 + 469/8 on both binaries**, patched-vs-own-pristine exactly the two
  `LowMem*` workdir-path echoes, and `Earlgrey_0_1,testflags`'s dump column
  reads blank under the PRISTINE binary too; the eighteen named rows all
  `CMP_EQUAL` under both binaries in both modes (**MOVED-WRONG 0**); all six
  canary databases SAME and at their pins.
* **Surelog byteverify, patched vs my own pristine: MOVERS 5 / 960** — the
  witness ×2 (the law) and `MiniAmiq`/`SeqDriver`/`Scoreboard` in `default`.
  Order-blind (sorted, path- and id-normalised): MiniAmiq 4 lines
  (`UINT`/`vpiDecompile` 1339→1213), SeqDriver 4 lines (628→1487), Scoreboard
  **0 lines**.  POSITIVE CONTROL: the pristine binary re-run into a third and a
  fourth workdir moves its OWN MiniAmiq three different ways
  (`2f41136994a7` → `95ad53c9f2a1` → `27419f6011b4`) and its own SeqDriver
  (`83fd8833a23a` → `2fb39f8b4130`); `BuildUVMPkg`/`SimpleUVM` draw identical.
  All stay `CMP_EQUAL`.  (My draw differs from the implementer's — that is what
  a coin does.)

---

## 2. DEFECT 1 — a gated read that the producer never EVALUATES  (`va3`, `va9`)

`pkgPatCallArgParam58` reads the raw syntax trees, so it answers YES for a
parameter context that the ELABORATED design never carries.  The producer
cannot: `getValue` is reached only from `ExprEval`'s value functor
(`CompileExpression.cpp:773/837/1157`, `EvalFunc.cpp:61`), i.e. only when a
parameter is actually REDUCED, and Surelog reduces a parameter only in a scope
it elaborates.

**`va3_deadgen`** — module `inner` carries the gated read in its parameter port
default and is instantiated ONLY inside `generate if (0)`; module `live` is the
same read in a live instance.  **`va9_deadblock`** — the same read inside an
uninstantiated generate block of a live module.

| arm / cell | golden ELAB | pristine | patched | FIXED |
|---|---|---|---|---|
| `va3` `pk::G1` (dead reader) | `A=64 B=64 D=32` (TAGGED, compiled) | 64/64/32 ✓ | **32/32/8 ✗** | 64/64/32 ✓ |
| `va3` `pk::G2` (live reader) | flattened (stamped) | 64/64/32 | 32/32/8 | 32/32/8 |
| `va9` `pk::H1` (dead block) | `A=64 B=64 D=32` (TAGGED, compiled) | 64/64/32 ✓ | **32/32/8 ✗** | 64/64/32 ✓ |
| `va9` `pk::H2` (live block) | flattened (stamped) | 64/64/32 | 32/32/8 | 32/32/8 |
| `va9` `pk::H3` (never read) | 64/64/32 | ✓ | ✓ | ✓ |

The patched binary's `va3`/`va9` cmp goes **5 → 14 lines on a NEW HEAD** —
golden `|vpiSize:64` against our `|vpiSize:32` on the dead reader's element, a
head the pristine binary does not have.  That is MOVED-WRONG on legal SV.
Order-blind: **NEW-golden-only 2 under the patch, 0 under the fix**, on both
arms.

**`va22_deadnest` is the same defect two levels down — and it is THE FALLING-
COUNT TRAP.**  `deep` carries the read, `mid` instantiates `deep`, and `mid` is
instantiated only inside `generate if (0)`.  Golden leaves `pk::N1` at
`A=64 B=64 D=32`; the pristine binary matches it and its cmp head is an
unrelated `module_inst work@deep` at **96 lines**.  Under the patched binary the
count FALLS to **14** — and the head is a NEW one EARLIER in the walk, golden's
`constant |vpiSize:64` at 16:29 against our 32.  A smaller cmp is not a better
cmp.  The fixed binary restores the pristine head and the 96 lines exactly.

**FIX** (`src/TypeEmit.cpp`, inside the predicate): collect from the ELABORATED
hierarchy (`comp.getRoot().topInstances` walked through instances, instance
arrays, generate blocks that are NOT `isUninstantiated`, generate-block arrays,
plus every package and compilation unit) the syntax of every parameter
declarator/declaration and every instance parameter-override list that really
exists, and let ONLY those turn the scan's parameter context on.  Dead scopes
have none, so they cannot arm the gate.  The walk dedupes on each definition
body's syntax, so its cost is bounded by the number of distinct definitions.

## 3. DEFECT 2 — a NESTED assignment pattern ends the walk, unstamped  (`va12`)

`:5423`'s `if (invalidValue) return result;` is the bail's sibling exit: a
nested `'{…}` operand has no value for `reduceExpr`/`get_uvalue`, so the walk
ends AT it.  Measured, members `A`(32) `N`(a 48-bit nested struct) `D`(8):

| cell | golden ELAB | pristine | patched | FIXED |
|---|---|---|---|---|
| `A: 64` | **32** | 64 | 32 ✓ | 32 ✓ |
| `N: '{P:7, Q:16'd3}` | **no vpiSize at all** | none ✓ | **48 ✗** | none ✓ |
| `D: 32'(5)` | **32** (compiled) | 32 ✓ | **8 ✗** | 32 ✓ |

cmp lines: pristine 16, patched **85 on a new head**, fixed **14** — the fixed
binary is the only one of the three that is strictly better than pristine here.

**FIX** (`src/ParamEmit.cpp`, in the member loop): an element that is an
`operation` with `VpiOpType() == vpiAssignmentPatternOp` **breaks the loop
BEFORE it is added**, so it and everything after it keep their compiled sizes.
It is checked before the `w58 > 64` width bail, because this exit does not stamp
its own element.

---

## 4. The rest of the adversarial grid — faces the implementer's grid did not cut

Every arm `golden_rc=0 ours_rc=0` on all four binaries (`rc58v.txt`).

| arm | face | golden | fixed binary |
|---|---|---|---|
| `va6_bound6465` | the bail BOUNDARY: a 64-bit member then a 65-bit member | `A=32 S64=64 B=32 S65=65 C=64` | **identical** — `>64` is exact, not off by one |
| `va14_maskrepl` | an overflowing LITERAL (`300` into 8 bits) and a REPLICATION element, inside the bailed state | `L=8 (UINT:300, decompile 300) RP=16 C=32 W=128 Z=64` | **identical sizes, value/decompile untouched** — the size-only write is right |
| `va1_bail64op` | a CAST OPERATION at a 64-bit member (is the exit the width or `invalidValue`?) | golden FLATTENS — a cast op does NOT end the walk | stamped, tagged (R0 shape residue), cmp unchanged at 5 |
| `va2_syscall` | `$bits(pk::S1)` / `$clog2(pk::S3)` — SYSTEM-call arguments | golden stamps AND flattens both; the never-read `S2` stays compiled | gate fires, `S2` untouched — no away-move |
| `va7_readerfaces2` | the read in ANOTHER package's localparam (`K1`), in an INTERFACE parameter default (`K2`), in a NET's packed dimension (`K3`), never read (`K4`) | stamps+flattens `K1`/`K2`/`K3`; `K4` compiled | `K1`/`K2` stamped, `K3` untouched (a MISSED case, not a wrong one), `K4` untouched |
| `va4_untyped` | an UNTYPED package parameter (`localparam U1 = u_t'{…}`), where `expandPatternAssignment` returns at `:5217` | golden folds `U1` away entirely | untouched by the gate (slang's explicit conversion keeps it out) — no away-move |
| `va10_defaultpat` | a pattern with `default:` | golden flattens it | stamps nothing, cmp unchanged at 25 ✓ |
| `va13_overflow` | an overflowing literal AND an overflowing reference, unbailed | golden flattens | cmp unchanged at 5 |
| `va15_refmask` | the landed `§ patElabUintResize` MASKING arm, re-cut inside the bailed state | golden keeps `UINT:300 / vpiDecompile:300` at `vpiSize:8` | **we write `44` — a PRE-EXISTING divergence, in pristine and patched alike** (residue R2 below) |
| `va16_multiinst` | the same gated read in a module instantiated TWICE with different overrides | golden stamps+flattens the one package object | stamped once, consistently; cmp unchanged at 5 |
| `va18_genfor` | the read inside a LIVE `generate for` body localparam (`F1`), against a never-read twin (`F2`) | stamps+flattens `F1`, leaves `F2` compiled | `F1` stamped, `F2` untouched — the liveness walk descends into generate-block arrays |
| `va20_crosspkg` | the struct's package, the function's package and the reader all DIFFERENT (`FuncStructVal`'s own shape) | stamps+flattens `pk::C1`, leaves the never-read `pk::C2` | same — package identity is NOT a conjunct (r11u54's candidate (a) is dead) |

`xd1` / `xd5` / `xd6` / `xd8` / `xd4` / `xd2` / `xd2b` / `xd3` (the implementer's
own arms) were re-run on all three binaries: golden matches their published
tables cell for cell, and the FIXED binary's elaborated listing is **identical
to the patched binary's on all eight**.

---

## 4b. The FULL BATTERY on the verified patch (`/tmp/v11u58_fix2.bin`)

1. **Builds.**  Pristine byte-identical to the main tree at `cfcaecd5`
   (`2fa585e9ec9f6ccea23c8fee77b6fa7f`); all three binaries `-j 2`, md5'd
   separately, `chmod 555` before any sweep.  Every `cmds.txt` audited by binary
   path: **1531 surelog arms and 1742 u2r arms per workdir, one path each, no
   third path**.
2. **Goldens** `23 PASS / 0 FAIL`; `SLANG_UHDM=/bin/false` `0 PASS`.
3. **uhdm2rtlil, both modes: 785 / 19 / 67**, joins against
   `results/gate_uhdm2rtlil.csv`, both mode halves of
   `results/golden_uhdm2rtlil.csv` and this pass's own pristine sweep — **0
   differing rows on all five**; byteverify **MOVERS 0 / 1608**
   (`PATH_SETS_IDENTICAL`, selfcheck 1607/1608).
4. **surelog `--mode both`: 474 CMP_EQUAL / 9 CMP_NOTEQUAL (default) + 469 / 8
   (testflags)** — the committed baseline; against `results/golden_surelog.csv`
   only the two `LowMem*` workdir-path echoes differ, and against this pass's own
   pristine sweep those two plus `Earlgrey_0_1,testflags`'s dump column, which
   draws both ways under the PRISTINE binary too (the documented `uhdm-dump`
   timeout draw; status `CMP_EQUAL`, byte pin held).
5. **surelog byteverify vs this pass's own pristine: MOVERS 5 / 960** —
   `StructParamFuncBodyFieldCompare` ×2 (the law; its database is BYTE-IDENTICAL
   to the submitted patch's, `e0708b2dc3d2`) and `MiniAmiq` ×2 + `SeqDriver`
   (the UVM coin, order-blind 4 lines each of the `UINT`/`vpiDecompile`
   line-number class).  POSITIVE CONTROL: `default/SeqDriver`'s "moved" hash
   `2fb39f8b4130` is EXACTLY what the PRISTINE binary drew on its own second
   run, and `testflags/MiniAmiq`'s pristine side `27419f6011b4` is what the
   pristine binary drew on its third.  All stay `CMP_EQUAL`, and `rowheads.sh`
   gives `cmp rc=0 / 0 heads` for SeqDriver, SimpleUVM, Scoreboard, MiniAmiq,
   BuildUVMPkg, Earlgrey_0_1 and FuncStructVal in both modes.
6. **The eighteen named rows: 36 cells, every one `CMP_EQUAL` and unchanged from
   pristine — MOVED-WRONG 0.**
7. **Canaries.**  `canaries.sh` **ok=52 changed=0** (surelog) and **ok=8
   changed=0** (u2r); `ctcan2.sh` PASS on both; `canaudit.sh`
   **audited=29 UNCOVERED=0 FENCE-BREACH=0**; all six protected databases SAME
   and at their pins — SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`,
   InterfaceModPort `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a` /
   `73a10e8217e5`, YosysOldOr `d68e0796d62c`, Earlgrey_0_1 `8bdf25272e08` /
   `59d0ee6d10c3`.  Earlgrey re-run standalone under both binaries: same pin,
   4 s each — the liveness walk costs nothing measurable on the largest design.
8. `results/*.csv` untouched; fence-name scan over the four slang-fenced names
   0/0/0/0; no fenced test dispatched; `GOLDEN_DEFER` unset; the patch applies
   clean on a fresh `cfcaecd5` and reproduces `src/ParamEmit.cpp`
   `507b043947cf1b901763af9e1f2202d6`, `src/TypeEmit.cpp`
   `b4ab6b08ec5cf360744063394684bc50`, `include/UhdmExporter.h`
   `65e8e4509f773f78df1950b04535c391`.

**NO ROW CONVERTS; ONE HEAD ADVANCES.**  Scoreboard unchanged at 474/9 + 469/8
+ 785/19/67 ×2.

---

## 5. Residues this verification leaves standing

* **R0 (the implementer's, confirmed).**  The FLATTEN half of the same read:
  wherever golden stamps AND flattens (`xd8` S1/S2/S5, `xd4` R1/R2, `xd3`,
  `xd2b`, `va1`, `va2` S1/S3, `va7` K1/K2, `va13`, `va10`) we keep the tagged
  tree.  Confirmed at the source: `expandPatternAssignment` returns the
  FLATTENED clone for a struct typespec when the walk completes
  (`CompileHelper.cpp:5494-5497`), and the ORIGINAL tagged tree when it bails —
  so golden's listing is tagged **exactly when the producer bailed**, which is
  why the witness and `FuncStructVal` are tagged at all.
* **R1 — the non-parameter constant context.**  `va7` `K3`: a read inside a
  net's packed dimension stamps in golden and does not in ours.  Missing, never
  wrong.  Same class as the member-select trigger the implementer left standing.
* **R2 — `§ patElabUintResize` masks a value the producer does not** (`va15`):
  golden's elaborated element keeps `UINT:300` at `vpiSize:8`; we write `44`.
  Pre-existing at `cfcaecd5`, untouched by this pass, and now measurable inside
  the flipped state.  This is the sharpest next cut in this family.
* **R3 — the other `invalidValue` exits.**  `va12` decodes one of them (a
  nested pattern).  Any other operand kind that `reduceExpr` cannot value will
  end the producer's walk the same way; only the nested-pattern face is
  measured and gated here.

## 6. Ops record

Worktrees `/tmp/wt_v11u58` (patch as submitted), `/tmp/wt_v11u58pris`
(pristine), `/tmp/wt_v11u58fix` (the verified patch), all at `cfcaecd5`.
Scratch `/tmp/v11u58_*`; grid `/tmp/v11u58_grid`; workdirs `/tmp/v11u58_wdp`
(pristine), `/tmp/v11u58_wdr` (patched), `/tmp/v11u58_wdf` (fixed),
`/tmp/v11u58_wdctl` + `/tmp/v11u58_wdctl2` (the UVM nondeterminism positive
controls).  Every `cmds.txt` audited by binary path: one path per workdir, no
third path.  No shared `/tmp/ctl_wd_*` control was read; `GOLDEN_DEFER` unset;
no fenced test dispatched; `results/*.csv` untouched.
