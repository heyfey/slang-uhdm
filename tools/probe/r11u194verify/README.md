# r11u194: second adversarial verification of passes 184 and 186 (verifier; measurement plus two refinements in fix.patch)

Base `706ab521` (branch matrix-1.87). Pass 184 (the expression/parameter ground: nine laws of r11u184 and r11v184's two
refinements) landed at `44393367`; pass 186 (the module/type ground: the thirteen r11u183 ground-B laws, seven r11u186
laws and four refinements) landed at `c168c209`. On top of them sit the verification r11u190 (`1a91673d`), pass 187
(`a1c89c1a`, the r11u183 ground-A laws), pass 188 (`6ab9f4fb`) and the r11u191 decode (`706ab521`, tools only).
Worktree `/tmp/wt_r11u194` (system-deps configuration, `-j 2`, `-j 1` when memory ran below 6 GB); scratch
`/tmp/r11u194_*`.

This directory is the deliverable. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is edited,
and `tools/uhdm-strictcmp/` is not edited (no comparator defect was found). The two refinements are
[fix.patch](fix.patch), a `git diff 706ab521 -- src` (`src/ExprEmit.cpp`, `src/ParamEmit.cpp`) that applies clean on a
fresh `706ab521` and on pass 192's `b6344400`; it is NOT applied here.

The brief speaks of "the canonicalisation patch you were given". No such patch was handed to this pass.

The cases name their laws in their first line (`// § law`), so `tests/LAWS.md` reads STALE in every sweep here. A clean
`706ab521` checkout reads STALE too (`python3 scripts/law_index.py --check` in a fresh worktree at the base:
`law index STALE`); it is the only red of every sweep below.

The slang-fenced tests are named nowhere in this directory (word-boundary scan of this directory and of r11u184repro,
r11v184repro, r11u186repro, v11u186repro: 0 files each; the positive control finds a planted name).
[drivers/env.sh](drivers/env.sh) resolves the repository from its own path, reads `$FENCED` from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and refuses to run without four names (negative control: a two-name line makes
it return 1). Every driver here that reads corpus sources or databases sources it and skips the four names by word
boundary. No gdb was used. Only the gate sweeps dispatched fenced rows.

## Verdict

**Two breaks, both refined in [fix.patch](fix.patch) behind their own switches. Every other law of the two landings
holds on 86 fresh cases in both views. The landings compose additively; no pair of laws cancels another's error. Every
CHANGE line of both integrations is a conversion, a strict subset or an unmasking. The downstream lanes are
byte-identical to golden's on every converted row.**

