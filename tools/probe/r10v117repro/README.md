# r10v117 — the ADVERSARIAL VERIFICATION of r10uvm117 (§ `pkgFreeSubRefVarHoistNet117`)

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's report
reproduced bit-for-bit from binaries this verifier built itself. One
**pristine-RIGHT → patched-WRONG** cell on legal SV was found by a new arm and
is repaired here (`src/ModuleEmit.cpp`, 4 non-comment lines,
§ `hoistedNetNeverOverAModuleParam117`); the repair also moves TWO PRE-EXISTING
§ `oobRefVarLocalHoistNet107` cells TO-GOLDEN.

**MEASUREMENT ONLY.** The official `uhdm-cmp` and `scripts/verify_golden.py` are
the only acceptance judges. slang was **NOT** patched; `results/*.csv` were
**READ ONLY**; **NO CORPUS ROW CONVERTED** (surelog CMP_NOTEQUAL stays **19**);
`GOLDEN_DEFER` unset. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `7fb7d67` |
| worktrees | `/tmp/wt_v117` (patched + fix), `/tmp/wt_v117pris` (pristine) — both fresh at `7fb7d67` |
| scratch | `/tmp/v117_*` only |
| pristine binary | `cc1dcd48920298639c02a3371750f62a` — **the implementer's pristine md5 EXACTLY**, and the main tree's `build/slang-uhdm` at `7fb7d67` |
| patched binary (as shipped) | `b778b33088c6d70540626300cb53aa19` — **the implementer's patched md5 EXACTLY** |
| verified binary (patch + this fix) | `18bd1d0adb05593f4d6b58beee6f9165` |
| all three | frozen `chmod 555` BEFORE any sweep |

The two independent builds reproducing the implementer's md5s byte for byte is
the strongest possible check on the patch's provenance: the shipped
`/tmp/r10uvm117.patch` (md5 `8614632aa9b387efab19c665439b8d27`, 45 files)
applies clean on a FRESH `7fb7d67` (`git apply` rc 0, 0 conflict markers) and
compiles to exactly the binary the implementer measured.

## 1. WHAT REPRODUCED

| claim | implementer | this verifier |
|---|---|---|
| SimpleUVM default/testflags head | 17 → 56 | **17 → 56**, 1 head per run |
| SeqDriver / Scoreboard-def / MiniAmiq / BuildUVMPkg / Earlgrey heads | 56/56/56/56/36 unchanged | **identical**, head text byte-identical (ids aside) |
| pristine SimpleUVM head object | `logic_net(work@top.p)@263:3-263:4 / RHS:<null>` | **verbatim** |
| new SimpleUVM head | the `this_type::m_typewide_sequences` foreach head | **id-stripped md5 `308d49ba30d4` — identical to SeqDriver's, Scoreboard/default's and MiniAmiq's** |
| goldens | 23/0 patched, 23/0 pristine, 0/23 `/bin/false` | **23/0, 23/0, 0/23** |
| surelog corpus | 1588 rows, CMP_EQUAL 937, CMP_NOTEQUAL **19** | **identical on both binaries** |
| uhdm2rtlil | 679/50/2 both modes both binaries | **identical** |
| `ct8rows` | PASS vs committed baselines and vs own pristine | **PASS ×3 surelog, PASS ×3 u2r** (status AND dump) |
| `cmds.txt` audit BY PATH | no leakage | **1523 `/tmp/v117_pat.bin`, 1523 `/tmp/v117_pris.bin`, 0 main-tree** |
| byte movers, surelog | 4/956, all predicted by name | **4 + Scoreboard/default (the COIN)**; order-blind attribution below |
| byte movers, uhdm2rtlil | 0/1358 | **0/1358** |
| mover attribution | "+9 dump lines, 0 removed" | **+9 / −0 on all four**, order-blind |
| canaries / ctcan2 / canaudit | ok=52, ok=8, PASS×2, audited=29 UNCOVERED=0 FENCE-BREACH=0 | **identical** |
| protected DBs | byte-identical; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **identical** |
| boundary file/def, file/elab | DIFFER 8 / 6, PROCESSED==LISTED, PRIS_REJECT==PATCHED_REJECT | **DIFFER 13 / 11 over 3631 arms — the SAME 8 / 6 plus this verifier's own 5 new arms**; PROCESSED=3631=LISTED, REJECT 138/138 and 152/152 |
| grid a1 | 6/6 nets, 0 away | **6 TO-GOLDEN, 0 AWAY** |
| grid a2 | 3/4 nets, 0 away | **2 TO-GOLDEN, 1 STILL (R-MODFN), 0 AWAY** |
| grid a3 | "2 TO-GOLDEN" | **2 TO-GOLDEN and 4 AWAY-GOLDEN** — the committed `GRID.txt:92` records the 4 itself; only the prose summary elides them (§4 R-MULTI) |
| grid a4 | 1/1, 0 away | **1 TO-GOLDEN, 0 AWAY** |
| the fence, pristine | HIT 4, OTHER 40, MIRROR 0 | **the HIT rows are `uvm_pkg::uvm_process_report_message` `263:3-263:4` `p`, HOME=PKG, one per mover database** |

