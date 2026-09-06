# r10uvm176 — § `ifaceRecvCallArgTakesTheOrdinaryWindow176` — **AN INTERFACE-METHOD CALL'S ARGUMENTS BIND EXACTLY WHERE AN ORDINARY CALL'S ARGUMENTS BIND** — the MiniAmiq ×2 29-line head CLEARED

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted**
and **NO CORPUS ROW CONVERTED**.  `GOLDEN_DEFER` stayed unset.  The four
slang-fenced tests were never dispatched and are named only inside
`canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `76252556` |
| pristine binary | md5 `b49636170347560e90432e4e18a11f3b`, built from this pass's OWN worktree at a clean `76252556` and frozen `chmod 555` before any sweep — it is byte-identical to the binary r10uvm175 landed as its patched artifact, and its own 956-row surelog sweep reproduced `results/golden_surelog.csv` row for row |
| patched binary | md5 `10dc137e115d174d49de081277acb5c8`, frozen `chmod 555`.  The patch applied to a **FRESH `76252556` worktree** and rebuilt there produces the **BYTE-IDENTICAL** binary, same md5 — the patch IS the artifact every number below was measured on |
| production surface | `src/ExprEmit.cpp` — **SIX code lines** (one gate expression and one RAII scope) inside the interface-method-call arm, plus the decode.  Nothing else. |
| probe surface | `tools/probe/r10uvm176repro/` only |
| docs | `RESUME.md` §3b — the MiniAmiq row, refreshed with the head this landing produced (it rides with the code, per the standing direction) |

---

## READ THIS FIRST — the numbers

| | |
|---|---|
| the head | **MiniAmiq default and testflags, 29 cmp lines, ONE head each — CLEARED.**  29 → **33**; the head OBJECT changed (an unbound `ref_obj::Actual_group` @94:29 → a `param_assign`'s folded `constant` @368:36, §10).  The two modes' cmp logs stay byte-identical to each other (md5 `d10e1669eb7a` → `4ac698a7142f`). |
| every other row's head | cmp log **BYTE-IDENTICAL** — SeqDriver ×2, SimpleUVM ×2, Scoreboard, BuildUVMPkg ×2, Earlgrey_0_1 ×2, Rggen. |
| corpus rows changed | **0** — both corpora, both modes, status AND dump column, against the committed baselines AND this pass's own pristine sweeps. |
| byte movers | **3 / 956** surelog — 2 **PREDICTED BY NAME before the patched sweep ran** and 1 the documented Scoreboard/default COIN (0 lines in the order-blind diff).  **0 / 1358** uhdm2rtlil, also predicted. |
| the corpus population | TWO cells per row-mode, `svaunit_vpi_wrapper.svh:94:29` and `:628:52`, and the whole-corpus face census proves they are the only ones. |
| the face census (956 surelog databases, both sides) | golden face cells 32 681; FACEDIFF **142 → 138**; MOVED 4, **TOGOLD 4, AWAY 0, MOVED-WRONG 0**.  uhdm2rtlil (1358 databases) holds **four** face cells in total and they already agree. |
| the census (nine UVM row-modes, EVERY family, 1 352 918 rows per binary) | ARG disagreeing cells 14 512 → **14 508**; REF (every reference in the database) 48 701 → **48 697**; OBJ **0 lines moved** — nothing created, destroyed or re-typed.  **TOGOLD 4, AWAY 0, MOVED-WRONG 0** in both moving families. |
| the grids (4 arms × 2 views, one Surelog golden each) | DEF **TOGOLD 20, AWAY 0, MOVED-WRONG 0** on the position key (18/0/2 on the full key, the 2 being receiver-NAME residues whose `vpiActual` still lands on golden's); ELAB **TOGOLD 20, AWAY 0, MOVED-WRONG 0**. |
| the WIDE boundary (4860 sources × 2 views) | `LISTED=4860 PROCESSED=4860 MOVED=6 ASYMMETRIC=0` — **all six are this pass's own arms.**  Not one earlier pass's arm moved. |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST — AND THE BRIEF'S DIRECTION IS **INVERTED**

This pass built its own pristine binary from a clean `76252556` worktree and
its own 956-row surelog sweep reproduced the committed baseline **row for row**
(`ct8rows` PASS, 0 differing rows, status AND dump column).  `rowheads.sh` on
that sweep:

```
MiniAmiq       default         29      1
MiniAmiq       testflags       29      1     (the two cmp logs BYTE-IDENTICAL, md5 d10e1669eb7a…)
```

which is r10uvm175's R0 to the byte.  The pristine cmp log
(`head_pris_MiniAmiq.default.cmp`) reads:

```
LHS:
decompile:
io_decl: (a_test_name), id:261648, line:91:51, endln:91:62
|vpiParent:
\_function: (svaunit_pkg::svaunit_vpi_wrapper::set_test_name_vpi), id:261647, line:91:4, endln:91:11
…
RHS: <null>
```

`BaseClass.h`'s **SINGULAR** `SafeCompare` prints this shape when the golden
value is present and ours is null — so **GOLDEN BINDS THE ARGUMENT AND WE LEAVE
IT BARE**.

> **THE BRIEF HAS THE DIRECTION BACKWARDS.**  It says "golden leaves the
> argument reference's actual edge NULL at `svaunit_vpi_wrapper.svh:94` where
> ours binds it to the formal's `io_decl`", and asks for a SUPPRESSING window.
> The log says the opposite, and so does the owner-finder, and so does the dump.
> This pass therefore **ADDS** a `vpiActual` that was absent.  (The brief's own
> AWAY definition is inverted with it: an argument golden binds and we leave
> bare is the DEFECT, not the regression; the regression to watch for — and
> scored explicitly below — is an argument golden leaves BARE that we bind.)

`ct176own.cpp`'s REFERENCE SCAN names the edge with no walk at all
(`OWNER.r10uvm176.txt`):

```
HEAD LHS = io_decl(a_test_name)@91:51-91:62#261648
HEAD RHS = <null>
REFERENCE SCAN — every golden edge that lands on the head, and ours:
  golden ref_obj(a_test_name)@94:29-94:40#261657
      edge vpiType=700 (singular)                  <- ref_obj::Actual_group
      ours   ref_obj(a_test_name)@94:29-94:40#190664 -> singular <null>
