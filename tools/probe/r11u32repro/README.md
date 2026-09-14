# r11u32 — the named-type declaration's two halves (and the third it uncovered)

Base `b44b24b1`, pins as `SUPPORT_MATRIX.md` states them (slang upstream-master
`7d61e0ad1` + UHDM v1.87, Surelog v1.87 the golden producer, uhdm2rtlil v0.68).
Target: the r11u29 triage's **K2** (corrected rank #2), with **K9** measured
beside it because the triage put both on "the named-type declaration road".

Everything below was measured on this pass's own builds; nothing is carried
forward from the triage's write-up.

---

## 1. The heads, re-measured on this pass's own pristine build

Pristine build in this pass's worktree is byte-identical to the main tree at
the base (`md5 0fc7b2ec16a79f41b5bc73ef10275de1`), and all fourteen rows
reproduce as `CMP_NOTEQUAL`, one head each (`evidence/heads_pristine.txt`,
`evidence/heads_quoted.txt`).

| row | head |
|---|---|
| `arb_idx_cast`, `gen_scope_numports`, `latch_packed_enum_loop`, `packed_array_reset_loop`, `param_name_collision_typeparam` | a def-view `logic_net` whose two decompiles differ in exactly one line: ours carries `|vpiNetType:36`, golden carries none |
| `struct_member_cfg_width`, `packed_array_struct_port_sel` | `RHS: <null>` on a golden `ref_typespec` — golden's net/var carries `vpiTypespec -> ref_typespec -> struct_typespec`, ours carries none |

`nets::Compare` reads `VpiNetType` (the pinned UHDM v1.87 tree's generated
`nets.cpp`), so the first face is judged.

## 2. The ELAB-view object-kind census the triage demanded

`kindcensus.py` sections each uhdm-dump the way §8 of RESUME prescribes —
DEF = `|uhdmallModules:`…`|uhdmtopModules:`, ELAB = `|uhdmtopModules:`…
`\_weaklyReferenced:`, and the TAIL is never counted — and joins the two sides
on `(section, vpiFullName)` as a **multiset** of object kinds, with a SHAPE
LISTER (per-kind row counts per section, both sides) printed beside it.
Calibrated golden-vs-golden to **0 disagreements on all seven designs** first;
golden-vs-ours then reads 19 / 14 / 0 / 4 / 3 / 5 / 3
(`evidence/*.census.txt`).

What it establishes, and it is what decided this pass's scope:

* `latch_packed_enum_loop` has **zero** kind disagreements — the `vpiNetType`
  stamp is its *only* difference, so the DEF half alone converts it;
* `gen_scope_numports`, `packed_array_reset_loop`,
  `param_name_collision_typeparam` disagree ONLY on (a) golden carrying a
  `packed_array_var` where we carry a `logic_net`/`logic_var` for the same
  declaration, and (b) the elab `type_parameter`'s own fullname/typespec —
  and (b) turned out to be invisible to the judge (all three go CMP_EQUAL with
  (a) fixed and (b) untouched; no generated `Compare` reads `VpiParent`, and a
  shared def object prints abbreviated at its second sighting);
* `arb_idx_cast` disagrees on a dozen unrelated rows — a `$unsigned` operand
  missing from a def-view `gen_for` condition, an `unsupported_typespec idx_t`,
  gen-scope `bit_select`/`ref_typespec` gaps. **Predicted NOT to convert**, and
  it did not: its head moved off this family onto the `$unsigned(genvar)`
  operand-vector gap (`evidence/heads_after_lawA.txt`);
* `struct_member_cfg_width`'s one DEF disagreement is the missing
  `ref_typespec` on `work@struct_member_cfg_width.fu_data_i` — a declaration
  with **no dimension at all**, i.e. a cell neither K2 half reaches. §5.

## 3. The GOLDEN GRID — 44 arms, and the dimension is not the distinguisher

`gengrid.py` writes one module per arm so every signal name is unique, and a
top instantiates all of them (an arm with no elab view would read as *agreeing*
while testing nothing). Axes: name kind {type parameter bound to a logic
vector / to an enum / to a struct; module-local typedef of a vector / enum /
struct; package typedef named unqualified / named scoped} x dims {none, packed
extra, unpacked} x position {body net, input, output}. Data ports are left
unconnected on purpose — a module-local enum or struct is a distinct type from
the package one, so no single top wire can legally drive them all, and nothing
under test is gated on a connection. `gridread.py` reads the DEF-view
`vpiNetType` and the ELAB-view object kind per arm; calibration golden-vs-
golden is **0 DEF-DIFF / 0 ELAB-DIFF**. Both producers compile the grid at
`rc 0` with no error (`evidence/grid_pristine.txt`).

