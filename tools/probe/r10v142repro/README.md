# r10v142 — ADVERSARIAL VERIFICATION of r10uvm142

**VERDICT: ACCEPT WITH FIX.**  Every headline number in the implementer's
report reproduced bit-for-bit on my own builds and my own sweeps.  One
**pristine-RIGHT → patched-WRONG** face survived their grids: a **class
CONSTRUCTOR with a paren-less header**.  Fixed here, minimally, in the same
flag the law already owns; ship `/tmp/r10uvm142.verified.patch`.

**MEASUREMENT-ONLY.**  Nothing in this directory is an acceptance judge.
`uhdm-cmp` and `scripts/verify_golden.py` are the authorities for every number
below.  slang was NOT patched, `results/*.csv` were READ ONLY and no row was
converted, `GOLDEN_DEFER` stayed unset, the four slang-fenced tests were never
dispatched and are spelled nowhere in this directory.

---

## 1. THE BREAK — § `tfItemLocalClassTsNotAConstructor142v`

> A CLASS CONSTRUCTOR IS NEVER THE TF-ITEM PRODUCTION, however its header is
> written.  Surelog compiles a constructor body through
> `CompileHelper::compileClassConstructorDeclaration` (`CompileStmt.cpp:2165`),
> which never reaches `compileTfPortDecl`'s `paBlock_item_declaration` arm at
> all — so a constructor's class-handle local keeps `compileVariable`'s
> **unnamed** fallback object even for a PAREN-LESS `function new;`.

The shipped gate is `tfItemLocalClassTs142 = !blockItems9`, and `blockItems9`
reads only the port-list paren (§ `blockItems9`: a FUNCTION takes the block
shape iff its header carries a paren, a TASK unless its body declares io).  A
paren-less `function new;` therefore reads TF-ITEM and the patch NAMES a
`class_typespec` golden leaves anonymous.

**Measured, four RIGHT→WRONG cells, both views** (`VARMS.pre-fix.txt`;
`v142_a_ctor.sv` / `v142_d_ctor2.sv`):

| cell | site | golden | pristine | patched (as submitted) |
|---|---|---|---|---|
| `14:7-14:13` | `Cv1142::new` (paren-less, package class) | `-` | `-` | **`Kv1142`** |
| `12:7-12:13` | `Bv4142::new` (paren-less, package class) | `-` | `-` | **`Kv4142`** |
| `18:7-18:13` | `Dv4142::new` (paren-less, an EXTENDED class) | `-` | `-` | **`Kv4142`** |
| `43:7-43:13` | `Mc4142::new` (paren-less, a MODULE class) | `-` | `-` | **`Mk4142`** |

Golden's own answer, read off Surelog's database: a constructor local is
anonymous under **both** header shapes — `function new;` 14:7 and
`function new();` 21:7 both `TSNAME=-`.  The paren-less ORDINARY methods beside
them in the same class (`vtf` 38:7, `stf` 44:7, `ptf` 50:7, `atf` 53:7,
`btf` 56:7) are all NAMED, which is the law working correctly.

### The fix

One conjunct, at the flag's only writer (`src/TaskFuncEmit.cpp`):

```cpp
tfItemLocalClassTs142 =
    !blockItems9 &&
    (sub.flags & MethodFlags::Constructor) == MethodFlags::None;
```

**Constructor-ness is slang's own flag, NOT the name** — the lesson
§ `ctorNoVars71` already paid for.  An ESCAPED identifier is exempt from
keyword rules, so `function void \new ;` is an ORDINARY paren-less method whose
locals golden DOES name: `v142_d_ctor2.sv` cells `24:7` / `25:7` are
**WRONG→RIGHT** under the flag test and would be RIGHT→WRONG under a
`sub.name == "new"` test.  Both cells are in the arm and both are scored.

After the fix: **RIGHT→WRONG 0 and AWAY 0 on every column of every one of the
ten verifier arm-views** (`VARMS.fixed.txt`), with the law's own gains intact
(TSNAME WRONG→RIGHT 76, TSINST 44 across the five arms × two views).

**The fix is corpus-invisible**, as its own model predicts: no corpus row has a
paren-less constructor with a same-component class-handle local.  Fixed vs
unfixed-patched is 1/956 byte movers (`Scoreboard/default`) and that one is
**ZERO lines order-blind** — the known ~50/50 coin, not the fix.

---

## 2. The break grids (`varms142.sh`, five arms × two views)

Every arm is a face the pass's own three grids do not carry.

