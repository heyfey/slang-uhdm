# r10vbuvm33 — adversarial verification of r10buvm33 (§ foreachScopedArrayWrittenClassVar33)

**VERDICT: ACCEPT.**  Every headline number reproduced bit-for-bit on this
verifier's own two builds; no pristine-right → patched-wrong cell was found on
any legal SystemVerilog shape, in either view, on 23 arm-views (the pass's
three arms, four new ones built here, and every earlier-pass arm the boundary
gate moved).  Two unmodelled escapes of the law are recorded below as R-V1 and
R-V2; neither is a regression and neither has any corpus incidence.

---

## 1. Bit-for-bit reproduction

Fresh worktrees at `7fcedfe` (pristine and patched), both configured
`-DCMAKE_BUILD_TYPE=Release` and built `-j 2`, md5'd separately, frozen
`chmod 555` before any sweep:

| binary | md5 | matches the pass's claim |
|---|---|---|
| pristine | `ae34152a8fddb784814f747eefb923c5` | yes |
| patched  | `9bb6af0a9bd2a50a7ab4fbb3fe375e2c` | yes |

Patch applies to a fresh `7fcedfe` with `git apply -3` rc=0, 0 conflict
markers, fence check 0/0/0/0, `results/*.csv` untouched, surface =
`include/UhdmExporter.h` + `src/StmtEmit.cpp` + `tools/probe/r10buvm33repro/`.

| gate | measured here | claimed |
|---|---|---|
| `tests/check_goldens.sh` (SLANG_UHDM exported to the patched binary) | 23 PASS / 0 FAIL | same |
| negative control `SLANG_UHDM=/bin/false` | 0 PASS / 23 FAIL | same |
| surelog `--mode both`, 1588 rows, BOTH binaries | `937 CMP_EQUAL / 567 SLANG_REJECT / 48 SURELOG_FAIL / 19 CMP_NOTEQUAL / 10 DEFERRED / 3 NO_DATABASE / 2 UNTRANSLATABLE / 1 TIMEOUT / 1 NO_UHDM`, identical on both sides | same; **no row converted** |
| `ct8rows.sh` surelog: committed-vs-patched, pristine-vs-patched, committed-vs-pristine | PASS ×3 (status AND dump) | same |
| uhdm2rtlil testflags AND default, BOTH binaries | 679 / 50 / 2 in all four sweeps | same |
| `ct8rows.sh` u2r: committed-vs-patched(tf), pristine-vs-patched(tf), pristine-vs-patched(def) | PASS ×3 | same |
| `byteverify.sh SELFCHECK=1` surelog | MOVERS **9 / 956**, SELFCHECK 955/956 | same |
| `byteverify.sh SELFCHECK=1` uhdm2rtlil | MOVERS **0 / 1358**, SELFCHECK 1357/1358 | same |
| canaries | `ok=52 changed=0 absent=0` and `ok=8 changed=0 absent=0` | same |
| `ctcan2.sh` EXPECT_UNKNOWN=1 / =6 | PASS / PASS | same |
| `canaudit.sh canaries.sh ctcan2.sh` from the pass dir | `audited=29 UNCOVERED=0 FENCE-BREACH=0` | same |
| protected DBs (md5, both modes) | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME**; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | same |

**cmds.txt audited BY BINARY PATH, file by file** (not by the string
`slang-uhdm`, which also matches `~/.cache/slang-uhdm-goldens/`):

* surelog, pristine workdir: 1523 / 1573 name `/tmp/vbuvm33_pris.bin`, **0 name
  the main-tree binary**; the other 50 are golden-cache hits that invoke no
  slang binary at all (verified by extracting every `*slang-uhdm*` token from
  those 50 files — all of them are `~/.cache/slang-uhdm-goldens/<hash>` paths).
* surelog, patched workdir: 1523 / 1573 name `/tmp/vbuvm33_pat.bin`, 0 main-tree.
* uhdm2rtlil: 1458 / 1462 each side, 0 main-tree.

**Movers, attributed ORDER-BLIND** (both dumps id-normalised, the uhdm-dump
`Restored design` banner normalised, `LC_ALL=C sort`ed — the only sound
attribution for `Scoreboard/default` and `SeqDriver`, which are coins):

```
default/BuildUVMPkg 36   default/MiniAmiq  72   default/Scoreboard 36
default/SeqDriver   72   default/SimpleUVM 36
testflags/BuildUVMPkg 36 testflags/MiniAmiq 72  testflags/SeqDriver 72
testflags/SimpleUVM   36                        = 468 lines
```

