# r11u63 — § connPathRootOwnTs63

**THE ELABORATED PORT-CONNECTION `hier_path` TAKES ITS `vpiTypespec` OFF THE
ROOT OBJECT ITSELF — A FRESH `ref_typespec` PER PATH WHOSE `vpiActual` IS THE
ROOT NET/VAR'S OWN `Actual_typespec`, THE IDENTICAL OBJECT — AND IT TAKES IT
ONLY ON A NAMED CONNECTION.**

Base `9dc8c859`. One law, one new arm at one existing site, one new argument on
one existing helper, three golden grids, one corpus mover pair, both mode
columns scored, every gate green.
**`struct_member_cfg_width` ADVANCES: the missing `ref_typespec` head CLEARS in
both modes and the head moves to a pattern-operand `vpiSize` (17 -> 36 cmp
lines, the new head object's own size).** The row stays `CMP_NOTEQUAL` in both
modes; **no baseline row is promoted and `results/*.csv` is untouched.**

---

## 1. THE WITNESS HEAD, RE-MEASURED AT `9dc8c859`

r11u62's R0 named this head. Re-measured with a frozen pristine binary built in
this pass's own worktree (md5 `5fc453cd3a119cc5de0debfa68714d63`, **byte-identical
to the main tree at the base**), one head each (`grep -c '^LHS:'` = 1),
**17 cmp lines in BOTH modes** — and all 17 ARE this one head (the block prints
twice per side; `uhdm-cmp` writes `decompile:` twice for one head, the
`rowheads.sh` trap):

```
LHS (golden)                                        RHS (pristine)
ref_typespec: (work@tb.t.m.c.a_i.fu_data_i.operand_a)   <null>
|vpiParent -> hier_path (fu_data_i.operand_a) 19:19-19:38
|vpiFullName:work@tb.t.m.c.a_i.fu_data_i.operand_a
|vpiActual -> struct_typespec (fu_data_t) 25:13-29:6
```

The singular-overload `RHS: <null>` names OUR MISSING VALUE (RESUME §9's head
decoding). The design writes `inner c (.a_i(fu_data_i.operand_a))` at
`uhdm2rtlil/test/struct_member_cfg_width/dut.sv:19` — a struct-member field read
as a PORT-CONNECTION actual, inside `mid`, whose `fu_data_i` is a port typed by
the **type parameter** `fu_data_t`.
[evidence/HEAD.struct_member_cfg_width.pristine.cmp](evidence/HEAD.struct_member_cfg_width.pristine.cmp).

### ADVANCE vs CONVERT — predicted BEFORE the sweeps, from the keyed arithmetic

**PREDICTED: ADVANCE, NOT CONVERT — LOUDLY.** The order-blind whole-dump
residue on the witness at the base (both dumps workdir-normalised and sorted) is
**149 golden-only / 37 ours-only lines**, and the golden-only shapes include
`constant` bounds at `dut.sv:6:34 / 6:37 / 6:53 / 6:56`, `logic_typespec` at
`6:27 / 6:46` and `DEC:3` / `DEC:64` — r11u62's recorded six remaining keyed
census rows (4 `range` + 2 `typespec_member` pairs golden has and we do not) on
`cfg_pkg::cfg_t`'s own members. Those sit UNDER the very `struct_typespec` this
law's new edge points at, so closing one head cannot close six rows.

**MEASURED AFTER THE LAW — the prediction holds.** The `ref_typespec` head is
GONE in both modes and the new head is a different object entirely, in a
different module, on a different road:

```
LHS: constant 31:52-31:54  |vpiParent -> operation 31:24-31:64
     |vpiDecompile:0  |vpiSize:1   |UINT:0  |vpiConstType:9
RHS: constant 31:52-31:54  |vpiParent -> operation 31:24-31:64
     |vpiDecompile:0  |vpiSize:64  |UINT:0  |vpiConstType:9
```

