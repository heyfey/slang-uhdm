# r10v111 — ADVERSARIAL VERIFICATION of r10uvm111 (§ pkgVarInitCmViewClone111)

**VERDICT: ACCEPT AS SHIPPED.**  Every headline number reproduced bit-for-bit
from my own two builds; seven new arms over eleven shapes the implementer's
grid did not vary produced **114 scored cells, 0 AWAY-GOLDEN, 0 new heads**.
No production line changed; this directory is evidence only.

LHS is always golden (Surelog); RHS is always ours.

---

## 1. Bit-for-bit reproduction (my own builds, my own sweeps)

| | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `93fc148b1c9dc9aa639cbf959631ce6c` | **same** |
| patched binary md5 | `5df0ffc52b0d66620fac5947732f279e` | **same** |
| goldens patched / pristine / `/bin/false` | 23/0, 23, 0/23 | **same** |
| surelog default | 471 / 283 / 25 / **10** / 5 | **same** |
| surelog testflags | 466 / 284 / 23 / **9** / 5 | **same** |
| uhdm2rtlil both modes | 679 / 50 / 2 | **same** |
| `ct8rows` vs committed CSVs and vs my own pristine control sweep | PASS, 0 rows | **PASS, 0 rows** |
| `byteverify` surelog | MOVERS 7/956 | **7/956, the same seven** |
| `byteverify` uhdm2rtlil | MOVERS 0/1358 | **0/1358** |
| a-priori `pred111` prediction | 7 DBs / 15 cells, u2r 0 | **identical, DB-for-DB** |
| nine-UVM-database census | 22 cells, TG 15 / AR 7 / AWAY 0 / SW 0 | **identical, cell-for-cell** |
| MiniAmiq head | 348/1 -> 46/1 both modes | **same**; every other row unchanged |
| canaries / ctcan2 / canaudit | 52 & 8 ok changed=0; PASS x2; audited=29 UNCOVERED=0 FENCE-BREACH=0 | **same** |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr SAME, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **same** |

Binaries were frozen `chmod 555` at `/tmp/v111_scratch/frozen/{pris,pat}.bin`
before any sweep, `SLANG_UHDM` was exported per binary, and every `cmds.txt`
was audited by binary PATH: 937/937 patched rows and 1027/1027 pristine rows
name the frozen binary; the remaining `cmds.txt` files carry no `slang:` line
at all (rows that never invoke slang).

**One ops correction for future passes.**  The golden Surelog is
`~/git-repos/Surelog/build/bin/surelog` (what `scripts/verify_golden.py:51`
runs), NOT the `sv-tests/third_party/tools/Surelog` binary named in
`RESUME.md` §2.  Goldens produced by the latter restore into a CORRUPT
database with this UHDM (`Internal Error: adding wrong object type
(int_typespec) in a actual_group group!`, then `uhdm-dump` SEGFAULTS) — a grid
built on it silently scores nothing.  `RESUME.md` §2's path line should be
fixed.

## 2. Breaking the law — seven new arms, eleven shapes

`arms/v111_b1..b7.sv`, each run through the real Surelog and both frozen
binaries, scored per cell by `vscore111.py` (a multiset-keyed variant of the
pass's own scorer: it keys on (view, package, variable, call name) and holds a
LIST of shapes per key, so two calls of the same name in one initializer cannot
collapse into one row).

