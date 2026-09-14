# r11u29 — THE FULL TRIAGE OF EVERY REMAINING NOT-EQUAL ROW at `d24291a2`

MEASUREMENT ONLY.  No production file is touched.  The judge is the official
`uhdm-cmp`; everything below is a reading of its output.

> **VERIFIED AND CORRECTED by r11v29** (adversarial verifier), evidence in
> `tools/probe/r11v29repro/`.  What was re-measured independently — own
> from-source build (md5 reproduces the pin `62547ac98ebcfdeb522171dc946d50ad`),
> own sweeps, own head extraction for all 92 rows — **reproduces this report
> byte-for-byte at the face level**.  Two things did not survive:
>
> * **K2's footprint bound is withdrawn.**  Re-run unfiltered, the same census
>   reports 39 disagreements over the five designs, not 10, and in four of the
>   five designs golden's ELABORATED view carries a `packed_array_var` where we
>   carry a `logic_net` — a second half of the producer law that the head hides.
>   `r11v29repro/evidence/K2_census_unfiltered.txt`, `K2_elabview_objectkind.txt`.
> * **Six rows did not carry their cluster's claimed face and were split out**
>   (`port_chained_type_param`, `genvar_pow_index`, `StructParamPatternInitCast`,
>   `StructParamFuncBodyFieldCompare`, `packed_array_struct`, and K11's two
>   members from each other).  `r11v29repro/evidence/splits.txt` quotes each head.
>
> The cluster table, the singleton list and the top-three section below are the
> CORRECTED ones.  Row count, row set, mode identity, the positive control, the
> fence exclusion, the K1 shared-head md5 and the coin-family stability all
> stand exactly as first reported.

---

## 0. What was measured, and the controls that make it readable

| | |
|---|---|
| base | `d24291a2` (`matrix-1.87`), worktree built from that commit |
| binary | the pristine `slang-uhdm`, md5 `62547ac98ebcfdeb522171dc946d50ad`. r11u29 MADE NO BUILD: the main tree at `d24291a2` already carries exactly that binary, so it was COPIED into this pass's own scratch, md5-verified against the pin, frozen `chmod 555`, and exported as `SLANG_UHDM` for every sweep. The harness silently defaults to the MAIN-TREE binary, so `cmds.txt` was read back per row to confirm the frozen path is the one that ran.  **r11v29 configured and built the tree from source at `d24291a2` (`-j 2`) and the resulting binary md5 IS the pin** — the shortcut is sound. |
| sweeps | this pass's OWN workdirs, `--jobs 2`, both corpora, both modes |
| judge | `~/.local/bin/uhdm-cmp` (UHDM v1.87), ONE head per run, heads counted `grep -c '^LHS:'` anchored at column 0 |

**The sweeps reproduce the baseline exactly, row for row**: uhdm2rtlil 768
equal / 36 not-equal / 67 reject in BOTH modes, surelog 469/14 default and
465/12 testflags, and the not-equal NAME SET matches
`results/golden_uhdm2rtlil.csv` and `results/golden_surelog.csv` by `diff`.
`results/*.csv` was read only.

**Positive control for the head extractor.**  Two known-EQUAL rows were
measured through the same driver in each corpus and read `0` cmp lines and
`0` heads with `cmp rc=0` (`1DUnpackedArray`, `2DeclarationsInFor`;
`1364_2005`, `AllBinding`).  A driver that reaches nothing must not read as
perfection, so `rowheads.sh`'s SKIP-NOFILE counter is quoted too: the only two
SKIPs are `Rggen/testflags` and `Scoreboard/testflags`, both expected, and
neither is a not-equal row.

**The fenced tests.**  The three slang-fenced not-equal tests were excluded by
matching the baseline rows against a FENCED list file built once from a
committed driver's own `FENCED=` line — their names are not spelled in this
pass, they appear in no cluster, and no arm of this survey dispatched them.
`26 - 6 = 20` surelog rows survive the exclusion (three tests x two modes).

**THE ROW COUNT.**  92 not-equal rows: 72 uhdm2rtlil (36 tests x 2 modes) +
20 surelog (11 tests; 9 in both modes, `Rggen` and `Scoreboard` default only).

**Every row's two modes carry the SAME head.**  For all 47 tests the default
and testflags `uhdm-cmp` output is ID-BLIND IDENTICAL
(`evidence/*/mode_identity.txt`, `MODE-SPLIT rows: 0`).  One face therefore
serves both modes, and no row needed splitting.

**The coin family.**  `MiniAmiq`, `SeqDriver`, `SimpleUVM`, `Scoreboard` were
measured from TWO INDEPENDENT database builds (a second `--filter` sweep with
its own workdir).  All seven of their not-equal rows read the same head
id-blind across both builds — `evidence/K1.coin_stability.txt`.  Only that
stable head is reported.