```

The site, `svaunit/sv/svaunit_vpi_wrapper.svh:91-95`:

```systemverilog
   virtual function void set_test_name_vpi(string a_test_name);   // 91
      test_name = a_test_name;                                    // 92
                                                                  // 93
      vpi_vif.set_test_name(a_test_name);                         // 94  <- col 29
   endfunction                                                    // 95
```

**AND OUR OBJECT IS ALREADY RIGHT IN EVERY OTHER RESPECT.**  Side by side, the
two dumps at line 94 differ by ONE FIELD:

```
golden                                            ours
\_method_func_call: (set_test_name) 94:15-94:28     \_method_func_call: (set_test_name) 94:15-94:28
  |vpiArgument:                                       |vpiArgument:
  \_ref_obj: (…::a_test_name) 94:29-94:40             \_ref_obj: (…::a_test_name) 94:29-94:40
    |vpiName:a_test_name                                |vpiName:a_test_name
    |vpiActual:                                     <-- THE DEFECT: ABSENT ON OUR SIDE
    \_io_decl: (a_test_name) 91:51-91:62
  |vpiName:set_test_name                              |vpiName:set_test_name
  |vpiPrefix:                                         |vpiPrefix:
  \_ref_obj: (…::vpi_vif) 94:7-94:14                  \_ref_obj: (…::vpi_vif) 94:7-94:14
```

Same kind, same spans, same prefix, same NOLINK, same name — one missing
`vpiActual`.  **The head is one field wide.**

### WHY LINE 92 IS NOT THE HEAD

`test_name = a_test_name;` is an ASSIGNMENT RHS, and inside a class-method body
an assignment's names bind nothing on either side — § `classMethodNoBind`'s own
rule.  Golden's 92:19 `ref_obj` carries no `vpiActual` and neither does ours;
the cell AGREES.  It is not a sibling of the head at all: line 94 is a CALL
ARGUMENT and line 92 is not.

---

## 2. THE DECODE — SURELOG'S SOURCE, READ, NOT INFERRED

`CompileHelper::compileTfCall`,
`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:4135`, dispatches a
statement-position subroutine call on the LEAF of the callee name:

| leaf | line | what happens |
|---|---|---|
| `paSystem_task_names` | :4190 | a `sys_func_call` |
| `paImplicit_class_handle` (`this.` / `super.` / `this.super.`) | :4194-4201 | handed to **`compileComplexFuncCall`** — a different builder |
| `paDollar_root_keyword` | :4202-4207 | a `sys_func_call` named `$root.…` |
| `paClass_scope` (`c::s.`) | :4208-4211 | handed to **`compileComplexFuncCall`** |
| a plain `slStringConst` | :4212-… | **THIS ARM** |

In the last arm, when the name's sibling is a `paConstant_bit_select` — which
is what a written `recv.meth(...)` produces — Surelog mints the object our
emitter mints (`:4224-4237`):

```cpp
    tfNameNode = fC->Sibling(Constant_bit_select);
    method_func_call* fcall = s.MakeMethod_func_call();
    const std::string_view mname = fC->SymName(tfNameNode);
    fC->populateCoreMembers(tfNameNode, tfNameNode, fcall);   // spanned at the METHOD
    fcall->VpiName(mname);
    fcall->VpiParent(pexpr);                                  // PARENTED AT THE STATEMENT
    ref_obj* prefix = s.MakeRef_obj();
    prefix->VpiName(name);                                    // the RECEIVER, unbound
    prefix->VpiParent(fcall);
    fC->populateCoreMembers(dollar_or_string, dollar_or_string, prefix);
    fcall->Prefix(prefix);
    call = fcall;
