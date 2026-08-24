# r10uvm122 — § `localBlockStmtSelBinds122`

**A POOLED REFERENCE BINDS ITS OWN BLOCK'S FIRST SELECT-LVALUE, AND A LOCAL
VARIABLE WAS THE HALF WE DID NOT MODEL** — the SeqDriver ×2 + MiniAmiq ×2 head
**CLEARED**.

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was
promoted** and **NO CORPUS ROW CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `7bfb970` |
| production surface | `src/StmtEmit.cpp` + `include/UhdmExporter.h` ONLY — three registries, two helpers, one second pass in `endSelTrack` |
| probe surface | `tools/probe/r10uvm122repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SeqDriver default / testflags** | **58** | **28** | 1 — a **NEW** head, a different family (§5 R0) |
| **MiniAmiq default / testflags** | **58** | **28** | 1 — the same new head |
| SimpleUVM default / testflags | 148 | 148 | cmp log **byte-identical** |
| Scoreboard default | 148 | 148 | cmp log **byte-identical** |
| BuildUVMPkg default / testflags | 148 | 148 | cmp log **byte-identical** |
| Earlgrey_0_1 default / testflags | 58 | 58 | cmp log **byte-identical** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes) | |
| byte movers | — | **11 / 956** surelog, **0 / 1358** uhdm2rtlil | |
| the six purpose-built goldens, DEF view | 189 of 236 comparable cells agreed | **226 / 236**, **37 TOGOLD (+1 in the ELAB view), 0 MOVED-WRONG, 0 AWAY** (the 10 left are residues R1–R4) | |
| the nine UVM databases | — | **70 cells TOGOLD, 0 MOVED-WRONG, 0 one-sided-patched** | |
| wide boundary | — | 3745 arms × 2 views, 9 moved cells, every one attributed | |

`crc1` appears in **FOUR** pristine head logs (SeqDriver ×2, MiniAmiq ×2, 20
lines each) and in **ZERO** patched head logs.  The cmp-line counts are DEPTH,
not distance.

---

## 1. THE HEAD, AND WHY ITS FRAMING HAD TO BE RE-READ FROM BOTH DUMPS

The 58-line head, verbatim from the pristine cmp log
(`head_pris_default_SeqDriver.cmp`), on `uvm-1.2 src/base/uvm_misc.svh`:

```
LHS (golden)                                   RHS (ours)
bit_select (uvm_pkg::uvm_oneway_hash::crc1)    bit_var (uvm_pkg::uvm_oneway_hash::crc1)
  @386:12-386:19                                 @372:16-372:20
|vpiParent: assignment @386:12-386:23          |vpiParent: begin (uvm_pkg::uvm_oneway_hash) @371:3
|vpiName:crc1                                  |vpiTypespec: ref_typespec -> bit_typespec @372:3
|vpiIndex: constant  vpiDecompile:0            |vpiName:crc1
             vpiSize:64  UINT:0  ct 9
```

The brief carried golden's side only, and golden's side is a trap: **the
differing slot is NOT the Lhs of `crc1[0] = 1;`.**  Read off both
`uhdm-dump`s, our `crc1[0]` bit_select at 386:12 is byte-identical to golden's,
index constant included.  The slot is
**`ref_obj::Actual_group` of the reference on the LINE BEFORE**:

```systemverilog
        if (msb ^ current_byte[_bit]) begin      // :384
           crc1 ^=  UVM_STR_CRC_POLYNOMIAL;      // :385  <- the ref_obj @385:12
           crc1[0] = 1;                          // :386  <- the bit_select
        end
```

| the six `crc1` references in `uvm_pkg` | golden's `vpiActual` | ours, pristine |
|---|---|---|
| `crc1 = 32'hffffffff;` @377:3 | `bit_var` @372:16 | `bit_var` @372:16 |
| `crc1 <<= 1;` @383:9 | `bit_var` @372:16 | `bit_var` @372:16 |
| **`crc1 ^= …;` @385:12** | **`bit_select` @386:12** | `bit_var` @372:16 |