| arm | what it breaks |
|---|---|
| `v142_a_ctor.sv` | CONSTRUCTORS (paren-less / paren'd, in-body / out-of-body) and the qualifier axis on paren-less ordinary methods (`virtual`, `static`, `protected`, `automatic`); a `begin`-block local INSIDE a tf-item subroutine, in a class and at package scope |
| `v142_b_faces.sv` | a FORWARD-DECLARED class (`typedef class`), an INTERFACE CLASS handle, an implementing class, a `#(...)` specialization and a bare generic, a typedef of a specialization; arrays / queues / dynamic / associative handle collections and three declarators on one statement; the PROGRAM and INTERFACE homes, and a class declared inside an interface |
| `v142_c_inst.sv` | THREE INSTANCES of one parameterized module, a class-handle RETURN type under both productions, a `$cast` target, a module TASK with body io, and a GENERATE-BLOCK subroutine |
| `v142_d_ctor2.sv` | the constructor face widened: module class, an EXTENDED class, `super.new`, and the ESCAPED-identifier `\new` control |
| `v142_e_leak.sv` | the FLAG LEAK: the gate is a member flag held across the whole recursive `makeTypespec` call, so a class handle reached THROUGH a struct member is where it could escape its `nested0` fence; plus `static` locals and a `fork`-block local |

**What they confirm about the law (all after the fix):**

* the PRODUCTION, not the qualifier, decides — `virtual` / `static` /
  `protected` / `automatic` paren-less methods all WRONG→RIGHT;
* a `begin`-block local inside a TF-ITEM subroutine stays anonymous, matching
  golden (`blk_n`, `blkb_n`, `g_blk`, `gb_blk`: no cell moves);
* the law holds in a PROGRAM, in an INTERFACE and in a GENERATE BLOCK
  (`i_same` 81:5 WRONG→RIGHT; `g_same` 49:7 WRONG→RIGHT ×3 instances);
* **the flag does NOT leak**: the class-handle member of a struct typedef
  (`12:5-12:11`, golden-anonymous) is RIGHT→RIGHT — `nested0` breaks the walk
  at the struct scope;
* the `builtinLocalUnnamed0` fence is untouched by construction (it is still
  AND-ed into the same `if`), and the TYPEDEF'd-handle fence holds
  (`p_td` / `pb_td` / `f_tdspec` unchanged, R1);
* a class-handle RETURN typespec is untouched in both productions
  (`v142_c_inst` 26:12 / 30:12 WRONG→WRONG) — that is the implementer's R5,
  confirmed as a separate site;
* an INTERFACE-CLASS handle (`22:5`, `v142_b_faces`) is a place where golden has
  **no `class_typespec` at all** and we mint one: the patch gives that surplus
  object a name and an instance.  ONLY-OURS before and after, count unchanged —
  the same shape as the implementer's nested-class residue R2.  Recorded as a
  new residue below; it is not a regression, but it is not measured toward
  golden either.

---

## 3. Everything in the implementer's report, re-measured

Two fresh worktrees at `eca7329`, both binaries built `-j 2` with md5s taken
separately and frozen `chmod 555` before any sweep; a third worktree for the
predictor; `SLANG_UHDM` exported explicitly per binary; every `cmds.txt`
audited by binary PATH.

| claim | my measurement |
|---|---|
| pristine heads 26/26 (SeqDriver ×2), 26/26 (MiniAmiq ×2), 29 ×3, 83/83, 15/15, 0 | **identical** (`HEADS.txt`) |
| the head is `class_typespec` at `uvm_component.svh:3383`, golden `vpiName:uvm_cmdline_processor` + `vpiInstance -> package uvm_pkg`, ours nameless and uninstanced, same span, same `vpiClassDefn`; ONE `^LHS:` | **identical**, read off my own pristine cmp log |
| patched heads SeqDriver ×2 **6254**, MiniAmiq ×2 **6222**, all others unchanged | **identical**, for the submitted patch AND for the fixed one |
| a-priori prediction: 2314 rows, 721 SKIP-NOFILE, **9 rows predicted to move**, per-row cell counts 10/12/6/12/6/10/12/12/6 | **identical**, re-run from my own pristine sweeps (`PREDICTION.reproduced.txt`) |
| `byteverify SELFCHECK=1`: surelog MOVERS **9/956** — exactly those nine; uhdm2rtlil **0/1358** | **identical** (`MOVERS.txt`) |
| order-blind whole-dump attribution 84 / 70 / 42 lines, **0 outside** `class_typespec` / `vpiName` / `vpiInstance` / the named package | **identical**, all nine |
| corpus census TSNAME/TSINST W→R 12/12, 12/12, 6/6, 6, 10/10 — 86 cells per field, RIGHT→WRONG 0, AWAY 0 | **identical** (`UVMCENSUS.reproduced.txt`; every scored row byte-identical to the committed `UVMCENSUS.txt`) |
| the three implementer grids, six arm-views | **byte-identical** TSNAME/TSINST verdict lines to the committed `ARMS.txt`, run against my FIXED binary (`ARMS142.reproduced.txt`) |
| goldens 23/0; `SLANG_UHDM=/bin/false` → 23 FAIL | **identical**, for pristine, submitted and fixed binaries |
| u2r 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL, `ct8rows` 0 differing rows both modes | **identical**, vs committed baseline AND vs my own pristine |
| surelog `--mode both`, `ct8rows` **0 differing rows over 1588**, no row converted, histograms default 471/283/25/10/5 and testflags 466/284/23/9/5/3/2/1/1 | **identical** |
| `cmds.txt` audit: 2981 of 3035 name the frozen patched binary, **0 name any other** | **identical** (1523 + 1458; the other 54 never invoked slang) |
| canaries `ok=52` / `ok=8` `changed=0`; `ctcan2` PASS ×2; `canaudit` `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **identical** |
| InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` | **identical** |
| wide boundary `LISTED=4034 PROCESSED=4034 MOVED=14 BREACH=0 RC-MISMATCH=0 NORUN=306` **BOUNDARY PASS** | **identical**, run PRISTINE vs my FIXED build (`BOUNDARY.v142.txt`) |
| positive control `LISTED=3 PROCESSED=3 MOVED=6` `POSITIVE-CONTROL-OK` | **identical** |
| the 8 foreign moved file-views (r10uvm139 / r10v139 grids) move TOWARD golden only: 8/4/12/4 W→R, 0 R→W | **identical** (`FOREIGN.txt`) |
| R0: `uvm_component.svh:3387:3` body `begin`, `Stmts` size mismatch, golden **6** vs ours **8`, the two extra being `assignment 3381:14-3381:23` and `assignment 3383:25-3383:64` | **identical**, counted off my own fixed cmp log |
| patch applies clean on a fresh `eca7329` and its `git diff` is byte-identical to the patch | **confirmed** (round-trip in a throwaway worktree) |

**Predictor audit** (the boundary gate's own instrument, and the thing that
would silently break the gate if it were not inert): the `pred142.diff` build
is **emitter-inert** — its database is byte-identical to pristine's on both
arms I checked, in both views, while naming 11 and 25 cells.  Measured, not
assumed.

**Boundary controls.**  The wide boundary compiles every `.sv`/`.svh` under the
WHOLE of `tools/probe`, so the must-stay arms of r10uvm139, r10uvm123,
r10uvm114, r10uvm112 and the § 83 / § 88 passes are all inside it.  MOVED=14:
this pass's own three grids (6) and four r10uvm139/r10v139 files (8).  **No
r10uvm123 / r10uvm114 / r10uvm112 / r10uvm83 / r10uvm88 file-view moved at
all.**

---

## 4. What is in this directory

| file | what it is |
|---|---|
| `v142_a_ctor.sv` … `v142_e_leak.sv` | the five break grids |
| `varms142.sh` | the arm driver (fd-3 list, `</dev/null` children, PROCESSED asserted, every rc recorded); reuses `../r10uvm142repro/{ct142cen,score142.py}` rather than forking them |
| `VARMS.pre-fix.txt` | the arms against the patch **as submitted** — the four RIGHT→WRONG cells |
| `VARMS.fixed.txt` | the arms against the **fixed** patch — RIGHT→WRONG 0, AWAY 0 |
| `ARMS142.reproduced.txt` | the implementer's own three grids, re-run against my fixed binary |
| `UVMCENSUS.reproduced.txt` | the corpus census, re-run against my fixed binary |
| `PREDICTION.reproduced.txt` | the a-priori prediction, re-run from my own pristine sweeps |
| `MOVERS.txt` | byteverify + the order-blind per-mover attribution |
| `HEADS.txt` | `rowheads.sh` on all three builds |
| `FOREIGN.txt` | the four foreign boundary movers, re-scored against golden |
| `BOUNDARY.v142.txt` | the wide boundary gate, pristine vs fixed |

---

## 5. Residues this verification adds (ranked)

* **RV1 — the INTERFACE-CLASS handle.**  `v142_b_faces` `22:5-22:12` /
  `30:5-30:12` (`IFv2142 f_iface`): golden emits **no `class_typespec`** at the
  declaration's span; we mint one, and after this pass it carries a name and a
  `vpiInstance`.  ONLY-OURS before and after, count unchanged, so the judge sees
  no new object — but the surplus object is now richer, not poorer.  Same
  species as the implementer's R2 (nested class).  Corpus incidence: zero.
* **RV2 — a BLOCK-production local of a class declared in an INTERFACE is
  NAMED in golden.**  `v142_b_faces` `85:5-85:13` (`Icls2142 ib_same` in
  `ibl2142()`): golden `Icls2142`, ours `-`, WRONG→WRONG.  § `localClassTsUnnamed15`
  says "same design component → unnamed", and an INTERFACE apparently is not
  that component for this purpose.  A pre-existing miss this pass neither
  causes nor fixes; the next place to look after R0.
* **RV3 — `function Cv3142::new;` (an OUT-OF-BODY constructor) is parented to
  the PACKAGE by both producers**, and golden gives its local a name and a
  `vpiInstance` that we already match; but golden also lists a `PAR` /`SCOPE`
  (`class_var(oct_n)` / `package(pv1142)`) that our object does not carry
  (`v142_a_ctor` `30:5`, WRONG→WRONG on both dump-only columns, unchanged by
  this pass).  Dump-only, invisible to the judge.
* **RV4 — the `\new` escaped-identifier method is unexercised by any corpus
  source.**  It is the only thing separating `MethodFlags::Constructor` from a
  name test, and only these arms cover it.  Keep `v142_d_ctor2.sv` alive.
