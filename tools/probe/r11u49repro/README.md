# r11u49 — an unpacked-struct package localparam's pattern Rhs carries the same typespec a packed one does

Base `a0dfe261` (v1.87 pass 47).  Pins per `SUPPORT_MATRIX.md`: slang
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 (`0445655ee7`), uhdm2rtlil v0.68.
Every golden in this directory is a real Surelog v1.87 run (`arm.sh`), never a
carried-forward framing.

Target: TRIAGE2's **C5**
([tools/probe/r11u44repro/TRIAGE2.md:451](tools/probe/r11u44repro/TRIAGE2.md#L451)),
whose two arms were already written down as residues R1 and R2 by one pass
([tools/probe/r11u34repro/README.md:375](tools/probe/r11u34repro/README.md#L375)
and [:384](tools/probe/r11u34repro/README.md#L384)).  **The PATTERN arm lands
here; the CAST arm does not** — it is a shape change plus a phantom-net mint,
measured and stated as R2 below with its own golden matrix.

---

## 0. THE TWO HEADS, RE-MEASURED AT `a0dfe261`

Pristine binary `md5 adf22bb0c9085e300eec1b4a7c8cdacc`, byte-identical to the
main tree's `build/slang-uhdm` at `a0dfe261`.  Four rows, two tests, two modes;
each `uhdm-cmp` run reports **one** head (`grep -c '^LHS:'` = 1 on all four).
Full logs: `evidence/head.pris.*.cmp`.

`iface_zero_width_field`, both modes — identical text:

```
LHS:
ref_typespec: , id:90
|vpiActual:
\_struct_typespec: (p::bus_t), id:2, line:7:11, endln:7:75
RHS: <null>
```

`typed_named_pattern`, both modes — identical text:

```
LHS:
ref_typespec: (work@typed_named_pattern), id:103
|vpiParent:
\_operation: , id:102, line:22:35, endln:22:132
|vpiFullName:work@typed_named_pattern
|vpiActual:
\_struct_typespec: (q::op32_i_t), id:13, line:9:11, endln:15:4
RHS: <null>
```

The owner is hidden by the singular overload, so both were located in
**golden's own dump**.  `iface_zero_width_field`'s is the `vpiOpType:75`
assignment pattern that is the `vpiRhs` of
`localparam bus_t B = '{CTL:0, DAT:8, STS:0}` (`dut.sv:8`) in the **elaborated**
package `p` listing; golden hangs a NAMELESS, PARENTLESS `ref_typespec ->
struct_typespec (p::bus_t)` off it and flattens the three `tagged_pattern`s to
bare constants at **size 32** (the `int unsigned` member width).  The
**definition** (`uhdmallPackages`) listing is BYTE-IDENTICAL on both sides — the
law's whole surface is the elaborated view.

Neither test converts: order-blind whole-dump distance at the base is
**1319 lines** (`iface_zero_width_field`) and **880 lines**
(`typed_named_pattern`).  This is a head pass.

---

## 1. THE PRODUCER

Both laws below are two faces of one Surelog call.  The flatten and the op
typespec are written by `CompileHelper::expandPatternAssignment`
(`src/DesignCompile/CompileHelper.cpp`, the `adjustOpSize` walk at `:5114-5203`
called from `:5421`), and a PACKAGE parameter reaches it down two roads:

* `CompileHelper::getValue`'s `pkg::NAME` arm
  (`src/DesignCompile/CompileExpression.cpp:901-955`) — it fetches the
  package's own `param_assign`, runs `expandPatternAssignment` +
  `reorderAssignmentPattern` on it IN PLACE and hands back a clone.  This is the
  SCOPED-REFERENCE trigger the landed `§ hasScopedPkgRef` family models.
* `substituteAssignedValue`, for every `P.member` select — it reduces `P`'s own
  elaborated value in place before answering the select.  This is the
  MEMBER-SELECT trigger.

Neither road asks whether the struct is `packed`.  The walk reads the
operation's typespec members, and a `struct_typespec` is a `struct_typespec`
either way — which is the whole of § unpackedPkgPatFlat49.  And the second road
runs wherever the select is COMPILED, which is the whole of
§ pkgScopeMemberSelect49.

---

## 2. LAW A — `§ unpackedPkgPatFlat49`

> **An UNPACKED-struct PACKAGE parameter's named/`default:` pattern flat-folds
> in the elaborated package listing exactly like a packed one, and carries the
> same bare op-level `ref_typespec` to its `struct_typespec`.**

**Our blocker,** named by r11u34 R1 and confirmed here: `structPat`
(`src/ParamEmit.cpp`, the `structPat = (pctS.kind == PackedStructType || …)`
assignment) admitted an UnpackedStructType only behind `unpStructOvRef9` (the
parameter-OVERRIDE arm), so a plain package localparam of unpacked struct type
never entered the flat-fold road — even though the road's own field walk
(`fsc9`) already selects `UnpackedStructType`.

**Grid** (`u1`, `a1`, `a5`, `b2`, `b3`, `a3`; `arm.sh`, read with `shape.py`).
Every arm `slrc=0 ourrc=0 slerr=0` on both binaries.

| arm | parameter | reader | golden, ELAB package listing | pristine |
|---|---|---|---|---|
| `a1` | `USEL` `ubus_t` UNPACKED | `USEL.DAT` in-package member select | typed + FLAT, constants at **32** | untyped, tagged |
| `a1` | `USCP` `ubus_t` UNPACKED | `p::USCP.DAT` scoped | typed + FLAT at 32 | untyped, tagged |
| `a1` | `UNON` `ubus_t` UNPACKED | never read | **untyped, tagged** | untyped, tagged |
| `a1` | `PSEL`/`PSCP`/`PNON` `pbus_t` PACKED | the same three faces | flat / flat / tagged | tagged / flat / tagged |
| `a5` | `W96` UNPACKED, **96 bits** | `p::W96.B` scoped | typed + FLAT at 32 | untyped, tagged |
| `u2` | 32-bit never-read, packed AND unpacked | none | tagged both | tagged both |

`a5` is the WIDTH control: the landed >64b package rule (`kmac_pkg::A`) is a
PACKED-only fact — golden flattens a 96-bit UNPACKED struct.  Nothing was needed
for it: slang's `Type::getBitWidth()` answers 0 for an unpacked struct, so the
`> 64` gate cannot fire on this face.

**THE THREE FENCES**, each an AWAY-GOLDEN cell on an earlier build of this law,
every one caught by the grid before any sweep:

| arm | shape | golden | law without the fence |
|---|---|---|---|
| `b2` `UN` / `UU` | a PATTERN-VALUED element (`'{ip: '{x:…}, k: 6}`) | tagged | flat — a minted flatten |
| `a3` `KTYP`, `b3` `UTYP` | a TYPE key (`'{int: 4}`) | tagged | TYPED op with **zero operands** |
| `a3` `KPOS`, `b3` `UPOS` | POSITIONAL (`'{1, 2}`) | operands re-sized to 32, op **UNTYPED** | typed — a minted typespec |

The pattern-element fence is `patParamPatElem26v`, the same predicate
`§ patParamEvalFuncRead26` already carries and for the same producer reason
(Surelog's flatten runs only `if (op->Typespec())`).  `'{default: N}` and
`'{A:1, default: N}` are NOT fenced: golden flattens both (`a3` `KDEF`/`KMIX`,
`b3` `UDEF`).

**Scope.**  `inPackage` only.  A module-LOCAL (`a2`) or MATERIALIZED-IMPORT
(`a6`) unpacked struct param already reaches a typed flat op75 through its own
road on the PRISTINE binary; widening this one onto them would double-emit.
Those two arms score `TO 0 AWAY 0` and are the law's negative control.

---

## 3. LAW B — `§ pkgScopeMemberSelect49`

> **The member-select trigger counts a select written anywhere inside the
> DECLARING PACKAGE. The construct it is written in decides nothing; the scope
> decides everything.**

`hasMemberSelectOf` (`src/TypeEmit.cpp`) required the select to sit inside a
`ParameterDeclaration` *and* inside a `PackageDeclaration`.  The first half was a
shape of the witnesses, not a rule.

**Grid `b1`** is the unconfounded measurement: eight identical packed-struct
package localparams, **no `p::NAME` anywhere** (the module wildcard-imports, so
the scoped-reference road cannot fire), each selected in exactly one context.

| where the select is written | golden, ELAB package listing | pristine | law |
|---|---|---|---|
| package PARAMETER declaration (`S_PARM`) | typed + FLAT | flat | flat |
| package TYPEDEF dimension (`S_TDEF`) | typed + FLAT | **tagged** | flat |
| package FUNCTION body (`S_FUNC`) | typed + FLAT | **tagged** | flat |
| package VARIABLE declaration dim (`S_VDEC`) | typed + FLAT | **tagged** | flat |
| MODULE localparam (`S_MPAR`) | tagged | tagged | tagged |
| MODULE typedef dimension (`S_MTDF`) | tagged | tagged | tagged |
| MODULE cont-assign (`S_MASN`) | tagged | tagged | tagged |
| never selected (`S_NONE`) | tagged | tagged | tagged |

The three MODULE faces stay declined because `inPkg` already excludes them —
that is exactly the polarity `§ pkgMemberSelectPkgScope` measured, and it is
untouched.  `a7` and `a8` are the same fact in isolation (a packed struct
selected only from a package typedef dimension / a package function body:
golden flattens, our pristine did not).

The law's diff is one predicate line plus its note.  `hasScopedPkgRef` and
`pkgPatScopedRef34` are untouched.

---

## 4. THE GOLDEN GRID — 14 arms, scored cell by cell

`score.sh` joins `shape.py`'s (listing, parameter, loc) cells three ways.
Full output: `evidence/GRID.score.txt`.

```
ARM u1  TO 2  AWAY 0   ARM a6  TO 0  AWAY 0   ARM b1  TO 3  AWAY 0
ARM u2  TO 0  AWAY 0   ARM a7  TO 1  AWAY 0   ARM b2  TO 1  AWAY 0
ARM a1  TO 3  AWAY 0   ARM a8  TO 1  AWAY 0   ARM b3  TO 1  AWAY 0
ARM a2  TO 0  AWAY 0   ARM a9  TO 2  AWAY 0
ARM a3  TO 3  AWAY 0   ARM a4  TO 0  AWAY 0
ARM a5  TO 2  AWAY 0
GRID TOTAL over 14 arms:  TO 19   AWAY 0   STILL 30   SAME 102
```

**MOVED-WRONG 0, AWAY-GOLDEN 0.**  Every arm `slrc=0 ourrc=0 slerr=0` on both
binaries; `a3` and `b3` were re-cut once each after Surelog's parser refused a
range-carrying type key (`'{int unsigned: 9}`, `'{logic [7:0]: 8'd3}`) — an arm
whose compile fails teaches error recovery, not golden.

---

## 5. CENSUS, and the movers predicted BY NAME before the patched sweeps

`census.py` is the shape lister; `cand.py` is its risk half.  The PREDICTION was
written to `evidence/PREDICTION.txt` from PRISTINE databases before a single
patched sweep was scored.

**Positive control, stated first.**  The golden column is non-empty in the real
corpora, not only in the synthetic grid: **227** golden typed-flat ELAB cells on
uhdm2rtlil/default, **484** on surelog/default and **416** on surelog/testflags.
A zero OUR column is therefore a fact about the corpus, not about the
instrument.

**Risk bound.**  `cand.py` lists every ELAB cell that is untyped+tagged on OUR
side — the complete set this law COULD flip: **335 per mode** on uhdm2rtlil, all
but three tests' worth of them AGREEING with golden (both tagged).  Those 335
are the AWAY-GOLDEN exposure and had to stay put.

**uhdm2rtlil, both modes** — the law's cell (golden typed+flat, ours
untyped+tagged) appears on exactly two tests:
`iface_zero_width_field` (4 cells: `p::B` in `uhdmtopPackages` plus the
materialized copies `work@my_if.B` / `work@pass.B` / `work@top.B`) and
`stamped_gen_param` (1 cell, `q2::IMPL`).

**Surelog suite, both modes** — exactly one test, `StructParamPatternInitCast`
(`cfg_pkg::Base`), and `Base` is a PACKED struct that is never member-selected
at all: it is passed WHOLE to a const-function builder from a MODULE parameter
declaration.

PREDICTED MOVER SET, stated LOUDLY before scoring:
**`iface_zero_width_field` in both uhdm2rtlil modes, and NOTHING ELSE — zero
movers in the Surelog suite, both modes.**  `stamped_gen_param` was predicted
NOT to move (packed, and its select is written in a module); so was
`typed_named_pattern` (the cast arm is not landed).

**Measured after.**  `byteverify.sh SELFCHECK=1` reports **MOVERS 2 / 1608** on
uhdm2rtlil — `./default/iface_zero_width_field-3e8dd54e/slang.uhdm` and
`./testflags/…` — the prediction, name for name, with nothing outside it.  On
the Surelog suite it reports 4 / 960, every one of them a UVM-family COIN proven
by RE-DRAW from the UNCHANGED pristine binary, not by assertion (gate 5).

---

## 6. WHAT MOVED

`iface_zero_width_field`'s C5 head is GONE in both modes.  The row does not
convert — it was never going to.  The new head is the SAME FIELD one level out,
on the materialized import copy:

```
LHS:
ref_typespec: (work@my_if), id:379
|vpiParent:
\_operation: , id:378, line:8:24, endln:8:46
|vpiFullName:work@my_if
|vpiActual:
\_struct_typespec: (p::bus_t), id:380, line:7:11, endln:7:75
RHS: <null>
```

Cell by cell on that test, golden vs law (`shape.py`):

| listing | golden | pristine | law |
|---|---|---|---|
| `uhdmallPackages p::B` (DEF) | tagged | tagged | tagged ✔ |
| `uhdmtopPackages p::B` (ELAB) | typed + flat/32 | untyped, tagged | **typed + flat/32 ✔** |
| `uhdmallInterfaces work@my_if.B` | typed + flat/32 | untyped, tagged | untyped, tagged — R0 |
| `uhdmallModules work@pass.B`, `work@top.B` | typed + flat/32 | untyped, tagged | untyped, tagged — R0 |
| `uhdmtopModules` ×6 copies | flat 32/32/32 | flat 32/**64**/**64** | flat 32/64/64 — R3 (pre-existing, unmoved) |

Scoreboard: uhdm2rtlil 783 / 21 / 67 both modes, surelog 474/9 + 469/8 — the
baseline exactly, unmoved.  This pass buys one head on two rows (four row-modes
of the cluster head), one packed sub-population corrected (LAW B), and four
decoded residues.

---

## 7. GATES — all green

Binaries frozen at immutable paths (`chmod 555`) before any sweep; every
`cmds.txt` audited by binary PATH — 1742 + 1531 `law.bin` lines in the patched
workdirs, 1742 + 1531 `pris.bin` lines in the pristine ones, and not one main-tree
path in either.

1. **BUILD.**  PRISTINE `md5 adf22bb0c9085e300eec1b4a7c8cdacc` — byte-identical
   to the main tree at `a0dfe261`, the brief's stated hash.  PATCHED
   `md5 d2d18afeeb28465f3ab0542185e67c0c`, 0 errors.
2. **GOLDENS.**  `tests/check_goldens.sh` PASS 23 / FAIL 0.  Negative control
   `SLANG_UHDM=/bin/false` PASS 0 / FAIL 23.
3. **uhdm2rtlil, both modes** (own pristine sweep + committed baselines).
   783 CMP_EQUAL / 21 CMP_NOTEQUAL / 67 SLANG_REJECT in each mode — the baseline
   exactly.  `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv` *PASS: every row
   byte-identical*; vs this pass's own pristine testflags and default CSVs
   *PASS* both.
4. **Surelog suite, `--mode both`.**  default 474 / 9, testflags 469 / 8 — the
   baseline exactly, and every other status bucket identical to the own-pristine
   sweep (DEFERRED 5/5, SLANG_REJECT 285/286, SURELOG_FAIL 25/23, NO_DATABASE 3,
   NO_UHDM 1, TIMEOUT 1, UNTRANSLATABLE 2).  `ct8rows.sh` flags **two** rows
   against the own pristine sweep and the same two against the committed
   `results/golden_surelog.csv`; both are the workdir PATH inside a golden-side
   failure message, status unchanged, and neither is this pass's:

   ```
   < LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/r11u49_pris/sl/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,
   > LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/r11u49_law/sl/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,
   < LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/r11u49_pris/sl/testflags/LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   > LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/r11u49_law/sl/testflags/LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   ```

   Earlgrey_0_1's dump column did NOT go blank on this pass's draws; its
   database byte-compare is exact (gate 6).
5. **byteverify, `SELFCHECK=1`, against this pass's own pristine workdirs.**
   * uhdm2rtlil: PATH_SETS_IDENTICAL (1608), **MOVERS 2 / 1608**, both
     `iface_zero_width_field` — the predicted set, name for name.  SELFCHECK
     1607/1608 flagged.
   * Surelog: PATH_SETS_IDENTICAL (960), MOVERS 4 / 960 — `MiniAmiq` and
     `SeqDriver`, both modes.  **All four are the documented UVM-family pristine
     nondeterminism, attributed by RE-DRAW, not by assertion.**  Running the
     PRISTINE binary itself, three consecutive times, on the sweep's own command
     line: `MiniAmiq/default` → `fef88e44daed` (18852233 B), `0408f4697b15`
     (18852233 B), `9453211e1ffb` (18852282 B) — three different hashes from one
     unchanged binary, none of them the sweep's `27419f6011b4` or the patched
     `a622e337712c`; `SeqDriver/default` → `2fb39f8b4130` (18074287 B),
     `2fb39f8b4130`, `d94ca3a85de8` (18074291 B) — two hashes and two sizes from
     one unchanged binary.  The path-normalised ORDER-BLIND sorted-dump diff on
     each of the four is the documented **4-line** class and nothing else:

     ```
     <       |UINT:0            >       |UINT:678
     <       |vpiDecompile:0    >       |vpiDecompile:678
     ```

     Their STATUS is `CMP_EQUAL` in both modes on both sweeps, which is what the
     family's pin requires.  SELFCHECK 959/960.
   * Both corpora: **MOVED-WRONG 0, AWAY-GOLDEN 0**, scored cell by cell on the
     14-arm golden grid (§4) as well as by name in the corpora.
6. **Protected databases, by name, patched vs own pristine** — every one SAME:
   `SVSwitch 4842211c4030` (both modes, hard byte pin), `YosysVerx 6ccda350c24a`
   (both modes, hard byte pin), `InterfaceModPort 59a365f3ce2c`,
   `BlackParrotComplex` (default `e3e354129d5a`, testflags `73a10e8217e5`),
   `YosysOldOr d68e0796d62c`, `Earlgrey_0_1` default `8bdf25272e08` and
   testflags `59d0ee6d10c3` — the two Earlgrey pins the brief names, hit
   exactly.  `packed_struct_array_fifo` is `CMP_EQUAL` in both u2r modes and
   STAYS equal.
7. **Canaries.**  `canaries.sh` patched-vs-own-pristine: surelog `ok=52
   changed=0 absent=0`, uhdm2rtlil `ok=8 changed=0 absent=0`; surelog against the
   committed CSV also `ok=52 changed=0`.  `ctcan2.sh` PASS on both corpora.
   `canaudit.sh canaries.sh ctcan2.sh` — `audited=29 UNCOVERED=0
   FENCE-BREACH=0`.  The battery is the current generation
   (`r10uvm221repro`, md5s `e1f84a84bf5d` / `3d3f9a2aa485` / `b2289875bb3d`).
8. **rowheads** on the converted families, patched workdir: `SeqDriver`,
   `SimpleUVM`, `Scoreboard/default`, `MiniAmiq`, `BuildUVMPkg`, `Earlgrey_0_1`
   — every one `0 cmp lines, 0 heads, rc=0`.  SKIP-NOFILE on
   `Scoreboard/testflags` and `Rggen/testflags` is the expected pair;
   `Rggen/default` is `CMP_NOTEQUAL` on the committed baseline, on this pass's
   pristine sweep and on its patched sweep alike.
9. **`results/*.csv` untouched** — `git status` shows two modified sources and
   one untracked probe directory, nothing else.  No fenced test was ever
   dispatched.  `GOLDEN_DEFER` unset throughout.
10. **No metric doc needs refreshing**: no scoreboard number moved.

---

## 8. RESIDUES

* **R0 — `iface_zero_width_field`'s next head, the MATERIALIZED-IMPORT face of
  this same law.**  Golden types and flattens the import copies of `p::B` in the
  DEFINITION listings of the interface and both modules
  (`uhdmallInterfaces work@my_if.B`, `uhdmallModules work@pass.B` /
  `work@top.B` — typed + flat at 32); we keep the tagged tree there because
  `structModDefTagged9` (`§ modDefImportPatSel`) holds the def view tagged for
  an import copy unless the module's parameter port list selects an imported
  parameter.  Golden's rule for this shape is evidently the package-scope
  member select reaching the CLONE.  Three cells per mode, quoted in §6; the
  head above is the first of them.  This is the R0 the next pass should take.
* **R1 — `stamped_gen_param`'s cell: a `pkg::P.member[i]` select written in a
  MODULE parameter declaration DOES flatten the package listing.**  Golden
  flattens `q2::IMPL` (`dut.sv:17`, a PACKED struct) off the single read
  `localparam q2::row_t UT = q2::IMPL.UnitTypes[grp]` at `dut.sv:44`.  Our
  `hasScopedPkgRef` excludes any reference written inside a parameter
  declaration — an exclusion measured on a WHOLE reference
  (`parameter p::cfg_t CFG = p::CFG_DEF`), and arm `a9` shows it does not hold
  for a member SELECT: golden flattens `S_MPAR`, `S_MPRT` and `S_MASN` there,
  all three read as `p::NAME.DAT` from a module.  One corpus cell per mode, one
  test, already `CMP_NOTEQUAL`.  A third law; deliberately not landed here.
* **R2 — the C5 CAST arm, `typed_named_pattern`.**  `T'{named keys}` over a
  STRUCT target is `vpiCastOp(67)` over `vpiConcatOp(33)` whose ten operands
  alternate (bare `ref_obj` named for the member, bound to a phantom
  `logic_net work@typed_named_pattern.<member>`; value), the nested
  `opcode: '{…}` surviving as a tagged op75, and the cast target's
  `ref_typespec (work@typed_named_pattern) -> struct_typespec (q::op32_i_t)` as
  the OWNER's `vpiTypespec` — in BOTH listings (golden's ELAB view is op67 too,
  where ours is op75 carrying the right ref already).  The sibling
  `NOP_PLAIN` (untyped `'{…}`) stays a plain tagged op75 in golden, so the law
  is scoped to the CAST spelling.  A shape change plus a five-net mint, not a
  stamp; `§ castDefaultPatternConcat` at the scope that law names and excludes.
  Two rows, 880 order-blind lines from equal.
* **R3 — an unpacked struct's flattened operands past the first keep 64.**
  Pre-existing and UNMOVED by this pass, on a face neither law touches: the
  MODULE road that already flattens a module-local (`a2` `UM`/`UN`) or
  materialized-import (`a6` `UI`/`UL`) unpacked struct param sizes operand 0 at
  the member width and leaves operands 1..N at the unsized 64, where golden
  sizes every one.  Six cells on `iface_zero_width_field`'s `uhdmtopModules`
  copies, three in the grid.  Identical on the pristine and the law binaries.
* **R4 — the PACKED positional and type-key faces of §2's fences.**  Arm `b3`:
  golden leaves `p::PPOS` (`'{8'd1, 8'd2}`) UNTYPED and keeps `p::PTYP`
  (`'{byte_t: 8'd3}`) tagged; our PRISTINE binary types the first and flattens
  the second to a typed op with zero operands.  Both are pre-existing PACKED
  behaviour on the scoped-reference road, unmoved here — this pass fenced only
  the UNPACKED admission it introduced.  Arm `b2` `p::PN` is the third face:
  golden keeps a PACKED struct with a pattern-valued element tagged; we flatten
  it.  No corpus cell is on any of the three (the census names none), which is
  why they are residues and not laws.

---

## 9. FILES

| file | what it is |
|---|---|
| `arm.sh` | one arm through Surelog + one slang-uhdm binary, both dumped, rc recorded (from r11u34) |
| `shape.py` | THE SHAPE LISTER — every `param_assign` in every top-level listing: op type, op-level typespec actual, operand kinds and constant sizes |
| `score.sh` | joins golden / pristine / law per cell: TO / AWAY / STILL / SAME |
| `census.py` | `shape.py` over a whole `verify_golden.py` workdir; differing cells + the GOLDEN typed-flat count (the positive control) |
| `cand.py` | every cell the law COULD flip, with golden beside it — the AWAY-risk bound |
| `u1.sv` `u2.sv` | r11u34's unpacked-reader-face and narrow-control arms, re-run at this base |
| `a1.sv` | unpacked vs packed, three reader faces each, one package |
| `a2.sv` `a6.sv` | the MODULE-local and MATERIALIZED-IMPORT negative controls |
| `a3.sv` `b3.sv` | key kinds: positional / named / `default:` / type key / mixed |
| `a4.sv` `b2.sv` | the nested-aggregate-member fence, unpacked and packed outer |
| `a5.sv` | the >64-bit unpacked width control |
| `a7.sv` `a8.sv` | the packed member-select trigger in isolation (typedef dim / function body) |
| `a9.sv` `b1.sv` | WHERE a member select must be written; `b1` is the unconfounded one |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` | the current-generation battery (r10uvm221repro), run here |
| `evidence/` | the six cmp heads, the prediction, the four censuses, the candidate bound, the grid score |