| arm | what it varies | cells | TO-GOLDEN | AWAY | STILL-WRONG |
|---|---|---|---|---|---|
| b1 | out-of-body method BODY shapes: plain / with locals / begin-end / explicit `return` / packed-vector return, plus an IN-BODY static method as the control | 20 | 15 | **0** | 0 |
| b2 | home + two wildcard importers (one never naming the class) + an EXPLICIT `import pkg::Cls` + a MODULE importer + a fully-qualified `pkg::Cls::m()` | 12 | 7 | **0** | 2 |
| b3 | nested imports C <- B <- A, with A importing BOTH so the same `C::m` entry can arrive twice (first-writer-wins vs Surelog's linear scan) | 12 | 11 | **0** | 0 |
| b4 | `$unit`-scope class, and a PARAMETERISED class reached as `Par4#(8)::pmk4()` | 10 | 5 | **0** | 4 |
| b5 | WHERE the call sits: package `parameter`, `localparam`, operation, ternary, concatenation, `$signed(...)` argument, and a package declaring a free function whose short name collides with the method's | 40 | 24 | **0** | 12 |
| b6 | tops and instances: an importing child module instantiated 3x, a second top importing nothing | 6 | 5 | **0** | 0 |
| b7 | two classes in ONE package with the same SHORT method name, a typedef ALIAS as the resolution head, and an out-of-body CONSTRUCTOR behind `Ctor7 h7 = new(3)` | 14 | 8 | **0** | 4 |
| **total** | | **114** | **75** | **0** | **22** |

Every one of the 22 STILL-WRONG cells is wrong in the PRISTINE binary too —
the patch created none of them (they are residues R-v1..R-v3 below).  The
official `uhdm-cmp` on all seven arms: identical line count AND identical head
OBJECT pristine vs patched (b1 8474, b2 4002, b3 3558, b4 3364, b5 9462,
b6 6162, b7 5394), and the head BLOCK itself is byte-identical on every arm — the law introduces no new head anywhere.

**The sharpest negative cells, all held:**
* b2 `v111b2expl` (EXPLICIT `import v111b2home::Zed2`): golden materialises no
  `Zed2::mk2` listing entry and keeps the class method; so do we, in BOTH views.
* b1/b2/b3/b4/b6 **elaborated HOME package**: golden keeps the class method
  because that view lists `class_defn`s, not `C::m` clones; the patch returns
  early there (`byName111` empty) in every arm.
* b7 **short-name collision**: `Alpha7::shared7` and `Beta7::shared7` each bind
  their OWN entry — a rebind keyed on the short name would have crossed them.
* b5 **package parameter initializers**: golden binds the importer's and the
  elaborated home's param_assign calls to the CLASS METHOD (only the home DEF
  view takes the listing entry).  The patch walks `Variables()` only, so it
  cannot touch them — the one place where "the view's own entry" would have
  been the WRONG answer is exactly the place the fence excludes.
* b1 `c_inbody` and b7 `h7 = new(3)`: neither golden nor we emit a `func_call`
  there, so there is nothing to move.

## 3. Boundary gate (my own run, over a tree that INCLUDES these arms)

`bound111.sh` over a COPY of the whole probe tree at 3441 arms (the pass tree
plus this directory), no path filter, `.sv` and `.v`, fd-3 list, children
`</dev/null`, PROCESSED asserted, rc per cell:

```
MODE=file VIEW=def   PROCESSED=3441 LISTED=3441 DIFFER=8 REJECTS 132/132
MODE=file VIEW=elab  PROCESSED=3441 LISTED=3441 DIFFER=8 REJECTS 144/144
MODE=dir  VIEW=def   PROCESSED=1501 LISTED=1501 DIFFER=6 REJECTS 117/117
MODE=dir  VIEW=elab  PROCESSED=1501 LISTED=1501 DIFFER=7 REJECTS 123/123
```
No asymmetric reject in any run.  In file mode the eight are `g111_a.sv`, my
six b-arms (**the positive control is built into the gate** -- seven arms the
law is supposed to move, and it moves them) and `r10buvm22repro/g22.sv`.
Nothing else in the tree moved: every arm of uvm89/92/94/95/97/98/99/103/105/
107/109, buvm13/15/16/18/20/23/24/28/57/64/88 and sd8-12 is byte-identical in
both views.  dir mode adds `r10uvm75repro`, `r10uvm76repro`, `r10v109repro`
(both views) and `r10uvm88repro` (elab only).

**Every non-arm differing directory acquitted, by two independent measurements
each.**  For all five, `pred111` reads **CELLS 0** off the pristine database --
the law's predicate never fires there, so the rebind code cannot have run.

| arm | pred111 | raw dump diff | ORDER-BLIND (sorted) diff | verdict |
|---|---|---|---|---|
| `r10uvm75repro` def / elab | CELLS 0 | 16 / 14 lines | **0 / 0** | pure `vpiTaskFunc` REORDER |
| `r10uvm76repro` def / elab | CELLS 0 | 12 / 18 lines | **0 / 0** | pure REORDER |
| `r10v109repro` def / elab | CELLS 0 | 20 / 18 lines | **0 / 0** | pure REORDER |
| `r10uvm88repro` def / elab | CELLS 0 | 0 / 4 lines | **0 / 0** | pure REORDER |
| `r10buvm22repro/g22.sv` | CELLS 0 | 6 lines | **12** | a real VALUE change -- see below |