```

`getTaskFunc(name = "vpi_vif", …)` then finds nothing (there is no subroutine of
that name), so **no `vpiFunction` link is attached** — golden's call is NOLINK,
exactly as ours is.  The arguments are compiled at `:4329-4333`:

```cpp
  if (VectorOfany* arguments =
          compileTfCallArguments(component, fC, argListNode, compileDesign,
                                 Reduce::No, call, nullptr, false)) {
    call->Tf_call_args(arguments);
  }
```

with **THE CALL ITSELF AS `pexpr`**.  Each argument reference is then built by
`compileExpression`'s name arm
(`CompileExpression.cpp:2982-3000`), which runs

```cpp
  if (pexpr) {
    if (UHDM::any *var = bindVariable(component, pexpr, name, compileDesign))
      ref->Actual_group(var);
    else if (component) component->needLateBinding(ref);
  }
```

and `CompileHelper::bindVariable` (`CompileStmt.cpp:3089-3151`) climbs
`scope->VpiParent()` — call → `begin` → `function`/`task` — returning the
matching entry of `Io_decls()` or `Variables()`.

**NOTHING ON THAT ROAD LOOKS AT THE RECEIVER'S TYPE.**  A virtual-interface
handle, a real interface port and an ordinary object all reach the same arm and
the same `pexpr` chain.  So the golden value of such an argument is
§ `classArgBind12`'s and § `controlBodyNoBind28`'s, verbatim — which is exactly
what the corpus says.

### THE CORPUS PROVES THE RULE INSIDE ONE CLASS

`svaunit_vpi_wrapper` calls through `vpi_vif` **ten** times.  Golden binds
**two** of them and leaves **eight** bare, and the split is § 28's depth gate
plus § 12's property rule, with no reference to the interface anywhere:

| site | written | control depth | argument is | golden |
|---|---|---|---|---|
| 94:29 | `vpi_vif.set_test_name(a_test_name)` | 0 | the FORMAL | **BOUND** |
| 628:52 | `vpi_vif.kill_all_assertions(get_test_name(), a_sim_time)` | 0 | the FORMAL | **BOUND** |
| 78:31 | `vpi_vif.update_coverage(test_name)` | 0 | a class PROPERTY | BARE |
| 555:51 | `vpi_vif.reset_assertion(get_test_name(), assertion)` | 1 (`if … begin`) | a body local | BARE |
| 575:53 | `vpi_vif.disable_assertion(…, assertion)` | 1 | a body local | BARE |
| 597:52 | `vpi_vif.enable_assertion(…, assertion)` | 1 | a body local | BARE |
| 619:50 / 619:61 | `vpi_vif.kill_assertion(…, assertion, a_sim_time)` | 1 | a body local / the FORMAL | BARE / BARE |
| 641:58 | `vpi_vif.disable_step_assertion(…, assertion)` | 1 | a body local | BARE |
| 664:57 | `vpi_vif.enable_step_assertion(…, assertion)` | 1 | a body local | BARE |

`a_sim_time` is the same formal at 628 (depth 0, BOUND) and at 619 (depth 1,
BARE): **the discriminator is the control-body depth, not the receiver.**  We
were bare at all ten.

---

## 3. THE BUG IN OUR EMITTER, IN ONE SENTENCE

`src/ExprEmit.cpp`'s INTERFACE-METHOD arm — the one whose own comment reads
*"INTERFACE method calls through a port (`ha_intf.summ2(a,b)`): … args bind
normally"* — emitted its arguments with **no § `classArgBind12` window open**.
In the home it was decoded on (a MODULE calling through an interface PORT) they
did bind normally, because `classMethodNoBind` is not set there.  Inside a class
method it is, and the whole argument list went silent.  The u2r row
`iface_method_call` — the very test the comment names — is byte-identical
before and after, on both binaries.

**THE PATCH IS SIX CODE LINES**, at that arm's argument loop:

```cpp
const bool ifaceArgWin176 =
    curSubClassScope9 && !curSubOob9 &&
    recv1.find('.') == std::string::npos &&
    recv1.find(':') == std::string::npos;
