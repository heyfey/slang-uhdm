# r10v130 — the ADVERSARIAL VERIFICATION of r10uvm130 § `newArrayArgHoistNet130`

**VERDICT: ACCEPT AS SHIPPED.** Every headline number reproduces bit for bit on
binaries this verifier built itself from fresh worktrees at `f611e1b`; nine new
adversarial arms across the law's whole face found **no pristine-right →
patched-wrong cell that the official judge convicts**, and the production
surface is unchanged in `/tmp/r10uvm130.verified.patch` (which adds only this
directory).

**MEASUREMENT-ONLY probes.** Nothing here is an acceptance judge. The official
`uhdm-cmp` and `scripts/verify_golden.py` are. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted**, **no corpus row
converted**. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, everywhere
below and in every script here.

| | |
|---|---|
| BASE | `f611e1b` |
| verifier worktrees | `/tmp/wt_v130` (patched), `/tmp/wt_v130pris` (pristine) — both built from scratch |
| pristine binary | md5 `f102bcba68a7d9317c746b848792fda1` — **the implementer's md5, bit for bit** |
| patched binary | md5 `96ac63809cd34213960a17a58a268e13` — **the implementer's md5, bit for bit** |
| gates | `GATES.r10v130.txt` — the whole battery, re-run, with the two corrections in §2 |
| grid | `GRID.r10v130.txt` — nine arms, both views, 56 NET + 56 REF cells TO-GOLDEN, 8 AWAY, all eight one inherited residue |

## 1. What reproduced

Everything the implementer claimed, measured again on this verifier's own
binaries and its own sweep workdirs, with `SLANG_UHDM` exported explicitly per
binary and **every `cmds.txt` audited by binary PATH** (1573/1523/0 and
1462/1458/0 per side, zero naming the main tree):

* goldens **23/0** on both binaries, `/bin/false` **0/23**;
* uhdm2rtlil **679 / 50 / 2** in both modes on both binaries, `ct8rows` PASS
  against the committed baseline and against the verifier's own pristine sweep,
  status **and** dump column;
* the surelog corpus **1588 rows**, histogram identical on both binaries,
  **CMP_NOTEQUAL 19 unchanged**, `ct8rows` PASS three ways, no row converted;
* byte movers **0 / 1358** on uhdm2rtlil; on surelog the four predicted
  databases moved with **the implementer's own md5s**, order-blind **40 ADDED /
  0 REMOVED** lines each;
* heads **SeqDriver 17 → 310**, everything else unchanged and **byte-identical**
  head text; the new head is the `named_fork` the implementer named, and its
  text equals their shipped `head_pat_default_SeqDriver.cmp` modulo object ids;
* canaries **ok=52 / ok=8, changed=0**, `ctcan2` PASS ×2, `canaudit`
  **audited=29 UNCOVERED=0 FENCE-BREACH=0**, the five protected databases SAME
  with `SVSwitch` at `4842211c4030` and `YosysVerx` at `6ccda350c24a`;
* golden-vs-golden calibration FIRST: **5 pairs, 502 family rows, EXPM_N=0**;
* the boundary over a COPY of the whole probe tree, no path filter, both MODEs
  and both VIEWs, `PROCESSED == LISTED` and symmetric rejects in all four —
  and the implementer's ten differing arms are **byte for byte the same list**,
  with the five dir-mode-only directories confirmed at **0 order-blind
  differing lines in both views**.

The verifier's own fence (`fence130v.py`, written independently of the pass's
`fence130.sh` and keyed on `(module fullname, implicit-net NAME)` instead of a
reference span) gives the corpus verdict in its own words:
**HIT 16 → 0, OTHER 4 → 4, MIRROR 6 → 6 with the two MIRROR sets BYTE-IDENTICAL**
over all 956 surelog databases, and the four databases it says must move are
exactly the four that did.

## 2. Two corrections to the pass's write-up (neither is a defect)

**(a) The surelog byte-mover count is 4 OR 5, not 4.** This verifier's sweep
produced **five** movers; the fifth is `./default/Scoreboard-59431470`, the
documented ~50/50 `vpiTaskFunc` list-order COIN (RESUME §9). Attributed
ORDER-BLIND it is **0 differing lines — 0 ADDED, 0 REMOVED** — so it is not a
mover at all. The pass's run happened to land on the same coin face. A lander
who re-runs must expect either count and attribute the fifth order-blind before
reading it as an unpredicted mover.