The Surelog decode was re-read from source, not taken on trust:
`UhdmWriter::lateBinding` (`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:3294`)
walks the reference's own parent chain; its `uhdmfunction` arm skips a candidate
whose object is `uhdmref_var` (`:3387`, `:3397`) and falls through; the mint at
`:3982-4004` (`s.MakeLogic_net()` at `:3985`) fires for `module_inst`,
`interface_inst` and `program`; and `lateBinding` is called for packages
(`:1304`) and modules (`:1575`, `:1623`, `:2072`) but **the class call at
`:1067` is COMMENTED OUT**. Nothing in the function tests for a class — the law
as decoded. `uvm-1.2 base/uvm_globals.svh:259-266` confirms
`uvm_process_report_message` is a package-scope FREE FUNCTION and `p` its line-262
`process` local.

## 2. THE ONE REGRESSION FOUND, AND THE FIX

### § `hoistedNetNeverOverAModuleParam117`

Arm **`v117_b5.sv`** writes the SAME collision twice — a hoisted `ref_var` local
whose name the importing module already declares as a **PARAMETER** and as a
**LOCALPARAM** — once in an out-of-body class method (§ 107's home, where the
PRISTINE binary already hoists) and once in a free package function (§ 117's new
home). Golden's answer is the same in both: **no net, and the reference left
UNBOUND**.

| cell | golden | pristine | patch as shipped | patch + fix |
|---|---|---|---|---|
| `oobParamName` (module `parameter`) | no net | **net @19:5** | net @19:5 | **no net ✓** |
| `oobLocalParamName` (module `localparam`) | no net | **net @20:5** | net @20:5 | **no net ✓** |
| `freeParamName` (module `parameter`) | no net | no net | **net @28:5 ✗ AWAY** | **no net ✓** |
| `freeLocalParamName` (module `localparam`) | no net | no net | **net @29:5 ✗ AWAY** | **no net ✓** |
| `oobVarName` / `freeVarName` (module `logic`) | binds the module's net | same | same | same ✓ |

`v117_b3.sv` cell `paramShadowC4` is the same defect reached from the shadow
grid: golden 0 nets, pristine 0, shipped patch **1**.

**It is judge-visible.** The extra element makes `module_inst::Nets` a VECTOR
size mismatch, and the extra `ref_obj::Actual_group` is read by the SINGULAR
`SafeCompare` overload — both are head-producing fields.

**The decode.** `UhdmWriter::lateBinding` consults the module's own parameter
value map BEFORE the implicit-net mint —
`Value* value = mod->getValue(name);` at
`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:3949-3959` — and takes
that arm instead of the `MakeLogic_net()` at `:3982-4004`. Our
`bindHoistedClassPropRefs` searched only the module's NET list, so a
parameter-named hoist fell through to the mint.