Golden's DEF-view `vpiNetType`, read off the grid:

| name kind | `T x` | `T [1:0] x` | `T x [1:0]` |
|---|---|---|---|
| type parameter (logic / enum / struct binding) | none | none | none |
| module-local typedef of a logic vector | **36** | **36** | **36** |
| module-local typedef of an enum | none | none | none |
| module-local typedef of a struct | none | none | none |
| package typedef, named unqualified | **36** | **36** | **36** |
| package typedef, named SCOPED | none | none | none |

**The dimension plays no part in the DEF half.** `vpiNetType` is stamped iff
the written name is an UNQUALIFIED logic-vector typedef; a type parameter, or
an enum/struct leaf, prints none at every dimension and every position. The
five K2 rows all sit on the *dimensioned* cells only because a packed dim makes
slang parse the name as an `IdentifierSelectName`, which the dimension-less
`portTypeParam` guard cannot see — the same parse split the emitter's own
`§ unqualDimNet9` note already records. `arb_idx_cast` proves it inside one
design: `idx_t idx_o` (no dim) already agreed; `idx_t [2**NumLevels-2:0]
index_nodes` did not.

Golden's ELAB-view object kind, same grid: a packed extra dimension makes the
declaration a `packed_array_var` for every name kind except a struct-bound one
(which is a `packed_array_net`), **at a port exactly as in the body** — the
port position is not a distinguisher.

## 4. The two laws

**§ namedTypeLeafNoNetType32** (`src/EmitHelpers.h`, the `NamedType` branch of
`netTypeFor`, beside the struct-leaf rule it generalises): descend the packed
dims to the leaf alias; a leaf whose syntax is a `TypeAssignment` (slang's
spelling of a type parameter, never a `typedef` — `typeParamOfAlias`) or whose
canonical type is an `EnumType` prints **no** net type.

**§ namedTypePackedDimElabVar32** (`emitTypeParamArrayVar`, `src/TypeEmit.cpp`,
called from the elab signal loop in `src/ModuleEmit.cpp` *ahead of* the
port/body split that used to hide it): a packed-dim declaration whose written
name is a TYPE PARAMETER bound to a logic vector elaborates as a
`packed_array_var` — the written dims as `vpiRange`, one bare `logic_var`
element, and a `vpiTypespec` ref to the ONE typespec object the type parameter
resolved to (`typeParamElabTs`, the same object `portTypeParam` already shares
for the dimension-less cell, so the two views cannot drift apart). The gate is
the LOGIC-VECTOR leaf: an enum- or struct-bound type parameter already reaches
its own factory and already matches golden, so firing there would move an
agreeing cell.

After the two laws the grid reads **DEF-DIFF 2, ELAB-DIFF 6** (from 9 and 9),
with **no arm moved away** (`evidence/grid_lawAB.txt`).

## 5. K9 — ONE law does NOT cover it, and here is what does