**(b) The boundary's `file/elab` run has ELEVEN differing arms, not ten**, and
the eleventh is a coin too. `r10vrgg3repro/xi_iface_param_type/dut.sv` differs
by ONE line, `|vpiSigned:1` on the interface-instance parameter
`work@top.arr[0]`. **200 repeat runs of each binary in a fixed directory**: the
**PRISTINE** binary produces the 13-line variant **2/200** and the patched
binary 0/200 (1/40 in an earlier batch). Pre-existing per-run nondeterminism in
both binaries — residue **R-IFPARAMSIGNED** below — and a standing lesson: a
lone differing boundary arm must be RE-RUN before it convicts a pass.

## 3. Breaking the law — nine arms, both views, every cell its own name

`GRID.r10v130.txt` carries the table; `drive130v.sh` builds golden + pristine +
patched in both views with every command and its `rc` echoed into `cmds.txt`,
and `score130v.py` scores each NET and REF cell TO-GOLDEN / AWAY-GOLDEN.

* **b1 — the READ FACE.** A queue index, a nested call's argument, a ternary
  condition and both its branches, a `$bits()` argument and a concatenation
  element, all INSIDE the `new[...]` list, hoist ✓; a loop bound, a `while`
  condition, an LHS-only name, a select index and a delay operand, all OUTSIDE
  it, bind normally and mint nothing ✓. **14 NET + 7 REF to golden, 0 away.**
* **b2 — the STATEMENT SHAPE**, including the one that could have been a
  widening: **a DECLARATION INITIALIZER** `int localDeclArr130v[] =
  new[declInitZet130v];`. Surelog compiles that through a different production
  and emits **no reference at all** — and so do we, on both binaries; nothing
  is minted on either side ✓. `if` branch, `case` item, `for` body, NAMED
  `begin`/`end`, an out-of-body TASK and a `fork ... join_none` all hoist ✓.
  **14 + 14 to golden, 0 away.**
* **b3 — TOP-MODULE COLLISIONS, where a widening would have lived.** The module
  declares a `wire` / a `parameter` / a `localparam` / an `int` variable / a
  `logic` reg of the hoisted name. Golden binds the wire, the int and the reg to
  the module's own declared object and mints **nothing** for the two parameter
  cells; the patched binary does **exactly the same in all five** and the
  module's net list does **not** grow — the pool binder's name-in-`nets` search
  covers three cells and § `hoistedNetNeverOverAModuleParam117` the other two.
  **2 + 8 to golden, 0 away.**