- **B1, § tpEnumCaBindsInstVar184v treats a PORT declared as a net of T as a net.** The refinement unparents the
  type-parameter enum copy only when a continuous assignment writes a VARIABLE of `T` declared in the child body
  (`ls.kind == SymbolKind::Variable`). A port declared with a net kind is a `Net` in slang: `output wire T so; assign
  so = si;` (T/t09), `inout wire T io` (t13), a non-ANSI `output wire T so;` (t14), `output wire T [1:0] so` (t12) and
  t05. Golden unparents the copy in every one of them (`vpiFullName:je_t`). The law without the refinement
  (`R11V184_TPCA_OFF`) writes `je_t` on t05, t09, t13 and t14; the refinement writes `work@top.v.T.je_t`. That is
  STAGE1-AWAY in both views, +4 golden-disagreeing dump lines per case-mode.
  - Decode: `NetlistElaboration::elabSignal` (third_party/Surelog/src/DesignCompile/NetlistElaboration.cpp 2050-2170).
    It first sets `isNet = true` for a net keyword. It then compiles the signal's typespec, and an `enum_typespec`
    (or a packed array of one) sets `isNet = false`. So the port lands in the elaborated instance's `Variables()`
    (golden `enum_var: (work@top.v.so)`, `packed_array_var` for t12), `bindVariable` finds it, and
    `writeCont_assign` unparents the typespec.
  - A BODY net `wire T w` stays a `logic_net` in golden (r11v184's vt12, and t10 here), which is why the refinement
    was right for body nets.
  - **Fix § tpCaPortNetIsVar194v** (`R11V194_TPCAPORT_OFF`; ParamEmit.cpp, inside the refinement's scan): a `Net` that
    is the internal symbol of one of the body's ports counts like a variable.
  - Result: t05, t09, t12, t13 and t14 reach golden's names in both views (10 case-modes; order-blind distance −4
    each, 0 golden lines lost). Body nets (t10, vt12), variable ports (t11, t15) and every r11u184/r11v184 T and X
    case keep their bytes.
- **B2, § incDecMemberSelIsLvalue184 gives a CALL ARGUMENT inside the operand's index the lvalue shape.** The law
  raises `inLhs` for the whole operand. A member select that is an argument of a call in the operand's index
  (`--s.g[ix(s.f[j])]`, I/i01 line 8; `s.f[ix(s.g[k])]++`, `++s.f[ix(ix(s.g[k]))]`, `s.f[$unsigned(s.g[k])]--`,
  `s.f[ix(s.g[k]) + 1]--` in I/i04; `s.f[pick(s.g[k])]++` and `s.f[o.pick(s.g[k])]--` in a class method, I/i05)
  therefore takes the lvalue shape: `s` at 8:16-17 and the bit_select at 8:16-20. Golden and pristine have the read
  shape: `s` at 8:14-15 on its own token and the bit_select at 8:18-19, at its index.
  - The dump judge ([dumpaway2.py](drivers/dumpaway2.py)) reads golden lines lost against `R11U184_INCDECSEL_OFF` on
    i01 (1 / 2 per view), i04 (6 / 12) and i05 (2 / 2). The chain-keyed record judge
    ([recaway2.py](drivers/recaway2.py)) reads away records on i04. The grid's record verdict hid it, because the
    law's other records move toward golden on the same cases.
  - Decode: `CompileHelper::compileTfCallArguments` (CompileHelper.cpp) compiles each argument afresh with
    `compileExpression`, outside the Variable_lvalue branch the operand goes through. This is the same mechanism as
    r11u190's B2.
  - **Fix § incDecSelCallArgRead194v** (`R11V194_IDCALLARG_OFF`; ExprEmit.cpp): the law records `callArgDepth` when it
    fires. emitExpr lowers `inLhs` for any expression emitted deeper in call arguments, or directly under a
    `func_call` / `method_func_call` / `sys_func_call` parent (a handle's method call emits its arguments without
    raising `callArgDepth`).
  - Result: i01 and i05 go to STRICT_EQUAL in both views. i04 goes col(8) -> fullname(3); the remaining records are
    the argument's index name `k`, the same on the law. The order-blind distances are i01 6 -> 0 / 12 -> 0,
    i04 60 -> 36 / 120 -> 72 and i05 12 -> 0, with 0 golden lines lost.

`R11V194_OFF` drops both; `R11U184_OFF` drops them too (they sit inside the pass-184 law branches).

**Fix measurements** (section 8):
- 16 case-modes move over 484 case-modes: every case here, r11u184repro, r11v184repro, r11u190verify ID/X/LC and
  r11u181repro im, both views. All 16 move toward golden with 0 golden dump lines lost.
- Each switch alone reverts exactly its own cases.
- The fix sweep reads 0/0/0 in every stage. `probe.csv`, `uhdm2rtlil.csv` and `downstream.csv` are byte-identical to
  HEAD's; `surelog.csv` equals HEAD's but the LowMem log-path texts.
- byteverify: 4 of 2560 corpus movers, all the UVM coin (0 predicted). 0 of 4087 probe movers. 0 of 805 downstream
  slang-lane movers.

**No other law of the two landings moves a field away from golden on fresh legal SV** (86 cases, 172 case-modes;
section 3):
- STRICT_EQUAL both-landings-off -> ON: default view 6 -> 29, `--elabuhdm` 7 -> 30.
- Judge-equal (uhdm-cmp): 38 -> 47 per view. No case leaves judge-equality.
- Field scoring over every aligned cell ([fieldscore.py](drivers/fieldscore.py)) reads FTOWARD or FSAME; the only
  FAWAY cells are ON against the fix state, i.e. B2 itself.
- Crashes: none caused by a law. X/x01 and Z/z01 segfault (rc 139) in `--elabuhdm` in EVERY switch state, WIDE
  included: residue N1.

**One hold-back, not a break** (H1, section 3.2):
- **The claim does not hold.** Pass 186 reported § typeParamUseSharesOwnTs183 and § classTpDefaultTsAtUse180
  "redundant". On TP/t03 they are not: order-blind distance 32 with neither law, 26 with pass 180 alone (HEAD), 12
  with the r11u183 law alone, 10 with both.
- **What the refinement costs.** § typeParamDefersToTpUse186 keeps the r11u183 law off while pass 180's is on, so HEAD
  writes four `class_typespec base` copies at the default tokens (5:27-31) where golden has one object. That is
  STAGE1-AWAY against `R11U186_TPDEFER_OFF`.
- **Why it is not a break.** The landing as a whole writes the pristine bytes there, and the deferral is pass 186's
  guard against the BuildUVMPkg order coin (r11u186 section 5). It is not refined here.

**Composition: additive; no pair of laws cancels another's error** (section 5):
- Status level: CANCEL 0 in all three stages.
- Byte level: CANCEL 0 over 6647 databases.
- The reconstructed historical states reproduce every committed count exactly:
  - `2b97649e`: 2895, 908, 1568;
  - `44393367` / `8e3153a2`: 2898, 908, 1574;
  - `c168c209`: 3026, 908, 1578;
  - pass 184's pristine `1eeff71d`: 2886, 455+451, 783+783;
  - `804e3b75`: 2880 (WIDE).
- `R11U183_OFF` spans both grounds; each ground's share is measured separately (section 5.2).

## 1. Binaries and states (frozen `chmod 555` in `/tmp/r11u194_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `law.bin` | `b912028331d23cb17d13344cd2b44d46` | worktree build of `706ab521` = the main tree's `build/slang-uhdm` (`b912028331d2`); rebuilt after fix1 with the sources reverted: the same md5 |
| `fix1.bin` | `35209ab5bd2e514e52da27f068c5e457` | + § tpCaPortNetIsVar194v alone (superseded) |
| `fix2.bin` | `14a4a47d5f82d676d1ba795d8dc9f118` | + § incDecSelCallArgRead194v without the call-parent branch (superseded; its sweep was stopped before the corpus stages, see section 10) |
| `fix.bin` | `d5385ee2ee382e0214df90bb49fa9d90` | `706ab521` + [fix.patch](fix.patch) (`6adcfc7dff772cdb480a872d34e0bb34`) |
| `uhdm-strictcmp` | `fa6e4f42f252ae0ab69d9845003e71c5` | = the main tree's `build/uhdm-strictcmp` |

State wrappers ([drivers/mkstate.sh](drivers/mkstate.sh)), all law.bin under switches:

| wrapper | switches | the state |
|---|---|---|
| `alloff.sh` | `R11U184_OFF R11V184_OFF R11U183_OFF R11U186_OFF` | both landings off (`R11U183_OFF` also drops pass 187's ground-A r11u183 laws) |
| `off184.sh` / `off186.sh` | `R11U184_OFF R11V184_OFF` / `R11U183_OFF R11U186_OFF` | one landing off |
| `off187.sh` / `off187T.sh` | `R11U187_OFF` / `R11U187_TRAILCALL_OFF R11U187_TRAILSEL_OFF` | pass 187 whole / its two naming laws only |
| `o187x183.sh` / `o187x186.sh` | `R11U187_OFF R11U183_OFF` / + `R11U186_OFF` | ground-B r11u183 share / pass 186 whole, on the 187-off base |
| `wide.sh` / `wideon.sh` | alloff + `R11U180_OFF R11V180_OFF R11U181_OFF R11V181_OFF R11U187_OFF R11U188_OFF R11V188_OFF R11V190_OFF` / the same list without the two landings | the brief's composition list |
| `pre184.sh` | alloff + `R11V190_OFF R11U187_OFF R11U188_OFF R11V188_OFF` | `2b97649e`, pass 184's integration base |
| `post184.sh` | `R11U183_OFF R11U186_OFF R11V190_OFF R11U187_OFF R11U188_OFF R11V188_OFF` | `44393367` = `8e3153a2`, pass 186's integration base |
| `post186.sh` | `R11V190_OFF R11U187_OFF R11U188_OFF R11V188_OFF` | `c168c209` |
| `s1eef.sh` | pre184 + `R11U180_OFF R11V180_OFF R11V185_OFF` | `1eeff71d`, pass 184's pristine base (process check) |
| `lawsoff.sh` | `R11U186_LAWSSORT_OFF` | determinism positive control |
| `s186tr.sh` | `R11U184_OFF R11V184_OFF R11V185_OFF R11V190_OFF R11U187_OFF R11U188_OFF R11V188_OFF` + `R11U183_TRACE`/`R11U186_TRACE` | pass 186's firing census at `a3a62624` + pass 186 (process check) |

## 2. Sweeps (`tests/sweep.sh --jobs 3`, [drivers/sweep.sh](drivers/sweep.sh), [drivers/queue.sh](drivers/queue.sh), queue2.sh, queue3.sh; `/tmp/r11u194_sw?`, same-length names)

Every sweep's 3273 corpus `slang:` lines name its own binary or wrapper
([evidence/sweeps_cmds_audit.txt](evidence/sweeps_cmds_audit.txt)). Every golden came from the cache (3273 of 3323 runs
served; the rest are the deferred and failing rows). Counts: [evidence/composition/state_counts.txt](evidence/composition/state_counts.txt)
([drivers/statecounts.py](drivers/statecounts.py)).

| sweep | state | probe EQUAL | surelog d+t CMP_EQUAL | u2r d+t | gate vs results/ |
|---|---|---|---|---|---|
| swH | law.bin, all four stages | 3137 (`probe.csv` byte-identical to `results/golden_probe.csv`) | 460+456 | 790+790 | **0/0/0** in every stage; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, not excused 0, `downstream.csv` byte-identical to `results/downstream_uhdm2rtlil.csv`; `uhdm2rtlil.csv` statuses identical (detail paths differ: SURELOG_ROOT) |
| swA | alloff | 2941 | 458+454 | 784+784 | - |
| sw4 / sw6 | off184 / off186 | 3133 / 2944 | 460+456 / 458+454 | 787 / 787 | - |
| sw7 / swT | off187 / off187T | 3124 / 3134 | 458+454 / 460+456 | 789 / 790 | - |
| swB / swC | o187x183 / o187x186 | 2941 / 2941 | 458+454 | 787 / 787 | - |
| swQ / swR / swS | pre184 / post184 / post186 | 2895 / 2898 / 3026 | 456+452 each | 784 / 787 / 789 | = committed `2b97649e` / `44393367` / `c168c209` |
| swW / swO | wide / wideon | 2880 / 3009 | 453+449 / 453+449 | 783 / 788 | - |
| swE | s1eef | 2886 | 455+451 | 783 | = pass 184's pristine (swP of r11u184) |
| swF | fix.bin, all four stages | 3137 | 460+456 | 790+790 | **0/0/0**; `probe.csv`, `uhdm2rtlil.csv`, `downstream.csv` byte-identical to swH's |

Canaries ([canaries_H.txt](evidence/sweeps/canaries_H.txt), [canaries_F.txt](evidence/sweeps/canaries_F.txt)):
`r11u107repro/canaries.sh` surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh`
(surelog) and `EXPECT_UNKNOWN=6 ctcan2.sh` (uhdm2rtlil) PASS, on swH and swF.

## 3. The fresh cases, per law ([cases/](cases), [evidence/grid/](evidence/grid))

86 cases in 25 groups, none in the grids of r11u184repro, r11v184repro, r11u186repro or v11u186repro; the first line
names the laws each attacks.
- [drivers/case.sh](drivers/case.sh) builds the golden with the pinned Surelog (check_probe's arguments; `EL=1` adds
  `-elabuhdm` / `--elabuhdm`; a `files` list names several root files).
- [drivers/grid.py](drivers/grid.py) runs each case in both views under several states, each against ON:
  - each named law's own switch (a refinement also under its parent's);
  - each landing off;
  - every pair of named laws (group X);
  - `extra` state pairs, for a law that is dead by default (TP);
  - ALLOFF and WIDE.
- grid.py reads UNFIRED / TOWARD / AWAY / MIXED / UNMASK / BYTES-ONLY / STAGE1-x.
- Every cell is also judged by [fieldscore.py](drivers/fieldscore.py), [recaway2.py](drivers/recaway2.py) and
  [dumpaway2.py](drivers/dumpaway2.py).
- Tables: [law_readings.txt](evidence/grid/law_readings.txt) and [lawtable.txt](evidence/grid/lawtable.txt); the raw
  grids are [grid_default.txt](evidence/grid/grid_default.txt) and [grid_elabuhdm.txt](evidence/grid/grid_elabuhdm.txt).

| group | cases | shapes (the brief's list) |
|---|---|---|
| E | e01-e04 | an enum declared in a nested generate block (e01); an enum and its variable in a generate-for body, read by a nested if/else block's process (e02); the enum and variable in an outer block, a process two blocks down (e03); a compilation-unit enum with no block variable in generate-for and generate-case processes (e04, r11v184's R2) |
| T | t01-t15 | two instances of different specializations, one with a generate CA (t01); a type override beside a defparam of the same instance (t02); a positional override of two type parameters, procedural writes only (t03); the CA in an if-generate inside a generate-for (t04); **port nets of T: `output wire T` plus a net declaration assignment (t05), `output wire T` alone (t09), `output wire T [1:0]` (t12), `inout wire T` (t13), non-ANSI `output wire T so;` (t14)**; an interface child with a modport and a generate CA (t06); a packed array of T written whole plus an unpacked array of T by elements (t07); a packed struct of T (t08); the body net-declaration assignment alone (t10); variable ports (t11, t15, controls) |
| P (paren) | p01_nested_paren_call, p02_class_this_super, p03_two_dim_member | nested parentheses, a parenthesized call, a parenthesized unary and operation index; this, super and handle paths in class methods; two-dimensional member selects and an array element's member |
| I | i01-i05 | **call indices taking member selects (i01, i04), a class method's own and a handle's method call (i05)**; this/super-rooted operands (the law's exclusion), a 2-D member select, a handle chain (i02); compound assignments beside ++ in a task and a generate scope (i03, control) |
| L | l01-l03 | a call index inside the read path, a call argument wrapping it, a 2-D target (l01); compound targets, a class method, an inc/dec operand's index (l02); streaming lvalues ending in a select (l03) |
| G | g01, g02 | nested generate scopes (if in for in a named block); a genvar index and a call index in a generate loop |
| R | r01, r02 | `$root` targets with two unpacked dimensions, a part select, an indexed part select, a call index (r01); a `$root` net CA target, a member target, a module class method (r02) |
| S | s01 | streaming lvalues whose operand is a member path ending in a select (r11v184's R3 shape), a slice size, a class method, two selects |
| C | c01, c02 | a package-qualified call (r11v184's R5 shape) and nested calls in non-trailing indices; a handle method call index in a class method, a call in a part-select bound |
| A | a01-a04 | associative dimensions keyed by string, int, a class and a typedef in a package function (a01), a module task/function with typedef, enum and string keys (a02), package class properties and a method local (a03), a `$unit` class and function (a04, § assocBracketPkgOnly186) |
| P (pkg) | p01_gen_ca_pkg_param, p02_two_pkgs_qualified, p03_pkg_param_own_ts | package parameters read in an if-generate and a generate-for CA of an instance; two packages, qualified and imported, two instances; logic-range parameters with bare decimal defaults in a generate CA |
| AL | a01, a02 | an alias of another package's typedef as a struct member; a three-step alias chain across two packages in two modules |
| U | u01-u04 | class, string and int elements in fixed, dynamic, queue and associative properties (u01); `q::e lst[$]`, `q::e arr[4]`, `q::e m[string]` (u02); a nested class qualifier and a parameterized qualified element (u03); a parameterized element class `pool#(...) m[comp]` (u04, the UVM `uvm_pool#(...) m_rsc[...]` shape) |
| F | f01-f03 | foreach over string-, int-, typedef- and enum-keyed locals (f01); class- and typedef-keyed properties and locals, a module function (f02); an all-associative 2-D local and a mixed local (f03) |
| TP | t01-t03 | a keyword default used as property, formal, return and local (t01); a class default, a task formal, a nested-begin local, a same-named handle in another class (t02); a class default with function/task/static locals, two specializations (t03), each also with `R11U180_TPUSE_OFF`, `R11U186_TPDEFER_OFF`, `R11U186_TPGATE_OFF` |
| H | h01, h02 | imported package variables with multi-line initializers (struct pattern, int expression, concatenation; wildcard); explicit imports into an interface and a module, a class handle excluded |
| IA | i01, i02 | interface-array port sizes written as a parameter, a package parameter, a 2-D size beside a range form (i01); a spaced parenthesized size, a macro size, two instances (i02) |
| Q | q01-q03 | nested macros building the path (q01); macros from an included file, a macro-argument index (q02); one-buffer and two-buffer selects at module level and in a generate scope (q03) |
| BT | b01, b02 | per-member typedef copies with two importing modules (b01); a nested package struct and a package variable (b02) |
| K | k01, k02 | imported parameter, string localparam and bit-vector parameter copies in two classes and a module (k01); expression-valued parameters (k02) |
| D | d01-d04 | enum values `1_0`, `1_000_000`, `32'd2_5`, longint package values (d01); a generate-for bound, if-generate and generate-case conditions (d02); range bounds, the size-form `[1_6]` (v11u186's residue), a case item, parameter defaults `1_000_000` and a 65-bit decimal, `-1_0` (d03); typedef, struct member, interface signal bounds and an interface enum (d04) |
| W | w01-w04 | three packages with one empty and interleaved names (w01); a local typedef shadowing an imported name (w02); a header import plus a body import, enum/struct typedefs, a modport, two instances (w03); two wildcards plus an explicit import (w04, abstains) |
| LS | l01 | an Earlgrey-like multi-file design: 6 packages of bare scalar typedefs, 8 modules binding them, 16 instances ([drivers/genls.py](drivers/genls.py)) |
| RE | r01, r02 | `$root` reads in a nested generate scope and a generate-for body (r01); a `$root` select read and a `$root` lvalue in one generate scope (r02) |
| X | x01-x07 | the brief's cross-ground pairs (section 5.3) |
| Z | z01 | residue N1 (a parameterized class inside a module, `--elabuhdm`) |

Per law, both views, each against its own switch (the cells where the law fires; STAGE1-CLOSER = judge-unequal on
both states, closer by the order-blind dump distance):

| law | cases (cells) | reading | downstream (ON vs OWN) | verdict |
|---|---|---|---|---|
| § genLocalEnumConstShared184 | 5 (10) | TOWARD 6 (e01, e02, x03), UNFIRED 4 (e03 STRICT_EQUAL; e04 the `$unit` enum, residue) | x03 EQUIVALENT -> IDENTICAL | holds |
| § tpEnumCopyAtTypedef184 | 16 (32) | TOWARD 6, STAGE1-CLOSER 23, SAME 2 (t03 positional: Surelog applies no override, r11v184 R1) | same | holds |
| § tpEnumCaBindsInstVar184v | 13 (26) | **STAGE1-AWAY 8 (t05, t09, t13, t14)**, TOWARD 2, CLOSER 2 | same | **BREAK B1** (fixed) |
| § memberSelParenIdxSpan184 | 3 (6) | TOWARD 6 (p01-p03 STRICT_EQUAL in both views) | same | holds |
| § incDecMemberSelIsLvalue184 | 6 (12) | TOWARD 4, STAGE1-CLOSER 8; **dump judge: golden lines lost on i01, i04, i05** | same | **BREAK B2** (fixed) |
| § incDecSelTopRestore184v | 2 (4) | TOWARD 2 | same | holds |
| § lvIdxMemberSelIsRead184 | 5 (10) | TOWARD 2, CLOSER 4, MIXED 2 (l03: field level FTOWARD, the record changed on two fields and left one wrong) | l03 EQUIVALENT -> IDENTICAL | holds |
| § genScopeTrailSelNameLate184 | 2 (4) | TOWARD 4 (g01, g02 STRICT_EQUAL with the law) | same | holds |
| § rootLvalueSpanAtRoot184 | 4 (8) | TOWARD 2, CLOSER 6 | same | holds |
| § streamLvMemberPathRead184 | 2 (4) | TOWARD 2, MIXED 2 (s01: FTOWARD, 14 fields lost, 0 added) | same | holds; r11v184's R3 stands (s01 keeps `col`) |
| § hpIdxCallNameSpan184 | 4 (8) | TOWARD 4, CLOSER 2 | same | holds; r11v184's R5 stands (`pk::` span, c01) |
| § assocPromotedBoundAtBracket183 | 4 (8) | TOWARD 2 (a01), UNFIRED 6 (a02, a03 STRICT_EQUAL) | same | holds |
| § assocBracketPkgOnly186 | 1 (2) | CLOSER 2 | same | holds |
| § pkgParamElabCaSharesDefFold183 | 2 (4) | CLOSER 2, UNFIRED 2 | same | holds (the size face R6 of r11u186 stands) |
| § pkgParamFoldOwnTs183 | 1 (2) | CLOSER 2 | same | holds |
| § aliasOfTdSharedKeepsModName183 | 2 (4) | CLOSER 2, UNFIRED 2 | same | holds |
| § classPropElemClassTsAtType183 | 3 (6) | TOWARD 2, CLOSER 2, MIXED 2 (u04: field level FTOWARD, lost 8; endcol 0 -> 30 where golden reads 16: residue N2) | same | holds |
| § classPropElemQualTs186 | 2 (4) | CLOSER 4 | same | holds |
| § foreachAssocLoopVarIdxTs183, § foreachAssocLocalSharesDeclTs183 | 3 (6) | TOWARD 2, CLOSER 2, UNFIRED 2 | same | hold |
| § typeParamUseSharesOwnTs183 (+ § typeParamGateNoLookup186) | 3 (6) | UNFIRED by default (deferred); with `R11U180_TPUSE_OFF` t03 CLOSER 32 -> 12 | same | holds |
| § typeParamDefersToTpUse186 | 3 (6) | **STAGE1-AWAY 2 on t03 against `R11U186_TPDEFER_OFF`** (26 vs 10); the landing writes pristine bytes there | same | holds against pristine; **hold-back H1** |
| § importNetTsToInitEnd183 | 2 (4) | CLOSER 4 | same | holds |
| § ifaceArrPortSizeDimAtExpr183 | 2 (4) | CLOSER 4 | same | holds |
| § macroPathTokSpans183 (+ § macroPathTokOneBuffer186) | 4 (8) | TOWARD 2 (q02), UNFIRED 6 (q01 STRICT_EQUAL; q03 two-buffer select keeps `endcol`, v11u186's finding 3) | same | holds |
| § memberBareTdAliasNamedByUse183 | 2 (4) | TOWARD 4 | same | holds |
| § classImportParamOwnRefs183 | 2 (4) | CLOSER 4 | same | holds |
| § enumConstUnderscoreDropped186 | 3 (6) | CLOSER 6 (d01, d04, x03 to judge-equal or STRICT_EQUAL) | **d01, x03 EQUIVALENT -> IDENTICAL** | holds |
| § synLitUnderscoreDropped186 | 1 (2) | CLOSER 2 | same | holds |
| § boundLitUnderscoreDropped186 | 2 (4) | CLOSER 4 | same | holds; `[1_6]` stands (v11u186's residue, d03) |
| § ifaceTwoPkgTdNameOrder186 | 4 (8) | TOWARD 2 (w03), SAME 4 (w01, w02: stage 1 on another face), UNFIRED 2 (w04 abstains) | same | holds |
| § lawSCopyIdOrder186 | 1 (2) | BYTES-ONLY 2 (LS/l01: `reorder 458` triggers; the copies' order moves, 6/6 runs one hash per state) | - | holds (section 7) |
| § rootElemAtNextTok186 | 2 (4) | TOWARD 2, CLOSER 2 | same | holds |

### 3.1 The flagged cells that are not breaks

- **L/l03, S/s01 (MIXED)**: the record key includes every field; OFF had the record with col + fullname wrong, ON only
  fullname. Field scoring: FTOWARD (lost 4-14, neutral 0) in both views.
- **T/t03 (STAGE1-SAME)**: Surelog does not apply a positional type override (r11v184's R1). The copy is located
  either way; the order-blind distance is the same.
- **W/w01, w02 (STAGE1-SAME)**: stage 1 on the interface's own typedef listing in every state; the law reorders names
  the judge never reaches.
- **BuildUVMPkg / SimpleUVM `intro` records** (joint.py, section 5): 4 / 2 `class_typespec uvm_pool` / `uvm_queue`
  records that pass 186 (with 184 off) changes from unlocated (0:0) to `uvm_config_db.svh 69:10-69:44`. Golden has
  69:10-69:18; the other four fields reach golden and the end column stays wrong. That is N2 (u04 reproduces it).

### 3.2 H1: § typeParamDefersToTpUse186 withholds a composed gain

TP/t03 (both views, stage 1 in every state on a task-local listing face, rc 4 "unsupported constructs" with a database
in every state). Order-blind dump distance to golden:

| state | distance |
|---|---|
| neither law (`R11U180_TPUSE_OFF R11U183_TYPEPARAM_OFF`) | 32 (el 58) |
| pass 180's § classTpDefaultTsAtUse180 alone (HEAD) | 26 (el 42) |
| § typeParamUseSharesOwnTs183 alone (`R11U180_TPUSE_OFF`) | 12 (el 34) |
| both (`R11U186_TPDEFER_OFF`) | 10 (el 28) |

What HEAD holds and golden lacks: 4 `class_typespec (base)` copies at 5:27-31 with their `vpiClassDefn` (the locals
share the parameter's one object in golden). The r11u183 law shares them. r11u186 section 2a's "redundant: either law
alone gives the row and every case" holds on its grids but not on this shape. Not refined: the deferral is the guard
r11u186 added after sharing made BuildUVMPkg a two-hash order coin; decoupling needs that coin decoded.

## 4. The breaks, record by record

B1 on T/t09 (default view; [evidence/fix_cases_judge.txt](evidence/fix_cases_judge.txt)):

    golden                       vpiFullName:je_t        (the type_parameter's enum copy; enum_var work@top.v.so)
    law without the refinement   vpiFullName:je_t
    HEAD (refinement)            vpiFullName:work@top.v.T.je_t
    fix                          vpiFullName:je_t

B2 on I/i01 (`--s.g[ix(s.f[j])];` line 8, [evidence/grid/dumpaway2.txt](evidence/grid/dumpaway2.txt)):

    golden / pristine   ref_obj s 8:14-15    bit_select work@top.bump.s.g[].g.s.f[j].f 8:18-19
    HEAD                ref_obj s 8:16-17    bit_select ... 8:16-20
    fix                 ref_obj s 8:14-15    bit_select ... 8:18-19   (STRICT_EQUAL, 270 objects)

Switch matrix ([evidence/fix_switch_matrix.txt](evidence/fix_switch_matrix.txt)): on the 16 moved case-modes
`R11V194_TPCAPORT_OFF` alone restores the law's bytes on exactly the T cases and `R11V194_IDCALLARG_OFF` alone on
exactly the I cases; `R11V194_OFF=1` restores the law's bytes on all 484 case-modes.

## 5. Composition ([evidence/composition/](evidence/composition))

### 5.1 The two landings ([compose_H_A_4_6.txt](evidence/composition/compose_H_A_4_6.txt), [bytecancel_H_A_4_6.txt](evidence/composition/bytecancel_H_A_4_6.txt), [joint_share.txt](evidence/composition/joint_share.txt))

H = HEAD, A = both off, 4 = pass 184 off, 6 = pass 186 off (the 1588 surelog rows are 1596 minus the 8 fenced, skipped
unread).

| stage | conversions A -> H | owner | changes A -> H | CANCEL |
|---|---|---|---|---|
| probe | 196 | OWN184 3 (exactly pass 184's claimed three), OWN186 192, JOINT 1 (`r10uvm143repro/g143_c_index`) | OWN186 35, OWN184 1 (`k9b`), JOINT 1 (`c2_idxkind`) | 0 |
| surelog | 4 | OWN186 (ApbSlave d/t, ArrayMethodIterator d/t: pass 187's ground-A laws, which `R11U183_OFF` also drops) | JOINT 9 (the UVM rows), OWN186 3 (Rggen d, SVSwitch d/t) | 0 |
| uhdm2rtlil | 12 | OWN184 6 (ibex_multdiv_fast, both TypeParameterAsPortTypeWithEnum rows, d/t), OWN186 6 (both ParameterFromPkg rows d/t; jeras_union d/t with pass 187) | 0 | 0 |

- **Byte level** (6647 databases): SAME 6326, OWN184 10, OWN186 298, BOTH 13 (the UVM rows, Earlgrey d/t,
  g143_c_index, c2_idxkind), **CANCEL 0**.
- **Record level** (joint.py, order-blind strict records ours-not-golden):
  - g143_c_index: pass 184 removes 3, pass 186 4, overlap 0, introduced 0 (7 -> 0);
  - c2_idxkind: 1 + 3 (9 -> 5);
  - Earlgrey_0_1 d: 25 + 0;
  - BuildUVMPkg d: 16 + 217;
  - SimpleUVM d: 16 + 188.
  - Neither landing cancels a record of the other. The only records one landing introduces alone are the N2
    relocations of 3.1.
- **The JOINT conversion `g143_c_index`** is the one probe conversion of pass 186's integration (128) beyond its
  claimed 127. It needs both landings: § hpIdxCallNameSpan184 takes the three `func_call helper` records and pass
  186's laws take the four behind them.

### 5.2 Each ground's share of R11U183 ([share_*.txt](evidence/composition))

`R11U183_OFF` switches off the r11u183 laws of BOTH grounds. pass 186's ground-B files (TypeEmit, ModuleEmit,
UhdmExporter, TaskFuncEmit) read `R11U183_OFF` only, while pass 187's ground-A files (ExprEmit, ParamEmit, StmtEmit)
also read `R11U187_OFF`. So the shares are:

| share (baseline sweep -> sweep) | probe conversions / changes | surelog | uhdm2rtlil |
|---|---|---|---|
| pass 187 whole (sw7 -> swH) | 13 / 20 | 4 conv (ApbSlave d/t, ArrayMethodIterator d/t) / 7 | 2 conv (jeras_union d/t) |
| pass 187's two naming laws (swT -> swH) | 3 / 6 | 0 | 0 |
| **ground-A r11u183 (pass 187; sw7 -> swT)** | 10 / 14 | 4 conv / 7 | 2 conv |
| **ground-B r11u183 (pass 186; swB -> sw7, 187 off)** | 183 / 28 | 0 / 12 | 4 conv (both ParameterFromPkg rows d/t) / 2 |
| pass 186's own seven laws + refinements on top (swC -> swB) | 0 / 0 (11 probe byte movers, no verdict) | 0 | 0 |
| pass 184 (sw4 -> swH) | 4 (incl. g143_c_index) / 2 | 0 / 9 | 6 conv |

- **The ground-B share is 183, not 128, because pass 188 is on.** 55 of those 183 probe conversions are pass 188's
  own (every one in the `a1c89c1a -> 6ab9f4fb` baseline diff): they need the ground-B laws. None of pass 186's 128
  integration conversions is missing from the share.
- **At pass 186's integration** (swR -> swS, 187 and 188 off) the landing converts exactly its 128 probe cases and
  4 u2r row-modes: 127 claimed plus g143_c_index (5.1).

### 5.3 Cross-ground pairs (group X, each pair off together; [grid_default.txt](evidence/grid/grid_default.txt))

| case | pair | reading |
|---|---|---|
| X/x01 | § tpEnumCopyAtTypedef184 × § typeParamDefersToTpUse186 × § classTpKeywordTsAtDefault188 (a module type parameter with a keyword default overridden by a module enum; a class type parameter with a keyword default specialized by it) | 184 CLOSER alone and in every pair; 186's defer and 188's keyword law unfired on this shape; `--elabuhdm` segfaults in every state (N1) |
| X/x02 | § incDecMemberSelIsLvalue184 × § macroPathTokSpans183 × § macroPathTokOneBuffer186 (inc/dec operands through macros, index an argument) | STRICT_EQUAL with everything on; 184 TOWARD 16 records, the macro laws unfired on these operands; every pair = 184 alone |
| X/x03 | § genLocalEnumConstShared184 × § enumConstUnderscoreDropped186 (a generate-block enum written with separators) | STRICT_EQUAL on; 184 alone TOWARD 5 records, 186 alone takes it from stage 1 to STRICT_EQUAL; additive; downstream EQUIVALENT -> IDENTICAL |
| X/x04 | § rootLvalueSpanAtRoot184 × § rootElemAtNextTok186 × § rootNetPathOwnNames181 (`$root` lvalues and reads in generate scopes) | stage 1 in every state; each law CLOSER alone and in every pair |
| X/x05, x07 | § lvIdxMemberSelIsRead184 × § nestRdIdxOnly190v × § lvIdxMixedPathIsRead181 (call arguments inside lvalue index paths) | x05: every law unfired (`arr[fx(s.f[k])]`: the call argument's lvalue shape is pre-existing on every binary, residue N3); x07: 184 CLOSER, 190v unfired |
| X/x06 | § hpIdxCallNameSpan184 × § trailIdxCallArgNamesByPath187 × § trailIdxSelNamesByPath187 (call indices under trailing selects) | every law TOWARD; 184 (4 records) + 187 (6) = 10 when off together: additive |

## 6. The CHANGE lines ([evidence/changes/](evidence/changes), [drivers/unmask.py](drivers/unmask.py), [unmaskpos.py](drivers/unmaskpos.py))

The integrations are reproduced by the switch states: `compare_results.py` between them lists
([list_pass184_at_2b97649e.txt](evidence/changes/list_pass184_at_2b97649e.txt),
[list_pass186_at_8e3153a2.txt](evidence/changes/list_pass186_at_8e3153a2.txt)):

- **Pass 184 at `2b97649e` (swQ -> swR)**: 3 probe + 6 u2r conversions, and CHANGES of 3 probe + 9 surelog + 0 u2r,
  exactly the brief's list:
  - probe: `g143_c_index endcol(7) -> file(4)`, `c2_idxkind file(9) -> file(8)`, `k9b endline(6) -> endline(4)`;
  - surelog: BuildUVMPkg d/t, SimpleUVM d/t, Scoreboard d `fullname(23) -> (21)`, SeqDriver d/t `(7) -> (5)`,
    MiniAmiq d/t `(8) -> (6)`.
  - Record level ([unmask_184_swQ_to_swR.txt](evidence/changes/unmask_184_swQ_to_swR.txt)): probe CONVERSION 3,
    SUBSET 3; surelog SUBSET 9; u2r CONVERSION 6. **Every change is a strict subset:** the on records are all among
    the off records (the UVM rows lose exactly the two `seed_map.count[type_id]++` records each).
- **Pass 186 at `8e3153a2` (swR -> swS)**: 128 probe + 4 u2r conversions, and CHANGES of 83 probe + 12 surelog +
  2 u2r:
  - surelog: jeras_union `fullname(75) -> file(60)` (u2r), SVSwitch `file(15) -> fullname(13)`, MiniAmiq
    `fullname(6) -> file(5)`, SeqDriver `fullname(5) -> file(4)`, BuildUVMPkg / SimpleUVM / Scoreboard
    `fullname(21) -> (20)`, Rggen `endcol(634) -> endcol(144)`.
  - Record level ([unmask_186_swR_to_swS.txt](evidence/changes/unmask_186_swR_to_swS.txt)): probe CONVERSION 128,
    SUBSET 24, UNMASK 57, BOTH-DIVERGED 2; surelog SUBSET 12; u2r CONVERSION 4, SUBSET 2. No NEW, no WORSE.
  - **Every one of the 57 UNMASK cases puts all its new records at or after the off walk's divergence**
    ([unmaskpos_186.txt](evidence/changes/unmaskpos_186.txt)).
  - The two BOTH-DIVERGED (`r10v160repro/x09_struct` depth(1) -> type(1), `x10_enum` depth(1) -> name(2)) likewise:
    new records at #139 and #127/#128, past the off divergence at #65 / #57
    ([unmaskpos_186_bothdiverged.txt](evidence/changes/unmaskpos_186_bothdiverged.txt)).
  - Every corpus change is SUBSET: Rggen's 144 records are all among the 634, MiniAmiq's 5 among its 6.

## 7. Downstream ([evidence/downstream/](evidence/downstream))

- **Converted rows, both lanes kept by the harness** ([drivers/dsnet.sh](drivers/dsnet.sh)):
  - Rows: ibex_multdiv_fast, TypeParameterAsPortTypeWithEnum, TypeParameterAsPortTypeWithEnumOfParametrizedWidth,
    ParameterFromPkgInNestedModule, ParameterFromPkgOnParameterPortList, jeras_union.
  - `_nohier.il`, `.il` and `_synth.v` are byte-identical between golden's lane and the slang lane in swH
    ([r11u194_dsnet_H.txt](evidence/downstream/r11u194_dsnet_H.txt)).
  - The same holds with both landings off ([r11u194_dsnet_A.txt](evidence/downstream/r11u194_dsnet_A.txt), the
    harness filtered to the six rows under `alloff.sh`). The slang databases move but the netlists do not: every row
    is IDENTICAL in both states, `ibex_multdiv_fast,IDENTICAL,OK,OK,3906,3906,,`.
- **The full downstream gate**: swH and swF `downstream.csv` byte-identical to `results/downstream_uhdm2rtlil.csv`
  (803 / 66 / 2 / 0); the fix moves 0 of 805 slang-lane databases.
- **This pass's cases** (ON, ALLOFF, OWN, FIX through the harness's `one()`, [drivers/dscase.py](drivers/dscase.py)):
  - 84 cases (Z and LS excluded): ON 66 IDENTICAL, 12 EQUIVALENT, 4 DIVERGENT, 2 STATUS_DIFF; ALLOFF -> ON: 3 EQUIVALENT -> IDENTICAL (D/d01, X/x03
    the separator laws, L/l03 § lvIdxMemberSelIsRead184 + § streamLvMemberPathRead184).
  - No case leaves IDENTICAL, and the fix moves no verdict.
  - The non-identical verdicts are the same in every state: T/t05, t08, t10 DIVERGENT (the type-parameter enum
    ports), H/h01 DIVERGENT, D/d03 STATUS_DIFF (the 65-bit parameter, N6 of r11u190), X/x01 STATUS_DIFF.
- **r11u186's D/d01, d02, d07** ([r11u186_D_cases.txt](evidence/downstream/r11u186_D_cases.txt)): IDENTICAL at the
  base, EQUIVALENT with both landings off, as pass 186 reported. v11u186's D/x01 (the `-1_0` enum): DIVERGENT with
  both landings off, EQUIVALENT at the base (its netlist still differs downstream although the database reads
  STRICT_EQUAL in both views: Surelog's own `-1_0` evaluation, v11u186's finding 1).
- **UVM file facets, order-blind** ([uvmdist_H_A_4_6.txt](evidence/uvm/uvmdist_H_A_4_6.txt); `all_file_away` =
  (type, name, file) triples ours holds more often than golden). Both landings off -> HEAD:

  | row | all_file_away | dist |
  |---|---|---|
  | MiniAmiq | 3346 -> 2646 | 9526 -> 7143 |
  | SeqDriver | 3141 -> 2381 | 7659 -> 5801 |
  | SimpleUVM | 1516 -> 1362 | 2781 -> 2579 |
  | Scoreboard d | 1215 -> 1082 | 2113 -> 1950 |
  | BuildUVMPkg | 368 -> 187 | 1265 -> 1036 |

  - `method_func_call` file facets 15 -> 12 (0 on BuildUVMPkg).
  - Shares: pass 184 alone takes 20-24 of MiniAmiq's distance (sw6 9506), pass 186 the rest (sw4 7163); additive
    within the coin's ±1.
- **First records at HEAD** ([first_records_H.txt](evidence/uvm/first_records_H.txt)):
  - MiniAmiq #899: the `uvm_severity` enum file (golden uvm_globals.svh 271:61, ours uvm_object_globals.svh 242:1);
  - MiniAmiq #1694 and SeqDriver #1677 / #1841: the `uvm_bitstream_t` / `uvm_integral_t` logic_typespec files
    (uvm_misc.svh vs uvm_object_globals.svh);
  - SimpleUVM #458 and Scoreboard #466: `UVM_MACRO_NUMFLAGS` references (golden bare, ours `uvm_pkg::`);
  - BuildUVMPkg #2834: `severity` full name through `uvm_report::verbosity`.

## 8. Determinism ([evidence/determinism/](evidence/determinism), [drivers/det.sh](drivers/det.sh) with `DETN`, [drivers/ob.sh](drivers/ob.sh))

| row-mode | law.bin, concurrent runs | reference sweep | positive control (`R11U186_LAWSSORT_OFF`, 6 runs) |
|---|---|---|---|
| Earlgrey_0_1 default | **1 hash in 6/6** (`94a33ef3f8de`) | = swH's | 2 hashes (4 + 2), order-blind 0 lines |
| Earlgrey_0_1 testflags | **1 hash in 6/6** (`f641f7fbc784`) | = swH's | 2 hashes (5 + 1) |
| MiniAmiq d / t | 3 runs: 2 / 3 hashes (+ the sweep's: 3 / 4) | | |
| SeqDriver d / t | 3 runs: 3 / 2 hashes (+ the sweep's: 4 / 3) | | |

- **§ lawSCopyIdOrder186 closes the Earlgrey order-only variant at the base.** Without it the two-hash coin returns
  in the same six-run batch.
- **The UVM one-constant coin still stands.** Every MiniAmiq / SeqDriver pair differs by 4 order-blind lines or 0:
  the right bound of `array_typespec types_t` (uvm_misc.svh 642:23-26), `vpiDecompile:0 / UINT:0` against `519` in
  one pair ([coin_miniamiq_pair.txt](evidence/determinism/coin_miniamiq_pair.txt)). Every variant reads uhdm-cmp
  0 lines and the same strict cell and object count.
- **Pass 193 has not landed.** The main tree's HEAD is pass 192 (`b6344400`), whose source diff touches only
  ExprEmit and ParamEmit and names § queueRetTwinDynShape191 only in `tests/LAWS.md` text. r11u191's
  `law_typeemit.patch` fix is not in the tree.
- **The fix sweep's 4 corpus movers are this coin**: MiniAmiq d/t and SimpleUVM d at 4 order-blind lines, SeqDriver d
  at 0 lines (its fix-sweep hash `b6672b2151f4` is one of law.bin's own three-run hashes).
- **LS/l01** (the synthetic multi-file scale case; [ls_scale_det.txt](evidence/determinism/ls_scale_det.txt)): 6
  concurrent runs give 1 hash with the law and 1 (another) hash without it, twice each. The law reorders 458 triggers
  deterministically; this heap layout does not reproduce the coin, so Earlgrey is the only positive control.

## 9. Residues

### Re-measured at the base (`706ab521`, passes 187, 188 and r11u190 on top)

| source | residue | at 706ab521 |
|---|---|---|
| pass 184, R1 | FuncStructValSimple d/t file(39)/(59) | **stands** |
| pass 184, R2 | Scr1SvTests d/t type(1) | **stands** |
| pass 184, R3 | `$root.top.v[$root.top.i]` (r11u181 rt/g06) | **stands**: stage 1 both views |
| r11v184, R1 | a positional type override (vt17) | **stands**: stage 1; fresh T/t03 SAME |
| r11v184, R2 | a `$unit` enum with no block variable (ve11, definition view) | **stands**: `file`; fresh E/e04 likewise (elaborated view STRICT_EQUAL) |
| r11v184, R3 | streaming member path ending in a select (vs01, vs02) | **stands**: `col`; fresh S/s01 likewise |
| pass 186, 1 | jeras_union, ArrayMethodIterator, ApbSlave waiting for the sister | **gone**: CMP_EQUAL d/t (pass 187's ground-A laws; 5.2) |
| pass 186, 2 (R1) | TypeParameterAsPortTypeWithEnum* named override | **gone**: CMP_EQUAL (pass 184) |
| pass 186, 3 (R2) | pass 176/180 carried (MiniAmiq #899 `uvm_severity` file) | **stands**: MiniAmiq's first record at HEAD |
| v11u186, 1 | Surelog separator defects (`-1_0` enum, wide if-generate condition, step `1_0`) | D/x04, D/x06 **stand** (stage 1); D/x01 now STRICT_EQUAL both views |
| v11u186, 2 | the size-form `[1_6]` decompile (D/x03) | **stands**; fresh D/d03 likewise |
| v11u186, 3 | § macroPathTokOneBuffer186 holds back a partial gain (Q/x01, x02) | **stands**: `fullname`, `endline`; fresh Q/q03 `endcol` |

### New, found here (none is a break but B1 and B2, which are fixed)

- **N1.** A parameterized class declared inside a module and specialized there (`class box #(type E = int)` inside the
  module, `box #(byte) b;`) segfaults with `--elabuhdm` (rc 139) in every switch state, WIDE included. The definition
  view writes a database. Cases Z/z01, X/x01 `_el`. Not a law's; a crash on legal SV.
- **N2.** § classPropElemClassTsAtType183 ends a PARAMETERIZED element class's `class_typespec` after its parameter
  list (`pool#(string, int) m_rsc[comp]`: ours 6:12-30, golden 6:12-16 at the class name; U/u04). The UVM rows carry
  it (`uvm_pool` / `uvm_queue` uvm_config_db.svh 69:10-44 vs 69:18). The law moved the object from unlocated to four
  of five fields right, so it is not AWAY. Ending the span at the class name token would close it.
- **N3.** The lvalue shape of a member select that is a call argument inside a PLAIN lvalue's index
  (`arr[fx(s.f[k])] <= ...`, X/x05) is pre-existing on every binary. § incDecSelCallArgRead194v fixes only the
  inc/dec operand's copy of it. The general rule (a call argument is compiled as a read) would convert x05 and is the
  next pass's.
- **N4.** A call argument's index name (`k` in `s.f[ix(s.g[k])]++`, I/i04) is named through the outer path in golden
  (`work@top.s.f[].f.s.g[k].k`), ours `work@top.s.g[k].k`, on the law and the fix alike.
- **H1** (section 3.2).

## 10. The fence and the process

**No law, case or number here rests on a fenced reading.**
- Every case is this directory's.
- Every corpus reading is a non-fenced row through a fail-closed driver or a gate sweep: bvmirror.sh
  `fenced_skipped=8`; predict184 rerun `fenced_excluded 8`; census186.sh `--filter` from `$FENCED`, 1588 surelog rows
  run; predict194.sh and dsnet.sh check `$FENCE_RE` before dispatch; det.sh, ob.sh, uvmdist.sh, joint.py,
  compose.py, bytecancel.py, unmask*.py refuse or skip fenced names.

**Laws re-derived from this directory's cases and Surelog's source only** (the two of each pass nearest the fenced
tests' parameter shapes):

- **§ tpEnumCopyAtTypedef184 / § tpEnumCaBindsInstVar184v**: `NetlistElaboration::elabSignal` (2050-2170, the isNet
  decision) and `UhdmWriter::writeCont_assign` / `CompileHelper::bindVariable`. Cases T/t04, t07, t09-t15; this is
  where B1 was found.
- **§ incDecMemberSelIsLvalue184**: `CompileHelper::compileTfCallArguments` (per-argument `compileExpression`). Cases
  I/i01-i05; this is where B2 was found.
- **§ pkgParamElabCaSharesDefFold183**: P/p01_gen_ca_pkg_param and p02_two_pkgs_qualified move closer (judge-unequal
  on the unsized-size face of r11u186's R6).
- **§ enumConstUnderscoreDropped186**: CompileExpression.cpp `slIntConst` (`value.erase(std::remove(..., '_'))`).
  Cases D/d01, D/d04 and X/x03 go to judge-equal / STRICT_EQUAL; downstream EQUIVALENT -> IDENTICAL.

**Drivers of the four evidence directories** (static reading plus a runtime source of each env.sh):

- **r11u184repro**: env.sh resolves the repository from its own path, reads canaudit.sh's `FENCED=` line and
  refuses without four names (sourced here: rc 0, 4 names).
  - Fail-closed with fenced skips: grid.sh, probemovers.sh and rowrec.sh source it and refuse a fenced path
    (`FENCED_RE`). bvmirror.sh, obrows.sh and predict184.sh require `$FENCED` with four names
    (`: "${FENCED:?}"`) and skip by word boundary. predict184.cpp refuses a fenced source or database (exit 4).
  - Do not check the fence: offwrap.sh and tracewrap.sh (binary shims for `verify_golden.py --filter`; the fence is
    the dispatcher's filter); enumrefs.py, recmv.py and obdist.py (record / dump readers taking any file);
    gridall.sh (through grid.sh); gridcmp.sh and switchmatrix.sh (case-scoped, default the pass's own cases, no fence
    check of their own).
  - Hard-coded scratch: `/tmp/r11u184_bin` (env.sh STRICT_CMP, obrows.sh), `/tmp/r11u184_tools/predict184`
    (predict184.sh), `/tmp/r11u184_g` (grid.sh, gridcmp.sh, switchmatrix.sh). All are pruned, so those drivers need
    the path edited; the predictor reran here through a copy with the binary path substituted.
- **r11v184repro**: env.sh resolves the repository from its own path, four-name check (rc 0 here).
  - Fail-closed: vgrid.sh, dscases.sh and vswitch.sh refuse a fenced path; probemovers.sh reads probe databases
    only.
  - Do not check the fence: vjoin.sh and vobdist.py (readers); tracewrap.sh (a shim).
  - Hard-coded: `/tmp/v11u184_bin` (tracewrap.sh, vswitch.sh, env.sh's STRICT_CMP default), `/tmp/v11u184_g`,
    `/tmp/v11u184_census.txt`.
- **r11u186repro**:
  - **v11u186's report stands for env.sh and det.sh and half-stands for case.sh.**
    - env.sh reads canaudit.sh from the hard-coded `/tmp/wt_r11u186` and exports `/tmp/r11u186_bin` paths. The
      worktree is pruned, so env.sh now returns 1 (fail closed: sourced here, rc 1, 0 names).
    - det.sh sources that env.sh, `cd`s into `/tmp/wt_r11u186` and runs `/tmp/r11u186_bin/<bin>`.
    - case.sh reads the fence from ITS OWN path (`$HERE/../../r11u107repro/canaudit.sh`, four-name check, refuses a
      fenced path) but hard-codes `/tmp/r11u186_bin/uhdm-strictcmp`, `/tmp/r11u186_gold` and `/tmp/r11u186_run`.
  - Also hard-coding the pruned worktree: bvmirror.sh, census.sh, chgdist.py (`/tmp/wt_r11u186/scripts`), dscase.sh,
    offcheck.sh, rowrun.sh, row.sh, sweep.sh and switches.sh. All refuse now through env.sh, except chgdist.py, which
    fails on the missing import.
  - uvmdist.sh reads the fence from its own path and skips by exact name.
  - Do not check the fence: censum.py, obdist.py and obd.sh (readers); probemovers.sh (probe only); grid.sh and
    dsgrid.sh (through case.sh / dscase.sh).
  - A word scan finds no driver naming a fenced test.
- **v11u186repro** (packaged from the verifier's scratch at integration):
  - env.sh reads canaudit.sh from the pruned `/tmp/wt_v11u186pris`: rc 1 here, fail closed.
  - cmp1.sh, det.sh and sweep.sh source `/tmp/v11u186_env.sh`, a scratch file that is gone, so they refuse.
  - case.py and ds.py assert four names in `$FENCED` from the environment (they do not read canaudit.sh themselves)
    and refuse a fenced path.
  - uvmdist.sh reads canaudit.sh from `/tmp/wt_v11u186pris`.
  - obd.py and build.sh do not check the fence (a dump reader; a build script).
  - None of these drivers runs from the tree as packaged, as the v11u186 README says.

**The predictions were written before their sweeps, as far as the tree can show** ([evidence/process/](evidence/process)):

- **Pass 184**:
  - The committed `predict184.cpp`, rebuilt with its own `cc184.sh` and run over swE (the `1eeff71d` state; probe
    2886, surelog 455+451, u2r 783+783 = r11u184's swP), reproduces `r11u184repro/evidence/predict_pristine.txt`
    **exactly: 6647 listed, 116 predicted, 0 differing lines**
    ([predict184_rerun_on_s1eef.txt](evidence/process/predict184_rerun_on_s1eef.txt)).
  - The 17 corpus movers of `byteverify_corpus.txt` and the 6 probe movers of `probe_movers.txt` are all inside the
    116.
  - The first predictor's output `predict_pristine_v1.txt` (114 names) lacks g143_c_index and c2_idxkind, the
    § hpIdxCallNameSpan184 movers; that law was not in law1. It also lacks `v84x2_incdec` and `g21b`, the two cases
    r11u184's README says it missed (swL's regression).
  - The prediction is a function of the pristine databases alone, so it could not have seen the law sweeps.
- **Pass 186**:
  - Its firing census, re-run with `census.sh`'s commands on the HEAD binary in pass 186's integration state
    ([drivers/census186.sh](drivers/census186.sh); fenced rows excluded by `--filter`), reproduces
    `r11u186repro/evidence/census_final.tsv` **byte for byte (542 keys, 0 differing lines)**, the sort law's
    `reorder`/`multi` classes included ([census186_rerun.tsv](evidence/process/census186_rerun.tsv)).
  - `predicted_movers_final.tsv` (508 keys) contains every one of the 36 corpus movers of `byteverify_G_vs_P.txt`
    and the 253 probe movers of `probe_movers_G_vs_P.txt`.
  - The census is a function of the law binary and the sources, not of the gate sweep. That it was frozen before the
    sweep is the README's statement; the tree keeps no timestamps to confirm it.
- **v11u186's cases**: the directory holds 40 cases, each with its `dut.sv` first line `// § <law>` (two with a
  `pkg.svh`). The README says "38 fresh cases" (and "35 break cases"); its text names 36 of the 40 (not H/x01,
  H/x02, R/x01, R/x03). The claim about the first lines holds for all 40.

**This pass's own prediction** ([prediction_fix194.txt](evidence/prediction_fix194.txt)):
- It was written at 22:40:23 from fix.bin, which predict194.sh traces on every tests/probe case in both views and on
  the corpus rows where pass 184's census saw TPENUM or INCDECSEL fire. The fix sweep started at 22:40:30.
- It names 0 probe and 0 corpus databases. The positive controls fire (I/i01 and I/i05 IDCALLARG, T/t09 TPCAPORT);
  the negative controls do not (T/t11, I/i02).
- Measured: 4 of 2560 corpus movers, all the UVM coin (section 8); 0 of 4087 probe; 0 of 805 downstream
  ([byteverify_F_vs_H.txt](evidence/sweeps/byteverify_F_vs_H.txt), SELFCHECK 2559/2560, PATH_SETS_IDENTICAL,
  mirrors `fenced_skipped=8`; [movers_orderblind_F_vs_H.txt](evidence/sweeps/movers_orderblind_F_vs_H.txt)).

**Operations of this pass, disclosed:**

- The fix was built three times in this worktree's `src/` (fix1, then fix2 and fix on top of it), each binary frozen
  under `/tmp/r11u194_bin` before use. The sources were reverted with `git checkout src` after fix1 (the rebuild of the
  reverted tree gave `b912028331d2` again) and after the final build. The deliverable carries no `src/` edit;
  fix.patch is the diff. The worktree's `build/slang-uhdm` is the last fix build; every measurement names a frozen
  copy.
- Two fix sweeps were started and stopped by this pass (their processes checked by command line, then killed):
  - one on fix2.bin, stopped in its probe stage when the method-call branch was added;
  - one on the final fix.bin, started before its prediction file was complete (a relative-path slip in the
    prediction command).
  Both scratch directories were deleted. The reported swF started at 22:40:30, after the prediction.
- A waiter loop of this session that could not terminate was stopped with the session's own task control.
- The main tree's HEAD moved to pass 192 (`b6344400`) during this pass; nothing here reads the main tree's files. The
  live pairs' worktrees were not touched.
- Up to three sweeps ran concurrently at `--jobs 3`; one ParamEmit-only rebuild ran at `-j 2` with 5 GB free (a
  single translation unit); no OOM.

## 11. Files

- [fix.patch](fix.patch): § tpCaPortNetIsVar194v and § incDecSelCallArgRead194v (`git diff 706ab521 -- src`).
- `cases/{A,AL,BT,C,D,E,F,G,H,I,IA,K,L,LS,P,Q,R,RE,S,T,TP,U,W,X,Z}/`: 86 cases.
  - Q/q02 includes `defs.svh`.
  - LS/l01 is generated by drivers/genls.py and carries a `files` list.
  - TP cases carry an `extra` file (state pairs for grid.py).
- `drivers/`:
  - environment and states: env.sh, laws.py, mkstate.sh;
  - sweeps: sweep.sh, queue.sh, queue2.sh, queue3.sh, statecounts.py;
  - cases: case.sh, grid.py, gridall.sh, gridsum.py, lawtable.py, fieldscore.py, recaway2.py, dumpaway2.py;
  - composition and changes: compose.py, bytecancel.py, joint.py, unmask.py, unmaskpos.py, unmaskposrow.py,
    lostrec.py;
  - downstream: dscase.py, dsrow.py, dsnet.sh;
  - determinism: det.sh, ob.sh, coin.sh, lsdet.sh, genls.py;
  - UVM: uvmdist.sh;
  - byte mirrors: bvmirror.sh;
  - fix: predict194.sh, fixcases.sh, fixjudge.py;
  - process: census186.sh.
  - Drivers copied from r11u190verify say so in their second line.
- `evidence/`: `grid/`, `composition/`, `changes/`, `downstream/`, `uvm/`, `determinism/`, `process/`, `residues/`,
  `sweeps/`, `sweeps_cmds_audit.txt`, `binaries.txt`, `prediction_fix194.txt`, `fix_cases_judge.txt`,
  `fix_cases_raw.txt`, `fix_switch_matrix.txt`.