**The fix** (`src/ModuleEmit.cpp`, inside `bindHoistedClassPropRefs`, in the
`if (!bind9)` arm only — 4 non-comment lines):

```cpp
if (auto* pshadow9 = body.find(cpr.name))
    if (pshadow9->kind == SymbolKind::Parameter ||
        pshadow9->kind == SymbolKind::Specparam)
        continue;
```

A name the module declares as a NET is a different cell and was already right
(`bind9` finds it; golden binds it too — `oobVarName` / `freeVarName`). The fix
is in the ONE place all five pool laws share, so § `classPropRefs`,
§ `withIterRefBindsHoistNet75`, § `classEnumConstBindsHoistNet76`, § 107 and
§ 117 all get golden's answer; the two § 107 cells it repairs are a
**pre-existing** defect this pass would otherwise have widened.

## 3. THE ARMS THIS VERIFICATION ADDS

Every cell has its OWN name; no arm reuses a spelling, a length or a case
pattern from another. All five are compiled in BOTH views by `grid_v117.sh`
(a thin wrapper on the implementer's own `grid117.sh`, so both sides are
measured by the same instrument) and scored by `score_v117.py` as MULTISETS,
TO-GOLDEN / AWAY-GOLDEN / STILL, with a Compare-visible payload and **no span in
the key**.

* **`v117_b1.sv` — the reference positions a1 does NOT have.** A receiver-call
  ARGUMENT (a1 only has the handle as the RECEIVER), the same in expression
  position, ternary condition and value, a `$display` argument, a free-package-
  function-call argument, a `$cast` destination, a `wait` event-control operand,
  an lvalue inside `fork/join_none`, a for-loop initialiser, a `repeat` body,
  and an `int` local at an INDEX position as the non-`ref_var` control.
  **9 TO-GOLDEN, 0 AWAY, 1 STILL.**
* **`v117_b2.sv` — the homes a2 does NOT have.** A STATIC in-body method, a
  STATIC out-of-body method, a block item inside a free package TASK, a package
  function reached through package scope, an INTERFACE's own function, a
  PROGRAM's own function, a MODULE's own TASK, and an out-of-body method of a
  class declared INSIDE A MODULE. **2 TO-GOLDEN, 0 AWAY, 2 STILL.**
* **`v117_b3.sv` — resolution controls and DECLARATION ORDER.** The staging
  vector r10uvm117 adds was measured only in the class-BEFORE-free-subroutine
  direction; this arm writes both. Plus the same name in two free subroutines,
  and collisions with a module net, a package variable, a class property and a
  module parameter. **2 TO-GOLDEN, 1 AWAY (the parameter shadow — fixed), 0
  STILL.**
* **`v117_b4.sv` — uvm109's `= new` fence in the new home, and TWO TOP
  MODULES.** `= new(...)`, `= new()`, the COPY form and a free TASK's `= new`
  all stay unbound with no wire on both sides; a select index inside an ordinary
  lvalue keeps its `int_var`. **2 TO-GOLDEN, 2 AWAY (R-MULTI, §4), 0 STILL.**
* **`v117_b5.sv` — the parameter/localparam collision written TWICE**, in
  § 107's home and in § 117's, which is what separates "this pass introduced it"
  from "this pass widened it". §2.

## 4. RESIDUES THIS VERIFICATION NAMES (ranked)