The four REORDER arms are nondeterministic under ONE binary alone: four
pristine runs of `r10uvm75repro`, `r10uvm76repro` and `r10v109repro` give
**four distinct dump hashes** each; `r10uvm88repro` flips more rarely, and
twenty runs of EACH binary give the SAME two-element hash set (18/2 pristine,
19/1 patched) -- the known parallel-parse `SourceLocation` trap (RESUME.md
Section 9, "Emitter nondeterminism").  None differs in file mode.

**`r10buvm22repro/g22.sv` -- a REAL value change, and provably not this law.**
The whole diff is three constants that shift by exactly 4096 (one page):
22392217 -> 22396313 twice and 22391361 -> 22395457.  They are the RIGHT BOUND
of the range of `typedef C22 ka_cls_t[string];` (`g22.sv:70`) -- an
ASSOCIATIVE-array typedef whose bound carries an ADDRESS.  Three measurements:

1. `pred111` reads CELLS 0 on that arm, so the law's predicate never fires;
2. the value is DETERMINISTIC per binary (pristine run twice: one hash) and
   unmoved by a 50 KB environment pad, so it is not a stack address;
3. **THIRD-BINARY CONTROL** -- the MAIN-TREE binary at commit `219d8645`
   (md5 `af17c942...`), which does **not** contain this patch at all, prints
   `22396313 / 22396313 / 22395457`: the PATCHED values, not the pristine ones.
   The constant tracks the BINARY, not the law.

Recorded as R-addr111; it is a pre-existing latent defect, not this pass's.

## 4. Code review of the patch

* `bindPkgVarInitClassMethodClones111` writes exactly one field,
  `func_call::Function`, and no name anywhere.
* Placement is safe: the only other writer of `func_call::Function` in
  `exportDesign` is `drainScopedCallBind26()`, which runs immediately BEFORE it
  and is called once; nothing after re-points a call.
* The DEF and TOP package views do not share initializer objects — proved by
  measurement, not by reading: in every arm the DEF home cell moves while the
  TOP home cell of the same package stays put.
* `AllPackages()` / `TopPackages()` overlap would be idempotent (the map lookup
  returns the same entry).

## 5. Residues this verification adds (all pre-existing, none created here)

* **R-v1 `$unit`-scope class.**  `arms/v111_b4.sv`: for a class declared in
  `$unit` with an out-of-body static method, golden binds an object NAMED
  `Unitk4::umk4` in EVERY package view — the elaborated home included, where the
  package-listing rule predicts the class method.  We bind the class method in
  all four cells.  4 cells; the law's negative row (`TOP home -> CLASSM`) is a
  package-listing fact, not a general one.
* **R-v2 package PARAMETER initializers.**  `arms/v111_b5.sv`: golden's HOME DEF
  view binds a `parameter`/`localparam` initializer's `C::m()` to the package
  listing entry (we bind the class method — 3 cells), while the importer views
  and the elaborated home bind the class method (we emit NO param_assign
  `func_call` there at all — 9 cells).  Two separate misses, both pre-existing.
* **R-v3 typedef-alias and fully-qualified heads.**  `AliasA7::shared7`
  (b7) and `v111b2home::Zed2::mk2` (b2): golden emits no `func_call` for either;
  we emit one bound to the class method.  6 cells.
* **R-addr111** (the implementer's, confirmed here with the source line): an
  associative-array `[string]` typedef range's right bound is an ADDRESS.
  `tools/probe/r10buvm22repro/g22.sv:70`.

## 6. Files

`arms/v111_b1..b7.sv` (the seven arms), `vscore111.py` (the multiset scorer),
`raw/ct_gold_b*.txt` (the golden binding table per arm),
`raw/score_b*.txt` (golden vs pristine vs patched per cell).
Instruments reused as-is from `tools/probe/r10uvm111repro/`: `ct111id.cpp`,
`pred111.cpp`, `predall.sh`, `bound111.sh`.
