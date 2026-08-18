# r10v98 — the ADVERSARIAL VERIFICATION of r10uvm98 (§ `bareTdNameFirstWriterWins98`)

**VERDICT: ACCEPT WITH FIX.** Every headline number of the implementer's pass
reproduced bit-for-bit from binaries I built myself; one **PRISTINE-RIGHT →
PATCHED-WRONG** family found on legal SystemVerilog and fixed here
(§ `modIfaceTdBeatsClassFirstWriter98v`); the fix is **byte-identical to the
shipped patch on both whole corpora** and costs **zero** of the pass's fixes.

**MEASUREMENT-ONLY.** Nothing in this directory is an acceptance judge:
`~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py` are.
slang was NOT patched; `results/*.csv` were READ ONLY; nothing was promoted;
**NO CORPUS ROW CONVERTED**. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS
ours**, everywhere below.

| | |
|---|---|
| BASE | `b924c9e` |
| worktrees | two FRESH ones at `b924c9e`, one pristine, one patched |
| pristine binary | md5 `3546f230b2c6b009b563c45026e18d49` — **matches the implementer's** |
| shipped-patch binary | md5 `7cd93275a5d3314647139ffc911d1f6c` — **matches the implementer's** |
| VERIFIED binary (patch + the fix) | md5 `b1b9d074025933d9687f4f077f8bfa05` |
| all three frozen `chmod 555` before any sweep | |

## 1. Reproduction of every headline number (independent build, independent sweeps)

| claim | implementer | verifier | |
|---|---|---|---|
| pristine / patched binary md5 | 3546f230…/7cd93275… | **identical** | ✅ |
| SeqDriver, MiniAmiq (both modes) cmp lines | 99,202 → 50, 1 head | **99,202 → 50, 1 head** | ✅ |
| SimpleUVM (both), Scoreboard/default | 99,106 → 108, 1 head | **99,106 → 108, 1 head** | ✅ |
| BuildUVMPkg / Earlgrey_0_1 / Rggen | 52 / 46 / 64 unchanged | **52 / 46 / 64 unchanged** | ✅ |
| the new head (R0) | `head_pat_default_SeqDriver.cmp` | **byte-identical after path/id normalisation** | ✅ |
| goldens | 23/0 both binaries, 0/23 `/bin/false` | **23/0, 23/0, 0/23** | ✅ |
| u2r both modes | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL | **identical, both binaries** | ✅ |
| surelog `--mode both` histogram | unchanged | **identical, both binaries** | ✅ |
| `ct8rows` (WHOLE ROW, status AND dump) | PASS, 0 differing rows | **PASS on all of: baseline↔pris, baseline↔pat, pris↔pat, both corpora, both modes** | ✅ |
| `byteverify SELFCHECK=1` | u2r 0/1358, surelog 9/956 | **0/1358 and 9/956, the same nine names** | ✅ |
| a-priori predictor (`pred98`, rebuilt here) | PREDICTED 0/1358 and 9/956 | **0/1358 and 9/956, exactly the nine measured movers** | ✅ |
| mover attribution | 22 lines order-blind (20 BuildUVMPkg), SeqDriver 62 ordered | **22/22, 20/20, SeqDriver 62/22** | ✅ |
| canaries / ctcan2 / canaudit / pins | 56, 9, PASS×2, audited=33 UNCOVERED=0, SAME=10 MOVED=0 | **identical, incl. SVSwitch 4842211c4030 and YosysVerx 6ccda350c24a** | ✅ |
| `cmds.txt` audited by binary PATH | main-tree binary never used | **1458 u2r + 1523 surelog cells, only my frozen binaries** | ✅ |

`GATES.r10v98.txt` is the transcript. Both corpora were swept THREE times
(pristine, shipped patch, verified patch), `--jobs 2`, `SLANG_UHDM` exported
explicitly per binary, into the verifier's own workdirs.

## 2. The census, rebuilt from scratch (`v98cen.py` / `v98score.py`)

An INDEPENDENT instrument: it parses `uhdm-dump` rather than linking UHDM.
Key = the site's `vpiFullName`; value = the bound typespec's **kind + VpiName +
`Class_defn` fullname** — the fields `class_typespec::Compare` reads —
**never the span, never the file** (`--nospan`; the span is kept only as a
declaration identifier for diagnosis, and a span-only move is judge-invisible).