The triage put K2 and K9 on one road ("a declaration whose written type is a
NAME"). At the level of the *fix* they are not one road, and the census says so:

* `packed_array_struct_port_sel` is a STRUCT-bound type parameter; both halves
  above deliberately do not reach it (firing there would move an agreeing
  cell), and its row is unchanged by this patch. Its residue is the same
  `struct_net`/`packed_array_net` face as grid arms `x_tps_*` (§6).
* `struct_member_cfg_width` is `fu_data_t fu_data_i;` — **no dimension at
  all**, so neither K2 half reaches it. Its missing typespec is produced by a
  different, already-landed clause, and it took a third purpose-built golden to
  name the distinguisher.

**§ typeParamArgNetNeedsNonAnsi32** (`defNetOmitsTypespec224`,
`src/ModuleEmit.cpp`): the landed clause "a local net typed by a typedef used
as a child instance's `type` parameter argument stays a bare `logic_net` in the
def view" needs the **NON-ANSI header gate** its sibling clause already
carries. Two purpose-built goldens, each calibrated golden-vs-golden to 0
(`k9.sv`, `k9b.sv`, `evidence/k9_probes.txt`):

* `k9.sv`, 2x2 over header {ANSI, non-ANSI} x typedef {passed as a child
  instance's `type` argument, not passed}: golden KEEPS the def-view typespec
  in **both** ANSI cells and strips it in **both** non-ANSI cells — the
  `type`-argument axis moves nothing;
* `k9b.sv` widens the ANSI cell over the typedef's own kind and the
  declaration's shape — struct, logic vector, enum, package typedef named
  unqualified, the same one named SCOPED, and a `var t_t x = '0;` with an
  initializer — and golden keeps the typespec in **all six**, with the non-ANSI
  arm beside them as the control that still strips.

The ungated clause stripped all six ANSI cells; gated, all eleven cells agree
(`evidence/k9_probes_lawC.txt`). It is a strict narrowing — the clause can only
ever ADD a typespec back — and the head of `struct_member_cfg_width` moves off
K9 onto a `param_assign` struct-constant encoding face. The row does not
convert; K9's other row does not move at all.

## 5b. What converted, and the gates

**Four rows CONVERT, both modes** — `latch_packed_enum_loop` (law A alone; its
census had no other disagreement, which is how it was predicted),
`gen_scope_numports`, `packed_array_reset_loop`,
`param_name_collision_typeparam` (laws A+B). uhdm2rtlil goes
**768 → 772 CMP_EQUAL / 36 → 32 CMP_NOTEQUAL in each mode**; the surelog corpus
is unmoved (474/9 default, 469/8 testflags, before and after). `arb_idx_cast`
and both K9 rows stay `CMP_NOTEQUAL` — every one of them was predicted not to
convert, and each moved TOWARD golden.

Gates, all against this pass's OWN pristine sweeps (the committed baselines
were reproduced by that pristine run first, the only two differing rows being
`SURELOG_FAIL` detail strings that embed the workdir path):

* pristine build byte-identical to the main tree at the base
  (`0fc7b2ec16a79f41b5bc73ef10275de1`); patched `5de09f4c516a1d7a01a6471153420dac`;
* `tests/check_goldens.sh` 23 PASS / 0 FAIL, and the `SLANG_UHDM=/bin/false`
  negative control 0 PASS / 23 FAIL;
* whole-row diff (status AND dump column) over both corpora, both modes: only
  the four converted rows differ, each quoted above;
* byte movers, patched vs pristine, with `SELFCHECK` as the positive control
  (803/804 and 959/960 flagged, so the instrument can see): **6 / 804** in each
  uhdm2rtlil mode — the five K2 rows plus `struct_member_cfg_width` — and every
  one was PREDICTED BY NAME from the sources before the patched sweep ran
  (`evidence/predictions.txt`, `evidence/byteverify_u2r.txt`);
* surelog: **5 / 960**, all of them the UVM coin — MiniAmiq (both modes),
  SeqDriver and SimpleUVM (default) on the documented 0-or-4-line line-number
  class, and Scoreboard (default) at **0 order-blind lines**, the documented
  pure `vpiTaskFunc`-order flip. Proved to be the producer's own
  nondeterminism by running the PRISTINE binary twice over the same three rows
  and getting three different databases with the same class
  (`evidence/uvm_coin.txt`). Those rows are CMP_EQUAL before and after;
* the protected databases are byte-identical by name, all twelve
  (`evidence/canaries.txt`): the HARD byte pins `SVSwitch 4842211c4030` and
  `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`,
  BlackParrotComplex, YosysOldOr, and `Earlgrey_0_1` at both of its pins
  (testflags `59d0ee6d10c3`, default `8bdf25272e08`). Earlgrey_0_1's canary row
  reads `changed` on the DUMP COLUMN alone — `CMP_EQUAL/differ ->
  CMP_EQUAL/` — which is the uhdm-dump timeout draw the ops rules name, and its
  database byte-compare, the actual pin, holds exactly;
* TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG per mover, order-blind, in the judged
  (location-blind) view, calibrated golden-vs-golden-vs-golden to 0/0/0:
  **AWAY-GOLDEN 0 everywhere** (`evidence/toaway.txt`). The single nonzero
  figure, `gen_scope_numports`' 4, is entirely the COUNT of the literal string
  `|vpiParent:` at one indentation level — no generated `Compare` reads
  `VpiParent`, and the official judge reads that row CMP_EQUAL in both modes;
* canaries: uhdm2rtlil `ok=8 changed=0`, surelog `ok=51 changed=1` (the
  Earlgrey_0_1 dump-column draw above, status unchanged), supplementary
  `ctcan2` PASS on both corpora, `canaudit` `audited=29 UNCOVERED=0
  FENCE-BREACH=0`;
* the patch applies cleanly (rc 0, no conflict markers) on a fresh `b44b24b1`
  and on `c731550c`, the head that landed beside this pass.

## 6. Residues this pass measured and did NOT touch

* `x_pkl_unp_net`, `x_tdl_unp_net` — an UNPACKED dimension on an unqualified
  logic-vector typedef: golden stamps 36, we print none. A pre-existing gap in
  the same producer, unchanged by this patch, now pinned by a grid cell.
* `x_pklq_pk_in`, `x_pklq_pk_out` — a packed-dim SCOPED package typedef at a
  PORT: golden elaborates a `packed_array_var`, we keep a `logic_net` (the body
  cell `x_pklq_pk_net` already agrees). The same port/body split law B closes
  for type parameters, one name kind over.
* `x_tps_nod_net`, `x_tps_pk_{in,net,out}` — a STRUCT-bound type parameter:
  golden is `struct_net` / `packed_array_net` where we are `struct_var` /
  `packed_array_var`. This is the `structTsIsNetStrict` (r10e88) face at a type
  parameter, not a named typedef.
* `arb_idx_cast` — head now on the `$unsigned(genvar)` operand-vector gap in a
  def-view `gen_for` condition (the K3 face the r11v29 verifier split out).

Each is carried into §7 with the grid cell or the head that pins it.

## 7. R0 — the next heads, each already named by a measurement here

* **R0** — `packed_array_struct_port_sel` and grid arms `x_tps_nod_net`,
  `x_tps_pk_{in,net,out}`: a STRUCT-bound type parameter. Golden is
  `struct_net` / `packed_array_net` where we are `struct_var` /
  `packed_array_var`, and golden's `packed_array_var` for the overridden case
  carries a `ref_typespec` we do not mint. This is the `structTsIsNetStrict`
  (r10e88) net/var test asked at a type parameter instead of at a named
  typedef — four grid cells and one corpus row, all in one place.
* **R1** — `x_pklq_pk_in`, `x_pklq_pk_out`: a packed-dim SCOPED package typedef
  at a PORT elaborates as a `packed_array_var` in golden and stays a
  `logic_net` for us, while the body cell `x_pklq_pk_net` already agrees. The
  same port/body split law B closes for type parameters, one name kind over —
  the factory and the call site are already in the right place.
* **R2** — `x_pkl_unp_net`, `x_tdl_unp_net`: an UNPACKED dimension on an
  unqualified logic-vector typedef. Golden stamps `vpiNetType 36`, we print
  none. Pre-existing, in the same `netTypeFor` branch law A now owns.
* **R3** — `struct_member_cfg_width`'s head after law C: a `param_assign`
  whose Rhs is a 64-bit `BIN` struct constant (`cfg_pkg::cfg_t CFG`), i.e. the
  landed encoding family, not this road.
* **R4** — `arb_idx_cast`: a `$unsigned(genvar)` operand missing from a
  def-view `gen_for` condition's operand vector (golden's operation has two
  operands, ours one). The K3 face the r11v29 verifier split out; one cmp head,
  nothing to do with the named type.

