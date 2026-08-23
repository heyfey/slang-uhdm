# r10v103 — ADVERSARIAL VERIFICATION of r10uvm103 (§ `invalidShellKeepsStmtPos103`) — **ACCEPT AS SHIPPED**

**MEASUREMENT ONLY.** Nothing in this directory is an acceptance judge. The
official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted**;
**no corpus row converted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `ecdded75` |
| worktrees | `/tmp/wt_v103` (patched), `/tmp/wt_v103pris` (pristine) |
| pristine binary | md5 `9ae62f2d6a19f72cf5cb259847914b9a`, frozen `chmod 555` |
| patched binary | md5 `345863eda3e6135f471565542c866c9f`, frozen `chmod 555` |
| production surface reviewed | `src/ExprEmit.cpp` ONLY — the `case ExpressionKind::Invalid` child unwrap |
| verdict | **ACCEPT AS SHIPPED** — no production change made by the verifier |

Both md5s were rebuilt from scratch in the verifier's own worktrees and
**reproduce the implementer's two binaries byte for byte**, so the build is
path-independent and every number below is a re-measurement, not a re-reading.

## 1. What was re-measured (every headline number, independently)

| claim | implementer | verifier | verdict |
|---|---|---|---|
| pristine binary md5 | `9ae62f2d…` | `9ae62f2d…` | REPRODUCED |
| patched binary md5 | `345863ed…` | `345863ed…` | REPRODUCED |
| golden dump tests, each binary | 23/0, 23/0, `/bin/false` 0/23 | same | REPRODUCED |
| u2r ct8rows (tf + def, status AND dump) | PASS | PASS | REPRODUCED |
| u2r byteverify | MOVERS 0/1358, SELFCHECK 1357/1358 | same | REPRODUCED |
| surelog ct8rows, 1588 rows | PASS, 0 differing | PASS, 0 differing | REPRODUCED |
| surelog status histogram | CMP_NOTEQUAL 10 / 9, unchanged | identical, pristine and patched | REPRODUCED |
| surelog byteverify | MOVERS 9/956, SELFCHECK 955/956 | same nine, no others | REPRODUCED |
| head SimpleUVM ×2, Scoreboard/default | 108 → 22, 1 head | 108 → 22, 1 head | REPRODUCED |
| heads SeqDriver / MiniAmiq / BuildUVMPkg / Earlgrey / Rggen | 17 / 348 / 72 / 46 / CMP_EQUAL, unchanged | identical | REPRODUCED |
| committed `head_pris_*.cmp`, `head_pat_*.cmp` | — | byte-identical to the verifier's own cmp logs (ids stripped) | REPRODUCED |
| golden-vs-golden calibration, surelog | 1516 goldens, 322 533 HPCALL, POS=STMT **0** | 1562 named − 46 absent, **322 533** HPCALL, POS=STMT **0** | REPRODUCED |
| golden-vs-golden calibration, u2r | 1460 goldens, 20 HPCALL, POS=STMT **0** | identical | REPRODUCED |
| the fossil, ours | pristine 29 rows / 9 DBs → patched **0 / 0** | identical, and the DB set matches the committed prediction file exactly | REPRODUCED |
| canaries / ctcan2 / canaudit | 52+8 ok, PASS/PASS, audited=29 UNCOVERED=0 FENCE-BREACH=0 | identical | REPRODUCED |
| byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort / BlackParrotComplex / YosysOldOr SAME | identical, both modes | REPRODUCED |
| boundary, file/def, file/elab | 3254 arms, DIFFER=5 | 3259 arms (＝3254 + the verifier's 5), DIFFER=**10** ＝ the same 5 + the verifier's own 5 | REPRODUCED |
| boundary, dir/def, dir/elab | 1471 dirs, DIFFER=4 | 1472 dirs, DIFFER=**5** ＝ the same 4 + the verifier's own dir | REPRODUCED |
| `r10uvm75repro` / `r10uvm76repro` dir-mode difference | the parallel-parse coin | CONFIRMED: sorted dumps identical, and **four pristine runs give four raw hashes that all sort to one** (`f68c1dd03555`) | REPRODUCED |

`cmds.txt` was audited BY PATH in all four sweeps: 1458 u2r invocations name only
`/tmp/v103_bin/{pris,pat}.bin`, 1523 surelog invocations likewise; **no
main-tree binary appears anywhere.** `SLANG_UHDM` was exported explicitly per
binary; every arm cell records its own rc.

## 2. Independent direction check — OWNER-KEYED CENSUS ON THE REAL TARGETS

`cell103v.py` parses a whole `uhdm-dump` into a tree and emits ONE row per
`function`/`task` owner: the `vpiStmt` / `vpiStmts` subtree rendered with
**Compare-visible material only** — object kind, `vpiName`, `vpiDefName`,
`vpiDecompile`, `vpiValue`, `vpiOpType`, `vpiConstType`, `vpiSize`,
`vpiDirection` and the field each child hangs off. **No span, no file, no
`vpiFullName`, no `vpiParent` back-reference subtree**, so a golden row and an
ours row are directly comparable and the DEF/ELAB view stays out of the key.
`score103v.sh` labels every owner TOGOLD / AWAY / STILL / MOVED? / SAME.

Run over the **whole database** of all four surelog movers (default mode):

| database | owners | SAME | STILL | TOGOLD | **AWAY** | MOVED? |
|---|---|---|---|---|---|---|
| SimpleUVM | 1183 | 808 | 373 | 0 | **0** | 2 |
| BuildUVMPkg | 1264 | 885 | 375 | 3 | **0** | 1 |
| MiniAmiq | 1384 | 764 | 618 | 0 | **0** | 2 |
| SeqDriver | 1183 | 636 | 545 | 0 | **0** | 2 |
| Scoreboard (the COIN row) | 1198 | 825 | 371 | 0 | **0** | 2 |

The `MOVED?` owners are exactly the ones the law names, and each was then read
out in full:

* `uvm_pkg::uvm_algorithmic_comparator::write` (uvm-1.2 `:131`, and the
  pp_output `:50754` twin) — patched is
  `method_func_call (before_export) [vpiPrefix ref_obj (…::write::comp)]`,
  **BYTE-IDENTICAL to golden's whole `function::Stmt` subtree**, in SimpleUVM
  and in BuildUVMPkg.
* `uvm_pkg::uvm_utils::get_config` (uvm_misc.svh `:720` / `:725`) — patched
  replaces the `hier_path (comp.uvm_report_warning|fatal)` with
  `method_func_call (uvm_report_warning|fatal)` + `vpiPrefix ref_obj (comp)`,
  which is golden's carrier. The residual differences under it (an empty-string
  constant, a `0` constant, and an `operation` that loses its `FIELD` /
  `TYPE::type_name` operands) are **byte-identical in the pristine database** —
  pre-existing, § `typeParamScopedCallRef59`'s family, not this pass's.
