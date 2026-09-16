# r11u54 — FOLDMAP roads D + B in the elaborated PACKAGE copy

Base commit `a7b98161` (v1.87 pass 52).  Pins: slang upstream-master `7d61e0ad1`,
UHDM v1.87, Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`), uhdm2rtlil
corpus v0.68.  Every golden in this directory is a real Surelog v1.87 run.

**One law lands: ROAD B.  ROAD D IS REFUTED AS BRIEFED** — the re-stamp is real
but its trigger is not the elaborated package view, and a build that read it
that way moved eight `uhdm2rtlil` rows and one `surelog` row AWAY from golden.
The brief's own caution (c) says to land the other alone when one over-runs;
that is what this pass does, and §5 records road D's measurement in full so the
next pass starts from the grid rather than from the brief.

---

## 1. The two witness heads, re-measured at the base

`scripts/verify_golden.py`, own `--out`/`--workdir`, `--jobs 2`, `SLANG_UHDM`
exported explicitly to a frozen pristine binary
(`md5 cf14ad224f6125a553825b3a6d29c842`, byte-identical to the main tree at
`a7b98161`); heads by `tools/probe/r10uvm67repro/rowheads.sh`.

```
TEST                              MODE       CMPLINES  HEADS  cmp rc
ibex_tracer                       default          36      1     255
ibex_tracer                       testflags        36      1     255
StructParamFuncBodyFieldCompare   default          36      1     255
StructParamFuncBodyFieldCompare   testflags        36      1     255
```

### 1a. `ibex_tracer` — ROAD B's head (the ELABORATED package listing)

```
LHS (golden)                                        RHS (ours, pristine)
ref_obj: (ibex_tracer_pkg::OPCODE_C0), line:305:87  constant: , line:305:87
|vpiParent: \_operation: , line:305:86              |vpiParent: \_operation: , 305:86
|vpiName:OPCODE_C0                                  |vpiDecompile:2'b00
|vpiFullName:ibex_tracer_pkg::OPCODE_C0             |vpiSize:2
|vpiActual: \_constant: , line:9:37                 |BIN:00 |vpiConstType:3
```

Order-blind whole-dump residue against the row's own golden (sorted dumps,
workdir path normalised), default mode:
**golden-only 17375 / ours-only 4134.**

### 1b. `StructParamFuncBodyFieldCompare` — ROAD D's head (elaborated package)

```
LHS (golden)                              RHS (ours, pristine)
constant: , line:30:23                    constant: , line:30:23
|vpiParent: \_operation: , 29:32..32:37   |vpiParent: \_sys_func_call: ($unsigned)
|vpiDecompile:64                          |vpiDecompile:64
|vpiSize:32                               |vpiSize:64
|UINT:64 |vpiConstType:9                  |UINT:64 |vpiConstType:9
```

`expr::Compare` reads `VpiDecompile` then `VpiSize`, so the judged failure is
the **size**, 32 against 64.  Order-blind residue **345 / 339** (unchanged by
this pass — road D does not land).

---

## 2. The producer, decoded against the pinned sources

* **ROAD B's refusal** — `CompileHelper::substituteAssignedValue`,
  `Surelog/src/DesignCompile/CompileExpression.cpp:83-105`, read verbatim:

  ```cpp
      if (opType == vpiAssignmentPatternOp || opType == vpiConcatOp) {
        substitute = compileDesign->getCompiler()
                         ->getCommandLineParser()
                         ->getParametersSubstitution();
      }
      for (auto operand : *op->Operands()) {
        if (!substituteAssignedValue(operand, compileDesign)) {
          return false;
        }
      }
  ```

  A concat or assignment-pattern ANYWHERE in the tree refuses substitution —
  the `return false` inside the operand loop is the recursion the brief names —
  unless `-parametersubstitution` is given, which our sweeps never pass.
* **The two package compiles** — `FunctorCompilePackage::operator()`,
  `CompilePackage.cpp:61-71` (`Reduce::Yes` into `uhdmtopPackages`, then a
  second `CompilePackage` on `getUnElabPackage()` with `Reduce::No` into
  `uhdmallPackages`), and `CompilePackage::compile`'s
  `m_helper.setElabMode(reduce == Reduce::Yes)` at `:80`.
* **Where `substituteAssignedValue` gates a read** — `CompileHelper::getObject`
  `CompileExpression.cpp:242`/`:288`, `getValue` `:927`/`:998`/`:1100`, and the
  `pkg::NAME` arm at `:2742`/`:2790` (behind `if (m_elabMode)`), plus
  `NetlistElaboration.cpp:280`, `DesignElaboration.cpp:2215`/`:2599` and
  `UhdmWriter.cpp:2203`.
* **ROAD D's re-stamp** — `CompileHelper::adjustOpSize`
  (`CompileHelper.cpp:5114-5203`), reached from `expandPatternAssignment`
  (`:5421`), itself reached for a PACKAGE parameter through
  `CompileHelper::getValue`'s `pkg::NAME` arm and through
  `ExprEval::getValue`'s by-name flatten (UHDM `templates/ExprEval.cpp:337-347`)
  — the two roads § pkgNestedPatElabNoExpandSize34 and § patParamEvalFuncRead26
  already decode.

**ONE HONEST GAP.**  The source road that makes the elaborated package's OWN
Rhs survive a concat is *not* pinned to a line.  `compileExpression`'s tail
reduce (`CompileExpression.cpp:3671`) calls `CompileHelper::reduceExpr` (`:823`)
→ `ExprEval::reduceExpr` (UHDM `templates/ExprEval.cpp:3109`), whose
`case vpiConcatOp:` (`:3993-4183`) *does* build a folded constant, and
`m_skipOperationTypes` is empty (nothing in Surelog calls `reduceExceptions`).
So the code as read predicts a fold that golden does not produce.  The
BEHAVIOUR is measured on three independent grids below and is what the law is
written against; the missing line is recorded as a residue, not dressed up.

---

## 3. The golden grid

Runner `run54.sh` (inherited unmodified); shapes by `shape54.py`, the SHAPE
LISTER: it prints every `param_assign`'s Rhs tree per listing section
(`uhdmallPackages` = DEF, `uhdmtopPackages` = ELAB) with the Compare-visible
fields only (`VpiSize`/`VpiDecompile`/`VpiConstType`/`VpiName`/typespec kind).

### 3a. ROAD B — `vb1` + `vb2` re-cut, `wb1` new (ELAB package listing)

| arm | cell | golden ELAB | ours (pristine) | ours (patched) |
|---|---|---|---|---|
| vb1 | `P1 = C0+2'b01` | constant | constant ✓ | constant ✓ |
| vb1 | `P2 = ~C0` | constant | ✓ | ✓ |
| vb1 | `P3 = C0?C3:C0` | constant @12:40 | ✓ | ✓ |
| vb1 | `P5 = (C3)` / `P6 = 2'(C3)` / `P7 = C3+1` | constant | ✓ | ✓ |
| vb1 | `Q0 = pk::C3` / `Q1 = pk::C3+2'b01` | constant | ✓ | ✓ |
| vb1 | **`P4 = {C0}`** | op + `ref_obj` | op + **constant** | **op + `ref_obj`** |
| vb2 | `K1 {C0,C3}` / `K6` localparam / `K7` nested | op + 2 `ref_obj` | op + 2 constants | **equal** |
| vb2 | `K2 {2'b01,2'b10}` | op + 2 constants | ✓ | ✓ |
| vb2 | **`K3 {2{C0}}`** | op tree | **one constant** | **op tree** |
| vb2 | **`K4 {C0}+4'b0001`** | op tree | **one constant** | **op tree** |
| wb1 | `S1 <<` `S2 ?:` `S3 &` `S7` part-sel `S10 4'(C0+C3)` `T1` | constant | ✓ | ✓ |
| wb1 | `S4 {C0[1:0],C3[1:0]}` / `T0` cross-pkg | op + part_selects | ✓ | ✓ |
| wb1 | **`S5 = C0 ? {C0} : C3`** | **constant** @19:36 | constant | constant (unmoved) |
| wb1 | **`S6 = 4'({2{C0[1:0]}})`** | op tree | **constant** | **op tree** |
| wb1 | **`S8` localparam `{2{...}}`** | op tree | **constant** | **op tree** |
| wb1 | **`S9 = {C0,4'h5}`** | op + `ref_obj`, reordered | op + 2 constants | **equal** |
| wb1 | **`S12 = {...} & 4'hF`** | op tree | **constant** | **op tree** |
| wb1 | **`T2 = 4'({2{pk::C0[1:0]}})`** | op tree | **constant** | **op tree** |