## 8. Reproducing

```bash
# the grid (both producers, rc recorded)
python3 gengrid.py grid.sv
surelog -parse -nobuiltin -nocache -sv -d uhdm grid.sv     # -> slpp_all/surelog.uhdm
$SLANG_UHDM grid.sv --single-unit -o ours.uhdm
uhdm-dump slpp_all/surelog.uhdm > g.raw; uhdm-dump ours.uhdm > o.raw
python3 gridread.py g.raw g.raw | tail -1     # CALIBRATION: 0 DEF-DIFF 0 ELAB-DIFF
python3 gridread.py g.raw o.raw

# the elab-view object-kind census over a verify_golden workdir
bash dumps.sh <workdir> default <outdir>
python3 kindcensus.py <outdir>/<test>.default.g.raw <outdir>/<test>.default.g.raw CALIB
python3 kindcensus.py <outdir>/<test>.default.g.raw <outdir>/<test>.default.o.raw <test>

# the K9 probes
python3 tsread.py g.raw g.raw n_ | tail -1    # CALIBRATION
python3 tsread.py g.raw o.raw n_

# a-priori mover prediction, from the SOURCES, before any patched sweep
python3 predict.py ~/git-repos/uhdm2rtlil/test
python3 predict_sl.py <file holding the fenced names, one per line>

# TO-GOLDEN / AWAY-GOLDEN / STILL-WRONG per mover, order-blind
NOLOC=1 python3 toaway.py golden.uhdm pristine.uhdm patched.uhdm <tag>
NOLOC=1 python3 toaway.py golden.uhdm golden.uhdm  golden.uhdm  CALIB   # 0/0/0
```