ClassArgBindIf38 cab176(classArgBindDepth12, ifaceArgWin176);
```

It raises **THE SAME COUNTER** § `classArgBind12` raises — not a new one — so
§ `controlBodyNoBind28`'s depth gate, § `blockLocalSameCtrlDepthArgBinds57/64`'s
carve-out, the class-PROPERTY silence, § `classInBodyRecvCallArgNoBind52` and
§ `newArrayArgNoBind16` all keep applying unchanged.  DIRECTION: **ADD** a
`vpiActual` that was absent; never reshape, never delete.

---

## 4. THE RECEIVER-SPELLING CONJUNCT IS SURELOG'S OWN DISPATCH

Our arm finds the receiver with `raw.find_last_of('.')`, which happily accepts
spellings `compileTfCall`'s dotted arm never sees.  The window therefore asks
the question the dispatch table in §2 asks: **is the receiver text ONE name?**
Arm C (`g176_c_recv.sv`) reads every spelling off ONE golden, DEF view:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| `s_plain` | `plain176.poke176(alfa176)` | BOUND | BARE | **BOUND** |
| `s_local` | a LOCAL handle, `grab176.poke176(epsil176)` | BOUND | BARE | **BOUND** |
| `s_formal` | the handle is the method's FORMAL, `held176.poke176(zeta176)` | BOUND | BARE | **BOUND** |
| `s_index` | `bank176[1].poke176(delta176)` | BOUND | BARE | **BOUND** (residue R2: golden also DROPS the subscript from the prefix NAME and we do not — the ARGUMENT still lands on golden's `io_decl`) |
| `s_spaced` | `plain176 . poke176(eta176)` | BOUND | BARE | **BOUND** (residue R2: golden trims the prefix NAME, we keep `"plain176 "`) |
| `s_this` | `this.plain176.poke176(beta176)` | **BARE** — and golden's object is a `method_func_call` NAMED `this` with a STRING-constant prefix (§ `thisRecvCall11`'s road, `compileTfCall:4194`) | BARE | **BARE — DECLINES** |
| `s_deep` | `nest176.deep176.poke176(gamma176)` | golden builds **no such call at all** | BARE | **BARE — DECLINES** |
| `s_scoped` | `spelling176::stat176.poke176(theta176)` | Surelog **refuses to compile it** (`CP0332`) | — | — |

The `s_this` and `s_deep` cells are what the `'.'` conjunct is for, and they are
measured, not asserted.  The `':'` conjunct has **no golden cell of its own** —
Surelog rejects the only spelling that could produce one — and is written for
exactness with the dispatch it mirrors, exactly as the `plainH` test ~100 lines
above this arm is.

---

## 5. THE HOME CONJUNCT IS A COUNTER-WITNESS, NOT A TIDY-UP

An intermediate binary (md5 `31f80e8e439667f750775e618a7eea33`, built and
measured, kept only as evidence) omitted `curSubClassScope9 && !curSubOob9`.
On the corpus it happens to move exactly the same two cells; on the ARMS it also
moves exactly the same cells.  It is still wrong, and the corpus holds the cell
that says so.

`svaunit/sv/svaunit_vpi_interface.sv:506-517` is an **INTERFACE's own** function:

```systemverilog
   function void update_coverage(string a_test_name);        // 506
      automatic int nof_attempts_failed_covered;             // 507
      …
      foreach(cover_info[index]) begin                       // 510
         if(cover_info[index].sva_enabled(a_test_name)) begin // 511
            get_cover_statistics_dpi(cover_info[index].get_sva_name(),
                                     nof_attempts_failed_covered,      // 512:72
               nof_attempts_successful_covered);                       // 513:16