(each ×2, the def and elab package listings; SeqDriver's `adpcm_pkg` clone of
the same function carries three more, and golden binds `bit_var` in ALL of
them — §2's fence.)

`expr::Compare` reads `BaseClass::Compare`'s VpiType first, so the object KIND
was the whole head.

---

## 2. THE LAW

> **§ `localBlockStmtSelBinds122`** — *A reference that reached Surelog's
> late-binding pool is answered by the FIRST block ancestor that can answer it,
> and a block answers in three steps: its `Variables()`, then its
> `Parameters()`, then its own DIRECT `Stmts()` — where an `assignment` /
> `assign_stmt` whose `Lhs()->VpiName()` is the name and whose Lhs is NEITHER
> `ref_obj` NOR `ref_var` hands the reference **THAT LVALUE OBJECT**.  We
> already modelled the step-3 answer for module NETS and function FORMALS; for
> a LOCAL VARIABLE we always answered step 1, wherever the declaration was.*

### DECODED FROM SURELOG, file and line

1. **The three questions.** `UhdmWriter::lateBinding`
   (`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:3294`) walks
   `ref->VpiParent()` upward.  The `uhdmbegin` arm (`:3551-3593`) reads
   `b->Variables()`, then `if (ref->Actual_group()) break;`, then
   `b->Parameters()`, then `if (ref->Actual_group()) break;`, then
   `b->Stmts()`:

   ```cpp
   for (auto init : *stmts) {
     if (init->UhdmType() == uhdmassignment) {
       assignment* as = (assignment*)init;
       const expr* lhs = as->Lhs();
       if (lhs && lhs->VpiName() == name) {
         if (lhs->UhdmType() == uhdmref_var) continue;    // the BARE spellings
         if (lhs->UhdmType() == uhdmref_obj) continue;    // are skipped
         ref->Actual_group((expr*)lhs);
         break;
   ```

   The `named_begin` (`:3598`), `fork_stmt` (`:3644`) and `named_fork`
   (`:3690`) arms are byte-for-byte the same three questions — arm c cells
   `c6_named` and `c10_fork` measure both.  The loop tail is
   `if (ref->Actual_group()) break; parent = parent->VpiParent();` (`:3736`),
   which is why the FIRST answering block ends the search.
2. **What the skips mean.** A WHOLE write (`v = 7;`, `v ^= 3;`) builds a
   `ref_obj` lvalue and is skipped; **every select shape is not**, so a
   `bit_select`, a `part_select`, an `indexed_part_select` and a `var_select`
   all answer.  Nothing in the arm reads the blocking flag, the index shape or
   the declaration's type — arm b measures all twelve shapes and golden
   re-points for the nonblocking `v[0] <= 1;` exactly as for `v[0] = 1;`.
3. **Why the declaring block always wins.** `Variables()` is question 1.  A
   local declared in the SAME block as the select therefore keeps its
   declaration (arm c `c1_decl_same`), and so does one whose declaring block is
   reached before any select-bearing one (`c11_twoout`, `c12_declsel`).
4. **THE VIEW FENCE — `-elabuhdm` inverts it, and it self-fences.**  UHDM's own
   `ElaboratorListener`, which `uhdm_main.cpp` runs under `--elabuhdm` exactly
   as Surelog does, re-binds every reference BY NAME against the elaborated
   scope stack — i.e. back onto the declaration.  Golden's elab databases show
   `bit_var` in every one of these cells and ours now do too: **all six arms,
   elab view, 0 MOVED-WRONG and 0 AWAY, measured, not assumed.**
5. **THE CLONE FENCE — an IMPORT COPY never takes the select.**  A wildcard or
   explicit import re-emits the package's subroutines, and the clone's own
   references arrive at `UhdmWriter::lateBinding` **ALREADY BOUND** — its first
   line is `if (ref->Actual_group()) continue;` (`:3296`) — naming the **HOME
   package's** declaration objects, so the block arm never answers for them.
   (`CompileHelper::importPackage`,
   `src/DesignCompile/CompileHelper.cpp:127-196`, is where the importer
   inherits the home's symbols and its whole `getLateBinding()` list; WHICH of
   its copies does that binding is NOT decoded here — the CELLS are.)
   Golden proves it cell
   for cell: SeqDriver's `adpcm_pkg` copies of `uvm_oneway_hash::crc1`,
   `uvm_mem::do_{read,write}::value_s` and
   `uvm_reg_map::get_physical_addresses::local_addr` all name
   `uvm_pkg::…`'s VARIABLE, while the `uvm_pkg` originals name the SELECT.
   The unfenced build measured this as **8 MOVED-WRONG cells on SeqDriver and 8
   on MiniAmiq** (`CENSUS.prefence.r10uvm122.txt`); the fence takes them to 0
   and adds them to SAME_AGREE.  Arm f is its purpose-built golden.

---

## 3. THE CHANGE (`src/StmtEmit.cpp`, `include/UhdmExporter.h`)

The existing `selTrack` model — the same law for a module NET written by a
BLOCKING procedural assignment, and for a function FORMAL — is **untouched**;
its registry, its carve-outs and its cells are byte-identical.  The local half
is a second, disjoint registry:

* `noteBlockDecls122(stmt)` — question 1.  Registered at the block scope push
  in `emitStmt`, for the DIRECT `VariableDeclaration` children of a
  `StatementKind::List` (and of a `Block` whose body is one, because a `begin`
  carrying declarations is built by the List arm's own wrapper loop and never
  re-enters `emitStmt` on the List — registering only one of the two ids left
  the other answering "no declaration here", which is exactly the `c12_declsel`
  regression the first build produced).
* `noteLocalStmtSel122(expr, obj, netMap)` — question 3.  Called from the
  `ExpressionStatement` arm, so the statement IS a direct member of the block's
  `Stmts()`.  It reads the EMITTED `assignment`'s `Lhs()` — which is why every
  select kind is covered without a per-kind hook — requires it to be neither
  `ref_obj` nor `ref_var`, peels the slang lvalue's selects to its base symbol,
  requires that base to be a local variable DECLARATION object, and requires
  `lhs->VpiName() == sym->name` (the bare-spelling test that excludes a
  `hier_path` `h.f[0]` and an unnamed concatenation `operation`).  First in
  statement order wins.
* `endSelTrack`'s second pass — the innermost-first walk over the reference's
  own block chain, stopping at a declaring block, fenced out of every import
  clone (`pkgImportCloneEmit || importCloneEmit || importCopyTsInst`, the
  three-clone-path test `noBindDv13` already uses).
* `localVarDecl122(actual)` — the pass re-points ONLY a reference whose actual
  is still a `variables` object and not a `ref_var`.  An UNBOUND reference
  stays unbound (a class in-body method's property and local, a `$unit`
  function's local and an interface task's local are all bare in golden and
  stay bare — arm e cells `e1`–`e3`, `e11`, `e12`), a NET or `io_decl` is the
  other model's, and a reference the other model already moved now carries a
  select, which is neither.

---

## 4. THE GOLDEN GRID — six arms, 236 comparable DEF-view cells, both views

`arms122.sh` builds each `g122_*.sv` under Surelog and both binaries in the
`def` and `elab` views, records every rc, and `score122.py` joins the cells on
(ref kind, ref name, ref span) with the multiplicity in the value, so a
colliding key can never drop a row and a one-sided set is reported as one.

| arm | face | pristine | patched |
|---|---|---|---|
| `g122_a_owner.sv` | 10 OWNERS (fn local, task local, formal, automatic, package var, int, logic, unpacked array, class property, return name) | 25 agree, 7 differ | **+6 TOGOLD**, 1 residue (§5 R1) |
| `g122_b_shape.sv` | 12 LVALUE SHAPES (literal/variable bit index, part-select, both indexed part-selects, 2-D `var_select`, concat, unpacked, member `hier_path`, NONBLOCKING, two selects, whole-write-first) | 39 agree, 11 differ | **+11 TOGOLD** |
| `g122_c_scope.sv` | 12 SCOPES (declaring block, deeper ref, non-direct select, inner-block select, shadowing decl, named begin, for/while/case/fork, two levels out, declaring-block-also-selects) | 45 agree, 6 differ | **+6 TOGOLD** |
| `g122_d_pos.sv` | 10 REFERENCE POSITIONS (LHS+RHS of one statement, condition, call arg, select index, return, rvalue-only NEGATIVE, rvalue-before-lvalue, other-name NEGATIVE, return name, nested call) | 35 agree, 10 differ | **+10 TOGOLD** |
| `g122_e_home.sv` | 12 HOMES (class in-body / out-of-body method, package var from a method, module initial / always_comb / nonblocking always / function / unpacked array / module-var-from-function, `$unit` function, interface task) | 33 agree, 5 differ | **+2 TOGOLD**, 3 residues (§5 R1–R3) |
| `g122_f_clone.sv` | the IMPORT-CLONE fence: a home package + a WILDCARD importer + an EXPLICIT importer + a module importer | 12 agree, 8 differ | **+2 TOGOLD** on the home, clone cells UNMOVED (6 pre-existing naming residues, §5 R4) |

**Totals over the DEF view's 236 comparable cells: 189 agreed pristine, 226
agree patched — 37 TOGOLD, 0 MOVED-WRONG, 0 AWAY, 0 one-sided-patched.**  The
ten that still differ are residues R1–R4 below, every one of them
pristine-identical.  The `elab` half of every arm is 0 MOVED-WRONG / 0 AWAY
too, with ONE more cell going TO GOLDEN there — 38 TOGOLD across both views
(`ARMS.r10uvm122.txt`).

The three decisive NEGATIVES, all golden:
* `c3_notdirect` — `v ^= 3; if (s) v[0] = 1;` — the select is not a direct
  statement of the block, so golden keeps the **declaration**;
* `d6_rvalonly` — `r = v[3]; v ^= 3;` — an RVALUE select is not an assignment
  Lhs, so golden keeps the **declaration**;
* `c1_decl_same` / `c12_declsel` — the declaring block answers first.

---

## 5. RESIDUES

* **R1 — a PACKAGE VARIABLE read from a free package function.**  Golden
  re-points it exactly like a local (arm a `a5_pkgvar`; the MODULE-scope twins
  arm e `e6`/`e10` already agree because a module-scope variable is a
  `logic_net` on both sides and is the shipped net model's cell); we bind
  package variables through
  `pkgViewVarObjs9`, a branch that never pushes the reference into
  `selWholeRefs`, so the pass cannot see them.  **ZERO corpus witnesses** in
  the nine UVM databases (the census's TOGOLD sets are all subroutine locals),
  which is why the branch was left alone.
* **R2 — a NONBLOCKING bit-write on a module NET.**  Arm e `e7`
  (`always @(mnet) begin … mnet ^= 3; mnet[1] <= 1; end`): golden re-points to
  the `bit_select`, and the shipped net model's `VpiBlocking()` gate (measured
  on `multiple_blocking_gate` / `asicworld_serial_crc` /
  `unpacked_array_shift_ff`) keeps the net.  The local half proves the gate is
  not Surelog's rule; whether the NET half's gate is a different law or a
  mis-attribution needs its own pass.  **Not touched here.**
* **R3 — the `$unit` and interface-task `io_decl`s** (arm e `e11`/`e12`):
  golden binds the formal, we leave it bare.  § `unitSubNoBind9`'s residue,
  pristine-identical, unrelated.
* **R4 — the import clone's ACTUAL NAMING.**  Golden's clone references name
  the HOME package's declaration object (`p122f_home::f122f::hv`); ours name
  the clone's own copy.  Six arm-f cells, pristine-identical, untouched.
* **R5 — `uvm_pkg::uvm_reg_map::get_physical_addresses::local_addr`** is an
  UNPACKED array whose element write re-points the whole ref to a
  `bit_select`; the same shape on a module-scope unpacked array
  (arm e `e9`) already agreed.  No residue, recorded because it is the one
  `array_var` cell in the corpus mover set.

**R0 (next head): the new SeqDriver/MiniAmiq head, 28 lines, both modes** — a
`ref_obj` NAMED BY ITS SELECT:

```
LHS  ref_obj (uvm_pkg::uvm_default_factory::register::m_inst_override_queues) @919:13-919:35
RHS  ref_obj (uvm_pkg::uvm_default_factory::register::m_inst_override_queues[obj]) @919:13-919:40
       both |vpiParent: method_func_call (queue) @919:41-919:46
```

`uvm-1.2 src/base/uvm_factory.svh:919`, inside
`uvm_default_factory::register`'s `foreach (m_wildcard_inst_overrides[i])`:

```systemverilog
   m_inst_override_queues[obj].queue.push_back(m_wildcard_inst_overrides[i]);
// ^col 13                  ^col 39
```

The object is the RECEIVER of the `queue` method call.  Golden names it with
the BARE associative-array name and spans the NAME ALONE (13–35); ours names it
with the SELECTED text and spans through the `]` (13–40).  A naming/span law in
the method-call receiver path — the same `decompileHelper` / receiver family
uvm89 and buvm14 already decoded — not this one.

---

## 6. INSTRUMENTS (all measurement-only; the judge is `uhdm-cmp`)

| file | what it does |
|---|---|
| `cells122.py` | census of every `ref_obj` / `ref_var` and the object its `vpiActual` names; keyed on kind + printed name + own span, never a fullname and never a file path; multiplicity in the row |
| `score122.py` | golden vs pristine vs patched per cell: TOGOLD / MOVEDWRONG / MOVEDOTHER / SAME_AGREE / SAME_DIFF / ONESIDED |
| `arms122.sh` | every `g122_*.sv` under Surelog + both binaries, BOTH views, per-arm subdirectory keyed on the arm's RELATIVE path, fd-3 file list, children `</dev/null`, every rc recorded, PROCESSED asserted |
| `uvmcen122.sh` | the same census over the named rows of two `verify_golden` workdirs; the golden path comes out of each row's OWN `cmds.txt` |
| `pred122.py` | A-PRIORI mover predictor from a PRISTINE dump alone (§7) |
| `predsweep122.sh` | runs the predictor over every database of a workdir, PROCESSED asserted |
| `bound122.sh` | the WIDE boundary (reused from `r10buvm30/bound30.sh` via `r10uvm120`): every `.sv`/`.v` under a COPY of `tools/probe`, both binaries, both views, no path filter |
| `g122_a_owner.sv` … `g122_f_clone.sv` | the six golden grids of §4 |
| `canaudit.sh` / `canaries.sh` / `ctcan2.sh` / `ct8rows.sh` / `byteverify.sh` / `rowheads.sh` | the standard gate battery, carried so `canaudit.sh` can prove the fenced names are covered here |

---

## 7. THE MOVER PREDICTION, MADE BEFORE THE COMPARISON

`pred122.py` reads a PRISTINE dump alone and names a database as a candidate
when it holds BOTH halves of the law's shape — a select object in an
`assignment`'s `vpiLhs` slot, AND a `ref_obj` of the same leaf name whose
`vpiActual` is still a `*_var` declaration.  It is deliberately an
OVER-approximation (it ignores the block chain, the declaring block and the
clone fence), so every database this law can touch is named and a named
database that does not move is a fence doing its job.

`PREDICT.r10uvm122.txt` is that sweep: **35 candidates out of 956 surelog
databases, and every one of the 11 byte movers is among them — 0 movers
unpredicted.**  The 24 predicted-but-unmoved databases are the fences doing
their job.  `MOVERS.r10uvm122.txt` attributes each
one line by line: the ONLY dump lines that change in ANY mover are `vpiActual`
targets going from a declaration (`bit_var` / `string_var` / `array_var` /
`logic_var`) to a `bit_select`.

| mover | order-blind moved lines | attribution |
|---|---|---|
| SeqDriver, MiniAmiq, SimpleUVM, Scoreboard (default), each mode | 32 | 8 cells × 2 package listings, all TOGOLD |
| BuildUVMPkg, both modes | 28 | 7 cells × 2 |
| **YosysOldSystem, both modes** | **2** | `byte_mixcolum.v`'s `function [7:0] xtime`: `reg [3:0] xtime_t;` at :61, `xtime_t[3] = in[7];` at :65 and the whole read in `xtime[4:1] = xtime_t^in[3:0];` at :69 — golden binds the `bit_select` @65:1 and we bound the `logic_var` @61:1.  **TO GOLDEN**, row CMP_EQUAL before and after |

Scoreboard/default is a ~50/50 COIN: its RAW diff is 124 lines and its
ORDER-BLIND diff is **32**, the same 32 as every other UVM row — the extra 92
are the documented `svunit_pkg` `vpiTaskFunc` ordering flip.

`PREDICT.u2r.r10uvm122.txt` is the same sweep over uhdm2rtlil: **16 candidates
out of 1358, 0 byte movers**.  All sixteen are fenced, and `rotate/dut.sv` is
spot-checked there — one `out` is a generate-block NET (the shipped model's
cell) and the other is a function-local `integer out` whose only select is the
RVALUE `wrap = out[4:0];`, which is arm d's `d6_rvalonly` negative.

---

## 8. GATES

`GATES.r10uvm122.txt` has the transcript.  All green:

* both binaries built at `7bfb970` and frozen `chmod 555` BEFORE any sweep;
  the PRISTINE worktree build is **byte-identical** to the campaign's control
  binary (`94786b24b692c0fbd46e1fefacfb715a`);
* goldens **23 PASS / 0 FAIL**, `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**;
* uhdm2rtlil `testflags` and `default`: **CMP_EQUAL 679 / SLANG_REJECT 50 /
  SURELOG_FAIL 2**, `ct8rows` PASS against the committed baseline AND against
  this pass's own pristine control, **byteverify MOVERS 0 / 1358**;
* surelog `--mode both`: **CMP_EQUAL 937 / CMP_NOTEQUAL 19 / DEFERRED 10 /
  NO_DATABASE 3 / NO_UHDM 1 / SLANG_REJECT 567 / SURELOG_FAIL 48 / TIMEOUT 1 /
  UNTRANSLATABLE 2** — `ct8rows` PASS, **0 differing rows over 1588**, no row
  converted;
* every `cmds.txt` audited BY BINARY PATH: 1523 patched / 1523 pristine
  (surelog), 1458 / 1458 (uhdm2rtlil), zero main-tree invocations;
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (uhdm2rtlil);
  `ctcan2` PASS on both; `canaudit.sh canaries.sh ctcan2.sh` PASS,
  FENCE-BREACH 0;
* protected databases by name: InterfaceModPort, BlackParrotComplex,
  YosysOldOr byte-identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a`;
* wide boundary: 3745 arms × 2 views, **9 moved cells** — seven are this pass's
  own `g122_*` arms (its positive controls, all TO GOLDEN) and two are
  `r10buvm22repro/g22.sv`, uvm120's documented R7 whose synthesized range holds
  an IMAGE-RELATIVE ADDRESS and shifts on any binary-size change (measured:
  `22441433` → `22445529`, +4096).
