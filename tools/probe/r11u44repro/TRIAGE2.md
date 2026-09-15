# r11u44 — THE SECOND FULL TRIAGE of every remaining not-equal row, at `beb0c148`

MEASUREMENT ONLY. No production file is touched. The judge is the official
`uhdm-cmp`; everything below is a reading of its output, plus one order-blind
whole-dump reading beside it. This refreshes
[tools/probe/r11u29repro/TRIAGE.md](tools/probe/r11u29repro/TRIAGE.md) (base
`d24291a2`) after **thirteen landings**, passes 29–41.

---

## 0. What was measured, and the controls that make it readable

| | |
|---|---|
| base | `beb0c148` (`matrix-1.87`), own worktree at that commit |
| binary | the pristine `slang-uhdm`, md5 `68790dddaa8db9c045ceeef4330527ec`. No build: the main tree at `beb0c148` already carries exactly that binary, so it was COPIED into this pass's own scratch, md5-verified against the pin, frozen `chmod 555`, and exported as `SLANG_UHDM` for every sweep. The harness silently defaults to the MAIN-TREE binary, so every row's `cmds.txt` was read back and names the frozen path. |
| sweeps | this pass's OWN workdirs, `--jobs 2`, both corpora, both modes, `--filter` anchored to the not-equal name set |
| judge | `~/.local/bin/uhdm-cmp` (UHDM v1.87), ONE head per run, heads counted `grep -c '^LHS:'` anchored at column 0 |
| dumper | `/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump` (v1.87), 180 s budget, every dump re-read to byte-stability before it was counted |

**THE ROW COUNT. 57 not-equal rows / 29 tests**: 46 uhdm2rtlil (23 tests × 2
modes) + 11 surelog (6 tests; 5 in both modes, `Rggen` default only — its
testflags row is `SURELOG_FAIL`, not a comparable row).

**The sweeps reproduce the baseline exactly, row for row.** All 46 uhdm2rtlil
rows and all 11 surelog rows read `CMP_NOTEQUAL`, and the `Rggen/testflags` row
reads `SURELOG_FAIL`, matching `results/golden_uhdm2rtlil.csv` and
`results/golden_surelog.csv` name for name
([evidence/sweep_u2r.csv](tools/probe/r11u44repro/evidence/sweep_u2r.csv),
[evidence/sweep_sl.csv](tools/probe/r11u44repro/evidence/sweep_sl.csv)).
`results/*.csv` was read only.

**THE HEADLINE OF THE THIRTEEN LANDINGS: 18 tests converted, ZERO new
not-equal tests appeared.** Every one of the 29 tests standing here was already
not-equal at `d24291a2`; the set shrank from 47 tests to 29 and gained nothing.
Gone: `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`, `SimpleUVM`, `Scoreboard`,
`dyn_field_select`, `gen_scope_numports`, `genscope_struct_member`,
`iface_param_2level`, `interface_array_fanout`, `latch_packed_enum_loop`,
`latch_perf_counters`, `packed_array_reset_loop`, `packed_array_struct_port_sel`,
`param_name_collision_typeparam`, `param_type_logic_width`,
`struct_member_expr_index`, `struct_param_dim`.

**Positive control for the head extractor.** Two known-`CMP_EQUAL` rows per
corpus were measured through the same driver: `1DUnpackedArray`,
`2DeclarationsInFor`, `1364_2005`, `AllBinding` — eight rows, every one `0` cmp
lines, `0` heads, `cmp rc=0`
([evidence/control.txt](tools/probe/r11u44repro/evidence/control.txt)). A driver
that reaches nothing must not read as perfection, so `rowheads.sh`'s own
`SKIP-NOFILE` counter is quoted too: across the whole survey the only SKIP is
`Rggen/testflags` (expected — no database), and `UNKNOWN-NAME=0` in both corpora.

**Positive control for the DISTANCE instrument** (a census is calibrated before
it is read). The same four equal rows through `dumpdist.sh` read exactly **2**,
and those two lines are `uhdm-dump`'s own header naming its input file, one per
side ([evidence/dumpdist_calibration.txt](tools/probe/r11u44repro/evidence/dumpdist_calibration.txt)).
Every `NETDIST` below is therefore `DISTANCE − 2`, and **NETDIST 0 means the two
dumps are the same multiset of lines.**

*Verifier narrowing of that calibration (r11v44).* All four of those control
rows carry `dump=match` in the baseline CSVs — they are BYTE-identical pairs, so
what they calibrate is the instrument's header floor, not "an equal row reads the
floor". Re-run on two further `CMP_EQUAL` rows that carry `dump=differ`,
`dumpdist.sh` reads **26** (`struct_member_expr_index`) and **17**
(`PackStructVar`), while two more `dump=match` rows read the floor **2**
(`iface_gen_delay`, `Chandle`)
([../r11v44repro/evidence/control.txt](tools/probe/r11v44repro/evidence/control.txt)).
So the floor is confirmed, and the reading stands — but a nonzero `NETDIST`
never implies not-equal. Read the column only as the fidelity axis §5 calls it.