`dut.sv:31` is `assign fu_data_i = '{operand_a: pa, operand_b: '0, tid: '0};` —
the `'0` pattern operand sized at its MEMBER, which is pass 60's family, not
this one. 36 cmp lines, one head, both modes
([evidence/HEAD.struct_member_cfg_width.law.cmp](evidence/HEAD.struct_member_cfg_width.law.cmp)).
The line count goes UP because the head OBJECT CHANGED and the new head's block
is longer — RESUME §7's reading, not a partial fix.

---

## 2. THE PRODUCER, DECODED — AND THE IDS THAT PROVE THE SHARE

**`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:5480-5494`,
`CompileHelper::compileSelectExpression`** is the whole law. It asks NO
registry; it reads the typespec off the object the root NAME resolves to:

```cpp
UHDM::hier_path *path = s.MakeHier_path();
VectorOfany *elems = s.MakeAnyVec();
if (instance && (reduce == Reduce::Yes)) {
  UHDM::any *rootValue = getObject(the_name, component, compileDesign,
                                   instance, pexpr);
  if (rootValue) {
    if (expr *expval = any_cast<expr *>(rootValue)) {
      path->Root_value(rootValue);
      if (ref_typespec *expval_rt = expval->Typespec()) {
        if (path->Typespec() == nullptr) {
          ref_typespec *path_rt = s.MakeRef_typespec();
          path_rt->VpiParent(path);
          path->Typespec(path_rt);
        }
        path->Typespec()->Actual_typespec(expval_rt->Actual_typespec());
      }
    } else if (UHDM::port *expval = any_cast<port *>(rootValue)) {
      path->Root_value(expval->Low_conn());          // NO TYPESPEC
    } else if (UHDM::param_assign *passign = ...) { ... }
  }
}
```

Three readings follow, and each is a fact of the transcription:

* **`instance && reduce == Reduce::Yes`** is the ELABORATED compile.
  `NetlistElaboration::high_conn_`
  (`~/git-repos/Surelog/src/DesignCompile/NetlistElaboration.cpp:1452`) compiles
  a connection actual with exactly that pair; the DEF-view `ref_module`
  connections never do, which is why every DEF row of every grid below is
  `ts=<none> rv=<none>`.
* **THE MINT IS PER PATH; THE ACTUAL IS SHARED.** Proved with ids on golden's
  own database (`tsid63`, which walks `Serializer::AllObjects` and prints
  pointer identity), not assumed:

  ```
  REF_TS #306 parent=type_parameter(fu_data_t)          actual#337 struct_typespec(fu_data_t)
  REF_TS #309 parent=struct_var(work@tb.t.m.fu_data_i)  actual#337 struct_typespec(fu_data_t)
  REF_TS #315 parent=hier_path(fu_data_i.operand_a)     actual#337 struct_typespec(fu_data_t)
  TYPESPEC #337 struct_typespec fu_data_t parent=type_parameter(fu_data_t)
  ```

  Three DIFFERENT `ref_typespec` objects, ONE `struct_typespec`. Our law
  reproduces the topology exactly (`#378 / #382 / #388` all on `#405`).
* **THE MINT CARRIES NO NAME.** Surelog sets `VpiParent` and `Actual_typespec`
  and nothing else. `ref_typespec::Compare` reads `VpiName`, `VpiDefName` and
  `Actual_typespec`, so both strings being EMPTY is part of the compared shape;
  `VpiFullName` is not compared and `ref_typespec::VpiFullName()` COMPUTES
  itself from the parent chain when unset, which is how golden's dump prints
  `work@tb.t.m.c.a_i.fu_data_i.operand_a` without Surelog ever writing one — and
  ours prints the identical string for the same reason.

**WHAT THE JUDGE READS HERE.** `hier_path::Compare`
(`~/git-repos/UHDM/build/generated/src/hier_path.cpp:110`) runs
`expr::Compare` FIRST — `VpiDecompile`, `VpiSize`, **`Typespec`** — and only
then `Path_elems`, `Root_value` (that is `vpiExpr`) and `VpiName`. So the
typespec is the FIRST compared field of the four, which is why this head sat in
front of everything else on this object.