```

Both of those arguments are two control bodies down and golden leaves them
**BARE**, while `control_assertion_dpi(…, a_sim_time)` at `383:56` in the same
file, at depth 0, is golden **BOUND**.  § `controlBodyNoBind28` — the gate that
draws that line in our emitter — is itself written
`curSubClassScope9 && !curSubOob9 && ctrlBodyDepth28 > 0`, so **in an interface
home the depth gate cannot fire at all**.  A home-blind window would have been a
bind with no depth gate: precisely the mistake r10uvm165 was written to fix.
The window is therefore raised only where the silence it lifts exists.

Where the flag is clear the arm already binds what the ordinary path binds —
arm B (`g176_b_home.sv`) measures all seven homes on one golden, DEF view:

| home | cell | golden | pristine | patched |
|---|---|---|---|---|
| in-body method of a `$unit` class | `c_unit_inbody` | BOUND | BARE | **BOUND** |
| in-body method of a PACKAGE class | `c_pkg_inbody` | BOUND | BARE | **BOUND** |
| OUT-OF-BODY method (function) | `c_pkg_oob` | BOUND | BOUND | BOUND |
| OUT-OF-BODY method (task) | `c_pkg_oobtask` | BOUND | BOUND | BOUND |
| a MODULE function, interface PORT receiver | `c_mod_fn` | BOUND | BOUND | BOUND |
| a module `initial` block | `c_mod_proc` | BOUND | BOUND | BOUND |
| an INTERFACE's own function | `c_iface_fn` | BOUND | BOUND | BOUND |

(`c_iface_fn` is arm B's one-sided pair: the bind AGREES on both binaries and
only the HOME container differs — golden parents the function at
`interface_inst`, we at `module_inst`.  A parenting residue owned by neither
this law nor this pass; `VpiParent` is read by no generated `Compare`
(RESUME.md §9).  Arm D's `a_oper` (the REF family) is the ninth cell the DEF
grid moves, which is why arm D scores REF TOGOLD 9 against ARG TOGOLD 8.)

---

## 6. THE ARGUMENT-KIND AND DEPTH GRID — WHAT MOVES AND WHAT MUST NOT

Arm D (`g176_d_arg.sv`), one golden, DEF view, one receiver spelling throughout:

| cell | written | control depth | golden | pristine | patched |
|---|---|---|---|---|---|
| `a_formal0` / `a_local0` | `pipe176.take176(kilo176, lark176)` | 0 | BOUND / BOUND | BARE / BARE | **BOUND / BOUND** |
| `a_formal1` / `a_local1` | the same names inside `if … begin` | 1 | BARE / BARE | BARE / BARE | BARE / BARE |
| `a_formal2` / `a_loopvar2` | inside `if` then `for` | 2 | BARE / BARE | BARE / BARE | BARE / BARE |
| `a_formal1b` / `a_blk1` | a local declared IN the block that raised the depth | 1 | BARE / **BOUND** | BARE / BARE | BARE / **BOUND** |
| `a_formal0b` / `a_blk0` | a bare `begin` (raises no depth) | 0 | BOUND / BOUND | BARE / BARE | **BOUND / BOUND** |
| `a_formal_nb` / `a_blk_nb` | a NAMED block | 0 | BOUND / BARE | BARE / BARE | **BOUND** / BARE |
| `a_fork` | a `fork … join_none` arm | 0 | BOUND | BARE | **BOUND** |
| `a_while1` | a `while` body | 1 | BARE | BARE | BARE |
| `a_prop` / `a_static` | a class PROPERTY and a STATIC property | 0 | BARE / BARE | BARE / BARE | BARE / BARE |
| `a_param` | a class PARAMETER | 0 | BARE | BARE | BARE |
| `a_oper` | a formal INSIDE an expression, `pipe176.take176(42, romeo176 + 1)` (an `operation`, so it has no ARG row of its own — read in the REF family) | 0 | BOUND | BARE | **BOUND** |
| `a_concat` | a CONCATENATION operand, `pipe176.one176({sierra176[15:0], sierra176[31:16]})` (both operands) | 0 | BARE | BARE | BARE — § `ClassArgBindOff12` zeroes the counter, and golden agrees |
| `a_nested_arg` | `pipe176.one176(helper176(tango176))` | 0 | BOUND | BARE | **BOUND** |
| `a_pkgvar` | `pipe176.one176(store176::shelf176)` | 0 | BARE | **BOUND** | **BOUND** (residue R5 — wrong before and after; this law does not touch it) |

`a_blk1` is the one that a depth-only reading would have got wrong, and the
CORPUS agrees with the arm: `svaunit_vpi_interface.sv:467/482/498` bind the
`foreach`-block local `enable_sva` while leaving the FORMAL `a_test_name` bare
in the very same call — § `blockLocalSameCtrlDepthArgBinds57/64` reading this
window through `blkLocalWindowBind64`.

Arm A (`g176_a_face.sv`) is the FACE plus its neighbours: five cells move
(a vif FUNCTION call and a vif TASK call with a formal, with a body local, and
two in one task), and the receiver-less call, the class-handle call, the
EXPRESSION-position vif call and the class-handle EXPRESSION call are all
unchanged and already agree.  The whole arm's ARG family reaches **DIFF 0**.

---

## 7. THE CENSUSES

**Whole-corpus FACE** (`wface176.sh`, `WFACE.r10uvm176.txt`) — every argument
reference of a `method_func_call`/`method_task_call` that carries a vpiPrefix and
NO link, over ALL 956 comparable surelog databases and ALL 1358 uhdm2rtlil
databases, BOTH SIDES:

```
surelog : golden FACE cells 32681   FACEDIFF 142 -> 138
          MOVED=4  TOGOLD=4  AWAY=0  MOVEDWRONG=0
          cells where GOLDEN BINDS and WE DO NOT (pristine): 34 — ALL in MiniAmiq,
            17 per mode = 2 this law owns + 15 residue R1 (an INTERFACE's own subroutine)
u2r     : golden FACE cells 4 (all in `iface_method_call`), FACEDIFF 0
```

**Nine UVM row-modes, EVERY family** (`cen176.sh`, `CENSUS.r10uvm176.txt`) —
1 352 918 census rows per binary, golden rows verified identical across the two
runs:

```
ARG  keys golden=114044 ours=114190 | disagreeing 14512 -> 14508 | MOVED=4 TOGOLD=4 AWAY=0 MOVEDWRONG=0
REF  keys golden=461077 ours=458277 | disagreeing 48701 -> 48697 | MOVED=4 TOGOLD=4 AWAY=0 MOVEDWRONG=0
OBJ  keys golden=812    ours=810    | disagreeing   343 ->   343 | MOVED=0
```

The four movers are named in full in `CENSUS.r10uvm176.txt`; they are the two
sites × two modes.  **OBJ MOVED=0** is the statement that nothing was created,
destroyed or re-typed.

---

## 8. THE GATES (`GATES.r10uvm176.txt`)

* build both, md5s recorded; **-j 2 only**, md5 taken separately.
* 23 golden dump tests: pristine **23/0**, patched **23/0**, `SLANG_UHDM=/bin/false`
  **0/23** (the negative control).  `SLANG_UHDM` exported EXPLICITLY to each binary.
* uhdm2rtlil, testflags: `CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2`;
  `ct8rows` **PASS** against `results/gate_uhdm2rtlil.csv` and against this pass's
  own pristine sweep, testflags **and** default.
* surelog, `--mode both`: `ct8rows` **PASS** against `results/golden_surelog.csv`
  and against this pass's own pristine sweep — **0 differing rows over 1588**,
  status AND dump column.  **No row converted.**
* byte movers: §MOVERS above; `SELFCHECK` 955/956 and 1357/1358 flagged.
* canaries `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); `ctcan2`
  PASS ×2; `canaudit` PASS; the protected databases byte-identical by name, with
  `SVSwitch 4842211c4030` and `YosysVerx 6ccda350c24a` on the pin.
