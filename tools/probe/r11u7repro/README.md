# r11u7 — § `ifacePortViewAggregateFlattens`

An interface PORT VIEW whose parameter default is a NESTED assignment pattern
shows the DECLARATION's own operation object — its span, its op type and its
ABSENT typespec — with only its OPERAND LIST replaced by the flattened member
values, each nested pattern stamped with its own member's typespec.

Everything here is MEASUREMENT-ONLY.  The judge is `uhdm-cmp` through
`scripts/verify_golden.py`.  The production surface is one queue + one applier
in `src/ModuleEmit.cpp`, its call site in `src/UhdmExporter.cpp`, and the two
members in `include/UhdmExporter.h`.

This pass was finished by a SECOND implementer on a worktree the first one
left behind, so every number in this file was re-measured from scratch on
binaries re-verified by md5 — the arms, the golden grid, the two heads, the
producer citations, both corpora in both modes, the wide boundary — and
`GATES.r11u7.txt` carries the re-measured battery.  Where the re-measurement
found something the first write-up did not, it is called out (the wide
boundary's empty-gate trap in §7, residue R6).

## 0. r11u4's residue R2 is REFUTED, and the head is somewhere else

R2 read this cell as a DEF-VIEW defect: "our interface DEFINITION view emits a
struct-parameter default as NESTED tagged_pattern members where golden emits
the bare member operation".  Measured here on its own real Surelog v1.87
golden, on a binary this pass built (`0cd3567badf786731e77120ee53a2fdc`, the
mandated pristine hash):

```
GenForIfaceLocalparamNestedGen, golden work@bus_if (the DEF view)
  op75@14:45 -> tagged_pattern[BUS]@12:37 -> op75@12:37
                  -> tagged_pattern[DAT]@12:44 -> constant UINT:32 size 64
OUR work@bus_if   the same tree, span for span, field for field
```

Golden's def view KEEPS the full nested `tagged_pattern` tree and ours already
reproduces it.  The whole residual difference lives on the PORT view
`work@top.c.sub`, and the pristine head is:

```
LHS: <null>
RHS: ref_typespec: (work@top.c.sub)
     |vpiParent: \_operation: , line:29:12, endln:29:19
     |vpiActual: \_struct_typespec: (p::cfg_t)
```

— a `vpiTypespec` golden does not carry, on an operation we built from the
INSTANTIATION site (`bus_if #(CFG_DEF)`, 29:12) rather than the declaration
(14:45).  Below it, a second Compare-visible difference: our inner op75 carries
`vpiSize:32`, golden's carries none.

## 1. The producer, decoded

`NetlistElaboration::elab_parameters_`
(Surelog v1.87 `src/DesignCompile/NetlistElaboration.cpp:262-419`) builds every
port view's param_assign vector:

```
pclone = clone_tree(mod_assign);   rhs = pclone->Rhs();          // 262-263
if (substituteAssignedValue(rhs))                                 // 264
    rhs = expandPatternAssignment(ts, rhs, ...);                  // 265
...
if (expr* tmp = eval.flattenPatternAssignments(s, tps, rhs))      // 412
    ((operation*)rhs)->Operands(((operation*)tmp)->Operands());   // 413-415
```

`ExprEval::flattenPatternAssignments` (UHDM v1.87
`templates/ExprEval.cpp:751-947`) reorders the `tagged_pattern` operands into
DECLARED MEMBER order (`tmp[i]`, 824-871), recurses on any member whose Pattern
is another op75 — and that recursion returns a FRESH clone carrying
`Typespec = fieldTypes[index]`, the member's own typespec (923-925, 940-941) —
then `recursiveFlattening` (653-746) drops each remaining `tagged_pattern`
wrapper for its `Pattern`.  It returns `opres`, a clone of the whole operation
that DOES carry the parameter's struct typespec.

WHICH OBJECT SURVIVES IS THE SPLIT the brief asked for.
`expandPatternAssignment` (`CompileHelper.cpp:5207-5501`) sets `result = rhs`,
re-flattens, and — because the flattened operand list holds no `tagged_pattern`
any more — takes the POSITIONAL arm (5397-5441), which per operand does
`get_uvalue(invalidValue, ...)`, then `adjustOpSize(...)` (which RESIZES the
operand in place), then `if (invalidValue) return result;`.

* **every member a scalar** → nothing goes invalid, every constant is resized
  to its member width, and the tail `result = rhs` (5497) hands back the
  FLATTENED CLONE, which carries the struct typespec.  That is the
  `op75 + struct ts -> bare constant` form; **our pristine emitter already
  produces it** and r11v4's guard already declines there.
* **some member an aggregate** → `get_uvalue` is invalid on it, the
  DECLARATION's own object survives with NO typespec, and line 413 swaps only
  its operands.  Members BEFORE the first aggregate one have already been
  resized; members after it have not.

## 2. The golden grid (h1-h5, real Surelog v1.87, every arm rc 0 / `[ERROR] : 0`)

`armrun.sh <armdir> <tag> <binary>` records surelog rc, its error count, the
slang rc, the cmp rc and the `^LHS:` head count.  `pashape.py <dump>` prints,
per interface view, the Rhs shape in Compare-visible fields only (kind,
`vpiOpType`, `vpiSize`, the value line, the typespec NAME) — no span, id,
fullname or parent, because no generated `Compare` reads one.

### The three views of one nested aggregate (h1, `q::cfg_t = {q::bus_t BUS}`)

| view | shape |
|---|---|
| `work@ia` DEF | `op75[ts=-](tagged[BUS](op75[ts=-](tagged[DAT](const sz=64))))` |
| `top.ua` HOME | `op75[ts=cfg_t](op75[ts=bus_t](const sz=64))` |
| `top.a0.p` PORT | `op75[ts=-]` `(op75[ts=bus_t](const sz=64))` |

Three levels recurse (`top.c0.p`:
`op75[ts=-](op75[ts=cfg_t](op75[ts=bus_t](const sz=64)))`), and the inline
default (`ib`) reads the same as the package-localparam one (`ia`).

### Holder forms x port forms (h4) — the shape is a property of the PORT VIEW

`a0` named plain, `a1` positional plain, `a2` NAMED MODPORT, `a3` named plain
onto the un-overridden instance, `a4` array element, `a5.r` re-passed port,
`a5.b0.q` the re-pass's own leaf, `g.a6.q` inside a generate block: EVERY one
reads `op75[ts=-](op75[ts=bus_t](const sz=64))`.  `a2` — the exempt
named-modport cell — wears the same SHAPE with the CONNECTED value
(`UINT:64`, `ovr=1`), which is r11u4's exemption unchanged.

### The two shapes this pass deliberately does NOT ship (h2, h3)

| arm/view | golden |
|---|---|
| h2 `f0.p` `fs_t = {int SCA; bus_t BUS}` | `op75[ts=-](const(UINT:5,sz=32),op75[ts=bus_t](const sz=64))` |
| h2 `s0.p` `sf_t = {bus_t BUS; int SCA}` | `op75[ts=-](op75[ts=bus_t](const sz=64),const(UINT:5,sz=64))` |
| h3 `o0.p` keys OUT OF ORDER `'{S:9, T:'{A:1,B:2}}` | `op75[ts=-](op75[ts=two_t](1,2),const(9,sz=64))` |
| h3 `i0.p` inner POSITIONAL `'{T:'{3,4}, S:9}` | `op75[ts=-](op75/sz64[ts=-](3,4),const(9,sz=64))` |

`f0`'s LEADING scalar is resized 64 -> 32 and `s0`'s TRAILING one is not —
`adjustOpSize`'s walk stopping at the first aggregate, measured.  `i0`'s inner
op carries NO typespec and a `vpiSize` instead, because the inner
`flattenPatternAssignments` takes its constant-operand early return (859-864)
and stamps nothing.  `o0` proves the reorder into declared-member order.

`s0` and `o0` this pass CONVERTS (their first declared member is the aggregate
one).  `f0` and `i0` it declines — see residue R1.

## 3. The law, and its gate

Queued in `emitInterfaceInstance` (the r11u4 port-view block, a third arm of
the same if/else chain, after face (B)'s `!hasTaggedMember4` guard), applied in
`applyIfacePaFlatten7()` from `exportDesign`.

DEFERRAL IS FORCED, and measured: at emission time the port-view parameter's
`Typespec()->Actual_typespec()` is still NULL (a trace build on
GenForIfaceLocalparamNestedGen printed `lhsRt=1 lhsAct=-1`, and the same for
our own Rhs operation's ref).  Every param typespec ref on a port view is bound
later, in exportDesign's `pendingParamTs` drain, so the applier runs
immediately after it.

The gate fires only when Surelog's resize walk is a NO-OP:

* the def view's Rhs is an `op75` whose every operand is a `tagged_pattern`
  and whose every declared member is matched (the conditions under which
  `flattenPatternAssignments` runs to its end rather than taking one of its
  early returns), AND
* the FIRST DECLARED member's value is itself an `op75` that also satisfies
  those conditions.

Then the def Rhs is CLONED (never shared — a shared subtree reads judge-equal
and `uhdm-dump` ELIDES it as a repeat, which is how r11u4's own scorer read a
converted test as unchanged) and flattened: declared-member order,
`tagged_pattern` wrappers dropped for their Pattern, each nested pattern that
itself flattens stamped with its member's typespec.

## 3b. THE ROWS THAT CONVERT — LOUDLY

Two surelog tests, in BOTH modes, four rows, measured through
`scripts/verify_golden.py` with the official `uhdm-cmp` as judge:

    < GenForIfaceLocalparamNestedGen,default,CMP_NOTEQUAL,decompile:,,
    > GenForIfaceLocalparamNestedGen,default,CMP_EQUAL,,,differ
    < GenForIfaceLocalparamNestedGen,testflags,CMP_NOTEQUAL,decompile:,,
    > GenForIfaceLocalparamNestedGen,testflags,CMP_EQUAL,,,differ
    < GenIfIfaceParamStructField,default,CMP_NOTEQUAL,decompile:,,
    > GenIfIfaceParamStructField,default,CMP_EQUAL,,,differ
    < GenIfIfaceParamStructField,testflags,CMP_NOTEQUAL,decompile:,,
    > GenIfIfaceParamStructField,testflags,CMP_EQUAL,,,differ

The surelog corpus moves 465/18 -> 467/16 default and 461/16 -> 463/14
testflags.  uhdm2rtlil does not move at all, in either mode, and not one of
its 1608 databases changes a byte -- every u2r design with this shape connects
its interface with a NAMED MODPORT, which `namedModportPortView9` exempts.

`results/*.csv` is READ-ONLY to this pass and was not touched; promoting these
four rows is the master's step.

## 4. Files

| file | what it is |
|---|---|
| `h1/ h2/ h3/ h4/ h5/` | the golden-grid arms (one `dut.sv` each) |
| `armrun.sh` | build one arm's golden + our database, record every rc |
| `pashape.py` | the Compare-visible param_assign shape reader |
| `pacen7.py` | the census + the anti-regression agreement scorer |
| `predict7.py` | a-priori mover prediction from the corpus SOURCES |
| `predictdb7.py` | the same prediction from the PRISTINE DATABASES (a superset, and it says why) |
| `byteverify7.sh` | name every database whose bytes move between two workdirs |
| `run.sh` | rebuild every arm and score both binaries against golden |
| `wide7.sh` | the WIDE BOUNDARY: every committed interface arm, both binaries, with an ARMS_WITH_TWO_DATABASES assertion |
| `canaries.sh` `ctcan2.sh` `canaudit.sh` `ct8rows.sh` | the gate battery, copied from `r10uvm221repro` |

## 5. Reproduce

```bash
bash tools/probe/r11u7repro/run.sh   <pristine-binary> <candidate-binary> /tmp/<mine>_arms
bash tools/probe/r11u7repro/wide7.sh <pristine-binary> <candidate-binary> /tmp/<mine>_wide
python3 tools/probe/r11u7repro/predict7.py surelog --list
python3 tools/probe/r11u7repro/predict7.py u2r --list
python3 tools/probe/r11u7repro/predictdb7.py <a pristine verify_golden workdir>
```

`wide7.sh` resolves `armrun.sh` through `ARMRUN=` (default: the copy in the
committed tree).  Point it at your own worktree's copy when the pass is not
landed yet — see §7 for what happens when that path is wrong.

## 6. Residues, ranked, with witnesses

**R1 — the LEADING-SCALAR RESIZE half of the same producer rule.**  When a
member BEFORE the first aggregate one is a scalar, Surelog's
`expandPatternAssignment` has already resized its constant to the member's bit
width before `get_uvalue` goes invalid.  Witness h2 `top.f0.p`
(`fs_t = {int unsigned SCA; bus_t BUS}`): golden
`op75[ts=-](const(UINT:5,sz=32), op75[ts=bus_t](const sz=64))`, ours
`op75[ts=fs_t](const(UINT:5,sz=32), op75/sz32[ts=bus_t](const sz=64))`.  The
gate here declines that shape because reproducing it needs a member bit-width
evaluator (`Bits(typespec)`) this file does not have.  Second face, same
residue: h3 `top.i0.p`, whose inner pattern is POSITIONAL — golden's inner op
carries NO typespec and `vpiSize:64` instead (its inner
`flattenPatternAssignments` early-returns and `adjustOpSize` writes the size
onto the ORIGINAL object, not onto a discarded clone).  Neither shape is
reachable from either corpus.

**R2 — the HOME view's nested op carries a spurious `vpiSize`.**  Untouched by
this pass and visible on every arm: h1 `top.ua`
`op75[ts=cfg_t](op75/sz32[ts=bus_t](const))` against golden
`op75[ts=cfg_t](op75[ts=bus_t](const))`, and the same on `uc`, `ud_ovr`, `uf`,
`us`, `uo`, h4 `u_df` / `arr[0]` / `arr[1]`.  It is a HOME-view question, not a
port-view one, and it is what still separates those cells after this pass.

**R3 — an OVERRIDDEN view drops the outer typespec too.**  h4 `top.u_ov`
(home) and `top.a2.q` (the exempt named-modport port view) read golden
`op75[ts=-](op75[ts=bus_t](const UINT:64))` while ours reads
`op75[ts=cfg_t](op75/sz32[ts=bus_t](const UINT:64))`.  Surelog reaches those
through `complexVal = clone_tree(instance's expression)`, which carries no
typespec of its own.  `namedModportPortView9` correctly keeps this pass off
`a2.q`; closing it needs the OVERRIDE path, not the declaration path.

**R4 — a `default:` key in a struct pattern is not modelled.**  `'{A: 1,
default: 0}` would have this applier hand member B the SAME object the default
key wraps, where Surelog `clone_tree`s it (ExprEval.cpp:880-884).  The gate
excludes the shape in practice (member 0 must be an explicit nested pattern)
and no corpus row has it; recorded so the next pass does not rediscover it.

**R5 — r11u4's residue R1 (the scalar VALUE half of a port view) still
stands.**  h4 `a0.q` / `a1.q` / `a5.r` / `a5.b0.q` / `g.a6.q` read `W 9` and
`BYT 8` against golden's `4` and `4`.  This pass fixes the AGGREGATE parameter's
value as a side effect (it now comes from the declaration's tree, which is why
those views' `CFG` converts from `UINT:64` to golden's `UINT:32`), but the
scalar parameters beside it are still the connected instance's.

**R6 — `memberValue7` matches a pattern key BY NAME, then falls back
POSITIONALLY; `ExprEval` falls back by TYPESPEC KIND and otherwise BAILS.**
Read at UHDM v1.87 `templates/ExprEval.cpp:825-861`: a `tagged_pattern` key
that matches no field NAME is matched against the first field whose typespec
has the same `UhdmType`, and a key that matches neither returns `result`
unflattened, as does any declared member left without a value.  This applier's
`memberValue7` has no kind-match arm.  Bounded by measurement and by the
language:

* an UNDECLARED member name (`'{BOGUS: …}`) and a pattern that leaves a member
  uncovered are both rejected by slang, so no database is ever produced for
  them and the divergence is unreachable;
* a TYPE key (`'{bus_t: '{DAT: 32}}`, legal SV) written in DECLARATION order
  picks the same operand either way;
* a type key written OUT of declaration order makes this applier's positional
  pick land a non-aggregate on member 0, so the gate DECLINES and the cell is
  left exactly as pristine emitted it.

So the gap costs agreement, never correctness.  Closing it means porting the
kind-match arm and the bail, which is the same work as R1's member bit-width
evaluator and belongs with it.

## 7. What the RE-MEASUREMENT changed

The wide boundary (`wide7.sh`) was first run with `armrun.sh` resolved through
the MAIN tree, where this pass's directory does not exist until it lands.
Every one of the 47 arms ran nothing, produced no database, and the driver
printed `MOVED=0` — a perfectly green gate over an empty set, the §9 trap
verbatim.  `wide7.sh` now takes the path through `ARMRUN=`, counts
`ARMS_WITH_TWO_DATABASES`, and prints `NO-DATABASE <arm>` for any arm that
built nothing; re-run that way it finds 47/47 built and 4 arms moving.