`vb2` goes from `cmp_rc=255`, 45 cmp lines, 1 head to **`cmp_rc=0`, 0 lines,
0 heads — judge-EQUAL**.  `wb1`'s own head is unchanged (a cross-package
part-select naming cell in the DEF listing, not this law's), and every one of
its road-B cells is now golden's.

**`S5` is the cell the brief's V1 law did not have**, and it is why
`concatBearing54` does not descend into a conditional: golden answers a
conditional with the SELECTED branch's own reduction (a `BIN:0001` size-4
constant with no `vpiDecompile` — exactly `ExprEval::reduceExpr`'s
`vpiConcatOp` arm's output — stamped at the branch, `19:36`), so a concat in a
branch still substitutes.  A rule that recursed there would have turned a cell
we already match into a mismatch.

Module scope is out: `vb2`/`wb1`'s module controls `M1`/`M2` fold whole on both
sides, and stay folded.

### 3b. ROAD D — `vd1` re-cut, `wd1`/`wd2`/`wd3` new

`vd1`/`wd1` (the FLAT form, reached because the module writes `pk::L.a`):
golden's elaborated package re-stamps EVERY element to its member's width —
8 / 16 / 64 / 32 in `vd1` (`C: 32'd7` into a `logic [63:0]` member **WIDENS**
to 64 with `vpiDecompile:32'd7`, `DEC:7`, constType 1 all preserved), and
8/16/64/32/4/8/3/1 in `wd1`, the operation element `e: K + 1` reduced first.
Ours keeps the tagged tree at the compiled sizes.  **Not closed by this pass**
— see §5.