**Calibrated golden-vs-golden FIRST**: SeqDriver default↔testflags golden
**6109 / 6109 OK, DIFF 0**; MiniAmiq **6589 / 6589, DIFF 0**. The key is
view-general and the instrument manufactures no cells.

Three-way over all nine moving databases, golden / pristine / VERIFIED:

```
SeqDriver   def/tf  cells 6195  TO-GOLDEN 8  AWAY-GOLDEN 0  CHANGED-STILL 0
SimpleUVM   def/tf  cells 4259  TO-GOLDEN 8  AWAY-GOLDEN 0  CHANGED-STILL 0
MiniAmiq    def/tf  cells 6681  TO-GOLDEN 8  AWAY-GOLDEN 0  CHANGED-STILL 0
Scoreboard  def     cells 4249  TO-GOLDEN 8  AWAY-GOLDEN 0  CHANGED-STILL 0
BuildUVMPkg def/tf  cells 4362  TO-GOLDEN 8  AWAY-GOLDEN 0  CHANGED-STILL 0
```

and the eight cells are exactly the ones the pass names — the
`uvm_tlm_{b,nb}_{initiator,target,passthrough_initiator,passthrough_target}_socket::connect::provider`
formals moving `defn=uvm_pkg::uvm_port_base` → `defn=uvm_pkg::uvm_algorithmic_comparator`.
**The implementer's central claim is confirmed by an instrument that shares no
code with theirs.**

## 3. WHAT BROKE — § `modIfaceTdBeatsClassFirstWriter98v` (the fix)

> **A MODULE-, INTERFACE- or PROGRAM-LEVEL TYPEDEF OF THE RACING BARE NAME IS
> THE FIRST WRITER, AND NO CLASS CAN WIN THAT NAME.**
>
> `ElaborationStep::bindTypedefs_` builds `defs` as FileContents → packages →
> **modules** (`design->getModuleDefinitions()`, a multimap keyed `lib@name`
> that carries **interfaces** as well as modules) → **programs** → classes.
> `specs.emplace` is first-writer-wins, so any module/interface/program-level
> typedef of the name is registered long before every class.
>
> The shipped table walks only `comp.getRoot().topInstances`, which misses the
> two shapes that matter: an **instantiated child module** and an
> **uninstantiated interface**. The law then handed the reference to the first
> CLASS instead.

**The break, measured on golden, both views** (`v98_c21`, `v98_c22`):

```
package p21v;
  class a21win98v;  typedef bit [7:0] wk21_t; endclass   // the first CLASS
  class m21base98v; typedef int wk21_t; endclass          // the BASE
  class z21der98v extends m21base98v;
    function void hot(wk21_t x); endfunction              // the inherited bare name
  endclass
endpackage
interface aif21v; typedef int wk21_t; wk21_t w; endinterface   // GOLDEN'S WINNER
module top21v; p21v::z21der98v z; initial z = new(); endmodule
```

| | binds `z21der98v::hot::x` to |
|---|---|
| GOLDEN | `int_typespec (wk21_t)` — the INTERFACE's |
| PRISTINE | `int_typespec (wk21_t)` — the base class's — **same judge-visible payload as golden** |
| SHIPPED PATCH | `bit_typespec (wk21_t)` from `p21v::a21win98v` — **a real, judge-visible mis-bind** |

`uhdm-cmp` **57 → 70 lines** in both views on both arms, and the patched head is
exactly that mis-bind (`LHS int_typespec (wk21_t)` @ the interface vs
`RHS bit_typespec (wk21_t)` @ `class_defn p21v::a21win98v`).
`v98_c22` is the same break with an instantiated child MODULE.