**Long heads were re-read.**  A partially written result reads like a result,
so the seven longest heads (`packed_struct_array_fifo` 6446 lines, `Rggen` 801,
`param_type_logic_width` 390, `interface_array_fanout` 351, `dyn_field_select`
160, and the three `ibex_*`) were compared twice against the recorded
head — all byte-stable (`evidence/reread_stability.txt`).

**The `--nobuiltin` rule** has nothing to bite on here: no head was taken from
a hand-run of `slang-uhdm`.  Every database is the harness's own, built by the
`cmds.txt` argv the harness wrote, and `scripts/verify_golden.py` appends
`--nobuiltin` exactly when the golden's Surelog argv carries `-nobuiltin`
(`scripts/verify_golden.py:664-665`); the three `ibex_*` rows' corpus argv carries
none, so neither side used it.

---

## 1. How a FACE is read

`uhdm-cmp` prints the head object's decompile on both sides.  The FACE is the
BLIND DIFF of the two renderings — ids, `line:`/`endln:`/`col:`/`file:` and
`vpiFullName` removed, because no generated `Compare` reads a location or a
full name (RESUME.md §9), so a location-only difference is noise.  What
survives is the field the judge disagreed on.  Two further readings, both from
§9:

* `RHS: <null>` is the SINGULAR overload: the LHS names golden's VALUE (the
  pointee), our side is missing, and the OWNER is hidden.  Where the owner
  matters below it is named from golden's own `vpiParent` of the head and
  confirmed in the dump — evidence, not a judged field.
* `LHS: <null>` is that overload's MIRROR: golden has NOTHING where WE emit an
  object.  Exactly one row in the corpus reads that way
  (`StructParamPatternInitCast`), and it is an OVER-emission, not a gap.

Tools: `facediff.py` (the face), `decode_heads.py` (the face as CSV),
`nettype_census.py` (the K2 census, calibrated golden-vs-golden first),
`survey.sh` (the whole run), `quote_cluster.sh` (the side-by-side quotes).

---

## 2. THE RANKED CLUSTERS

Rank is TESTS PER FIX: how many distinct tests one producer law would clear.
Rows = the not-equal rows those tests own (2 per test except where noted).
The quoted, id-blind heads for every cluster are in `evidence/<K>.heads.txt`.

| rank | cluster | tests | rows | the shared FACE (LHS golden / RHS ours) |
|---|---|---|---|---|
| 1 | **K1 — an `inside` VALUE RANGE is one `vpiListOp` operand** | 5 | 9 | golden wraps `[A:B]` in an inner `operation` `vpiOpType:37` (vpiListOp) and hands THAT to the `inside` op; we hand the outer op the left bound's `ref_obj` |
| 2 | **K2 — `vpiNetType` on a named-type declaration carrying a packed dim** | 5 | 10 | `<named packed type> [range] x` — golden leaves `vpiNetType` UNSET, we stamp 36.  *The head is shared by all five; the census does NOT bound the fix — see the corrected law below.* |
| 3 | **K4 — a type parameter's actual type loses its dimension** | 4 | 8 | golden `packed_array_typespec`/`array_typespec` (range + `vpiElemTypespec`), ours the bare element typespec |
| 4 | **K5 — the fold DECISION at a RANGE BOUND** | 4 | 8 | golden KEEPS `operation(param - 1)` as the range bound where we fold (3 tests); golden FOLDS where we keep (1 test) |
| 5 | **K3 — the fold DECISION away from a range** | 3 | 6 | golden keeps the symbolic leaf (a package parameter, `$bits`) where we fold (2); golden folds a struct-parameter read where we keep (1) |
| 6 | **K6 — a folded constant's SIZE under a range: golden 32, ours 64** | 3 | 6 | same value, same `range` parent on both sides, `vpiSize` 32 vs 64 (one row also `UINT`/ct9 vs `INT`/ct7) |
| 7 | **K7 — how an assignment-pattern `operation` is stamped** | 3 | 6 | same object (`vpiOpType:75`): golden carries a `vpiTypespec` ref we omit (2), we stamp a `vpiSize` golden omits (1).  *One law is known for the typespec half only — count 2 for it.* |
| 8 | **K8 — a folded constant's ENCODING at equal size** | 2 | 4 | `vpiSize` equal (32) on both sides; the `vpiConstType`/value encoding differs — `INT`/ct7 vs `UINT`/ct9, `BIN`/ct3 vs `UINT`/ct9 |
| 9 | **K9 — a named-type declaration's missing `ref_typespec`** | 2 | 4 | golden links `vpiTypespec -> ref_typespec -> struct_typespec`; we emit the net/var with NO typespec |
| 10 | **K10 — an interface ARRAY element is absent from our elaborated view** | 2 | 3 | golden has `interface_inst ...[0]` with its variables; ours `<null>` |
| 11 | **K12 — a phantom def-view net** | 2 | 4 | golden's module DEFINITION carries an extra `logic_net` (netType 1) minted from an identifier used in a type-parameter expression; we have none |
| — | **S — twelve singletons** | 12 | 24 | §3 |