`wd2` vs `wd3` is the arm that decides road D, and it is one package written
twice differing ONLY in whether a const function takes the parameter whole:

| element | member | wd2 golden | wd3 golden | our pristine (both) |
|---|---|---|---|---|
| `A: 64` | `int unsigned` | 64 | **32** | 64 |
| `B: unsigned'(64)` | `int unsigned` | 64 | **32** | 64 |
| `C: $unsigned(64)` | `int unsigned` | 64 | **32** | 64 |
| `D: 32'(5)` | `logic [7:0]` | 32 | **8** | 32 |
| `E: NR + 1` | `int unsigned` | 64 | **32** | 64 |
| `L: 128'({64'b0,64'b0})` | `logic [NR-1:0][63:0]` | no size | **vpiSize:128** | no size |

`wd3` adds `function automatic r_t build(u_t c);` and
`parameter pk::r_t R = pk::build(pk::BASE)`.  Nothing else differs.

---

## 4. THE LAW THAT LANDS — § pkgElabConcatTreeNoFold54 (ROAD B)

> In the ELABORATED PACKAGE listing the producer replaces the whole Rhs with
> its reduced object **unless the Rhs tree contains a concatenation or a
> replication anywhere**, the refusal recursing into operands.  A kept tree is
> the DEFINITION listing's tree, down to its `ref_obj` leaves and their
> `vpiActual`.  A conditional is answered with its SELECTED branch's reduction,
> so the walk does not descend into one.  Binary/unary operations, width casts,
> part-selects, parenthesised reads and cross-package reads all substitute.

Two code sites, both in `src/ParamEmit.cpp`, both inside `emitParameters`:

1. the generic `tryFoldConst` fence — the existing
   `!(inPackage && <top-level concatenation under casts>)` conjunct is widened
   to `!(inPackage && concatBearing54(*init))`, which adds the REPLICATION and
   the concat-under-an-operation cases (`K3`, `K4`, `S6`, `S8`, `S12`, `T2`);
2. `pkgElabSymOperands` — the flag that already names the `Reduce::No` road for
   a MULTIDIMENSIONAL package parameter — is set for the same predicate, so the
   surviving tree keeps its `ref_obj` leaves bound through `pkgParamDefRhs`
   (`P4`, `K1`, `K6`, `K7`, `S9`).

`concatBearing54` is 16 lines; the law, the producer citation, the conditional
exception and the whole grid are in the comment above it.

---

## 5. ROAD D — WHAT WAS MEASURED, AND WHY IT DOES NOT LAND