**0 unattributed lines**: every one of the 468 names `m_typewide_sequences`.
(The raw per-DB diff reads 38 / 74 because the dump's first line carries the
database path; normalising it away leaves 36 / 72.)

**Heads** (`rowheads.sh`, pristine and patched sweeps, one `^LHS:` each):
SeqDriver default+testflags 56 → 56 and BuildUVMPkg default+testflags 56 → 56,
with the head OBJECT moving from
`class_var 'this_type::m_typewide_sequences' @496:12-496:23` (pristine LHS,
read from this verifier's own pristine cmp log) to
`LHS int_var (…::i) @496:44-496:45` vs `RHS array_var (…::i)` — the pass's R0,
confirmed on all four row-modes.  SimpleUVM 17, Scoreboard/default 60,
MiniAmiq 60, Earlgrey_0_1 36, Rggen 0: unchanged.

**Independent TO-GOLDEN check on a second row.**  SimpleUVM/default's golden
cache database was dumped and the cell read directly: the patched
`class_var (…::this_type::m_typewide_sequences) line:496:12 endln:496:23` +
`unsupported_typespec (this_type::m_typewide_sequences)` is character-identical
to golden's, where pristine had `ref_var (…::m_typewide_sequences) 496:12-496:32`.

---

## 2. The instruments built here

`vgrid33.py` is a **VIEW-GENERAL MULTISET** comparator, written because the
pass's own `gridcmp33.py` keys a dict on the foreach's SOURCE LINE and keeps
the FIRST expansion (`if key not in out`).  A package's DEF and ELAB copies
land on the same source line, so a per-line last/first-writer dict can hide a
disagreement in whichever copy it drops — buvm19's and buvm22's recorded trap.
`vgrid33.py` instead counts EVERY `foreach_stmt` occurrence as a multiset row.

It also keys on the object's own **`|vpiName:` field**, never on the
parenthesised label the dump prints after `\_class_var:` — that label is the
**vpiFullName**, which no generated `Compare` reads.  Keying on it manufactured
20-25 phantom "residues" per elaborated arm on the first run here (golden's
`work@top33.oob33.…` copy against our `p33::der33::oob33.…` copy); re-keying on
`vpiName` collapsed all of them.

`PROJ=var` projects onto (line, col, VAR kind/name/span, TS kind/name/span);
`PROJ=loop` projects onto the loop variables; the default keeps both.
`vdist33.py` turns the same parse into an order-blind **multiset distance to
golden**, so an arm can be scored rather than eyeballed: a landing may never
raise `dist(golden, patched)` above `dist(golden, pristine)`.

`varm33.sh` runs one arm in BOTH views against Surelog and BOTH frozen
binaries, echoing every command and its rc into `cmds.txt`.

---

## 3. The four arms built here (every cell read off golden)

* **`v33a.sv` — TARGET TYPES.**  The same `C::<array>` foreach over a packed
  vector, a byte unpacked array, a base-less enum array, a based enum array, a
  packed-struct array, a packed-union array, a typedef'd array, a queue of
  class handles, a string-keyed assoc, an int-keyed assoc, a 2-D unpacked
  array, and the two SKIPPED-dimension spellings `[,j]` / `[i,]`.  **Golden
  answers `class_var 'tc33::<name>'` + `unsupported_typespec` of the same name
  and span for every one of the twelve** — the law is type-independent, and the
  span always ends at the column the final identifier starts at.
* **`v33b.sv` — QUALIFIER SHAPES.**  `$unit::`, a package-typedef collision, a
  package `parameter` array, a package `localparam` array, a typedef'd-type
  parameter array, a packed-element parameter array, a package and a class
  sharing a name, an ESCAPED final identifier, a static-method home, two
  independent class qualifiers.  All four parameter spellings answer golden's
  `class_var 'coll33::<P>'` over a **bare `int_typespec`** — the patch's one
  escape covers `parameter`, `localparam`, a typedef'd type and a packed
  element alike.  The escaped final identifier `esc33c::\esc.name33` comes out
  `class_var 'esc33c::esc.name33' @47:14-47:22` on both golden and patched.
* **`v33c.sv` — HOMES.**  A package task, an out-of-body method of a class
  declared INSIDE a module, a `fork…join_none`, a `final` block, an interface
  `initial`, a MODULE TWIN with identical text, a generate loop with two
  instances, two instances of the same module, a virtual class qualifier, a
  `$unit` class qualifier and a scoped `foreach` inside a CONSTRAINT.
* **`v33d.sv` — THE OTHER POSITIONS.**  24 non-`foreach` sites for the same
  `::`-scoped data reference — `cont_assign` Rhs and output `cont_assign`, port
  actual, bare read, assignment Lhs, indexed read, indexed Lhs, part-select,
  indexed part-select, `$size`, `$bits`, package qualifier, package indexed,
  three segments, `$display` arguments, a scoped CALL with a scoped argument, a
  scoped void call, a package free function, concat members, a condition, a
  call argument, a return expression — beside the law's own cell.

**The whole pristine-vs-patched delta on `v33d` is the ONE foreach cell**: the
raw dump diff is 20 lines in the def view and 34 in elab, and every line is the
D21 `dsrc33::sq33` header (`ref_var 'sq33' @45:14-45:18` →
`class_var 'dsrc33::sq33' @45:14-45:22`, matching golden exactly).  All 24
other positions and both scoped calls are byte-identical, so
§ staticScopedRef12 and § classScopeCallWrittenQualifierIsLookupKey32 are
untouched by construction, not just by assertion.

---

## 4. Score: no arm gets farther from golden

`vgrid33.py PROJ=var` verdicts and `vdist33.py` distances, golden vs pristine
vs patched, both views, 23 arm-views:

```
g33a1  def  dist 44 -> 0     g33a1  elab dist 124 -> 0
g33a2  def  dist 44 -> 8     g33a2  elab dist 132 -> 60
g33a3  def  dist 16 -> 2     g33a3  elab dist  30 -> 4
v33a   def  dist 29 -> 3     v33a   elab dist  58 -> 6
v33b   def  dist 28 -> 6     v33b   elab dist  56 -> 12
v33c   def  dist 28 -> 8     v33c   elab dist  80 -> 24
v33d   def  dist  2 -> 0     v33d   elab dist   4 -> 0
vg25   def  dist 26 -> 18    vg25   elab dist  59 -> 41
vg19c  def  dist 16 -> 8     vg19c  elab dist  30 -> 18
vg19d  def  dist 10 -> 2     vg19d  elab dist  20 -> 4
vg19e  def  dist  8 -> 4     vg19e2 def  dist   8 -> 4
                             vg19e2 elab dist  18 -> 10
```

**Every arm-view strictly better; WORSE = 0; BROKEN = 0.**  `g33a1` and `v33d`
reach distance 0 in both views.

The official `uhdm-cmp` on the earlier-pass arms the boundary moved:
`vg19e` def **56 → 15**, `vg19e2` def and elab **56 → 50**, `vg25` elab
**4680 → 4676**, `vg19c` / `vg19d` unchanged at 128 — those two arms' own heads
lie elsewhere.

---

## 5. Why the law CANNOT regress this face (structural, not statistical)

Read from Surelog rather than inferred:

* `CompileStmt.cpp:527` hands the foreach loop list's child to
  `compileVariable`, so a `::`-written array reference always enters
  `CompileType.cpp:554`'s `paClass_scope` arm — measured, not assumed: a
  PACKAGE qualifier (`coll33::PA33`, `both33::bv33`) takes the same arm, not
  `paPackage_scope`.
* That arm's `completeName` is `StrCat(packageName, "::", typeName)` =
  **first written segment + final identifier**, unconditionally, whether or not
  any lookup hits.
* The only way the KIND is not `class_var` is
  `getSimpleVarFromTypespec` (`CompileType.cpp:78-240`), and the seventeen
  variable kinds it can mint — `int_var`, `logic_var`, `bit_var`, `byte_var`,
  `enum_var`, `struct_var`, `union_var`, `array_var`, `packed_array_var`,
  `class_var`, `string_var`, `real_var`, `short_real_var`, `integer_var`,
  `long_int_var`, `short_int_var`, `time_var` — **do not include `ref_var`**.

So golden's answer for a `::`-written foreach array is never
`ref_var '<leaf>'`, and `ref_var '<leaf>'` is exactly what the pristine binary
emitted for every one of them.  There is no cell on this face where pristine
was right, which is why no BROKEN cell exists to be found.

---

## 6. Boundary gate (independent run, whole probe tree + the four new arms)

`bound33.sh` over a COPY of `tools/probe` with the four arms of this directory
added, no path filter, `.sv` and `.v`, arm list on fd 3, children `</dev/null`,
PROCESSED asserted, rc per cell, four configurations:

```
MODE=file VIEW=def   PROCESSED=3611 LISTED=3611 DIFFER=13 PRIS_REJECT=138 PATCHED_REJECT=138
MODE=file VIEW=elab  PROCESSED=3611 LISTED=3611 DIFFER=12 PRIS_REJECT=152 PATCHED_REJECT=152
MODE=dir  VIEW=def   PROCESSED=1528 LISTED=1528 DIFFER= 8 PRIS_REJECT=121 PATCHED_REJECT=121
MODE=dir  VIEW=elab  PROCESSED=1528 LISTED=1528 DIFFER= 7 PRIS_REJECT=127 PATCHED_REJECT=127
```

`PRIS_REJECT == PATCHED_REJECT` in all four and `asym.txt` was never written —
no asymmetric reject anywhere.  Every differing arm accounted for:

* `r10buvm33repro/g33a{1,2,3}` and `r10vbuvm33repro/v33{a,b,c,d}` — the law's
  own arms, scored against golden in §4.
* `r10vbuvm19repro/vg19c`, `vg19d`, `vg19e`, `vg19e2` and
  `r10vbuvm25repro/vg25` — earlier-pass arms that carry this law's cell; all
  five move TOWARD golden (§4), and `vg19e`/`vg19e2` had this law's cell as
  their OWN uhdm-cmp head.
* `r10buvm22repro/g22.sv` — the carried ADDRESS family: 12 diff lines, **0 of
  them anything but `|UINT:` / `|vpiDecompile:`**, and every value shifted by
  **exactly 4096**; the same binary run twice on this arm differs in 0 lines,
  so it is layout, not behaviour.
* `r10uvm75repro`, `r10uvm76repro`, `r10uvm88repro`, `r10v109repro` (dir mode
  only) — proved COINS by running the PRISTINE binary twice on each: 14, 14, 4
  and 10 differing lines with no patch involved at all.
* `r10vbuvm19repro` is a BOTH-REJECT in dir mode, which is why it appears in
  the file lists and not the directory ones.

**No bind-window directory appears in any differ list** — `classArgBind12`,
`retNameRecvCollapseArgsBindLikeBody15`, `collArgNamedBlkLocalNoBind15`,
`controlBodyNoBind28`, `blkLocalSameCtrlDepthArgBinds57/64`,
`pkgVarBindsOnlyThroughInstance88`, `formalDefaultBindsLikeBody13`,
`classInBodyRecvCallArgNoBind52`, `superNewFormalBinds28`, `newArrayArgNoBind16`,
`writtenCallArgs16`, `namedTfArgsFormalSlots4`, `genLpPortConnCopyableOnly11v`,
the uvm89/92/94/95 name-text arms, buvm23/24/26/27/28's and uvm90/95/96's arms
are all byte-identical in both views.

---

## 7. Residues found here (ranked), and the pass's own, confirmed

**R-V1 — the package-typedef COLLISION refutes "no lookup".**  The law is
stated as "the written text is the whole rule: no lookup, no key, no
resolution".  There IS a lookup, and it can hit.  `CompileType.cpp:562`
(`pack->getDataType(typeName)`) and `:582-596` (`design->getClassDefinition`,
bare then `<component>::<first>` then `<parentScope>::<first>`) both run
BEFORE the `class_var` default at `:614`, and a hit replaces the kind through
`getSimpleVarFromTypespec`.  It misses for a data member because
`insertDataType` (`CompileHelper.cpp:160/168/636`) registers typedefs and class
definitions while variables go into a separate map — but nothing stops the
FINAL identifier's name from ALSO naming a typedef of the FIRST segment's
package.  Measured on `v33b.sv` cell W5:

```
package coll33; typedef int dq33; class inner33; static int dq33 [$]; ... endpackage
foreach (coll33::inner33::dq33[i])
  golden    int_var   'coll33::dq33' @59:14-59:31  ts int_typespec 'coll33::dq33' @12:11-12:14
  pristine  ref_var   'dq33'         @59:14-59:18  ts unsupported_typespec 'dq33'
  patched   class_var 'coll33::dq33' @59:14-59:31  ts unsupported_typespec 'coll33::dq33' @59:14-59:31
```

The patched cell has golden's NAME and golden's SPAN and pristine had neither,
so this is strictly closer, not a regression — but the KIND and the TYPESPEC
are still wrong on this shape.  Zero corpus incidence (the census's 26 scoped
foreach cells are one name in one home) and the neighbouring cell W6
(`coll33::inner33::only33`, no collision) is byte-right.  Modelling it needs
the package/class DataType lookup plus a typespec→var-kind map, which is a law
of its own; it should be a separate pass if a corpus row ever needs it.

**R-V2 — the `$unit::` qualifier is a MISS.**  `v33b.sv` cell W4,
`foreach ($unit::uarr33[i])` over a `$unit`-scope array: golden answers
`class_var '$unit::uarr33' @58:14-58:21` + `unsupported_typespec` of the same
name and span — Surelog's `packageName` is simply the token text `$unit`.
`foreachScopedArrayName33`'s `segId33` returns a null token for slang's
`UnitScope` node, so the helper bails and we keep pristine's
`ref_var 'uarr33'`.  Again a miss, not a regression (pristine was equally
wrong), and again zero corpus incidence — but it is a one-case extension of
`segId33` if the shape ever appears.  Note the pass's README claims a `$unit`
qualifier among its "sixteen spellings": those cells (`g33a2` S4/T2) qualify by
a CLASS DECLARED in `$unit` (`unitc33::`), which is an ordinary identifier; the
literal `$unit::` token is not covered by any of the pass's arms.

**R-V3 — elaborated copy count on `g33a2`.**  Golden emits 5 copies of the
out-of-body class-scope body where we emit 4 (and 15 headerless `foreach_stmt`
rows where we emit 12).  Identical in pristine and patched, so pre-existing and
not this law; it is what raises `g33a2 elab`'s residual distance to 60 while
`g33a1 elab` reaches 0.

**R-V4 — bare foreach over a packed vector / a `$unit` variable.**  `v33a` V14
binds an `array_typespec` where golden binds the vector's own
`logic_typespec @31:3-31:14`; `v33b` W15 binds an `array_typespec` where golden
binds `unsupported_typespec 'uarr33'`.  Unqualified spellings, untouched by
this patch, unchanged between the two binaries.

**R-V5 — hygiene.**  `tools/probe/r10buvm33repro/bound33.sh:24` still carries
buvm32's default `OUT=${OUT:-/tmp/r10buvm32_bound}`.  It is an overridable
default and every run here passed `OUT` explicitly, but a driver in pass N
should not name pass N-1's scratch.

**The pass's own residues, confirmed by measurement here:**

* **R1** (escaped-qualifier span) — `g33a3` E1 `\esc33 ::eq33`: kind and name
  are golden's, end column 23 against golden's 27.  Confirmed; spans are not
  read by any generated `Compare`, and pristine was wrong in kind AND name AND
  span, so nothing regressed.
* **R4** — `r10vbuvm19repro/vg19e.sv --elabuhdm` **segfaults rc=139 on BOTH
  binaries**, reproduced here directly (both children died with SIGSEGV and no
  database on either side).  Pre-existing and symmetric.
* **R5** — the `g22` address family, verified line by line above.

**R0 confirmed.**  With the class_var cell cleared, the new head on all four
row-modes is the loop variable of the same `foreach`, one field later in
`foreach_stmt::Compare`: `LHS int_var (…::i) @496:44-496:45` (with a
`ref_typespec -> int_typespec`) against `RHS array_var (…::i)` (with an
`array_typespec`).  It was masked, not created: none of the 468 attributed
mover lines mentions it.  This verifier's arms show the same split
independently — `v33c` and `v33a` answer `int_var 'i'` on golden and
`array_var 'i'` on both our binaries for the loop variable of a scoped foreach
in the package-task, module, interface, generate and `$unit`-class homes, while
every unqualified control agrees.

---

## 8. Files

* `v33a.sv` / `v33b.sv` / `v33c.sv` / `v33d.sv` — the four arms of §3.
* `vgrid33.py` — the VIEW-GENERAL multiset foreach-header comparator, keyed on
  `vpiName` and never on the dump's parenthesised fullname; `PROJ=var|loop|all`.
* `vdist33.py` — order-blind multiset DISTANCE to golden per arm-view.
* `varm33.sh` — one arm, both views, golden + both frozen binaries, with an
  auditable `cmds.txt`.