35 clustered tests + 12 singletons = 47 tests; 68 + 24 = 92 rows; every row assigned.

**What the correction changed.**  r11u29 ranked K1 · K2 · K3 · K4 · K5 · K6 · K7 ·
K8 · K9 · K10 · K11 · K12 with 5/5/5/5/4/4/3/3/2/2/2/2 tests and 5 singletons.
Six rows did not carry their cluster's claimed face and moved to §3
(`port_chained_type_param` out of K4, `genvar_pow_index` and
`StructParamPatternInitCast` out of K3, `StructParamFuncBodyFieldCompare` out of
K6, `packed_array_struct` out of K8), and **K11 dissolved** — its two members
disagree on two different judged fields (`Path_elems` versus `VpiName`), which is
a shared object KIND, not a shared face.  Every head quoted in
`r11v29repro/evidence/splits.txt`.

---

### K1 — an `inside` value range is ONE operand, a `vpiListOp` operation  (5 tests / 9 rows)

`BuildUVMPkg`, `MiniAmiq`, `SeqDriver`, `SimpleUVM` (both modes) and
`Scoreboard` (default).

All five carry **the identical head**: with ids and source locations blinded
the five `uhdm-cmp` outputs are the SAME TEXT (md5 `0c1a52351c31`), and four of
them (`MiniAmiq`, `SeqDriver`, `SimpleUVM`, `Scoreboard`) are identical with
ids alone blinded — same file offset, same names; only `BuildUVMPkg`'s larger
single-unit file moves the line number.  The construct is `uvm_domain.svh`,
`phases = phases.find(item) with (item.get_state() inside
{[UVM_PHASE_STARTED:UVM_PHASE_CLEANUP]});` — **line 199 of the `uvm-1.2` copy**
(r11v29 correction: the measured heads read `line:199:63`; line 194 is the same
statement in the `1800.2-2017-1.0` copy, which these rows do not use).  Quoted id-blind, golden and ours:

```
LHS (golden)                                  RHS (ours)
operation: , line:#, endln:#                  ref_obj: (uvm_pkg::uvm_domain::jump::UVM_PHASE_STARTED)
|vpiParent: \_operation:                      |vpiParent: \_operation:          <- the SAME outer op
|vpiOpType:37                     <- vpiListOp   |vpiName:UVM_PHASE_STARTED
|vpiOperand: \_ref_obj: (…UVM_PHASE_STARTED)
|vpiOperand: \_ref_obj: (…UVM_PHASE_CLEANUP)
```

Golden's outer `inside` operation (op 95) takes TWO operands — the tested
expression and ONE `vpiListOp` operation holding the range's bounds.  Ours
takes the bounds flat, so its second operand is the left bound itself.

*Suspected producer site.*  `src/TypeEmit.cpp:16987` — the `InsideExpression`
arm walks `ie.ranges->valueRanges` and pushes `emitSyntaxExpr(*vr)` straight
into the op-95 operand list; the comment above it,
`src/TypeEmit.cpp:16986` (`op 95 with [x, a, b, ...]`), is the model this
measurement refutes for a value RANGE.  There is no `OpenRangeExpression` arm
anywhere in `src/` (grep: zero hits), which is why a `[A:B]` element collapses
to its left bound.  A simple-value `inside` set (`inside {a, b}`) is NOT this
face and is not disturbed by it — the five heads all sit on a bracketed range.

Landed-law residue: none names it; this family has never been touched.

---

### K2 — `vpiNetType` on `<named packed type> [range] x`  (5 tests / 10 rows)

`arb_idx_cast`, `gen_scope_numports`, `latch_packed_enum_loop`,
`packed_array_reset_loop`, `param_name_collision_typeparam`.

Every head is a `logic_net` whose two decompiles differ in exactly one line:
ours carries `|vpiNetType:36`, golden carries none.  `nets::Compare` reads
`VpiNetType` (`../UHDM/build/generated/src/nets.cpp:277`, the pinned UHDM v1.87 tree), so the field is judged.

**CORRECTED (r11v29).**  A depth-keyed census over the five designs, calibrated
golden-vs-golden to 0 disagreements first, was read as bounding the whole
footprint at 10 nets.  Re-run UNFILTERED it does not: it reports **39**
disagreements, of which 10 are the `vpiNetType` face, and in `gen_scope_numports`
our dump carries **103** net rows against golden's 77
(`r11v29repro/evidence/K2_census_unfiltered.txt`).  The calibration is genuinely
clean on all five — that half of the claim stands.