**The brief's D-law is: "the elaborated PACKAGE copy re-stamps EVERY
assignment-pattern element constant to ITS OWN typespec_member's width".  That
is false as a property of the view.**  `wd2` is the counter-arm: an elaborated
package listing whose six pattern elements — bare literal, `unsigned'()`,
`$unsigned()`, a size cast, an operation and a 128-bit cast — golden leaves at
their compiled sizes, and which our pristine binary already matches cell for
cell.

A build that stamped on the view alone was made, swept and scored.  It moved
**ten uhdm2rtlil rows and eight surelog rows**, every one of them
`CMP_EQUAL -> CMP_NOTEQUAL`, i.e. AWAY from golden:

```
uhdm2rtlil  ff_dead_both_branches  ff_dead_guarded_reset  struct_param_repl_count
            iface_scalar_localparam  iface_nested_param_field
            iface_struct_field_param_width  iface_struct_field_partsel
            ImportedDoubleCastedParameter  TypedefStructParamWithRangeInSubmodule
            NestedStructArrayParameterInitializedByPatternPassedAsPort
surelog     AssignmentPatternInAssignmentPattern  Earlgrey_0_1  FuncStructVal
            GenForIfaceLocalparamNestedGen  GenForStructParamBound
            GenIfIfaceParamStructField  InterfaceParamOverrideProp  (+1)
```

Golden's elaborated listing for each of those carries the DEF sizes — e.g.
`ff_dead_both_branches` `cfg_pkg::Cfg = '{XLEN: 64, RVH: 1'b0}` keeps `XLEN` at
**64**, and `ImportedDoubleCastedParameter`'s `kmac_pkg::A` cast op carries **no
size at all**.

**THE TRIGGER IS A READER, AND `wd3` NAMES ONE OF ITS FACES.**  A second build
gated the stamp on "this package parameter appears as a CALL ARGUMENT inside a
parameter declaration" — the const-function whole read whose in-place reduce
§ patParamEvalFuncRead26 already decodes.  That build reproduces `wd3` and the
corpus witness EXACTLY (`cfg_pkg::Base` becomes XLEN 32 / NrRules 32 /
`vpiSize:1024` on Length's cast op, and the row's head clears and advances to
TRIAGE2's C3 anonymous-struct family, 18 -> 37 cmp lines) — **but it still
breaks `FuncStructVal`**, which has that exact shape:

```
  parameter config_pkg::cva6_cfg_t CVA6Cfg =
      build_config_pkg::build_config(cva6_config_pkg::cva6_cfg);
```

and whose `cva6_config_pkg::cva6_cfg` golden leaves at the compiled sizes.  So
the const-function read is NECESSARY (wd2 vs wd3) and NOT SUFFICIENT
(FuncStructVal).  The conjunct that separates `cfg_pkg::Base` / `pk::BASE` from
`cva6_config_pkg::cva6_cfg` is the open question — the candidates the evidence
leaves standing are (a) the struct's own package vs the function's package vs
the parameter's package (Base/BASE have all three in one package; cva6_cfg has
three different ones), and (b) the function BODY's shape (Base's `build_config`
is three statements, cva6's declares twenty initialised locals first).  Both are
one arm each; neither is guessed here.

**Nothing of road D is in the patch.**  What is committed is the grid
(`wd1`/`wd2`/`wd3`), so the next pass cuts the remaining conjunct from a
measured baseline instead of from the brief.

---

## 6. Census, movers and the positive control

**A-priori prediction, BY NAME, before the patched sweeps.**  `cen54.py` is the
superset (any package parameter whose Rhs carries a brace; 126 test
directories, both corpora, `project.f` filelists followed — without that the
u2r witness `ibex_tracer` is invisible, its sources living in `../ibex/rtl/`).
`pred54.py` is the tight list that models the two gates directly: **60
directories**, 42 B-only, 10 D-only, 8 both.  POSITIVE CONTROL: both dispatched
witnesses come out of the scan — `uhdm2rtlil ibex_tracer B` and
`surelog StructParamFuncBodyFieldCompare D`.

**Measured movers (patched vs my own pristine workdirs, `byteverify.sh`
`SELFCHECK=1`):**