**WHY OUR SIDE WAS MISSING IT, AND ONLY HERE.** Our site already binds the root
edge: `bindConnPathRootTs53` ([src/ModuleEmit.cpp:7633](../../../src/ModuleEmit.cpp#L7633),
§ connPathRootTs53) resolves the path's root by NAME out of the connection's own
`NamedValueExpression`s and binds `Root_value` from `parentNets` — the witness's
`hier_path` already carried `rv=struct_var:fu_data_i` at the base. The typespec
edge, though, asked `typedefTs` for the root's SLANG type, and `fu_data_i` is a
port typed by a TYPE PARAMETER: slang mints a fresh alias per specialization and
the registry has nothing for it. **This pass does not invent the law; it gives
the same site Surelog's own source for the answer when the registry has none.**

---

## 3. THE GOLDEN GRID (Surelog v1.87 = golden; every arm's rc recorded)

Three grids, all `surelog -parse -nobuiltin -nocache -sv -d uhdm` **rc=0, 0
`[ERR`**, our binary rc=0 on each. Scored by the SHAPE LISTER
[hpgrid63.cpp](hpgrid63.cpp), which keys every `hier_path` in a database by
(elaborated owner, immediate parent KIND, written text) and prints the
COMPARE-VISIBLE payload (`Typespec` actual kind+name, `Root_value` kind+name,
`VpiSize`, `VpiDecompile`, `Path_elems` size) — so DEF and ELAB rows are BOTH
scored and neither can hide.
**CALIBRATION golden-vs-golden FIRST on every grid: g1 43 rows 0 DIFF, g2 22
rows 0 DIFF, g3 11 rows 0 DIFF.**

### g1 — [grid/g1_connts63.sv](grid/g1_connts63.sv), 43 rows: root kinds x member kinds x directions x holders x views x neighbour roads

| cell | shape | golden (ELAB) | pristine | law |
|---|---|---|---|---|
| c01 | module-scope struct VAR root, input | `struct_typespec` + `rv=struct_net` | same | same |
| c02 | struct NET root | `struct_typespec` | same | same |
| c03 | UNION root | **`union_typespec`** | same | same |
| c04 | NESTED member `v.inner.a` (3 elems) | `struct_typespec` of the ROOT | same | same |
| c05 | the root IS A PORT of the holder | `struct_typespec` | same | same |
| **c06** | **the root is a port typed by a TYPE PARAMETER** (the R0 face) | **`struct_typespec` + `rv=struct_var`** | **`ts=<none>`** | **converts** |
| c07 | GEN-LOCAL root | `struct_typespec` + `rv=struct_net` | same | same |
| c08 | OUTPUT direction actual | `struct_typespec` | same | same |
| c09 | inside a CONCAT (2 paths) | `struct_typespec` on both | same | same |
| c10 | inside a BINARY op (2 paths) | `struct_typespec` on both | same | same |
| **c11** | **mid-path ELEMENT SELECT on an unpacked array of structs** | **`array_typespec` + `rv=array_var`** | **`ts=<none>`** | **converts** |
| **c12** | **ANONYMOUS struct root** | **`struct_typespec` with an EMPTY name** | **`ts=<none>`** | **converts** |
| c13 | LOCALPARAM root `LP.a` | golden FOLDS it — no hier_path at all | we emit one (pre-existing, R2) | unchanged |
| c14 | NEIGHBOUR ROAD: `cont_assign` Rhs | `ts=<none> rv=<none>` | same | same |
| c15 | NEIGHBOUR ROAD: `always_comb` assignment | `ts=<none> rv=<none>` | same | same |
| c16 | NEIGHBOUR ROAD: `param_assign` initialiser | `ts=<none> rv=<none>` | same | same |
| c17 | connection inside a GENERATE block, module-scope root | `struct_typespec` | same | same |
| c18 | INSTANCE ARRAY connection (2 elements) | `struct_typespec` on both | same | same |
| c19 | TERNARY actual (2 paths) | `struct_typespec` on both | same | same |
| c20 | unpacked-array root of a typedef'd element | **`rv=array_net`, `ts=<none>`** | same | same |

**Pristine 40/43 -> law 43/43, three cells CONVERT, 0 MOVED-WRONG, 0
AWAY-GOLDEN.** The single `ONLY-OURS` row (c13) is unchanged by the law.
[evidence/GRID.g1.pristine.txt](evidence/GRID.g1.pristine.txt),
[evidence/GRID.g1.law.txt](evidence/GRID.g1.law.txt),
[evidence/GRID.g1.golden.txt](evidence/GRID.g1.golden.txt).

c20 is the cell that makes a typespec-KIND fence unnecessary: an `array_net`
root carries NO `ref_typespec` of its own on EITHER side, so
`expval->Typespec()` is null in Surelog and the same one test is null here.

### g2 — [grid/g2_fence63.sv](grid/g2_fence63.sv), 22 rows: the roots that must be DECLINED

| cell | shape | golden (ELAB) | pristine = law |
|---|---|---|---|
| f01 | **INOUT** direction | `struct_typespec` + `rv=struct_net` | same |
| f02 | POSITIONAL connection | **`ts=<none> rv=<none>`** | we stamp both (PRE-EXISTING, R1) |
| f03 | RE-PASSED one level deeper | `struct_typespec` | same |
| f04 | PLAIN interface-port root `conn.req.a` | **`ts=<none>`, `rv=ref_obj`** (Surelog's `port` branch) | same |
| f05 | MODPORT-qualified root `sub.req.a` | `ts=<none> rv=<none>` | same |
| f06 | PACKAGE-scoped root `q63::PKGV.a` | golden folds it — no hier_path | same |
| f07 | ENUM-membered struct root, inside a concat | `struct_typespec` + `rv=struct_var` | same |
| f08 | PACKED-ARRAY element select (no member) | no hier_path at all | same |
| f09 | FUNCTION-local root | `ts=<none> rv=<none>` (def only) | same |
| f10 | concat in a CONT_ASSIGN (neighbour road) | `ts=<none> rv=<none>` | same |
| f11 | root declared in a FOR-GENERATE block | `struct_typespec` + `rv=struct_net` | same |
| f12 | root in an ENCLOSING generate, connection NESTED | `struct_typespec` + `rv=struct_net` | same |

**Pristine 21/22 -> law 21/22, 0 cells move, 0 MOVED-WRONG, 0 AWAY-GOLDEN.**
f11/f12 are why this law carries **NO GENERATE FENCE**: the pattern-CA road's
landed `rootGenLocal114` fence exists because THAT root reaches `getObject`
through a gen_scope netlist that lists `array_vars()`, which `getObject`
(`CompileExpression.cpp:150-232`) does not search; a port-connection root is a
plain net and golden answers it.
[evidence/GRID.g2.golden.txt](evidence/GRID.g2.golden.txt).

### g3 — [grid/g3_pos63.sv](grid/g3_pos63.sv), 11 rows: THE POSITIONAL AXIS, which CONVICTED a fence before this arm shipped

The same connection written NAMED and POSITIONAL, on the three root kinds:

| cell | connection | root | golden | pristine | law |
|---|---|---|---|---|---|
| p01 | `.a_i(v.a)` | typedef | `struct_typespec` + `rv` | same | same |
| p02 | `(v.a, o)` | typedef | **`ts=<none> rv=<none>`** | we stamp both | unchanged (R1) |
| **p03** | `.a_i(pin.a)` | TYPE PARAMETER | **`struct_typespec` + `rv`** | `ts=<none>` | **converts** |
| p04 | `(pin.a, o)` | TYPE PARAMETER | **`ts=<none> rv=<none>`** | `rv` only | unchanged (R1) |
| **p05** | `.a_i(anon.a)` | ANONYMOUS | **`struct_typespec` + `rv`** | `ts=<none>` | **converts** |
| p06 | `(anon.a, o)` | ANONYMOUS | **`ts=<none> rv=<none>`** | `rv` only | unchanged (R1) |
| p07 | `({v.a,v.b}, o)` | typedef, concat | **`ts=<none> rv=<none>`** ×2 | we stamp both | unchanged (R1) |

**Pristine 4/11 -> law 6/11, two cells CONVERT, 0 MOVED-WRONG, 0 AWAY-GOLDEN.**
Without the fence, p04 and p06 would have moved from pristine-wrong to
differently-wrong on legal SV — the exact failure the landed § patHierPathRootTs114
records for its own gen-local cells.

**COMBINED: 76 rows, pristine 65 right -> law 70 right, +5, 0 MOVED-WRONG,
0 AWAY-GOLDEN.**

---

## 4. WHAT WAS WRITTEN

One new arm at one existing site, one new argument, **no line of behaviour
removed**.

* [src/ModuleEmit.cpp](../../../src/ModuleEmit.cpp) — § connPathRootOwnTs63, in
  `bindConnPathRootTs53`, immediately after the SHIPPED `Root_value` binding
  (which stays exactly where and as it was, ungated). It fires only when the
  root name resolves in `parentNets`, the connection is NAMED, the path has no
  typespec yet, the bound object IS an `expr`, and that object's `ref_typespec`
  has an actual; it then mints one nameless `ref_typespec` parented at the path
  and points it at the ROOT's OWN actual object.
* [src/ModuleEmit.cpp](../../../src/ModuleEmit.cpp) — the one call site gains
  `findConnSyntax(connInst, ps.name) != nullptr`, the named-connection test.
* [include/UhdmExporter.h](../../../include/UhdmExporter.h) — the declaration's
  law paragraph and the new argument's contract.

### The fences, each a measured golden cell

| # | shape | why declined |
|---|---|---|
| F1 | a POSITIONAL (ordered) connection, and `.*` | g3 p02/p04/p06/p07 and g2 f02: golden carries NEITHER field. `findConnSyntax` answers null for both spellings, so one test declines both. (Surelog does not expand `.*` at all — one nameless port with a `STRING:.*` constant and no hier_path.) |
| F2 | a root that is not in `parentNets` | Surelog's `getObject` is that same lookup; a root it cannot answer gets nothing (g2 f05 modport, f06 package-scoped, f09 function-local) |
| F3 | a root whose UHDM object is not an `expr` | Surelog's second branch (a `port` root) writes `Root_value` and NO typespec — g2 f04, the plain interface port, `rv=ref_obj ts=<none>` on both sides |
| F4 | a root object with no `ref_typespec` of its own | g1 c20, an `array_net` root: `ts=<none>` in golden AND here, through ONE test rather than a kind fence |
| F5 | a path that already HAS a typespec | the shipped `typedefTs` arm keeps every cell it already owned (g1 c01-c05, c07-c10, c17-c19), so this arm cannot re-point a landed edge |
| F6 | the DEF view | this site runs only on the elaborated connection walk; all 23 g1 def rows, all 11 g2 def rows and all 3 g3 def rows are `<none>/<none>` in golden and in both binaries |

**NO KIND FENCE.** Golden attaches `struct_typespec`, `union_typespec`,
`array_typespec` and an ANONYMOUS `struct_typespec` alike (g1 c01-c04, c11,
c12); a "struct only" fence would have refused two of the three cells this law
converts.

---

## 5. CENSUS, PREDICTION AND GATES

### The a-priori mover prediction, from PRISTINE DATABASES, and its positive control

[predict63.cpp](predict63.cpp) opens PRISTINE databases only — it runs no
binary and reads no source. A `hier_path` this law can newly stamp is one that,
in the pristine database, has NO `Typespec` while its `Root_value` is an `expr`
carrying a `ref_typespec` with an actual. It is a **SUPERSET** two ways over: it
accepts a `hier_path` on ANY road while the law fires only on the elaborated
port-connection walk, and it ignores the named/positional fence. It cannot MISS,
because the law never creates a `Root_value` the pristine binary did not already
create — that binding is byte-identical in both binaries.

*Positive control* ([evidence/POSCTL.predict63.txt](evidence/POSCTL.predict63.txt)):
on g1 it names exactly the three cells that move (`pin.a`, `av[1].a`, `anon.a`)
and no other; on g3 it names four, the two that convert plus the two the
positional fence declines; on the corpus witness it names the one; on g2 it
names none, and that zero is READ — g2's single wrong cell already carries a
typespec from the shipped arm, so there is nothing for this law to add.

*Predicted, BEFORE the patched sweeps:*
**u2r — exactly 2 arms of 1608: `struct_member_cfg_width`, both modes, and
nothing else** ([evidence/PREDICT.u2r.full.txt](evidence/PREDICT.u2r.full.txt)).
**surelog — ZERO arms of 960** ([evidence/PREDICT.sl.txt.named](evidence/PREDICT.sl.txt.named),
an empty file). That zero is not a vacuous scan: the same scanner reading the
same corpus's face ([faceset63.cpp](faceset63.cpp)) names **13 surelog tests
that DO hold an elaborated port-connection `hier_path`** — `Earlgrey_0_1`,
`HierPathBind`, `InterfaceModExp`, `InterfaceParamOverrideProp`,
`InterfaceStructMemberPort`, `InterfaceUnpackedStructArrayDim`, `OneNetInterf`,
`OneNetModPort`, `OneNetModPortGeneric`, `OneNetRange`, `Rggen`, `Scr1SvTests`,
`SVSwitch` — every one of which already carries golden's edge or is fenced.

*Measured:* **u2r MOVERS 2 / 1608 — `struct_member_cfg_width`, both modes, and
nothing else. surelog MOVERS 3 / 960 — `SeqDriver` (both modes) and
`MiniAmiq/testflags`, none of them a predicted candidate and all three
CONVICTED AS THE COIN** by an order-blind 4-line `UINT`/`vpiDecompile`
LINE-NUMBER pair moving BOTH ways plus a positive control in which the SAME
frozen pristine binary, re-run once per arm, lands on a THIRD hash every time
([evidence/POSCTL.coin.txt](evidence/POSCTL.coin.txt)). All five UVM-family rows
stay `CMP_EQUAL`.

### Mover attribution (order-blind: `uhdm-dump` | workdir-normalised | sort)

Both `struct_member_cfg_width` databases carry a **nonzero size delta**
(25184 -> 25273 default, 20273 -> 20241 testflags — the testflags database gains
lines and loses bytes, which the serializer's string packing explains and the
MOVER RULE convicts either way), so no 4096-multiple is involved and the
page-boundary positive control is not needed. The sorted diff is **eight ADDED
lines each and nothing removed**, and they are the law's one edge:

```
>   \_hier_path: (fu_data_i.operand_a), line:19:19, endln:19:38
>   \_ref_typespec: (work@tb.t.m.c.a_i.fu_data_i.operand_a)
>   \_struct_typespec: (fu_data_t), line:25:13, endln:25:26
>   |vpiActual:
>   |vpiFullName:work@tb.t.m.c.a_i.fu_data_i.operand_a
>   |vpiParent:
>   |vpiTypespec:
```

which is golden's cell exactly. **TO-GOLDEN 2, AWAY-GOLDEN 0, STILL-WRONG 0.**
[evidence/MOVERS.attribution.txt](evidence/MOVERS.attribution.txt).

### The keyed census, with the SHAPE LISTER beside it

[census63.sh](census63.sh) runs `hpgrid63` over a named arm set, **calibration
golden-vs-golden FIRST on every arm**, then golden-vs-pristine and
golden-vs-law, reading each arm's golden out of its OWN `cmds.txt`.

* **u2r, all 21 tests that hold the law's face, BOTH modes**
  ([evidence/CENSUS.u2r.testflags.txt](evidence/CENSUS.u2r.testflags.txt),
  [evidence/CENSUS.u2r.default.txt](evidence/CENSUS.u2r.default.txt)):
  **21 scored, calibration 0 DIFF on every one, TO-GOLDEN 1, AWAY-GOLDEN 0,
  UNCHANGED 20** in each mode. The 20 unchanged include the whole 17-test
  `iface_*` family, `mriscv_bind_sva`, `OneNetModport` and
  `StructMemberAsModuleInput`; the one is `struct_member_cfg_width`, 1 DIFF -> 0.
* **surelog:** 957 of the 960 databases are byte-identical under the law and the
  other three are the coin, so every keyed census over them is zero by
  construction — and it was RUN anyway over the 13 tests that hold the law's
  face, BOTH modes: **13 scored default / 12 testflags (Rggen has no testflags
  golden), calibration 0 DIFF on every one, TO-GOLDEN 0, AWAY-GOLDEN 0,
  UNCHANGED all** — `Earlgrey_0_1` (14478 keyed rows default, 21910 testflags),
  `Rggen`, `Scr1SvTests`, `SVSwitch` and `OneNetModPortGeneric` among them, each
  with its PRIS and LAW columns byte-identical. Recorded at
  [evidence/CENSUS.sl.testflags.txt](evidence/CENSUS.sl.testflags.txt) and
  [evidence/CENSUS.sl.default.txt](evidence/CENSUS.sl.default.txt).
* Shape listers:
  [evidence/SHAPES.g1.golden.txt](evidence/SHAPES.g1.golden.txt),
  [evidence/SHAPES.struct_member_cfg_width.golden.txt](evidence/SHAPES.struct_member_cfg_width.golden.txt).

### The gates

| gate | result |
|---|---|
| (1) build both, md5 | pristine `5fc453cd3a119cc5de0debfa68714d63` — **byte-identical to the main tree at `9dc8c859`**; law `44a1172e38bf2ac198365a9b15aea810`. (`ParamEmit.cpp` is untouched by this pass, so its `__LINE__` sensitivity is not in play.) |
| (2) goldens | `PASS=23 FAIL=0`; `SLANG_UHDM=/bin/false` -> `PASS=0 FAIL=23` |
| (3) u2r both modes | `786 CMP_EQUAL / 18 CMP_NOTEQUAL / 67 SLANG_REJECT` ×2; every row **byte-identical** to `results/gate_uhdm2rtlil.csv`, to `results/golden_uhdm2rtlil.csv` (BOTH modes, 1742 rows joined, 0 differing) and to my own pristine sweep in both modes |
| (4) surelog `--mode both` | `474/9` default + `469/8` testflags; status AND dump histograms identical to `results/golden_surelog.csv` and to my pristine sweep. Law-vs-baseline and law-vs-pristine differ in exactly **two** row-sides each: the `SURELOG_FAIL` detail strings that quote the WORKDIR PATH (`LowMemLib`, `LowMemPkg`). `Earlgrey_0_1`'s dump column is populated in both modes this run |
| (5) byteverify SELFCHECK=1 | u2r `MOVERS 2/1608`, SELFCHECK `1607/1608` flagged; surelog `MOVERS 3/960`, SELFCHECK `959/960`; `PATH_SETS_IDENTICAL` both |
| canaries | `ok=52 changed=0 absent=0` (surelog) and `ok=8 changed=0 absent=0` (u2r) — **identical to my own pristine sweep's reading**; `ctcan2` PASS ×2 (`ok=58` / `ok=1`, `changed=0`); `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| rowheads | SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg / Earlgrey_0_1 all `0 lines 0 heads`; Rggen `64 lines 1 head` (unchanged) |
| protected DBs | `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`, `Earlgrey_0_1` default `8bdf25272e08` / testflags `59d0ee6d10c3`, `BlackParrotComplex` and `YosysOldOr` — every one byte-identical to pristine and every hard pin at its OPS value |
| UVM family | BuildUVMPkg, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard all still `CMP_EQUAL` |
| landed conversions | `iface_zero_width_field` and `indexed_partsel_array` still `CMP_EQUAL` in both modes |

`results/*.csv` untouched. **The row ADVANCES but does not convert, so no
baseline row is promoted.**

---

## 6. RESIDUES, and R0

* **R0 — THE WITNESS'S NEW HEAD: A PATTERN OPERAND'S `vpiSize`.**
  `struct_member_cfg_width` `dut.sv:31`
  `assign fu_data_i = '{operand_a: pa, operand_b: '0, tid: '0};` — golden sizes
  the `'0` operands at **1**, we size them at **64**. 36 cmp lines, one head,
  both modes. Pass 60 landed "an elaborated pattern operand is sized at its
  member" on the PARAMETER road; this is the same question on a `cont_assign`
  whose Lhs is a struct VARIABLE, and the row's remaining keyed residue (the 4
  `range` and 2 `typespec_member` pairs on `cfg_pkg::cfg_t`) lives behind it.

* **R1 — THE POSITIONAL CONNECTION'S ROOT EDGE (g3 p02/p04/p06/p07, g2 f02).**
  Golden gives an ORDERED connection's `hier_path` NEITHER `Root_value` NOR a
  typespec; the shipped `typedefTs` arm and the shipped `Root_value` binding
  give it both. Pre-existing, untouched, and deliberately not corrected here:
  `hier_path::Compare` READS `Root_value`, so removing it moves a compared field
  on every positional member connection in both corpora and needs its own grid,
  its own census and its own boundary.

* **R2 — THE LOCALPARAM ROOT GOLDEN FOLDS (g1 c13, g2 f06).**
  `#(...)`-free `sink_i u (.a_i(LP.a))` over a struct localparam leaves NO
  `hier_path` in golden's elaborated connection at all — the actual is folded to
  a constant. We emit a path (carrying a typespec from the shipped arm). A FOLD
  question, pre-existing, a different family's road.

---

## 7. REPRODUCING

```bash
# the grids (CALIBRATE golden-vs-golden FIRST; every arm's rc recorded)
cd <scratch> && cp <repo>/tools/probe/r11u63repro/grid/*.sv .
cp <repo>/tools/probe/r11u63repro/{hpgrid63.cpp,tsid63.cpp,predict63.cpp,faceset63.cpp} .
for f in hpgrid63 tsid63 predict63 faceset63; do
  g++ -O1 -std=c++17 $f.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
      -luhdm -lcapnp -lkj -o $f; done
~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv -d uhdm g1_connts63.sv
cp slpp_all/surelog.uhdm g1.golden.uhdm
$SLANG_UHDM g1_connts63.sv --single-unit -o g1.ours.uhdm
./hpgrid63 --rows g1.golden.uhdm g1.golden.uhdm | tail -1   # CALIBRATION: DIFF 0
./hpgrid63 --rows g1.golden.uhdm g1.ours.uhdm               # the grid
./hpgrid63 g1.golden.uhdm                                   # the SHAPE LISTER
./tsid63 g1.golden.uhdm | grep -E 'HIER_PATH|REF_TS|TYPESPEC'   # the ids

# the a-priori prediction and its positive control (PRISTINE databases only)
./predict63 g1.ours.uhdm g1
bash predsweep63.sh <pristineWorkdir> PREDICT.txt

# the law's face, by name, across a corpus
for d in <pristineWorkdir>/<mode>/*/; do ./faceset63 $d/slang.uhdm $(basename $d); done

# the keyed census, both modes
bash census63.sh <mode> <lawWorkdir> <prisWorkdir> names.txt <outdir>
```