**The fix** (`collectFwModIfaceTds98v`, `src/TypeEmit.cpp`): register every
module-, interface- and program-level typedef NAME in the winner table, from
the SYNTAX, as a **SUPPRESSOR** (`al == nullptr`). Winning the name makes
`fwWinner98` return null, so the hook falls through to the pristine behaviour —
the same NO-OP a `$unit` winner already takes (the pass's R4). Minimal: it can
only ever *stop* a fire, never create or redirect one.

**Every boundary of the fix was measured on golden, not guessed:**

| arm | golden's answer | consequence for the fix |
|---|---|---|
| `v98_c3` | a module, a program and an interface all declare the name → golden picks the **INTERFACE** (`work@if3v` < `work@sub3v`) | interfaces are in the modules group |
| `v98_c24` | program `aprg24v` **LOSES** to module `zmod24v` | programs are a LATER group (3), exactly as `defs` orders them |
| `v98_c25` | a typedef in a module's **generate block** → golden keeps the CLASS winner | only DIRECT members are registered |
| `v98_c26` | a typedef in a module's **function** → golden keeps the CLASS winner | ditto |
| `v98_c27` | a typedef in an unconditional **`generate…endgenerate`** region → golden keeps the CLASS winner | ditto |

## 4. The grid: 27 arms × 2 views, span-blind, `Class_defn` in the payload

`GRID.r10v98.txt` (verified) and `GRID_SHIPPED.r10v98.txt` (shipped), same arms,
same instrument, same binaries-under-test:

```
SHIPPED  patch:  FIXED 61   BROKE 4   <- v98_c21 def+elab, v98_c22 def+elab
VERIFIED patch:  FIXED 61   BROKE 0
```

**No fix lost, every break removed.** The arms cover: every reference shape of
an inherited bare name (formal / `output` / `ref` / defaulted formal / return /
method local / property / static property / `$cast` target / `new()` argument /
`#()` parameter / `$bits`), every home (package, `$unit`, module-nested,
class-nested, program, interface), the qualified spellings `Base::td` and
`Base#(int)::td`, shadowing in the derived class, 1–3 unrelated declarers before
and after alphabetically with mixed case and digits, package- and `$unit`-level
typedefs of the same name, interface classes (declared and implemented), deep
4-level chains, multiple inheritance through interface classes, parameterized
bases with 3 live specialisations, a generic-class winner with 3
specialisations, 1–3 instances, importers present and absent, a `.v` file, a
class whose name equals the typedef name, method-local and generate-block
typedefs, and mutual cross-family references (reentrancy).

Highlights measured on GOLDEN that the pass's write-up does not carry:

* **the first-writer key is the typedef's OWN bare name even when its target is
  another typedef** (`v98_c1`: `typedef seed_t rank_t;` still wins `rank_t`) —
  the `specs.emplace(prevDef->getTypespec()->VpiName(), …)` branch at
  `ElaborationStep.cpp:161` does not derail the law;
* the law is **kind-blind**: an `enum`, a packed `struct`, an unpacked array and
  a packed vector winner all take the name (`v98_c2`, 4 TO-GOLDEN cells);
* **interface classes never win** (`v98_c4`) — the pass's `isIfaceClass11`
  exclusion is right, and had it been absent this cell would have BROKEN;
* the **nested-class short-name key** (pass 11) survives: `binner17v` beats
  `pv17v::zbase17v` in golden and in ours (`v98_c17`).

## 5. The boundary (`v98bound.sh`, `BOUNDARY.r10v98.txt`)

From a **COPY** of the whole `tools/probe` tree, **no path filter**, `.sv` AND
`.v`, fd-3 lists, children `</dev/null`, PROCESSED asserted, rc recorded and
compared per cell, **both views**, and — beyond the pass's own gate —
**PER-DIRECTORY arms as well as per-file** (every `.sv`/`.v` of a directory
compiled together):

```
FILES_LISTED=3081 FENCED_SKIPPED=0 FILES_PROCESSED=3081
DIRS_LISTED=1397  DIRS_PROCESSED=1397
RC_PAIRS_COMPARED=8956  RC_DIFF=0  ASYMMETRIC_OUTPUT=0
MOVED=54  PROCESSED-ASSERT-OK
```

Every moved cell that is not one of the pass's own arms was scored THREE-WAY
against a rebuilt golden with the official `uhdm-cmp` per cell:

| directory arm | verdict (def / elab) |
|---|---|
| `r10sd10repro/vgrid10`, `r10sd11repro/vgrid10`, `r10sd12repro/vgrid10` | **BROKE 0 / BROKE 0** |
| `r10sd11repro/grid11`, `r10sd12repro/grid11` | **BROKE 0 / BROKE 0**, and cmp **92 → 17 lines** |
| `r10uvm75repro`, `r10uvm76repro`, `r10uvm88repro`, `r10uvm97repro` | **BROKE 0 / BROKE 0** |

**BROKE 0 on all 18 directory cells**, so vsd11's and uvm97's typedef laws and
the sd8-12 boundaries hold. The per-file movers reproduce the pass's own list
(`r10uvm34repro/t46a`, `r10uvm35repro/t47a,b,c`, `r10uvm97repro/g97_a1_selftd`,
`r10v97repro/v97_c1_mixedgroup`, `v97_c4_specparams`, `v97_c8_counts`), all
BROKE 0.

**One boundary cell is a COIN, not a mover.** `d0889_r10uvm88repro` (a 9-file
directory arm) differs by 4 lines — a `vpiTaskFunc` LIST-ORDER flip of
`p3::base3::oob_base`, the documented macro-buffer `SourceLocation` ordering
under slang's parallel parse. The PRISTINE binary alone, run 5× on that arm,
produced two different dumps (`8f67589c075e` ×4, `27b8cd3f9dc6` ×1), and so did
the verified binary. **Order-blind diff pristine↔verified: 0 lines in both
views.** This is why the shipped patch's boundary reports MOVED=52 and mine 54:
the difference is the coin, not the fix.

## 6. The fix's corpus footprint: ZERO

`byteverify SELFCHECK=1`, verified vs the SHIPPED patch:
**MOVERS 0 / 1358 (uhdm2rtlil) and 0 / 956 (surelog)** — the databases are
byte-identical, so all nine movers, their md5s, every head and every row are
the shipped pass's own. Verified vs pristine reproduces 0/1358 and 9/956 with
the same nine names. `ct8rows` PASS on every pair. Canaries `ok=56`/`ok=9`
`changed=0`, `ctcan2` PASS ×2, `canaudit audited=33 UNCOVERED=0
FENCE-BREACH=0`, pins `SAME=10 MOVED=0`. The verified binary run 3× on one arm
is byte-identical.

## 7. Residues, ranked

* **RV1 — the module/interface/program winner is a NO-OP, not a bind.** When
  golden's first writer is a module- or interface-level typedef we now decline
  to move rather than binding to that object (`v98_c3`, `v98_c22`,
  `v98_c24`: golden `byte_typespec`, ours `int_typespec`). Binding it needs the
  module-typedef registry that `fwWinnerTs98` does not consult. No corpus
  reach measured. Same shape as the pass's R4.
* **RV2 — group 0 (`$unit`) ties are unordered.** All compilation units share
  the container key `""`, while Surelog walks `getAllFileContents()` in PathId
  (command-line) order. Two files each declaring the same `$unit` typedef name
  would be a coin. Unreachable today because a `$unit` winner is a NO-OP.
* **RV3 — the pass's own R1 (the out-of-block half) is confirmed**, in golden,
  by `r10sd11repro/grid11` (`px4::aderiv4::f_oob::o_inh`) and by
  `uvm_pkg::uvm_sequence_library::m_check::lib`. Unmodelled by design.
* **RV4 — the pass's `bound98.sh` header claims "per-file AND per-directory
  arms" but the script only ever compiles ONE file per cell.** The directory
  half is supplied here; it is what found the sd10-12 grid cells and the coin.
* **RV5 — copy-count, not value.** In the ELAB view of `r10sd11repro/grid11`
  two cells score CHANGED-STILL: the VALUE is now golden's
  (`defn=px1::zelem1`) but golden carries 3 and 6 copies where we carry 1 and
  3. Pre-existing copy-count family, not this law.

## 8. Files

```
v98run.sh      one arm, one view: Surelog golden + pristine + candidate, rc per
               cell, OFFICIAL uhdm-cmp verdict, then the census score
v98runall.sh   the whole arm battery (fd-3 list, children </dev/null)
v98cen.py      the census: uhdm-dump -> (site vpiFullName) -> bound typespec
               kind|VpiName|defn=<Class_defn>, --nospan for the judge-visible view
v98score.py    three-way OK / FIXED / BROKE / STILL / CHANGED-STILL, multiset join
v98bound.sh    the wide boundary: per-FILE and per-DIRECTORY arms, .sv and .v,
               no path filter, fd-3, </dev/null, PROCESSED asserted, rc per cell
v98dirarm.sh   three-way score of one directory arm against a rebuilt golden
v98sweep.sh    the three corpus sweeps for one binary (SLANG_UHDM exported)
v98_c1..c27    the 27 arms
GRID / GRID_SHIPPED / CENSUS / GATES / BOUNDARY .r10v98.txt   the measurements
```