* BuildUVMPkg's three TOGOLD owners — `initialize`, `set_inst_override`,
  `set_type_override` (pp_output `:14073` / `:14088` / `:14125`).

Order-blind byte attribution (sorted, workdir-normalised, `id:` stripped) of all
nine movers: 8 databases carry **64** indent-blind changed lines at uvm-1.2
lines **131 / 720 / 725**; the two BuildUVMPkg rows carry **76** at pp_output
**14069 / 14070 / 14073 / 14076 / 14077 / 14088 / 14125 / 50754**. Nothing else
in any database changed, and Scoreboard/default's sorted diff is
**line-for-line identical to SimpleUVM's**, so the `vpiTaskFunc` coin
contributed nothing.

## 3. BREAKING THE LAW — the adversarial grid (arms/, 9 files, both views)

Every cell is a statement whose expression slang wraps in a bad-expression
shell. `score103v.sh` scored each arm against a freshly built Surelog golden in
**both** views. **AWAY = 0 in every arm, in both views.**

| arm | what it varies | def | elab |
|---|---|---|---|
| `v103_b1.sv` | components 2/3/4/5; receivers class handle / `this.` / `super.` / class static / element-select / call-valued index; 0/1/3 args; NAMED args; `void'()`; expression position | SAME 22 TOGOLD 12 STILL 1 MOVED? 1 **AWAY 0** | identical |
| `v103_b2.sv` | HOMES: in-body function, in-body task, OUT-OF-BODY function AND task, static method, `if` / `for` / `case` arm, named `begin`, `fork…join_none`, `#1` delay, class in a module / program / interface | SAME 14 TOGOLD 9 STILL 6 MOVED? 1 **AWAY 0** | identical |
| `v103_b3.sv` | `$display` / `$write` / `$sformat` / `$fwrite` / `$cast`; BUILT-IN methods `push_back` / `delete` / `itoa`; the function-return-variable receiver (`retNameRecvCollapse69`); bare undotted call; `void'()`; expression positions (Rhs, condition, ternary, return, call arg) | SAME 30 TOGOLD 6 **AWAY 0** | identical |
| `v103_b4.sv` | virtual interface handle, virtual interface ARRAY element, interface task; the buvm23 `with`-clause carve-out; the SAME generic class left at its default specialisation AND specialised 3× with a class that binds | SAME 17 TOGOLD 1 STILL 2 MOVED? 2 **AWAY 0** | identical |
| `v103_b5.sv` | shells whose child is NOT a `Call` — BinaryOp / `&&` / Assignment / MemberAccess / ElementSelect / Concatenation; chained `a.b().c()`; trailing member; receiver through the type parameter; index expression | SAME 15 TOGOLD 1 STILL 11 **AWAY 0** | SAME 14 STILL 12 TOGOLD 1 |
| `v103_c1_vifbind.sv` | NEGATIVE CONTROL — virtual-interface calls with a BINDABLE argument | **databases byte-identical** between the binaries | identical |
| `v103_c2_syscall.sv` | NEGATIVE CONTROL — five system calls with an unbindable argument | **databases byte-identical** (`823c28795b8b…`), every cell already golden | identical |
| `v103_c3_nested.sv` | two unbindable pieces in one argument list; unbindable receiver AND argument; nested dotted read; call as an assignment Rhs | SAME 15 TOGOLD 2 STILL 2 **AWAY 0** | identical |
| `v103_c4_vifprefix.sv` | POSITIVE CONTROL for residue **R-V** below | MOVED? 2 SAME 17 STILL 1 **AWAY 0** | identical |
| `v103_c5_slots.sv` | EMPTY argument slots (buvm24 § `emptyArgSlotIntZero24`) and `void'()` over a dotted call, both inside a shell | SAME 18 TOGOLD 2 MOVED? 1 **AWAY 0** | identical |