The 29 extra rows are not a depth-key artifact.  For the SAME declaration,
Surelog's ELABORATED view carries a `packed_array_var` (of `logic_var` /
`enum_var` elements) where we carry a `logic_net`
(`r11v29repro/evidence/K2_elabview_objectkind.txt`):

```
golden  \_packed_array_var: (work@tb.t.gen_cut[0].i_tc_sram_wrapper.wdata_i)
ours    \_logic_net:        (work@tb.t.gen_cut[0].i_tc_sram_wrapper.wdata_i)
```

Four of the five designs are like that (`gen_scope_numports`,
`param_name_collision_typeparam`, `packed_array_reset_loop`, `arb_idx_cast`);
only `latch_packed_enum_loop` agrees on the object kind.  The ten nets whose
`vpiNetType` disagrees are still real and still the head:

```
gen_scope_numports              tc_sram.wdata_i  tc_sram.rdata_o
                                tc_sram_wrapper.wdata_i  tc_sram_wrapper.rdata_o
packed_array_reset_loop         d_i  q  q_o
param_name_collision_typeparam  inner.d_i
latch_packed_enum_loop          cf_type
arb_idx_cast                    index_nodes
```

Each one is a declaration of the shape `<named type> [range] <name>` where the
named type is a `parameter type` (four tests) or an enum `typedef`
(`latch_packed_enum_loop`).  **The distinguisher is proved INSIDE one design**:
in `arb_idx_cast` only `idx_t [2**NumLevels-2:0] index_nodes` disagrees —
`idx_t idx_o` (same named type, no dimension) and `logic [..] req_nodes` (a
dimension, no named type) agree on both sides.  In `gen_scope_numports` the
top module's `logic [DATA_WIDTH-1:0] wdata_i` agrees while the child modules'
`data_t [NumPorts-1:0] wdata_i` does not.