**The fenced tests.** The three slang-fenced not-equal tests were excluded by
matching the baseline rows against a FENCED list file built once from a
committed driver's own `FENCED=` line
([tools/probe/r10sd4repro/canaudit.sh:37](tools/probe/r10sd4repro/canaudit.sh#L37)).
Their names are not spelled in this pass, they appear in no cluster, no arm of
this survey dispatched them, and the `--filter` regexes that drove both sweeps
were built from the post-exclusion list. `17 − 6 = 11` surelog rows survive.

**Every two-mode test's two heads are ONE head.** For all 28 two-mode tests the
`default` and `testflags` `uhdm-cmp` output is ID-BLIND IDENTICAL
([evidence/mode_identity.txt](tools/probe/r11u44repro/evidence/mode_identity.txt),
`MODE-SPLIT rows: 0`; `Rggen` is `ONE-MODE-ONLY`). One face therefore serves both
modes, and **no row needed splitting**. The whole-dump reading agrees
independently: the per-row `GOLD_ONLY`/`OURS_ONLY` counts are identical in
`default` and `testflags` for all 23 uhdm2rtlil tests
([evidence/dumpdist_u2r.txt](tools/probe/r11u44repro/evidence/dumpdist_u2r.txt)
vs [evidence/dumpdist_u2r_tf.txt](tools/probe/r11u44repro/evidence/dumpdist_u2r_tf.txt)).

**Partial dumps.** The largest database in the survey is `Rggen` (1 587 228
golden lines / 1 582 844 ours). It, and every other row, was dumped TWICE per
side and required to be `cmp`-identical before a number was taken; no row read
`PARTIAL`. The three `ibex_*` rows (80–182 k lines) are byte-stable too.

**`--nobuiltin` — CORRECTED BY THE VERIFIER (r11v44).** Nothing here was
hand-run: every database is the harness's own, built by the argv the harness
wrote. But the original claim on this line — that the `ibex_*` heads and the
huge-design distances were taken with `--nobuiltin` on both sides — is **wrong
in `default` mode**, and every row's own `cmds.txt` says so:

```
default   … slang-uhdm -I../ibex/prim -I../ibex/rtl …ibex_icache.sv --single-unit -o …      (no --nobuiltin)
testflags … slang-uhdm -I../ibex/prim -I../ibex/rtl --top ibex_icache … --single-unit --nobuiltin -o …
```

`--nobuiltin` reaches the slang argv only through `translate()`, which runs for
`testflags` ([scripts/verify_golden.py:683](scripts/verify_golden.py#L683)) and
for `folded` ([:665](scripts/verify_golden.py#L665)). The `default` arm instead
rebuilds both argvs from `location_args(parts)`
([:313](scripts/verify_golden.py#L313)), which keeps only the point-at-the-
sources flags and therefore drops `-nobuiltin` — **from the Surelog side too**.
So the true reading is: `default` runs with builtins on NEITHER side,
`testflags` with builtins suppressed on BOTH. Each mode is SYMMETRIC, which is
what the measurement needs, because the golden cache key is the Surelog argv
itself ([:83](scripts/verify_golden.py#L83)) — the two modes are two different
cache entries, each built with its own matching argv.

No number in this report moves: the verifier re-measured every row in both
modes and the two modes agree throughout — 0 `MODE-SPLIT` heads, and identical
`GOLD_ONLY`/`OURS_ONLY` for all 23 uhdm2rtlil tests
([../r11v44repro/evidence/dd_u2r.txt](tools/probe/r11v44repro/evidence/dd_u2r.txt)
vs [dd_u2r_tf.txt](tools/probe/r11v44repro/evidence/dd_u2r_tf.txt)). These
designs use no builtin, so the flag changes nothing here — but do not carry the
original sentence forward as a control.

---

## 1. How a FACE is read, and what counts as ONE head

`uhdm-cmp` prints the head object's decompile on both sides. The FACE is the
BLIND DIFF of the two renderings — ids, `line:`/`endln:`/`col:`/`file:` and
`vpiFullName` removed, because no generated `Compare` reads a location or a full
name, so a location-only difference is noise. Two readings of the `<null>`
forms, both from [RESUME.md:419](RESUME.md#L419) §9:

* `RHS: <null>` — golden's edge points at something, ours points at nothing.
  When the LHS block renders a whole object *with* its children (C1), that is
  the VECTOR overload printing the CONTAINER: the owner is the object shown and
  the missing thing is the vector under it. Read off the pinned header, not
  remembered — [../../.local/include/uhdm/BaseClass.h:217](../../.local/include/uhdm/BaseClass.h#L217):
  `else if ((lhs != nullptr) && !lhs->empty() && (rhs == nullptr)) {
  context->m_failedLhs = lhs_obj; return 1; }` — `lhs_obj` is the OWNER and
  `m_failedRhs` is never set, so the head shows the container and `<null>`.
* `LHS: <null>` — the mirror: golden has NOTHING where WE emit an object. Three
  rows read that way here (`cfg_func_width_loop`, `packed_struct_array_fifo`,
  `StructParamPatternInitCast`), and all three are OVER-emissions, not gaps.

**A shared-head claim in this report is proved, not asserted.**
`sharedhead.sh` blinds ids, every source location (including `vpiRef*`) and the
DESIGN'S OWN NAME, then md5s both heads and prints them side by side. It does
NOT blind `vpiFullName`: a cluster that survives the full name is stronger than
one that needs it hidden. Where the md5s differ the tool prints the diff, and
this report says so instead of claiming one head
([evidence/shared/](tools/probe/r11u44repro/evidence/shared)).

---

## 2. THE RANKED CLUSTERS

Rank is TESTS PER FIX. Each test is assigned to exactly ONE cluster — the
cluster of its own head; a test whose behind-the-head residue also carries
another cluster's face is noted, never double counted.

| rank | cluster | tests | rows | one head? | the shared FACE (LHS golden / RHS ours) |
|---|---|---|---|---|---|
| 1 | **C2 — the fold DECISION** | 5 | 10 | no — one decision, five constructs | golden keeps the written expression where we fold (3 tests); golden reduces where we keep (2) |
| 2 | **C3 — the anonymous `localparam type` struct's `VpiName` + `vpiInstance`** | 2 (+2 behind other heads) | 4 (+4) | **YES**, md5 `7fa7f25fbcdf`, cross-corpus | golden's `struct_typespec` is UNNAMED with no `vpiInstance`; ours is named `it_t` and carries `vpiInstance -> module_inst` |
| 3 | **C1 — a chained / overridden type parameter's ACTUAL typespec** | 2 | 4 | **YES**, md5 `7df37b083205` | golden's actual IS the named parameter's OWN `logic_typespec` (with its range); ours is the same kind with a null `Ranges` vector |
| 4 | **C4 — an ours-only `ref_typespec -> int_typespec` on an expression object** | 2 | 4 | no — same shape, different holders | `LHS: <null>`: we mint a typespec on a `ref_obj` / on a folded constant that golden leaves untyped |
| 5 | **C5 — a struct-typed localparam's pattern Rhs carries no `vpiTypespec`** | 2 | 4 | no — two op kinds (75, 67) | golden links the pattern/cast operation to its `struct_typespec`; we link none |
| 6 | **C6 — the `$unsigned(genvar)` operand missing from a `gen_for` condition** | 2 | 4 | **YES**, md5 `7ccad305d821` | golden's op20 condition has TWO operands, the first `$unsigned(level)`; ours has ONE |
| 7 | **C7 — a folded constant's ENCODING: ours always answers `UINT`/ct9** | 2 | 4 | no — golden answers ct7 in one, ct3 in the other | same value, same size; the `vpiConstType` and the value rendering differ |
| — | **S — twelve singletons** | 12 | 23 | — | §4 |

29 tests, 57 rows, every row assigned
([CLUSTERS.tsv](tools/probe/r11u44repro/CLUSTERS.tsv); the accounting is
re-derivable with one `awk` over that file).

---

### C2 — the fold DECISION  (5 tests / 10 rows)

`bits_of_type_param`, `ibex_tracer`, `mem_packed_2d_byte_write`,
`struct_param_pattern_packing`, `StructParamFuncBodyFieldCompare`.

This is the LARGEST surface in the survey and the only cluster whose members do
NOT share one head: what they share is one producer DECISION — when Surelog's
constant reducer runs. Both directions are present.

| test | golden | ours |
|---|---|---|
| `bits_of_type_param` | KEEPS `sys_func_call $bits(req_t)` as the `param_assign` Rhs | folds to `UINT:97` at 64 |
| `ibex_tracer` | KEEPS `ref_obj ibex_tracer_pkg::OPCODE_C0` as an operand | folds to `BIN 2'b00` at 2 |
| `mem_packed_2d_byte_write` | KEEPS `op11(ref_obj NDATA, constant 1)` at a body typedef's range bound | folds — and the folded object is visibly wrong: `vpiDecompile:"NDATA-1"` carrying `UINT:1` at 64 |
| `StructParamFuncBodyFieldCompare` | DROPS the `unsigned'()` wrapper, constant under an `operation` at size 32 | keeps `sys_func_call ($unsigned)`, size 64 |
| `struct_param_pattern_packing` | **FOLDS** `hier_path CFG.n` to `UINT:3` at 32 | **KEEPS** the `hier_path` |

*Verifier correction to the direction tally (r11v44).* The ranked table's
one-liner used to read "golden keeps where we fold (4); golden folds where we
keep (1)". The split is **3 / 2**, and the table just above already says so:
`StructParamFuncBodyFieldCompare`'s `unsigned'(64)` IS written in the source
(`StructParamFuncBodyFieldCompare/dut.sv:30`), and golden is the side that
reduces it away — the same direction as `struct_param_pattern_packing`, not the
opposite one. This only sharpens the reason C2 is held back: the two directions
are more evenly balanced than the summary implied.

The golden-reduces rows carry the distinguisher in plain sight: golden's folded
`3` for `assign o_n = CFG.n;` is stamped with the source location of the literal
`3` in `localparam cfg_t LIT = '{n: 3, base: 64'h1000};` (`line:18:34`) while
its `vpiParent` is the `cont_assign` at `40:10` — Surelog substitutes the
pattern element OBJECT, it does not mint a new constant at the read.

*Landed-law residue that names it.*
[tools/probe/r11u27repro/README.md:407](tools/probe/r11u27repro/README.md#L407)
R0 — "the fold DECISION, not the encoding" — is the standing head for this
family; [tools/probe/r11u33repro/README.md:276](tools/probe/r11u33repro/README.md#L276)
R5 names `bits_of_type_param`, `ibex_tracer` and `struct_param_pattern_packing`
by name and re-measured them unchanged, and
[tools/probe/r11u35repro/README.md:382](tools/probe/r11u35repro/README.md#L382)
R2 decodes `mem_packed_2d_byte_write`'s half down to
`CompileModule.cpp:653`/`:1130` handing a hard `Reduce::No` into
`compileTypeDef` → the element `compileTypespec`. Both of those residues
explicitly say the family needs its own census before a line is written — R2
adds that `mem_packed_2d_byte_write` also carries a missing `vpiNetType:36` and
a hier-path naming behind its head, so the fold alone does not convert it.

*Why it is not in the top three.* Five tests is the biggest prize on the board
and there is still no single law: the two directions have never been shown to be
one switch, and the one row whose head is on the FOLD side
(`struct_param_pattern_packing`) would need a fold INSTALLED, the third kind of
change. Same reasoning the first triage used to hold K5+K6+K3 back.

---

### C3 — the anonymous `localparam type` struct's `VpiName` + `vpiInstance`  (2 tests at the head / 4 rows, +2 tests behind other heads)

`cva6_struct_param_field` (uhdm2rtlil) and `StructParamFieldRange` (surelog)
carry **the identical head**: blinded of ids, of every source location and of
each design's own name, the two `uhdm-cmp` outputs are the SAME 164-line text,
md5 `7fa7f25fbcdf`
([evidence/shared/C3.txt](tools/probe/r11u44repro/evidence/shared/C3.txt)).
Both designs are CVA6 `build_config_pkg` repros; their whole-dump residues are
also the same text once the names and locations are stripped, and both read
`NETDIST 497`.

The construct is `localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] x;
logic [Cfg.XLEN-1:0] y; };`. Quoted id-blind, golden and ours:

```
LHS (golden)                              RHS (ours)
struct_typespec:                          struct_typespec: (it_t)
\_struct_typespec:                        |vpiName:it_t
\_ref_typespec: (work@<D>.I.x)            |vpiInstance:
\_struct_typespec:                        \_module_inst: work@<D> (work@<D>)
\_ref_typespec: (work@<D>.I.y)            \_struct_typespec: (it_t)
                                          \_ref_typespec: (work@<D>.I.it_t.x)
                                          \_struct_typespec: (it_t)
                                          \_ref_typespec: (work@<D>.I.it_t.y)
```

Three differences on one object, two of them judged, and the judged order is
read off the pinned generated body rather than remembered —
[../UHDM/build/generated/src/typespec.cpp](../UHDM/build/generated/src/typespec.cpp)
`typespec::Compare` walks `VpiName` (setting BOTH `m_failedLhs` and
`m_failedRhs`, which is why this head renders both objects in full), then
`Typedef_alias`, then `Instance`. So the name is what stopped the judge and the
`vpiInstance` is behind it. Golden's object is UNNAMED, carries no `vpiInstance`,
and spans only the `struct packed` keywords (`23:26..23:32`); ours is named
`it_t`, carries the def-view `module_inst`, and spans to the closing brace
(`23:26..26:4`). The `it_t` segment our member `ref_typespec` full names gain is
the same fact one level down.

**The footprint is measured, not guessed, and it reaches two more tests.** The
same 60-line `it_t` residue sits in the whole-dump diff of
`StructParamPatternInitCast` and `StructParamFuncBodyFieldCompare` too — both
are the same CVA6 repro family and both declare `localparam type it_t = struct
packed {...}`, but an earlier head fires first (C2's wrapper for one, an orphan
constant for the other). Exactly **60 `it_t` lines in each of the three surelog
diffs**, a constant footprint:

```
StructParamFieldRange            total=499  it_t-lines=60
StructParamPatternInitCast       total=745  it_t-lines=60
StructParamFuncBodyFieldCompare  total=723  it_t-lines=60
```

*Landed-law residue that names it.*
[tools/probe/r11u35repro/README.md:375](tools/probe/r11u35repro/README.md#L375)
R1 names all three fields exactly — "golden's `struct_typespec` for
`localparam type it_t = struct packed {...}` is UNNAMED, carries no
`vpiInstance`, and spans `23:26..23:32`; ours is named `it_t`, carries the
def-view `module_inst`, and spans to the closing brace. Three judged fields on
one object, in both corpora." That pass measured it and declined it.
[tools/probe/r11u35repro/README.md:361](tools/probe/r11u35repro/README.md#L361)
R0 and its R4 name the typespec POOL COPY COUNT as the gate on the fold half
(golden four copies of the `x` member's typespec, ours five) — the count is a
gate on aiming a FOLD, not on stamping a NAME, which is why C3 is dispatchable
and C2 is not.

---

### C1 — a chained / overridden type parameter's ACTUAL typespec  (2 tests / 4 rows)

**SPLIT BY THE VERIFIER (r11v44): `port_chained_type_param` is NOT in this
cluster.** It was listed here as a third member on the strength of a landed
pass's residue rather than on this survey's own measurement, and the measurement
refutes it. See the box below; the cluster is `type_param_packed_dim` and
`type_param_override_elem_sel` only.

Those two carry **the identical head** — blinded, the two 47-line texts are
byte-for-byte the same, md5 `7df37b083205` under this report's blinder
([evidence/shared/C1.txt](tools/probe/r11u44repro/evidence/shared/C1.txt)) and
identical again under the verifier's independently written one
([../r11v44repro/vblind.sh](tools/probe/r11v44repro/vblind.sh)) — which needs no
design-name blinding at all here, both designs being `dut`.

The head is a whole `logic_typespec` on the LHS carrying `vpiRange -> range
[UINT:1 : UINT:0]`, with `RHS: <null>` — the vector overload printing the
CONTAINER, i.e. our copy of that typespec has NO `Ranges` vector at all. The
judged field is named in the pinned generated body:
[../UHDM/build/generated/src/logic_typespec.cpp:124](../UHDM/build/generated/src/logic_typespec.cpp#L124),
`SafeCompare(lhs, lhs->Ranges(), rhs, rhs->Ranges(), context)`. Golden's own
dump names the owner:

```
golden   type_parameter (work@dut.resp_id_t)         ours   type_parameter (work@dut.resp_id_t)
         |vpiTypespec:                                      |vpiTypespec:
         \_ref_typespec: (work@dut.resp_id_t)               \_ref_typespec: (work@dut.resp_id_t)
           |vpiActual:                                        |vpiActual:
           \_logic_typespec: , line:2:31, endln:2:42          \_logic_typespec: , line:3:32, endln:3:36
                  ^ id_t's OWN object, carrying [1:0]                ^ a FRESH object minted at the NAME, no range
```

for `parameter type id_t = logic [1:0], parameter type resp_id_t = id_t`. The
two members:

| test | the written form | golden's actual | ours |
|---|---|---|---|
| `type_param_packed_dim` | `parameter type resp_id_t = id_t` | `id_t`'s own `logic_typespec 2:31..2:42` with `range [1:0]` | a fresh `logic_typespec 3:32..3:36`, `Ranges` null |
| `type_param_override_elem_sel` | `child #(.id_t(logic [1:0])) u` | `logic_typespec 32:17..32:28` with `range 32:23..32:28` | the SAME object at the SAME span, `Ranges` null |

#### Why `port_chained_type_param` had to come out

Its head is a different object kind on a different owner at a different source
line, and the measurement is in this pass's OWN committed evidence — the report
prose simply did not match it.

```
LHS (golden)                                    RHS (ours)
struct_typespec: , line:2:32, endln:2:38        logic_typespec: , line:2:32, endln:2:90
|vpiPacked:1                                    |vpiParent:
|vpiTypespecMember: (a) (b) (c)                 \_type_parameter: (work@dut.noc_req_t), line:2:20, endln:2:29
```

* The judged difference is the **object KIND** (`struct_typespec` vs
  `logic_typespec`), not a null `Ranges` vector. The face keys say it without
  argument: C1's two members read `OURS-NULL:logic_typespec`; this row reads
  `struct_typespec G[…] O[<logic_typespec>…]`
  ([../r11v44repro/evidence/my_faces.key.txt](tools/probe/r11v44repro/evidence/my_faces.key.txt)).
* The owner is **`noc_req_t`, the FIRST parameter**, whose default is an
  anonymous `struct packed {...}` written on `dut.sv:2` — not the chained
  `req_t = noc_req_t` on line 3. This pass's own `headctx.sh` printed exactly
  that (`== port_chained_type_param side=LHS line:2:32 … SRC[dut.sv:2]:
  parameter type noc_req_t = struct packed { … }`,
  [evidence/headctx_u2r.txt](tools/probe/r11u44repro/evidence/headctx_u2r.txt)),
  and the raw head in
  [evidence/heads_raw/port_chained_type_param.default.cmp](tools/probe/r11u44repro/evidence/heads_raw/port_chained_type_param.default.cmp)
  agrees byte for byte with the verifier's re-run
  ([../r11v44repro/evidence/C1split.port_chained_type_param.cmp](tools/probe/r11v44repro/evidence/C1split.port_chained_type_param.cmp)).
  The struck table cell "a fresh `logic_typespec 3:32..3:41`" was a
  transcription error: the object is at `2:32..2:90`.

**Where it belongs instead.** By head-object kind it groups with C3, not C1 —
`struct_typespec` heads in this survey are exactly `cva6_struct_param_field`,
`StructParamFieldRange` and this row. The construct is C3's construct one
declaration-form over: an anonymous `struct packed {...}` standing as a type
default. C3 builds a `struct_typespec` and mis-stamps its `VpiName` /
`vpiInstance`; here we build **no `struct_typespec` at all**, only a bare
`logic_typespec` spanning the struct text. Different face, so it is carried in
§4 as a singleton — but it is the right row to census ALONGSIDE C3, not to
count as a C1 witness.

*Suspected producer site, already decoded by a landed pass.*
[tools/probe/r11u31repro/README.md:300](tools/probe/r11u31repro/README.md#L300)
R0 — "the chained type parameter's default must BORROW the named parameter's
object, not mint a fresh one" — names Surelog's arm
(`CompileHelper.cpp:3589-3612`, "`parameter type A = B` where B is ANOTHER type
parameter of the same list … resolve the chain directly against that list", with
`borrowed_tps` pointed at without re-parenting at `:3621-3624`) and names our
own: `makeTypeParamDefaultTs` reaches its `dt.kind == TypeAlias` arm, finds
nothing in `typedefTs` (a type parameter is not a typedef), and falls through to
minting. That residue also asserts a third member — "This is also the standing
`port_chained_type_param` face that r11v29 ejected from K4 — the same producer
arm, so R0 closes both" — but that assertion is **not confirmed by this
survey's measurement** (see the box above), and a residue written ten landings
ago is not evidence for today's head. Treat R0 as claiming the two rows whose
head this survey actually measured.
[tools/probe/r11u31repro/README.md:317](tools/probe/r11u31repro/README.md#L317)
R1 is the override arm, named on this very row: "golden's `work@dut.u.id_t`
actual is `logic_typespec 32:17..32:28` with `range 32:23..32:28` `[1:0]`; ours
is the same object AT THE SAME SPAN with a null `Ranges`. The span is already
right, so the gap is the range alone."

Both `type_param_*` rows MOVED onto this head when pass 31 (`3621c70e`) landed.

---

### C4 — an ours-only `ref_typespec -> int_typespec` on an expression object  (2 tests / 4 rows)

`cfg_func_width_loop` and `packed_struct_array_fifo`, both `LHS: <null>`, both
MOVED onto this head inside the thirteen landings. **Not one head** — the md5s
differ (`9e1d7bcab399` / `c09894c5ca5c`) because the HOLDER differs. What is
shared is the shape, quoted side by side:

```
cfg_func_width_loop                           packed_struct_array_fifo
LHS: <null>                                   LHS: <null>
ref_typespec: (q::maxw::i)                    ref_typespec: (work@…​.status_cnt_n)
|vpiParent:                                   |vpiParent:
\_ref_obj: (q::maxw::i), line:31:20           \_constant: , line:23:10, endln:23:20
|vpiActual:                                   |vpiActual:
\_int_typespec:                               \_int_typespec:
```

One is a function-body `ref_obj` (`if (cfg[i])` inside `function automatic int
unsigned maxw`), the other is a FOLDED RANGE BOUND turned constant
(`logic [ADDR_DEPTH:0] status_cnt_n`). In both we mint a `ref_typespec` named
after the enclosing declaration and point it at an `int_typespec`; golden leaves
the expression object untyped. Two arms of "we type expression objects Surelog
does not", tests-per-fix 1 + 1 unless the guard is written where both reach it.

*Landed-law residue.*
[tools/probe/r11u34repro/README.md:370](tools/probe/r11u34repro/README.md#L370)
R0 names `cfg_func_width_loop`'s head verbatim ("the extra
`ref_typespec (q::maxw::i)` on a function-body `ref_obj`").
[tools/probe/r11u41repro/README.md:260](tools/probe/r11u41repro/README.md#L260)
§6 names `packed_struct_array_fifo`'s as "a constant's `int_typespec`".
**One prediction is refuted here**:
[tools/probe/r11u37repro/README.md:360](tools/probe/r11u37repro/README.md#L360)
R0 forecast that `packed_struct_array_fifo`'s next head would be a
localparam-scope NAMING question (`work@….FifoDepth.ADDR_DEPTH` vs
`work@….ADDR_DEPTH`) plus two ours-only `packed_array_typespec`s. The measured
head is neither; the row's cmp log collapsed from 6446 lines to 17 and the
naming gap is now somewhere behind this over-emitted typespec. *(Verifier
narrowing: "refuted" applies to the HEAD forecast only — R0's predicted CONTENT
is still standing behind it and is measurable in this row's order-blind residue,
4 `work@packed_struct_array_fifo.FifoDepth.ADDR_DEPTH` lines golden-only and
8 ours-only `packed_array_typespec` lines. Do not write R0 off as wrong about
the design; it was wrong about which object the judge would stop on.)*

---

### C5 — a struct-typed localparam's pattern Rhs carries no `vpiTypespec`  (2 tests / 4 rows)

`iface_zero_width_field` and `typed_named_pattern`. Both heads are `RHS: <null>`
on a `ref_typespec` whose `vpiActual` is a `struct_typespec`; the judged field is
the owner operation's `vpiTypespec`. The owner is hidden by the singular
overload, so both were located in **golden's own dump**, not claimed:

* `iface_zero_width_field` — owner is the `vpiOpType:75` assignment pattern that
  is the `vpiRhs` of `localparam bus_t B = '{CTL:0, DAT:8, STS:0}` in package
  `p` (line `8:24`); golden hangs `vpiTypespec -> ref_typespec -> struct_typespec
  (p::bus_t)` off it. `bus_t` is an UNPACKED struct.
* `typed_named_pattern` — owner is the `vpiOpType:67` (`vpiCastOp`) over a
  `vpiOpType:33` concat that is the `vpiRhs` of
  `localparam op32_i_t NOP_CAST = op32_i_t'{imm_11_0: 12'h123, …}` (line
  `22:35`); golden hangs `ref_typespec (work@typed_named_pattern) ->
  struct_typespec (q::op32_i_t)` off it.

Same field, same direction, two different owner op kinds — so **two arms**, md5s
`3f56ad05fa8d` / `ed887e7bbf58`.

*Landed-law residue.* Both arms are already written down as separate residues by
one pass. [tools/probe/r11u34repro/README.md:375](tools/probe/r11u34repro/README.md#L375)
R1 is the unpacked-struct arm and names our site: `structPat`
(`src/ParamEmit.cpp:12912`) refuses an UNPACKED struct, "so `localparam bus_t B =
'{CTL:0, DAT:8, STS:0}` never enters the flat-fold road even though the road's
field walk already handles `UnpackedStructType`" — and that pass's own corpus
census predicted `iface_zero_width_field` by name.
[tools/probe/r11u34repro/README.md:384](tools/probe/r11u34repro/README.md#L384)
R2 is the cast arm: "`T'{named keys}` over a STRUCT target must be
`vpiCastOp(67)` over `vpiConcatOp(33)` … carrying the cast target's ref —
`§ castDefaultPatternConcat`", and warns it is "a shape change plus a phantom-net
mint, not a stamp".

---

### C6 — the `$unsigned(genvar)` operand missing from a `gen_for` condition  (2 tests / 4 rows)

`arb_idx_cast` and `genvar_pow_index` carry **the identical head**: blinded of
ids, locations and each design's own module name, the two 72-line texts are the
same, md5 `7ccad305d821`
([evidence/shared/C6.txt](tools/probe/r11u44repro/evidence/shared/C6.txt)).
Both designs write the same loop:

```
for (genvar level = 0; unsigned'(level) < NumLevels; level++) begin : …
```

Golden's def-view `gen_for` condition is an `operation` (opType 20) with TWO
operands — a `sys_func_call ($unsigned)` whose argument is `ref_obj level` bound
to an `int_var`, and `ref_obj NumLevels`. Ours has ONE: the cast-wrapped genvar
operand is simply absent.

**`genvar_pow_index` is the closest row in the corpus, and this is the whole of
it.** Its order-blind whole-dump distance is `NETDIST 13`, and every one of those
13 lines is the `$unsigned` subtree:

```
G \_sys_func_call: ($unsigned), line:12:26, endln:12:42     G |vpiArgument:
G \_operation: , line:12:26, endln:12:54                    G |vpiName:$unsigned
G \_ref_obj: (work@genvar_pow_index.level), line:12:36      G |vpiName:level
G \_int_var: (work@genvar_pow_index.level), line:12:15      G |vpiFullName:…level
G |vpiOperand:   G |vpiParent:   G |vpiParent:   G |vpiActual:   G \_sys_func_call: ($unsigned)
```

Nothing else. A fix that mints that operand **converts `genvar_pow_index`
outright**; `arb_idx_cast` (`NETDIST 512`) does not follow it.

*Landed-law residue.*
[tools/probe/r11u32repro/README.md:252](tools/probe/r11u32repro/README.md#L252)
R4 names `arb_idx_cast`'s head exactly — "a `$unsigned(genvar)` operand missing
from a def-view `gen_for` condition's operand vector (golden's operation has two
operands, ours one) … one cmp head, nothing to do with the named type." That
pass moved `arb_idx_cast` onto this head and predicted it by name before the
move.

---

### C7 — a folded constant's ENCODING: ours always answers `UINT`/ct9  (2 tests / 4 rows)

`ibex_icache` and `struct_member_cfg_width`. **Not one head** (md5
`db252567e46b` / `b2919a06c2f6`): the judged field and OUR answer are shared —
`vpiConstType` 9 with a plain `UINT` rendering, at a size that already agrees —
but golden's answer differs per arm.

```
ibex_icache (ibex_icache.sv:87, under an operation)   struct_member_cfg_width (under a param_assign)
G |INT:22   |vpiConstType:7                            G |vpiDecompile:64'b000…0011  |BIN:000…0011  |vpiConstType:3
O |UINT:22  |vpiConstType:9                            O |vpiDecompile:274877906947  |UINT:274877906947  |vpiConstType:9
```

*Landed-law residue.*
[tools/probe/r11u38repro/README.md:400](tools/probe/r11u38repro/README.md#L400)
R0 names `ibex_icache`'s NEW site — "`ibex_icache.sv:87 logic
[IC_TAG_SIZE-1:0] fill_tag_ic0;` — a PACKED range bound whose substituted leaf is
golden `INT:22` ct 7 at 32 where we write `UINT:22` ct 9 at 32 … the stored
`Value`'s ENCODING at an OPERATION LEAF, the third site of the same substitution".
[tools/probe/r11u32repro/README.md:249](tools/probe/r11u32repro/README.md#L249)
R3 predicted `struct_member_cfg_width`'s head one landing before it appeared: "a
`param_assign` whose Rhs is a 64-bit `BIN` struct constant (`cfg_pkg::cfg_t
CFG`), i.e. the landed encoding family, not this road."

---

## 3. HAS THE HEAD MOVED SINCE THE FIRST TRIAGE?

Per row, this pass's face key against the committed first-triage key
([tools/probe/r11u29repro/evidence/u2r/faces.key.txt](tools/probe/r11u29repro/evidence/u2r/faces.key.txt),
[tools/probe/r11u29repro/evidence/surelog/faces.key.txt](tools/probe/r11u29repro/evidence/surelog/faces.key.txt)),
read by the same reader. **9 of 29 heads moved by face; a tenth
(`ibex_icache`) kept its face and moved SITE** — a face key is site-blind, so
the cmp LINE COUNT is quoted as the second reading. Full table in
[evidence/moved.txt](tools/probe/r11u44repro/evidence/moved.txt).

| test | verdict | cmp lines then → now | what the old head was | what it is now |
|---|---|---|---|---|
| `cva6_struct_param_field` | MOVED | 76 → 166 | golden keeps `op11(hier_path Cfg.XLEN, 1)` at the range bound; we fold | C3: the `it_t` naming + `vpiInstance` |
| `StructParamFieldRange` | MOVED | 76 → 166 | same | C3 |
| `type_param_packed_dim` | MOVED | 94 → 47 | golden a `packed_array_typespec` over `ref_obj rt_t.DEPTH`; ours the bare element | C1: the chain-borrow, `Ranges` null |
| `type_param_override_elem_sel` | MOVED | 94 → 47 | same | C1: the override actual, `Ranges` null |
| `arb_idx_cast` | MOVED | 58 → 74 | `OURS-ONLY |vpiNetType:36` on a named-type net | C6: the missing `$unsigned(genvar)` operand |
| `cfg_func_width_loop` | MOVED | 82 → 17 | `OURS-ONLY |vpiSize:1` on a `vpiOpType:75` pattern | C4: the ours-only `ref_typespec -> int_typespec` |
| `packed_struct_array_fifo` | MOVED | **6446 → 17** | a phantom def-view `logic_net d_t` in the module's net vector | C4 |
| `struct_member_cfg_width` | MOVED | 17 → 64 | `RHS: <null>` on golden's `ref_typespec -> struct_typespec (fu_data_t)` | C7: the `BIN`/`UINT` encoding |
| `Rggen` | MOVED | **801 → 64** | `RHS: <null>` on `interface_inst …register_if[0]` with its variables | S: the element EXISTS now; its port-view `VALUE_WIDTH` reads 64 where golden reads 32 |
| `ibex_icache` | face SAME, SITE moved | 64 → 60 | the ct7/ct9 encoding at one leaf | the same face at `ibex_icache.sv:87` |

The other **19** heads are unchanged in face and in cmp line count (29 tests
minus the 10 rows of the table above; the original "20" was an arithmetic slip).
The verifier reproduced this table independently, reading the same face key
through the same committed reader against the same committed first-triage keys:
exactly nine `FACE-MOVED` rows, name for name the nine above, plus
`ibex_icache` face-same at 64 → 60 lines
([../r11v44repro/evidence/my_faces.key.txt](tools/probe/r11v44repro/evidence/my_faces.key.txt),
[rowheads_u2r.txt](tools/probe/r11v44repro/evidence/rowheads_u2r.txt),
[rowheads_sl.txt](tools/probe/r11v44repro/evidence/rowheads_sl.txt)).

**`Rggen` deserves its own sentence.** The first triage's K10 said golden has an
`interface_inst work@rggen.u_block_0.u_adapter.register_if[0]` with its variables
and "we produce no such object". Pass 35 (`ef795c51`) built it; the head then
moved 737 lines deeper, exactly as
[tools/probe/r11u36repro/README.md:231](tools/probe/r11u36repro/README.md#L231)
§7 predicted ("the head moves DEEPER, the row does not convert"). The new head is
decodable: `rggen-sample/block_0.sv:147` instantiates
`rggen_register_if #(8, 32, 64) register_if[25]()`, and
`rggen_register_if.sv:4` declares `parameter int VALUE_WIDTH = BUS_WIDTH`.
Golden's PORT-side view inside `rggen_apb_adapter` carries `VALUE_WIDTH =
UINT:32` — the interface's OWN DEFAULT, re-evaluated against its own
`BUS_WIDTH = 32` — while we carry the connected instance's actual, `UINT:64`.

---

## 4. THE SINGLETONS  (12 tests / 23 rows)

| test | NETDIST | face |
|---|---|---|
| `port_chained_type_param` | 52 | **Moved here from C1 by the verifier (r11v44).** `parameter type noc_req_t = struct packed { logic [31:0] a; logic [15:0] b; logic c; }` at `dut.sv:2` — golden builds a `struct_typespec 2:32..2:38` (`vpiPacked:1`, three `typespec_member`s); we build a bare `logic_typespec 2:32..2:90` parented straight to `type_parameter (work@dut.noc_req_t)`. The judged difference is the object KIND, so it is NOT C1's null-`Ranges` face. Closest row after `genvar_pow_index`, and C3's construct one declaration-form over — census it with C3. |
| `unpacked_elem_partsel_comb` | 60 | `RHS: <null>` on a `var_select` as a `cont_assign` Rhs. `assign cl_sel[i] = cl_rdata[i][{off_i, 3'b0} +: FW];` — golden builds `var_select(cl_rdata)` → `vpiIndex ref_obj i` → `indexed_part_select` (`vpiConstantSelect:1`, `vpiIndexedPartSelectType:1`, base `op33({off_i, 3'b0})`, width `ref_obj FW`); we emit no `var_select` there. Second-closest row in the corpus. |
| `SequenceInst` | 76 | `property_spec` expression. Golden is `op51` (`\|=>`) over `op54`/`op61` over the leaves (`start_event ##0 end_event[->1] \|=> form`); ours hands the bare `ref_obj work@m.p_triggers.rst` — the `disable iff` leaf standing where the property expression belongs. |
| `const_cast_signext` | 179 | `RHS: <null>` on a `ref_typespec (imm_t)` whose parent is the typedef's own `logic_typespec (imm_t)` at `typedef logic signed [31:0] imm_t;`: golden links the typedef alias to its base `logic_typespec`, we emit no alias. `typespec::Compare` walks `Typedef_alias` BEFORE `Instance`, so this is the alias edge. |
| `packed_array_struct` | 205 | `assign arr = '0;` onto a packed array of structs: both sides `BIN` ct3 with decompile `'0`, golden keeps `vpiSize:-1` (RAW, unsized) and we size it to 168. The direct residue of the landed "an unbound fill keeps its raw shape" law at a target shape that law does not reach. |
| `type_param_unpacked_port` | 231 | `input resp_t in_i [N-1:0]` where `parameter type resp_t = base_resp_t`: golden builds an `array_typespec` on the port (`vpiArrayType:1`, range `op11(ref_obj in_i.N, 1)`, `vpiElemTypespec -> ref_typespec`); ours is the bare `struct_typespec (pk::resp_t)`. The chain is already resolved on our side (we reach the base typedef object), so this is the unpacked PORT dimension, not C1. |
| `LargeValue2Struct` | 388 | a NAMING head: golden's `logic_typespec` is named `sram_key_t` and hangs under a `ref_typespec (work@top.pack::scrmbl_key_init_t.key.sram_key_t)`; ours is `pack::sram_key_t` with no parent. **Do not dispatch as a naming fix** — the campaign's recorded dead end is that Surelog's naming is context-dependent and a uniform `pkg::` change breaks goldens. Decide it from the OWNER. |
| `StructParamPatternInitCast` | 743 | the mirror null: `LHS: <null>`, and our `constant 32'd64 DEC ct1` at `localparam user_cfg_t Base = '{XLEN: 32'd64};` has NO `vpiParent` — an ORPHAN we mint that golden does not have. Behind it sits C3's 60-line `it_t` residue. |
| `anon_struct_packed_dim` | 860 | `struct packed { pte_t pte; pte_t gpte; } [1:0] content_q, q_n;` — golden a `packed_array_typespec` (`vpiRange -> [UINT:1 : UINT:0]`, `vpiElemTypespec -> ref_typespec -> struct_typespec`); ours a bare `logic_typespec`. The pass-30 law ("a packed dimension on a named element is an array typespec over that element") asked at an ANONYMOUS struct DECLARATION instead of a named element. |
| `iface_zero_width_field` | 1115 | see C5 — cluster member; the NETDIST is quoted here because it is the largest of the small rows. |
| `stamped_gen_param` | 1378 | golden `logic_typespec (q2::row_t)` NAMED, reached through a `ref_typespec (q2::q2::row_t)`, wrapped by a `packed_array_typespec` with `UINT:2`; ours an UNNAMED `logic_typespec` reached through a `typespec_member (UnitTypes)` with `UINT:1`. C1-adjacent (a type parameter's actual) but the objects differ too much to share a fix. [tools/probe/r11u34repro/README.md:375](tools/probe/r11u34repro/README.md#L375) R1's census also lists it as "a PACKED-struct face of the same column" as C5. |
| `ibex_pmp` | 5800 | a packed range bound whose leaf is a WILDCARD-IMPORTED package parameter: same value, golden `vpiSize:32`, ours 64. [tools/probe/r11u33repro/README.md:253](tools/probe/r11u33repro/README.md#L253) R1 decodes it (`parameter int unsigned PMP_ADDR_MSB = 33`, `g2_site33` 65:9/66:9 are the purpose-built twins) and warns it converts nothing on its own — "`ibex_pmp` has 36 further STILL-WRONG range cells behind that head". |
| `ibex_tracer` | 19807 | see C2 — cluster member. Its NETDIST is the largest of the non-`Rggen` rows. |
| `Rggen` | 76532 | see §3. |

*(`iface_zero_width_field`, `ibex_tracer` and `Rggen` are cluster/§3 members
repeated here only for their distance; the twelve singleton TESTS are the rows
marked `S` in [CLUSTERS.tsv](tools/probe/r11u44repro/CLUSTERS.tsv).)*

---

## 5. THE WHOLE-DUMP DISTANCE, every row, closest first

`NETDIST` = order-blind multiset difference of the two `uhdm-dump` renderings
(ids blinded, absolute paths reduced to basenames — **dump paths embed the
workdir**), minus the instrument's calibrated floor of 2. Both modes agree row
for row, so `default` is quoted.

| NETDIST | test | cluster | | NETDIST | test | cluster |
|---:|---|---|---|---:|---|---|
| 13 | `genvar_pow_index` | C6 | | 231 | `type_param_unpacked_port` | S |
| 52 | `port_chained_type_param` | S | | 320 | `struct_param_pattern_packing` | C2 |
| 60 | `unpacked_elem_partsel_comb` | S | | 388 | `LargeValue2Struct` | S |
| 76 | `SequenceInst` | S | | 497 | `cva6_struct_param_field` | C3 |
| 101 | `bits_of_type_param` | C2 | | 497 | `StructParamFieldRange` | C3 |
| 134 | `cfg_func_width_loop` | C4 | | 512 | `arb_idx_cast` | C6 |
| 141 | `type_param_packed_dim` | C1 | | 675 | `typed_named_pattern` | C5 |
| 153 | `mem_packed_2d_byte_write` | C2 | | 721 | `StructParamFuncBodyFieldCompare` | C2 |
| 168 | `type_param_override_elem_sel` | C1 | | 743 | `StructParamPatternInitCast` | S |
| 179 | `const_cast_signext` | S | | 860 | `anon_struct_packed_dim` | S |
| 190 | `struct_member_cfg_width` | C7 | | 1115 | `iface_zero_width_field` | C5 |
| 205 | `packed_array_struct` | S | | 1378 | `stamped_gen_param` | S |
| 216 | `packed_struct_array_fifo` | C4 | | 5800 | `ibex_pmp` | S |
| | | | | 7584 | `ibex_icache` | C7 |
| | | | | 19807 | `ibex_tracer` | C2 |
| | | | | 76532 | `Rggen` | S |

Read it as a fidelity axis, not a judge: a row can carry one head and 13 wrong
lines (`genvar_pow_index`) or one head and 76 532 (`Rggen`). **Six rows are under
100 lines from golden**; all six have a decoded face.

---

## 6. THE TOP THREE DISPATCH TARGETS

The ranked table above is ordered by tests-per-fix. The dispatch order is not
the same, because two of the larger clusters carry an explicit "census first"
from the passes that measured them.

**REORDERED BY THE VERIFIER (r11v44).** The original order put C1 first on the
strength of three tests. The C1 split leaves it with two, tying it with C4, C5,
C6 and C7 on tests-per-fix, so the tie has to be broken on reach and on proof
instead: C3 now carries the largest dispatchable reach on the board (up to
4 tests / 8 rows, measured), and C6 carries the survey's only *proved*
conversion. C1 keeps third place on the strength of a site decoded down to our
own function name — that has not changed, only its test count has.

**1 — C3, the anonymous `localparam type` struct's `VpiName` + `vpiInstance`.**
The largest dispatchable reach in the survey: 2 tests at the head, 2 more behind
it, up to **4 tests / 8 rows on one law**. Detail in the §6 entry that follows
(unchanged from the original, which had it third).

**2 — C6, the `$unsigned(genvar)` operand.** The only fix this triage can PROVE
converts a row. Detail below.

**3 — C1, the chained / overridden type parameter's ACTUAL typespec.**
**2 tests / 4 rows**: `type_param_packed_dim` and
`type_param_override_elem_sel`. Witness rows: `type_param_packed_dim/default`
and `type_param_override_elem_sel/default`, whose heads are byte-identical
blinded (md5 `7df37b083205`, quoted in
[evidence/shared/C1.txt](tools/probe/r11u44repro/evidence/shared/C1.txt),
re-proved independently by the verifier). `port_chained_type_param` is NOT a
witness — its head is a `struct_typespec`/`logic_typespec` KIND mismatch on the
first parameter's anonymous-struct default, §2. Suspected law: *the actual
typespec of `parameter type B = A`, and of an override written as a keyword type
with packed dims, IS the named object — golden points at `A`'s own typespec (its
range) without re-parenting; we must stop minting a fresh unranged one at the
name.* Site, already decoded and left standing by the pass that created this
head: [tools/probe/r11u31repro/README.md:300](tools/probe/r11u31repro/README.md#L300)
R0 (our `makeTypeParamDefaultTs` `dt.kind == TypeAlias` arm falling through to a
mint; Surelog `CompileHelper.cpp:3589-3612` + `:3621-3624`) and
[tools/probe/r11u31repro/README.md:317](tools/probe/r11u31repro/README.md#L317)
R1 (the override arm, "the gap is the range alone"). The brief must say that R0
also claims `port_chained_type_param` and that this survey does not: score the
pass on two tests, and let the third ride with C3's census.

---

*The two entries below are the original §6 text for C6 and C3, kept verbatim;
only their rank labels changed.*

**C6, the `$unsigned(genvar)` operand.** 2 tests / 4 rows, ONE head (md5
`7ccad305d821`), and the only place in this triage where a fix is *proved* to
convert a row: `genvar_pow_index`'s ENTIRE order-blind whole-dump residue is the
missing operand, 13 lines, nothing else — so clearing the head clears the row.
Witness rows: `genvar_pow_index/default` (the conversion) and
`arb_idx_cast/default` (the same head at `NETDIST 512`, which will move but not
convert — say so in the brief so the pass is not scored against it). Suspected
law: *a `gen_for` condition's operand vector must carry the cast-wrapped genvar
— `sys_func_call ($unsigned)` over `ref_obj level` bound to the loop's
`int_var` — as its first operand; we drop the wrapper and the operand with it.*
Named a landing ago by
[tools/probe/r11u32repro/README.md:252](tools/probe/r11u32repro/README.md#L252)
R4. Smallest surface on the board.

**C3, the anonymous `localparam type` struct's `VpiName` + `vpiInstance`.**
2 tests at the head (`cva6_struct_param_field`, `StructParamFieldRange` — ONE
head, md5 `7fa7f25fbcdf`, **the only cross-corpus shared head in the survey**),
and the SAME 60-line residue measured behind the heads of two more
(`StructParamPatternInitCast`, `StructParamFuncBodyFieldCompare`), so up to
**4 tests / 8 rows on one law**. Witness rows: `StructParamFieldRange/default`
and `cva6_struct_param_field/default`. Suspected law: *an anonymous
`struct packed {...}` written as a `localparam type`'s default is UNNAMED and
carries no `vpiInstance` — the `it_t` name belongs to the type parameter, not to
its typespec — and its span is the `struct packed` keywords alone.* Named field
for field by [tools/probe/r11u35repro/README.md:375](tools/probe/r11u35repro/README.md#L375)
R1, which measured it and declined it. Two cautions for the brief: (a) two of the
three judged fields are `VpiName` and `Instance`, and Surelog's naming is
context-dependent — decide it from the OWNER, never by a uniform rename;
(b) the pool COPY COUNT that
[tools/probe/r11u35repro/README.md:361](tools/probe/r11u35repro/README.md#L361)
R0/R4 names is the gate on the FOLD half of these designs, not on this stamp, so
it does not block the dispatch — but it will still be standing afterwards on the
two behind-head rows. *(Verifier addition: send `port_chained_type_param` with
this brief as a CENSUS question, not a conversion target. It is the same
construct — an anonymous `struct packed {...}` standing as a type default — at
the parameter-port-list declaration form, where we build no `struct_typespec` at
all. Whether one producer serves both forms is exactly what a census would
settle, and the answer decides whether this law is worth 4 tests or 5.)*

**Deliberately NOT in the top three: C2, the fold DECISION — 5 tests / 10 rows,
the largest surface.** It is ranked first by tests-per-fix and dispatched last
because no single law has been written for it: the two directions
(golden-keeps-we-fold on four tests, golden-folds-we-keep on
`struct_param_pattern_packing`) have never been shown to be one switch, closing
the second means INSTALLING a fold, and both
[tools/probe/r11u33repro/README.md:233](tools/probe/r11u33repro/README.md#L233)
R0 and [tools/probe/r11u35repro/README.md:382](tools/probe/r11u35repro/README.md#L382)
R2 say in as many words that it needs its own census first. Dispatch it after
C1/C6/C3, with a census brief, not an implement brief.

---

## 7. Files

* `TRIAGE2.md` — this report.
* `CLUSTERS.tsv` — every test, its rows, its cluster, its MOVED verdict, its
  `NETDIST` and its one-line face. The accounting (29 tests / 57 rows) is
  re-derivable with one `awk` over it.
* `survey2.sh` — the whole measurement end to end: fence list from a committed
  driver, row set from the READ-ONLY baselines, frozen md5-verified binary, both
  sweeps, heads, mode identity, faces, constructs, distances, and BOTH positive
  controls.
* `dumpdist.sh` — the order-blind whole-dump distance (calibrated golden-vs-
  golden-equal to a floor of 2; re-reads every dump to byte-stability; blinds the
  embedded workdir).
* `headctx.sh` — the head's object, its `vpiParent` and the SOURCE LINE the
  construct is written on.
* `sharedhead.sh` — the shared-head prover: blinds ids, every location and the
  design's own name, md5s both heads, prints IDENTICAL or the diff.
* `evidence/` — `rowheads_*.txt` (cmp lines + head count per row, with the
  SKIP/UNKNOWN counters), `control.txt` and `dumpdist_calibration.txt` (both
  positive controls), `mode_identity.txt`, `faces.key.txt` / `faces.full.txt`,
  `headctx_*.txt`, `dumpdist_*.txt` (both modes), `moved.txt` (the
  head-moved verdict against the committed first triage), `shared/C*.txt` (the
  side-by-side head quotes per cluster, with md5s), `heads_raw/` (every row's
  raw `uhdm-cmp` output, ids blinded), and this pass's own filtered sweep CSVs.
  The sweeps were `--filter`ed to the 29 triaged tests, so no artifact in this
  directory spells a fenced test name.
* [tools/probe/r11u29repro/TRIAGE.md](tools/probe/r11u29repro/TRIAGE.md) — the
  FIRST triage (base `d24291a2`), which this report refreshes.