Cells worth naming, because they are golden answers this campaign had not
recorded before:

* `C2` `el.put(tp.conv(kk))` — 2 components, unbindable argument: golden KEEPS
  the argument (`mfc put` / prefix `el` / arg). Patched matches byte for byte.
* `T2`/`T3` `this.el.put(…)` — golden is `method_func_call` **named `"this"`**
  with an unparented STRING constant `"this"` as prefix (the `thisRecvCall11`
  shape), and the argument survives only in the 2-component spelling. The
  PRISTINE binary emitted a **bare `constant "this"` as the whole statement**;
  patched matches golden exactly. Two owners recovered that no one had claimed.
* `Zps` `bo.farm[2].put(bad)` — golden's ARGUMENT is the INDEX `2`
  (`compileTfCallArguments` compiling the `Constant_bit_select`'s child). Patched
  matches byte for byte; the implementer's decode of `a.b[1].c(x)` is confirmed
  on an independent spelling.
* `ST` `Leaf1::sput(bad)` — golden emits a **bare `ref_obj (Leaf1::sput)`** as
  the statement. Both binaries emit `func_call (sput)` with the argument.
  UNCHANGED by the patch (STILL); a new, measured, unclaimed residue.
* `Htim` `#1 bo.slot.put(bad)` — the timing-control precedent holds and the cell
  moves TO GOLDEN.

## 4. RESIDUES the verifier measured (ranked)

**R-V — NEW-IN-PATCHED garbage `vpiPrefix` name on a VIRTUAL-INTERFACE
statement call whose argument does not bind.** Arm `v103_c4_vifprefix.sv`,
both views:

```
written   vif.ifun( tp.conv(kk) );                 // tp : unspecialised type param
GOLDEN    method_func_call (ifun) [ arg, vpiPrefix ref_obj (…::R1::vif)  vpiName=vif ]
PRISTINE  hier_path (vif.ifun) [ … ]                                  ← wrong VpiType
PATCHED   method_func_call (ifun) [ arg, vpiPrefix ref_obj  vpiName=`vif.ifun( tp` ]
```

The prefix's `VpiName` is raw source text sliced from the receiver's start to
the first token slang could not bind: `vif.ifun( tp`, and
`vif.ifun2( kk, tp` for the two-argument spelling. Origin:
`std::string recvText = rawText(recv->sourceRange)` at `src/ExprEmit.cpp:16946`
— inside a bad-expression shell slang gives `call.arguments()[0]` (the receiver)
a source range that runs past the receiver, and this arm slices it verbatim.

**It is NOT a regression and NOT corpus-visible.** Pristine was already wrong
here (wrong `VpiType`, the FIRST test in `BaseClass::Compare`); patched now
matches golden on `VpiType`, `VpiName` and the whole argument subtree and fails
one level deeper, on a sub-object's name — strictly closer. The defect **PRE-DATES
this pass**: the element-select spelling `varr[1].ifun(bad)` carries the
identical garbage in the PRISTINE binary (`v103_b4.sv` cell `W2`, scored STILL),
and with a BINDABLE argument the same call is byte-perfect in both binaries
(`v103_c1_vifbind.sv`, databases byte-identical). No corpus database reaches the
shape: the nine movers' new prefixes are the clean `comp` / `factory`, and both
fences read 0/0 after the patch. Fixing it means teaching that arm to distrust
`rawText` inside a shell, which touches a path carrying
§ `thisStmtHandleCall85`, § `builtinRecvIndexedStepIsBitSelect74` and
§ `dottedIdxRecvFromSyntax23` — a deliberate pass, not a verifier edit.

**R-S′ — the `super.` cell now changes shape.** The implementer's R-S records
golden's answer for `super.<member>.<method>()`; the verifier adds that the
PATCH ITSELF moves the cell when the argument does not bind (arm `v103_b1.sv`
cell `S3`): pristine `hier_path (super.bmid.slot.put)` → patched
`method_func_call (slot)` + `vpiPrefix ref_obj (bmid)`; golden is
`method_func_call` **named `"super"`** with an unparented STRING constant
`"super"` as prefix. Patched clears `VpiType` and fails on `VpiName`; the
`"super"` token, which the pristine `hier_path` name-text at least carried, is
now gone. Not corpus-visible (no mover carries a `super.`-rooted site). This
raises R-S from "measured but corpus-masked" to "measured AND now half-modelled",
which strengthens the implementer's case for taking it next.

**R-E — the empty-argument-slot list, now REACHABLE by the judge.** Arm
`v103_c5_slots.sv` cell `E2`, `el.p3( , , tp.conv(kk) )`: golden's
`Tf_call_args` is TWO entries — ONE `constant` with `vpiConstType=7` standing for
the omitted slots, then the argument — where ours substitutes the two DEFAULT
values and lists THREE. The argument list is **byte-identical pristine and
patched** (§ `emptyArgSlotIntZero24`'s family, pre-existing); what changes is
that pristine hid it under a `hier_path` whose `VpiType` failed first, and
patched now matches on `VpiType`/`VpiName`/`vpiPrefix` so the vector reaches the
judge. That is the campaign's normal "the head gets deeper" motion, not a
regression — but it is the one place where this pass makes a pre-existing defect
newly judge-reachable, so it is named here.

**R-ST — `<class>::<static_method>(args)` in statement position.** Golden emits a
bare `ref_obj` named `Leaf1::sput`; both binaries emit a `func_call` carrying the
argument. Unchanged by this pass, previously unrecorded.

**R-N — module / program / interface-nested classes are absent from our DEF
listing entirely** (`v103_b2.sv` owners `Mfun`, `Moob`, `Pfun`, `Ifun`:
`<absent>` in both binaries, present in golden). Pre-existing, unrelated, and
large.

## 5. Instrument notes (traps found, for the next verifier)

* `bound103.sh` in `MODE=dir` derives an EMPTY scratch key for the `.` entry
  (`tools/probe` holds 7 top-level `.sv` files), so that arm's databases land in
  `$OUT` itself and the cleanup prints `rm: refusing to remove '.'`. The arm IS
  still compiled and compared — the reading is sound — but the message is not a
  failure and must not be read as one.
* `r10uvm103cen.cpp` walks `Serializer::AllObjects` (uvm97's trap: an ALIASED
  census row can name an object that is not in the dump tree). Its two claims
  were therefore re-validated against instruments that only ever see reachable
  objects: the official `uhdm-cmp` heads, `byteverify`, and the dump-tree
  census in this directory. All three agree.
* `verify_golden.py` and `tests/check_goldens.sh` silently default `SLANG_UHDM`
  to the MAIN TREE binary — which at the time of this verification was built
  from a DIRTY tree (uvm102's in-flight `src/ParamEmit.cpp`), md5
  `4e1d739b…`, i.e. **not** an `ecdded75` binary. Exporting per binary and
  auditing every `cmds.txt` by path is what keeps that out of the numbers.
* `/tmp/ctl_*_91a158a` are controls for a DIFFERENT head and were not used;
  the verifier built its own pristine sweeps at `ecdded75`.

## 6. FILES

```
README.md              this file
GATES.txt              the whole re-run battery with its numbers
cell103v.py            owner-keyed, Compare-visible dump-tree census
score103v.sh           TOGOLD / AWAY / STILL / MOVED? per owner vs a golden
grid103v.sh            builds one arm's three databases in both views (rc per cell)
attr103v.sh            order-blind per-database mover attribution
arms/v103_b1..b5.sv    the adversarial grid
arms/v103_c1..c5*.sv   two negative controls, three positive controls
```