* every sweep and every arm ran a FROZEN binary at an immutable path and every
  `cmds.txt` was audited BY BINARY PATH: **0** of 1573+1358 name the main-tree
  binary.
* every arm command's `rc` is recorded in its `cmds.txt`; the only non-zero rc in
  the grid is Surelog's own `rc=4` on arm C, which is the `s_scoped` cell's
  `CP0332` and is reported as such in §4.

---

## 9. THE BOUNDARY AND THE FLOOR

```
LISTED=4860 FENCED_SKIPPED=0 PROCESSED=4860 MOVED=6 NO_OUTPUT_PAIRS=380
PROCESSED-ASSERT-OK
```

All six moved arm-views are this pass's own `g176_*.sv` — the positive control
that proves the gate can see.  `ASYMMETRIC_OUTPUT` is **0**, the reading that
would convict a crash introduced here.  Not one arm of r10uvm175, r10uvm172,
r10uvm171, r10uvm170, r10uvm165, r10uvm164, r10uvm161, r10uvm124, r10uvm89,
r10uvm77-79, r10uvm82-91, r10buvm3-15 or r10sd8-12 moved.

---

## 10. R0 — THE NEXT HEAD ON THIS ROW

**MiniAmiq default and testflags, 33 cmp lines, ONE head each, the two logs
BYTE-IDENTICAL** (md5 `4ac698a7142f`).  It is the MIRROR of the head this pass
cleared, so it was decoded with r10uvm165's mirror owner-finder
(`OWNER.next.r10uvm176.txt`):