* **b4 / b9 — the eight AWAY cells, and they are ONE inherited residue.**
  Golden's owner is the FIRST MODULE WRITTEN that cannot bind the name
  (`UhdmWriter::lateBinding`'s first line is `if (ref->Actual_group())
  continue;` and the refs are SHARED), so exactly one module ever mints it; our
  pool binds every module whose materialised packages contain the home.
  **b7 proves this is not the pass's**: written with a `ref` formal — §
  `oobRefVarLocalHoistNet107`'s own population — the **PRISTINE** binary already
  mints in all four modules where golden mints none, and the patched binary is
  identical to it (0/0). **Corpus reach is zero**, measured: MIRROR 6 → 6
  byte-identical, 0/1358 on uhdm2rtlil.
* **b5 — HOMES.** A virtual out-of-body method, a static out-of-body method, an
  OUT-OF-BODY TASK and a DERIVED class's out-of-body method all hoist ✓; the
  **IN-BODY TASK stays unhoisted ✓ (the control)**; a module's own task is
  R-MODFN, the pass's own declared residue. **8 + 8 to golden, 0 away.**
* **b6 — DECLARATION KINDS.** A `const` local, an `automatic` local, a `static`
  local, an `output` formal, an `inout` formal, an enclosing named-block local,
  a `foreach` iterator and a formal WITH A DEFAULT all hoist ✓. **16 + 15 to
  golden, 0 away.** One MISS, pre-existing and unchanged: a **function-scope
  `localparam`** (residue R-FNLPARAM below).
* **b8 — a GENUINELY UNDECLARED name.** slang rejects it, `rc=3`, and the two
  binaries' stderr is BYTE-IDENTICAL. It lives in `rejarm/` so the boundary's
  `MODE=dir` run cannot let one rejecting arm blind the whole directory.

**The official judge on all nine arms, both views**: every arm is already
CMP_NOTEQUAL on the PRISTINE binary, so **no arm flips EQUAL → NOT-EQUAL**. Two
cells change WHICH head surfaces; on b9 the entire pristine→patched dump delta
is **9 ADDED / 0 REMOVED** lines — one wire and its binding — so the new head is
a pre-existing deeper difference UNMASKED once the reference cell started
comparing equal, the same cascade as SeqDriver's 17 → 310.

## 4. The must-stay controls

Every committed arm of `r10uvm75repro`, `r10uvm107repro`, `r10uvm117repro`,
`r10uvm127repro`, `r10v107repro`, `r10v117repro` and `r10v127repro/arms` — 47
files — scored in BOTH views: **46 arms 0 to-golden / 0 AWAY**, and
`r10v107repro/v107_b2.sv` alone moves, **2 NET + 2 REF TO GOLDEN, 0 away**.

## 5. Residues this verification adds to the queue

* **R-OWNERMOD** — *which* module owns the hoisted wire. Golden: the first
  module written that cannot bind (an INTERFACE and a PROGRAM are not
  late-binding owners at all; an EXPLICIT-ITEM importer `import p::c;` is).
  Ours: every module whose materialised-package set contains the home — and
  `collectMaterializedPkgs` does not count an explicit-item import or an import
  written inside a GENERATE BLOCK at all, which the PRISTINE binary already
  gets wrong (arm b9: golden owns the wire in `work@topItemCont130v`, both our
  binaries own it in `work@topPlainCont130v`). Fixing it means changing the
  SHARED pool binder that §§ 75 / 107 / 109 / 117 all use, on **zero corpus
  witnesses** in either direction — recorded, deliberately not widened. This is
  uvm107's R-MULTI stated one level sharper.
* **R-FNLPARAM** — a **function-scope `localparam`** read in a `new[...]`
  argument. Golden mints a wire for it (arm b6 cell `lparamLocalEps130v`,
  `work@topDecl130v` @25:23-25:41); we never do, because
  `newArraySubScopeSym16` admits only `Variable` / `FormalArgument` /
  `Iterator` and slang gives a function `localparam` `SymbolKind::Parameter`.
  Identical on both binaries; **zero corpus witnesses**.
* **R-IFPARAMSIGNED** — `|vpiSigned:1` on an interface-instance `parameter`
  flips per run on BOTH binaries (pristine 2/200, patched 0/200; the arm is
  `r10vrgg3repro/xi_iface_param_type/dut.sv` in the ELAB view). A third member
  of the emitter-nondeterminism family RESUME §9 already names.
* **R-ADDRCONST — REPRODUCED EXACTLY, and it is a real emitter defect.**
  `r10buvm22repro/g22.sv` (which contains **zero** `new[`) differs by 12 lines
  in both views: `|vpiDecompile:` / `|UINT:` values `22466073` → `22470169` and
  `22465217` → `22469313`, i.e. `0x156CE19 → 0x156DE19` and
  `0x156CAC1 → 0x156DAC1`, a shift of exactly `0x1000`. `readelf`: both
  binaries are `ET_EXEC`, `.bss` starts at `0x156ba00` (pristine) and
  `0x156ca00` (patched) — the same `0x1000`. The values are **`.bss` addresses
  of the emitting binary** leaked into the RIGHT RANGE of the `array_typespec`
  we mint for `typedef C22 ka_cls_t[string];` (g22.sv:70), where golden emits a
  `string_typespec` and no constant at all. Deterministic per binary, moves
  with ANY change to static layout, and neither value is golden's — so the cell
  has no direction and every future pass will see this arm "differ". Worth its
  own pass.

## 6. Files here

`v130_b1..b7.sv`, `v130_b9.sv`, `rejarm/v130_b8.sv` — the arms.
`drive130v.sh` (golden+pristine+patched, both views, auditable `cmds.txt`),
`score130v.py` (TO-GOLDEN / AWAY-GOLDEN per NET and REF cell),
`fence130v.py` (the verifier's own corpus fence — independent key),
`goldcal130v.py` (golden-vs-golden calibration, run FIRST).
`GATES.r10v130.txt`, `GRID.r10v130.txt`,
`FENCEV.{pristine,patched}.surelog.tsv`,
`head_b9_def_pris.cmp` + `head_b9_def_pat.head` (the unmasking cascade).

FENCED= (list only — the four names are deliberately NOT written into any
artefact of this verification).