```
uhdm2rtlil   1608 paths, PATH_SETS_IDENTICAL, SELFCHECK 1607/1608
  MOVER ./default/ibex_tracer-573593b3/slang.uhdm
  MOVER ./testflags/ibex_tracer-573593b3/slang.uhdm
  MOVERS: 2 / 1608                       <- both PREDICTED BY NAME (road B)

surelog      960 paths, PATH_SETS_IDENTICAL, SELFCHECK 959/960
  MOVER ./default/MiniAmiq-544c7f61      ./default/Scoreboard-59431470
  MOVER ./testflags/MiniAmiq-544c7f61    ./testflags/SeqDriver-32af76aa
  MOVERS: 4 / 960                        <- the UVM COIN, not the law
```

**The four surelog movers are attributed to the documented nondeterminism, with
a positive control.**  Order-blind (sorted, path-normalised):

```
default/MiniAmiq     4 lines   < UINT:843   > UINT:651   (+ the two vpiDecompile)
testflags/MiniAmiq   4 lines   < UINT:968   > UINT:0
testflags/SeqDriver  4 lines   < UINT:1270  > UINT:561
default/Scoreboard   0 lines   -- a pure ORDER move (the svunit_pkg
                                  `vpiTaskFunc` list flip), byte-different and
                                  content-identical
```

POSITIVE CONTROL: the PRISTINE binary run a SECOND time into a third workdir
(`--filter 'MiniAmiq|SeqDriver|SimpleUVM|Scoreboard|BuildUVMPkg'`) moves four
of five UVM files against the first pristine sweep, with different values again
(`default/MiniAmiq` 843 -> 1388, `default/SeqDriver` 0 -> 1201,
`testflags/MiniAmiq` 968 -> 0, `testflags/SeqDriver` 1270 -> 0) and
`default/SimpleUVM` drawing byte-identical — the documented 0-or-4-line class,
including the 0-line draw.  So the class is the binary-independent coin, and
the patched sweep drawing a DIFFERENT subset of the same five names (SimpleUVM
out, Scoreboard in) is itself the coin's signature.  All of these rows stay
`CMP_EQUAL`.

**`ibex_tracer` moves TOWARD golden, line by line.**  Order-blind whole-dump
against its own golden:

```
              golden-only   ours-only
pristine         17375        4134
patched          17103        3862      (-272 / -272)
```

and the 420 changed dump lines are exactly 42 constants replaced by 42
`ref_obj (ibex_tracer_pkg::OPCODE_C<n>)` carrying `vpiName` / `vpiFullName` /
`vpiActual -> constant`.  **TO-GOLDEN 272, AWAY-GOLDEN 0, MOVED-WRONG 0.**

Its head CLEARS and ADVANCES: the road-B `ref_obj (OPCODE_C0)` head is gone and
the new head is an ours-only `enum_const (OPCODE_LUI)` — one of the 276
ours-only `enum_const` lines FOLDMAP already names in the residue — with cmp
lines 36 -> 19 in both modes.  **ADVANCE, not CONVERT**, exactly as predicted.

**The protected databases, by md5, patched vs pristine — every one SAME, and
every absolute pin at its stated value:**

```
SVSwitch            default/testflags  4842211c4030   (HARD BYTE PIN)
YosysVerx           default/testflags  6ccda350c24a   (HARD BYTE PIN)
InterfaceModPort    default/testflags  59a365f3ce2c
BlackParrotComplex  default e3e354129d5a  testflags 73a10e8217e5
YosysOldOr          default/testflags  d68e0796d62c
Earlgrey_0_1        default 8bdf25272e08  testflags 59d0ee6d10c3
```

`canaries.sh` ok=52 changed=0 (surelog) and ok=8 changed=0 (uhdm2rtlil);
`ctcan2.sh` PASS on both; `canaudit.sh` (r10uvm221repro, the current
generation) audited=29 UNCOVERED=0 FENCE-BREACH=0.  The UVM family's databases
stay pristine-nondeterministic and their rows stay `CMP_EQUAL`.

---

## 7. Gates (all green, patched binary vs the committed baselines)

1. **Builds.**  Pristine build in this pass's own worktree =
   `cf14ad224f6125a553825b3a6d29c842`, byte-identical to the main tree at
   `a7b98161`.  Patched build md5 recorded in the ops log; both frozen
   `chmod 555` before any sweep, and every `cmds.txt` audited by BINARY PATH.