```
HEAD LHS(golden) = <null>
HEAD RHS(ours)   = constant()@368:36-368:48#181751     ("32'h04c11db6", under a param_assign)
MIRROR REFERENCE SCAN — every edge of OURS that lands on the head, and golden's:
  ours   param_assign()@368:11-368:48   edge vpiType=82 (singular)
      golden param_assign()@368:11-368:48 -> singular constant()@368:36-368:48     (PRESENT both sides)
  ours   ref_obj(UVM_STR_CRC_POLYNOMIAL)@385:21-385:43   edge vpiType=700 (singular)
      golden ref_obj(UVM_STR_CRC_POLYNOMIAL)@385:21-385:43 -> singular <null>      <-- THE EDGE
  ours   ref_typespec()@0:0-0:0        edge vpiType=81 (singular)
      golden ref_typespec()@0:0-0:0 -> singular constant()@368:36-368:48           (PRESENT both sides)
```

Site, `uvm-1.2/src/base/uvm_misc.svh:368` and `:385`:

```systemverilog
parameter UVM_STR_CRC_POLYNOMIAL = 32'h04c11db6;               // 368
function int unsigned uvm_oneway_hash ( string string_in, int unsigned seed=0 );
  …
  for (int _byte=0; _byte < string_in.len(); _byte++) begin    // 378
     for (int _bit=0; _bit < 8; _bit++) begin                  // 381
        if (msb ^ current_byte[_bit]) begin                    // 384
           crc1 ^=  UVM_STR_CRC_POLYNOMIAL;                    // 385  <- col 21
```

**A PACKAGE-LEVEL `parameter` REFERENCED FROM A PACKAGE FREE FUNCTION'S COMPOUND
ASSIGNMENT BINDS ITS `vpiActual` TO THE FOLDED CONSTANT ON OUR SIDE AND IS NULL
ON GOLDEN'S.**  The `param_assign::Rhs` and `ref_typespec::Actual_typespec` edges
hold that constant on BOTH sides, so nothing is missing and nothing is
mis-shaped: the head is ONE singular `ref_obj::Actual_group`.

**AND IT IS THE HEAD SeqDriver×2 ALREADY CARRIES.**  MiniAmiq's new cmp log and
SeqDriver's differ only in ids and in the package name on the `ref_typespec`
(`svaunit_pkg` vs `uvm_pkg`) — same object, same 33 lines, same edge.  One law
clears two rows.

**AND THE RULE IS NOT "NEVER BINDS".**  The same mirror scan run on SeqDriver
shows golden holding **two** copies of that reference, one BOUND to the constant
and one NULL:

```
  ours   ref_obj(UVM_STR_CRC_POLYNOMIAL)@385:21-385:43#1255
      golden …#2598  -> singular constant()@368:36-368:48#2494      <- BINDS
  ours   ref_obj(UVM_STR_CRC_POLYNOMIAL)@385:21-385:43#4088
      golden …#120067 -> singular <null>                            <- DOES NOT
```

so the next law is **WHICH COPY BINDS** — the DEF listing's, the elaborated
one, or a wildcard-import clone's — not a blanket suppression.  Direction:
SUPPRESS, gated.  The natural instruments are this pass's `ct176cen` (its REF
family is already keyed by HOME, and `--face` is not wanted here) and
r10uvm165's mirror owner-finder.  Note that r10uvm175's and this table's earlier
framing of the SeqDriver head as a `ref_typespec` difference is REFUTED by that
scan and is corrected in `RESUME.md` §3b with this landing.

---

## 11. RESIDUES, ranked