* **R-MULTI (uvm107's, inherited, NOT fixed here).** The hoisted wire is minted
  in EVERY module that materialises the package; golden mints it once, in the
  FIRST module that cannot bind the name. Measured again on `g117_a3.sv`
  (4 AWAY cells: `ownerAlpha`/`ownerBeta` in `topA117c` and `topB117c`) and on
  `v117_b4.sv` (2 AWAY: a second top module that imports the package at FILE
  scope but names nothing of it). The implementer's own `GRID.txt:92` records
  the four; the report's "0 AWAY" summary line does not. **Zero corpus reach** —
  SimpleUVM and SeqDriver have one importing module each, and the ours-only
  implicit-net name set is unchanged. A pass that fixes it must move
  § classPropRefs / § 75 / § 76 / § 107 / § 117 together, which is why it is
  NOT fixed here.
* **R-ARGEXPR — the argument POSITION law is finer than § 5's R1.** `v117_b1`
  cell `freeCallArgB6`: an argument of a FREE package-function call in
  EXPRESSION position — golden mints the wire, we bind the `ref_var`
  declaration. The same argument in STATEMENT position (a1 cell 04
  `sink117a(userArgDelta);`) golden leaves as `ref_var`, and we agree. So
  golden's rule is EXPRESSION-vs-STATEMENT, while § 107's disjunct
  (`recvUserMethodArgDepth107 > 0`) counts only USER-CLASS RECEIVER calls —
  which is why `recvArgExprZ2` and `dispArgU4` and `castDstW1` all land right and
  `freeCallArgB6` does not. **Zero corpus witnesses** (the fence's HIT set is
  four cells, all `p`). Ranked next after R-MODFN in this family.
* **R-STAGEORDER — the staging vector is a heuristic, not the law.**
  `v117_b3` package `PkgFnFirst`: a free package function written BEFORE the
  class that shares the hoisted name. Surelog's pool is the package's SOURCE
  order, so golden spans the wire at the FREE FUNCTION's line (20:5); we span it
  at the class's (27:5), before and after the patch. **Not a regression** — the
  staging never moves a wire that was already right, it only fails to repair
  this direction — and a net's span is judge-invisible (no generated `Compare`
  reads `VpiLineNo`). The complete fix inserts a staged entry at its SOURCE
  position rather than appending it.
* **R-MODFN, widened.** The implementer names a MODULE's own FUNCTION. `v117_b2`
  adds two more faces with the identical shape: a MODULE's own **TASK**
  (`modTaskS5`) and an **out-of-body method of a class declared inside a
  MODULE** (`modOobT7`) — golden mints in both, we mint in neither, because our
  pool is keyed on a module's MATERIALISED PACKAGES and neither body has a
  package home. Zero corpus witnesses.
* **R-LISTORDER has a FOURTH member.** `r10uvm88repro` joins `r10uvm75repro`,
  `r10uvm76repro` and `r10v109repro` in dir mode (both views). Its raw diff is a
  single `vpiTaskFunc` permutation of `p3::base3::oob_base`; its ORDER-BLIND
  diff is **0**; and the PRISTINE binary ALONE gives two different whole-dump
  md5s in four runs of that directory. Not a mover.
* **R-ADDR and R-LISTORDER reproduced as stated.** `r10buvm22repro/g22.sv`'s two
  values move by EXACTLY 4096 (`22412697 → 22416793`), low 12 bits unchanged,
  on a binary that is exactly 4280 bytes larger — an address-derived garbage
  constant, not a mover. Scoreboard/default's raw-diff is the emitter COIN: its
  ORDER-BLIND diff is **0 real lines** (the single differing line is the
  `uhdm-dump` banner path).

## 5. THE INSTRUMENTS HERE

| file | what it is |
|---|---|
| `v117_b1.sv` … `v117_b5.sv` | the five adversarial arms of §3 |
| `grid_v117.sh` | thin wrapper on `r10uvm117repro/grid117.sh` so both sides use ONE instrument |
| `score_v117.py` | the multiset scorer: NET rows keyed (view, module, name, IMPL/OTH), REF rows keyed (view, owner, span, name) with the payload (actual KIND, ACTIMPL), and a `ref_var`-declaration set diff so a binding answer is never confused with a declaration one |