2. **Goldens.**  `check_goldens.sh` 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false`
   0 PASS / 23 FAIL (negative control).
   Every `cmds.txt` audited by BINARY PATH: 1531 surelog + 1742 uhdm2rtlil arms
   name the patched binary in the patched workdirs and the pristine one in the
   pristine workdirs, with no third path anywhere.
3. **uhdm2rtlil, both modes.**  `ct8rows.sh` vs `results/gate_uhdm2rtlil.csv`,
   vs the `default` half of `results/golden_uhdm2rtlil.csv`, and vs this pass's
   own pristine sweep: **0 differing rows** in all three.
   784 CMP_EQUAL / 20 CMP_NOTEQUAL / 67 SLANG_REJECT, both modes, unchanged.
4. **surelog, `--mode both`.**  `ct8rows.sh` vs `results/golden_surelog.csv`
   and vs this pass's own pristine sweep: **0 differing rows** other than two
   `SURELOG_FAIL` rows whose detail column echoes the workdir path
   (`LowMemLib`, `LowMemPkg` — a path artifact, not a status change).
   474/9 default + 469/8 testflags, unchanged.
5. **byteverify `SELFCHECK=1`** against this pass's own pristine workdirs —
   §6, every mover named and attributed.
6. `results/*.csv` untouched.  No row CONVERTS; two heads ADVANCE.

---

## 8. Residues left standing, and R0

* **R0 — ROAD D's remaining conjunct.**  The member-width re-stamp of an
  elaborated package pattern element is REAL (`wd3`), is triggered by a
  const-function whole read (`wd2` vs `wd3`), and that trigger is not
  sufficient (`FuncStructVal`).  Two arms decide it: one moving `wd3`'s struct
  typedef and its builder function into a SECOND package, one giving `wd3`'s
  builder twenty initialised locals before the member writes.  Closing it closes
  `StructParamFuncBodyFieldCompare`'s head (its residue is 345/339 and the next
  head is TRIAGE2's C3 anonymous `struct_typespec`).
* **The FLAT road-D form** (`vd1`/`wd1` `L`/`P`): golden flattens a >64-bit
  package struct pattern that is `pkg::NAME`-read outside a parameter
  declaration, and re-stamps its operands; the WIDTH RULE
  (`ParamEmit.cpp` ~13119) keeps ours tagged.  Its own siblings are §49's
  recorded positional re-size residue and `vd1`'s V4 head (the unpacked-ARRAY
  pattern localparam's `vpiSize:1` + anonymous `array_typespec` vs golden's
  named `barr_t` and no size) — measured, fenced, NOT chased, per caution (b).
* **`wb1` S11** `-C0`: golden `INT:-1` / `vpiDecompile:-1` / constType 7, ours
  `UINT:15` / `15` / constType 9 — a unary-minus encoding residue, untouched.
* **`wb1` S5**: golden's substituted constant is `BIN:0001` size 4 with NO
  `vpiDecompile`, ours `UINT:1` decompile `1` — the conditional-branch fold's
  encoding, untouched by this pass and unchanged by it.
* **The unpinned producer line** for the elaborated package's own-Rhs concat
  refusal (§2's gap).

## 9. Ops record

Worktree `/tmp/wt_r11u54` at `a7b98161`; scratch `/tmp/r11u54_*`; workdirs
`/tmp/r11u54_wdp` (pristine control, built by this pass), `/tmp/r11u54_wdr`
(patched), `/tmp/r11u54_wdctl` (the nondeterminism positive control).  Binaries
frozen at `/tmp/r11u54_pris.bin` and `/tmp/r11u54_pat*.bin`, `chmod 555`.  No
shared `/tmp/ctl_wd_*` control was read.  `GOLDEN_DEFER` unset; all builds
`-j 2`; no fenced test was ever dispatched.

## 10. Instruments (all measurement-only; the judge is `uhdm-cmp`)

* `shape54.py` — the SHAPE LISTER: every `param_assign` Rhs tree, per listing
  section, Compare-visible fields only.
* `cen54.py` — the superset census by name (follows `project.f` filelists).
* `pred54.py` — the tight a-priori mover prediction, with the two witnesses as
  its positive control.
* `run54.sh` — the grid runner (inherited from r11u51/r11u35 unmodified).