* **R1 — a call inside an INTERFACE's OWN SUBROUTINE leaves its arguments bare
  where golden binds them.**  FIFTEEN face cells per MiniAmiq mode, named in
  full in `WFACE.r10uvm176.txt`: `a_sva.set_enable(a_test_name, enable_sva)` at
  309/333/357/382/407/433 (both arguments) and
  `sva_info[index].set_enable(…, enable_sva)` at 467/482/498 (the block local
  only), plus `call_callback_dpi(a_test_name)` at 123:25 and
  `control_assertion_dpi(…, a_sim_time)` at 383:56, which are a different SHAPE
  as well (golden builds a linked `func_call`, we build a `method_func_call`).
  These are NOT this arm — `set_enable` is a CLASS method, so they go down the
  class-receiver arm — and they are silenced by a different disjunct of the bind
  gate, which is why the home-blind intermediate binary did not move them
  either.  It is the largest single remaining cluster in MiniAmiq's ARG family
  and it is a pass of its own.
* **R2 — the receiver ref's NAME in this arm.**  Golden strips a subscript
  (`bank176[1]` → `bank176`) and trims whitespace (`plain176 . poke176` →
  `plain176`); we write the raw text before the last dot.  Arm C `s_index` and
  `s_spaced`; **zero corpus cells** (every corpus receiver here is one plain
  name).  It is why the DEF grid scores MOVED-WRONG 2 on the full key and 0 on
  the position key — the `vpiActual` in both cells lands exactly on golden's.
* **R3 — a `this.`-rooted receiver.**  Golden's object is a `method_func_call`
  NAMED `this` with a STRING-constant prefix; ours is named after the METHOD with
  a `this.<name>` prefix ref.  Arm A `c_this_vif`, arm C `s_this`; **zero corpus
  cells**.  It became arm A's DEF head after this law cleared arm A's own cell,
  and it belongs to § `thisRecvCall11` / r10uvm84-85's family.
* **R4 — a TWO-NAME receiver (`a.b.meth()`).**  Golden builds no such call at
  all — `compileTfCall`'s dotted arm needs a single StringConst — and we build a
  `method_func_call` with a dotted prefix.  Arm C `s_deep`; **zero corpus cells**.
* **R5 — a PACKAGE variable as an argument** (`pipe176.one176(store176::shelf176)`,
  arm D `a_pkgvar`): golden BARE, ours BOUND, before AND after.  Pre-existing;
  this window cannot change it (the window only ADDS, and the cell is already
  bound).
* **R6 — a measurement note, not a defect of this law.**  In the ELAB view our
  database carries the class DEFINITION's method AND its elaborated copy where
  Surelog's `--elabuhdm` output carries one, so an arm cell reads
  `{BARE:1, BOUND:1}` against golden's `{BOUND:1}` before this law and
  `{BOUND:2}` after.  `score176.py --set` collapses that multiplicity; the DEF
  view needs no collapse and is scored as a multiset.

---

## 12. FILES

| file | role |
|---|---|
| `g176_a_face.sv` | arm A — THE FACE and its neighbours (call kinds, positions, depth, multiplicity, the class/receiver-less controls) |
| `g176_b_home.sv` | arm B — the seven HOMES ($unit / package / in-body / out-of-body / module fn / module process / interface fn) |
| `g176_c_recv.sv` | arm C — the RECEIVER SPELLINGS and the two DECLINES |
| `g176_d_arg.sv` | arm D — the ARGUMENT KINDS and the CONTROL-BODY DEPTHS |
| `grid176.sh` | the arm driver — golden + both binaries, both views, every rc, the official judge on each arm-view |
| `ct176cen.cpp` | the census (`Serializer::AllObjects`): ARG / REF / OBJ families, `--face`, `--nospan` |
| `cen176.sh` | the census over a `verify_golden` workdir, both sides, row folded into the key |
| `wface176.sh` | the LAW'S FACE over a whole workdir, both sides, with the mover columns |
| `predict176.sh` | the A-PRIORI mover prediction from pristine databases alone |
| `score176.py` | the multiset join and the scoring columns (`--drop=RECV`, `--set`) |
| `ct176own.cpp` | the owner-finder (r10uvm175's, verbatim) — the judge decode and the REFERENCE SCAN |
| `bound176.sh` | the WIDE boundary gate |
| `byteverify.sh`, `ct8rows.sh`, `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `rowheads.sh` | the gates |
| `GATES/CENSUS/WFACE/GRID/BOUNDARY/MOVERS/PREDICT/OWNER*.txt` | the evidence |
| `head_pris_MiniAmiq.*.cmp`, `head_pat_MiniAmiq.*.cmp` | the head, before and after |