*Suspected producer law, CORRECTED — it has TWO halves.*  Surelog models a
declaration whose written data type is a NAME as **a DEF-view net with NO net
type AND an ELAB-view `packed_array_var`/`logic_var`** — not a net at all.  The
emitter already states exactly that, for the dimension-less case, in its own
comment at `src/EmitHelpers.h:563-565` ("def-view net with no net type +
type-param default typespec; elab-view logic_var").  A packed dimension on top of
the name, and a plain `typedef` name instead of a type parameter, both escape the
`portTypeParam` guard at `src/EmitHelpers.h:860` (helper `src/EmitHelpers.h:566`)
and fall through to the wire answer that `src/TypeEmit.cpp:20233` stamps — and,
in four designs, to the wrong object kind in the elaborated view as well.
**An implement pass that clears only the `vpiNetType` stamp will move the head,
not convert the test.**  Build the census that bounds the elab-view half BEFORE
writing a line.

---

### K3 — the fold DECISION away from a range bound  (3 tests / 6 rows)

| test | golden | ours |
|---|---|---|
| `ibex_tracer` | KEEPS `ref_obj ibex_tracer_pkg::OPCODE_C0` as the operand | folds to `BIN 2'b00` at 2 |
| `bits_of_type_param` | KEEPS `sys_func_call $bits(req_t)` as the `param_assign` Rhs | folds to `UINT 97` at 64 |
| `struct_param_pattern_packing` | FOLDS `hier_path CFG.n` to `UINT 3` at 32 | KEEPS the `hier_path` |

**CORRECTED (r11v29): two rows left this cluster.**  `genvar_pow_index` folds
nothing on either side — golden's `gen_for` condition has TWO operands and ours
has ONE, the `$unsigned(genvar)` operand simply missing; that is an operand-vector
gap, not a fold decision.  `StructParamPatternInitCast` is the mirror null with
an ORPHAN constant (no `vpiParent` on our side), i.e. an over-emission.  Both are
in §3 with their heads quoted in `r11v29repro/evidence/splits.txt`.

Landed-law residue that already names what is left: **`tools/probe/r11u27repro/README.md:407`
R0 — "the fold DECISION, not the encoding"**, and
`tools/probe/r11u27repro/README.md:441` R6 ("golden INSTALLS the operation and
we fold … golden folds and we keep the operation"), with
`tools/probe/r11u27repro/README.md:434` R4 naming the bare-`$call` half
("the mint fence refuses a bare Call deliberately").  The landed encoding laws
(passes 22–27) deliberately stopped at the encoding; the DECISION is the
named next head there, and this survey gives it its first corpus witnesses.

---

### K4 — a type parameter's actual type loses its dimension  (4 tests / 8 rows)

`type_param_packed_dim`, `type_param_override_elem_sel` (the two heads are the
same text line for line once ids, locations and the designs' own names are
blinded), `anon_struct_packed_dim`, `type_param_unpacked_port`.

Golden builds the array typespec and hangs the element off it:

```
packed_array_typespec                       |   ours:
|vpiRange -> range                          |   logic_typespec          (the ELEMENT only)
|  |vpiLeftRange  -> operation / constant   |
|  |vpiRightRange -> constant               |
|vpiElemTypespec -> ref_typespec -> <elem>  |
```

`type_param_unpacked_port` is the unpacked twin (`array_typespec` vs the bare
`struct_typespec pk::resp_t`).  One law — "the override's written dimensions
belong to the type parameter's actual typespec" — covers all four, and all four
golden heads carry a `vpiRange`.

**CORRECTED (r11v29): `port_chained_type_param` left this cluster.**  Its golden
head carries NO range at all — golden's actual is a `struct_typespec` with three
`typespec_member`s where we emit a `logic_typespec`.  Nothing is losing a
dimension there; a chained override is resolving to a different type.  §3.

---

### K5 — the fold DECISION at a RANGE BOUND  (4 tests / 8 rows)

`cva6_struct_param_field` (u2r) and `StructParamFieldRange` (surelog) are the
SAME face on the same construct, one in each corpus — quoted side by side:

```
golden, both:  operation ,  |vpiParent: \_range:   |vpiOpType:11
               |vpiOperand: \_hier_path: (Cfg.XLEN)   |vpiOperand: \_constant 1
ours,   both:  constant ,   |vpiParent: \_range:   |vpiDecompile:63 |vpiSize:64 |INT:63 |ct7
```

`mem_packed_2d_byte_write` is the same direction on a plain parameter
(`operation(ref_obj NDATA − 1)` kept by golden; we fold — and our folded
object is visibly wrong besides: `vpiDecompile:"NDATA-1"` with `UINT:1`).
`iface_param_2level` is the OPPOSITE direction: golden folds
`s.CFG.BUS.DAT − 1` to `INT 31`, we keep the operation.

The two directions are one producer decision — when Surelog's range reducer
runs — so they are one cluster, but the implement pass must find the
distinguisher: a struct-parameter member read through a module parameter
(`Cfg.XLEN`) is KEPT, while the same shape reached through an interface
instance (`s.CFG.BUS.DAT`) is FOLDED.

---

### K6 — a folded constant's SIZE under a range: golden 32, ours 64  (3 tests / 6 rows)

`genscope_struct_member` (`EXP_BITS+MAN_BITS` → `UINT 15`),
`ibex_pmp` (`UINT 33`), `latch_perf_counters` (`UINT 4`, and ours also flips
`ct9`→`ct7`) — all three a constant sitting under a `\_range:` parent **on both
sides**, same value, `vpiSize` 32 versus 64.

**CORRECTED (r11v29): `StructParamFuncBodyFieldCompare` left this cluster.**  Its
two sides do NOT share the context: golden's constant hangs off an `operation`,
ours off a `sys_func_call ($unsigned)` that golden has already dropped.  Clearing
the 32/64 size there leaves the wrapper mismatch standing, so it is a
fold-DECISION row wearing a size face, not a K6 row.  §3.

Same judged field in all three: `vpiSize`.  This is the ENCODING half of the
family passes 22–27 landed — those laws mint at 64 for an unbound install by
design; nothing in them reaches a RANGE.

---

### K7 — how an assignment-pattern `operation` is stamped  (3 tests / 6 rows)

All three heads sit on an `operation` with `vpiOpType:75`:

* `typed_named_pattern`, `iface_zero_width_field` — golden carries
  `vpiTypespec -> ref_typespec -> struct_typespec` (named in the first,
  NAMELESS in the second, whose owner was located in golden's own dump as the
  `'{CTL:0, DAT:8, STS:0}` Rhs of `localparam bus_t B`); we carry none.
* `cfg_func_width_loop` — the mirror: we stamp `|vpiSize:1` on the pattern
  operation, golden leaves it unset.

Landed-law residue that names the producer rule:
**`tools/probe/r11v26repro/README.md:56` — "Surelog types the elaborated pattern
operation exactly when every element reduces to a CONSTANT"**, the fact that
verifier used to re-cut r11u25's flatten gate.  Both K7 gaps are that same
stamp, read from the emission side instead of the evaluation side.

**r11v29 caveat.**  The cluster is a shared OBJECT (the `vpiOpType:75` operation),
not a shared FIELD: two rows are the missing `vpiTypespec`, one is the extra
`vpiSize` (and `cfg_func_width_loop` carries NO `vpiTypespec` on either side, so
the typespec law does not reach it).  Count **2** tests for the typespec law and
1 for the size mirror; verified by re-reading both heads in full.

---

### K8 — a folded constant's ENCODING at equal size  (2 tests / 4 rows)

`ibex_icache` (`22` at 32 on both sides: golden `INT` ct7, ours `UINT` ct9) and
`struct_param_dim` (`4` at 32 on both sides: golden `BIN` ct3 with a
`logic_typespec` ref, ours `UINT 32'h4` ct9 with a `struct_typespec` ref).  The
size agrees; the encoding is what the judge stops on.

**CORRECTED (r11v29): `packed_array_struct` left this cluster.**  Its two sides
AGREE on the encoding (`BIN`, ct 3, decompile `'0`) and differ only in `vpiSize`
— and not 32-vs-64 but UNSIZED (−1) versus SIZED (168).  A cluster titled "at
equal size" cannot hold a row whose only difference is the size.  It is the
direct residue of the landed "an unbound fill keeps its raw shape" law at a
target shape that law does not reach, and it is a singleton.  §3.

---

### K9 — a named-type declaration's missing `ref_typespec`  (2 tests / 4 rows)

`struct_member_cfg_width` (`fu_data_t fu_data_i;` at module scope) and
`packed_array_struct_port_sel` (the elaborated `packed_array_var` for
`input T [1:0] arr_i`).  Both heads are `RHS: <null>` on golden's
`ref_typespec`; the owner is golden's `vpiParent` of that head, confirmed in
the dumps — golden's net/var carries
`vpiTypespec -> ref_typespec -> struct_typespec`, ours carries no typespec at
all.  Note the same emitter reach as K2 (a declaration whose written type is a
NAME): K2 is a field we stamp and golden does not, K9 a link golden makes and
we do not.  Together the two clusters put **7 tests on the named-type
declaration road**.

---

### K10 — an interface ARRAY element is absent  (2 tests / 3 rows)

`interface_array_fanout` (`work@dut.f.m[0]`) and `Rggen`
(`…u_adapter.register_if[0]`, default only, 801 cmp lines — the longest head
in the survey, re-read byte-stable).  Both are `RHS: <null>` on an
`interface_inst` whose `vpiName` carries the `[0]` subscript and whose
`vpiVariables` golden fills in.  We produce no such object.

---

### K11 — DISSOLVED (r11v29)

r11u29 grouped `dyn_field_select` and `struct_member_expr_index` because both
heads are a `hier_path`.  They disagree on two DIFFERENT judged fields:

* `dyn_field_select` — the two `hier_path`s carry the SAME `VpiName`; what differs
  is `Path_elems` (golden nests `bit_select(tbl[row_i])` with a `vpiIndex`, ours
  is one composite `ref_obj` literally named `tbl[row_i][col_i]`).
* `struct_member_expr_index` — the path element KINDS agree; what differs is the
  NAME TEXT on the `hier_path` and on its `bit_select`: golden
  `value.mantissa[23 - 1]` (the parameter folded into the text) against our
  `value.mantissa[p::MAN_BITS - 1]`.  This is the F1 family (`hier_path`
  `VpiName` TEXT) the cluster census has tracked since r10.

A shared object KIND is not a shared FACE.  Both are singletons in §3; heads
quoted in `r11v29repro/evidence/splits.txt`.

---

### K12 — a phantom def-view net  (2 tests / 4 rows)

`param_type_logic_width`: golden's `work@shift_reg` DEFINITION carries a
`logic_net b` (`vpiNetType:1`) that the module does not declare — `b` is a name
used inside the instantiation's type-parameter override
`logic [$bits(a)+$bits(b)-1:0]`.  `packed_struct_array_fifo`: golden's
definition carries a `logic_net d_t`, the name of the TYPEDEF used as the
default of `parameter type dtype = d_t`.  Both heads are the module_inst's
net-vector size mismatch (the VECTOR overload sets both containers).  One
producer habit, two tests.

**r11v29 caveat.**  The head face is genuinely shared, but `packed_struct_array_fifo`
carries further OURS-ONLY distinguishers under the same head (two extra
`packed_array_typespec`s, and a `ref_obj` golden names
`work@packed_struct_array_fifo.FifoDepth.ADDR_DEPTH` against our
`work@packed_struct_array_fifo.ADDR_DEPTH`) — its 6446-line cmp log is the
longest in the survey.  The phantom-net law alone will not convert it; treat
tests-per-fix here as 1 confirmed + 1 probable.

---

## 3. THE SINGLETONS  (12 tests / 24 rows)

The first five are r11u29's; the seven marked **[r11v29]** were split out of a
cluster whose claimed face their head does not carry
(`r11v29repro/evidence/splits.txt` quotes every one).

| test | face |
|---|---|
| `const_cast_signext` | `RHS: <null>` on a `ref_typespec` whose parent is the typedef's own `logic_typespec(imm_t)`: golden links the typedef alias to its base `logic_typespec`, we emit no alias. `typespec::Compare` walks `Typedef_alias` before `Instance` (RESUME.md §9), so this is the alias edge. |
| `LargeValue2Struct` | a NAMING head: golden's `logic_typespec` is named `sram_key_t`, ours `pack::sram_key_t`. **Do not dispatch as a naming fix** — the campaign's recorded dead end is that Surelog's naming is context-dependent and a uniform `pkg::` change breaks goldens. Decide it from the owner (golden's typespec hangs under a `ref_typespec` parent, ours has no parent). |
| `SequenceInst` | `property_spec` expression: golden builds `operation(51)` over `operation(54)` over the leaves; ours hands the bare `ref_obj work@m.p_triggers.rst`. The SHAPE (an operation wrapper we flatten to a leaf) is K1's shape on a different construct, but the construct is a concurrent-assertion property, not an `inside` set. |
| `stamped_gen_param` | golden `logic_typespec(q2::row_t)` plus a `packed_array_typespec` wrapper with `UINT:2`; ours an unnamed `logic_typespec` reached through a `typespec_member`, `UINT:1`. K4-adjacent (a type parameter's actual type) but the objects differ too much to share a fix. |
| `unpacked_elem_partsel_comb` | `RHS: <null>` on a `var_select` (an unpacked element carrying a part-select) as a `cont_assign` Rhs; we emit no `var_select` there. |
| `port_chained_type_param` **[r11v29, was K4]** | a CHAINED type-parameter override: golden's `type_parameter` actual is a `struct_typespec` with three `typespec_member`s, ours a `logic_typespec`. Golden's head carries NO `vpiRange` — nothing is losing a dimension. |
| `genvar_pow_index` **[r11v29, was K3]** | the `gen_for` condition `operation` (opType 20): golden has TWO operands (`sys_func_call $unsigned(level)`, `ref_obj NumLevels`), ours has ONE (`ref_obj NumLevels`). An operand-VECTOR gap — the `$unsigned`-wrapped genvar operand is absent from ours; nothing is folded on either side. |
| `StructParamPatternInitCast` **[r11v29, was K3]** | the mirror null: `LHS: <null>`, and our `constant 32'd64 DEC ct1` has NO `vpiParent` — an ORPHAN we mint that golden does not have. An over-emission, not a fold decision. |
| `StructParamFuncBodyFieldCompare` **[r11v29, was K6]** | golden's `constant 64` sits under an `operation` at size 32; ours under a `sys_func_call ($unsigned)` at 64. TWO differences stacked — golden dropped the `$unsigned` wrapper AND sized at 32; a size-only fix moves the head to the wrapper. Belongs with the fold-DECISION family, not with the range-bound size rows. |
| `packed_array_struct` **[r11v29, was K8]** | `'0` on a `cont_assign` to a packed array of structs: both sides `BIN` ct3, golden keeps `vpiSize:-1` (RAW, unsized) and we size it to 168. The direct residue of the landed "an unbound fill keeps its raw shape on any Rhs" law at a target shape that law does not reach. |
| `dyn_field_select` **[r11v29, was K11]** | `hier_path` `Path_elems` SHAPE: the two paths carry the same `VpiName`; golden nests `bit_select(tbl[row_i])` with a `vpiIndex`, ours is one composite `ref_obj` literally named `tbl[row_i][col_i]`. |
| `struct_member_expr_index` **[r11v29, was K11]** | `hier_path` `VpiName` TEXT: the element kinds agree; golden's text is `value.mantissa[23 - 1]` (parameter folded in) against our `value.mantissa[p::MAN_BITS - 1]`. The F1 family. |

---

## 4. THE TOP THREE DISPATCH TARGETS  (r11v29-corrected)

**1 — K1, the `inside` value range.**  5 tests / 9 rows, unchanged and the
strongest claim in the survey.  Witness rows: `MiniAmiq/default`,
`SeqDriver/default`, `SimpleUVM/default` (their heads are identical with ids
alone blinded, md5 `75555f9dd8f9`; `BuildUVMPkg` and `Scoreboard/default` join
them once the source location is blinded too, all five at md5 `0c1a52351c31` —
re-measured independently in `r11v29repro/evidence/K1_shared_head.txt`).
Suspected law: *a value range `[A:B]` inside an `inside` set is ONE operand — an
`operation` with `vpiOpType` `vpiListOp` (37) carrying the two bounds; only a
simple value element goes into the set operand list bare.*  Site:
`src/TypeEmit.cpp:16987`, whose own comment one line above
(`src/TypeEmit.cpp:16986`, "`op 95 with [x, a, b, ...]`") is the refuted model,
and there is no `OpenRangeExpression` arm anywhere in `src/` (grep re-run by
r11v29: zero hits).  Highest tests-per-fix, the smallest surface, the only
cluster that reaches the surelog UVM family, and its four coin rows hold the same
head across THREE independent database builds — so a conversion there is
attributable.

**2 — K2, `vpiNetType` on a named type carrying a packed dimension.**  5 tests /
10 rows at the head — but **the footprint bound r11u29 claimed is withdrawn**.
Witness rows: `arb_idx_cast/default` (the in-design control: one net disagrees,
its two neighbours agree), `latch_packed_enum_loop/default` (the enum-typedef
arm, so the law is not written for type parameters alone, and the ONLY one of the
five whose elaborated object kinds already agree), `gen_scope_numports/default`
(four nets, and a same-design plain-`logic` counterexample that must stay
agreeing).  Suspected law, **two halves**: *Surelog models a declaration whose
written data type is a NAME — type parameter or typedef — as a DEF-view net with
NO `vpiNetType` **and** an ELAB-view `packed_array_var`/`logic_var`, not a net at
all; an extra packed dimension on the name does not change either half.*  Site:
the `portTypeParam` guard at `src/EmitHelpers.h:860` (helper
`src/EmitHelpers.h:566`), reached from `src/TypeEmit.cpp:20233`; the emitter's own
comment at `src/EmitHelpers.h:563-565` already states both halves for the
dimension-less case.  **Dispatch this one with a census of the ELAB-view object
kind first** — clearing the stamp alone moves the head in four of the five
designs.  Shares its road with K9 (2 more tests → 7 tests on the named-type
declaration).

**3 — K4, the type parameter's lost dimension.**  4 tests / 8 rows
(`type_param_packed_dim`, `type_param_override_elem_sel`, `anon_struct_packed_dim`,
`type_param_unpacked_port`).  Witness rows: `type_param_packed_dim/default` and
`type_param_override_elem_sel/default`, whose heads are the same text line for
line once names and locations are blinded.  Suspected law: *the dimensions
written on a type-parameter override belong to the parameter's ACTUAL typespec —
golden builds a `packed_array_typespec` (packed) or `array_typespec` (unpacked)
carrying the range and hangs the element off `vpiElemTypespec`; we emit the bare
element.*  All four golden heads carry a `vpiRange`; one direction, no known
counter-arm — which is why r11v29 ranks it above K5 at equal tests-per-fix.

**The largest surface, deliberately NOT in the top three: K5 + K6 + K3, the
reducer.**  10 tests across three clusters sit on one decision — when Surelog's
constant reducer runs.  `StructParamFieldRange/default` (surelog) and
`cva6_struct_param_field/default` (u2r) are the same face in both corpora (golden
keeps `operation(hier_path Cfg.XLEN − 1)`, we fold to `INT 63` at 64);
`genscope_struct_member/default` is the encoding half (golden `UINT 15` at 32,
ours at 64); and `iface_param_2level/default` folds the OTHER way — a struct
member read through a module parameter is KEPT, the same shape through an
interface instance is FOLDED.  This is
`tools/probe/r11u27repro/README.md:407` R0 ("the fold DECISION, not the
encoding") given its first corpus witnesses.  It needs its own census before a
line is written; dispatch it after K1/K2/K4, not instead of them.

---

## 5. Files

* `TRIAGE.md` — this report.
* `CLUSTERS.tsv` — every row, its cluster, its one-line face.
* `survey.sh` — the whole measurement (rowheads + mode identity + faces +
  positive control) for one corpus.
* `facediff.py`, `decode_heads.py` — the face readers.
* `nettype_census.py` — the K2 census (calibrate golden-vs-golden first).
* `quote_cluster.sh` — the side-by-side id-blind head quotes.
* `owners.sh` — the `RHS: <null>` owner locator driver around the committed
  `r10earl60repro/tsinst60`.  NOT used for the report's owner claims: on the
  first `RHS: <null>` row it reports `POOL-EMPTY`, because its candidate pool
  is `typespec::Instance` edges only and these heads hang on `Typespec` edges.
  The owners quoted in §2 come from golden's own `vpiParent` and were
  confirmed in the golden dump instead.  **A general owner locator (pool = all
  objects, bisect, then pick the deepest single mask that moves the head) is
  the instrument this survey wanted and did not have.**
* `../r11v29repro/` — the adversarial verifier's own build, sweeps, heads,
  unfiltered K2 census, split evidence and coin double-run.
* `evidence/` — per-row heads (`*.heads.txt` per cluster), the rowheads
  tables, the mode-identity proofs, the face keys and full faces, the K2
  census, the coin double-run, the re-read stability, and this pass's own
  sweep SUMMARIES (`sweep_summary.txt` per corpus — status counts, the
  row-for-row agreement with the baseline, and the triaged row list).  The raw
  sweep CSVs are deliberately NOT committed: a whole-corpus CSV carries the
  fenced test names verbatim, and nothing in this probe directory is allowed to
  spell them.
