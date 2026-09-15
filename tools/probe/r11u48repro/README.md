# r11u48 — the ours-only `ref_typespec -> int_typespec` on an expression object

TRIAGE2's **C4** (`tools/probe/r11u44repro/TRIAGE2.md:406`) framed two tests,
four rows, one SHAPE and two holders. This pass decodes both holders, and they
turn out to be two DIFFERENT producer rules that happen to print the same
three-line dump fragment. Both are landed here, each behind its own gate and
its own grid arms.

* **§ foldedBoundTsIsTheSignednessCapture48** — a folded RANGE BOUND carries an
  `int_typespec` ref **iff the folded value is SIGNED**. `packed_struct_array_fifo`
  **CONVERTS**, both modes.
* **§ callArgSubroutineLocalOffRetExprNoTs48** — a call argument that is a bare
  reference to a SUBROUTINE-BODY LOCAL carries no formal-typespec stamp
  **outside the return-expression window**. `cfg_func_width_loop` **ADVANCES**
  (head cleared, next head is r11u34's own R0).

---

## 1. THE HEADS, RE-MEASURED AT 2e089d24

Four arms, own workdir, own pristine binary (`md5 bb429bfd6362775094b3e74909d02667`,
byte-identical to the main tree at the base). `uhdm-cmp` writes the head to
STDERR; `grep -c '^LHS:'` reads 1 on each.

```
cfg_func_width_loop / default + testflags      (head md5 3399f2a4741e, both)
LHS: <null>
RHS:
decompile:
ref_typespec: (q::maxw::i), id:195
|vpiParent:
\_ref_obj: (q::maxw::i), id:194, line:31:20, endln:31:21
|vpiFullName:q::maxw::i
|vpiActual:
\_int_typespec: , id:41, line:23:42, endln:23:45
```

```
packed_struct_array_fifo / default             (head md5 8bb0ec013f02)
LHS: <null>
RHS:
decompile:
ref_typespec: (work@packed_struct_array_fifo.status_cnt_n), id:428
|vpiParent:
\_constant: , id:427, line:23:10, endln:23:20
|vpiFullName:work@packed_struct_array_fifo.status_cnt_n
|vpiActual:
\_int_typespec: , id:429
```
(`/testflags` is the same object at different ids, head md5 `9bfbaaec4670`.)

TRIAGE2 read the first as "a bit-select as an `if` condition". It is not:
`dut.sv:31:20` is the **`i` of `fwidth(i)`**, a CALL ARGUMENT, and `23:42..45`
is the `int` of `fwidth`'s own formal `int unsigned i` — the head is the
FORMAL-TYPESPEC STAMP landing on an argument. The second is the LEFT bound of
`logic [ADDR_DEPTH:0] status_cnt_n` folded to the constant 1. Neither
`ref_typespec` carries a name of its own: the `(…)` and `vpiFullName` in the
dump are uhdm-dump's synthesis from the parent chain (arm B sets
`VpiFullName` explicitly, arm A copies the argument's).

`expr::Compare` (`~/git-repos/UHDM/build/generated/src/expr.cpp:100`) reads
`VpiDecompile`, `VpiSize`, then `Typespec()`; `LHS: <null>` is the SINGULAR
`SafeCompare` overload with golden's side null — an OURS-ONLY object, both
times.

## 2. CENSUS GOLDEN-vs-GOLDEN FIRST — where golden DOES type an expression object

`tscen48` walks `Serializer::AllObjects()` and keys every IS-A-`expr` object by
`(kind, parent kind, typespec kind)`; names, files, lines and spans are
deliberately out of the key because `Compare` never reads them. Run over all
**1742 uhdm2rtlil goldens** (`evidence/CENSUS.golden.u2r.exprts.txt`):

```
49285  constant under=param_assign ts=ref_typespec act=int_typespec
45409  parameter under=module_inst ts=ref_typespec act=int_typespec
26221  logic_net  under=module_inst ts=ref_typespec act=logic_typespec
  ...
  298  constant under=range       ts=ref_typespec act=int_typespec     <-- arm B
  157  ref_obj  under=func_call   ts=ref_typespec act=logic_typespec   <-- arm A
    6  ref_obj  under=func_call   ts=ref_typespec act=int_typespec
```

So the brief's caution (a) is REAL and both "strip all" spellings are refuted
before they are written: golden types 298 range-bound constants and 175 call
arguments. Variables and nets IS-A `expr` too, so a blanket rule would also
strip every declaration's typespec.

The two heads isolate to ONE cell each, ours against golden, same database:

| cell | golden | ours (pristine) |
|---|---|---|
| `cfg` `ref_obj under=func_call act=int_typespec` | 0 (7 bare) | **2** (5 bare) |
| `fifo` `constant under=range act=int_typespec` | 0 | **1** |

## 3. THE PRODUCERS, DECODED

### Arm B — `CompileExpression.cpp:3032-3045`, the identifier fold

`CompileHelper::compileExpression`'s identifier arm, under `Reduce::Yes`,
answers a name from the instance's stored `Value` and then:

```cpp
UHDM::constant *c = s.MakeConstant();
c->VpiValue(sval->uhdmValue());  c->VpiDecompile(sval->decompiledValue());
c->VpiConstType(sval->vpiValType());  c->VpiSize(sval->getSize());
if (sval->isSigned()) {                       // <-- THE PRESENCE SPLIT
  int_typespec *ts = s.MakeInt_typespec();  ts->VpiSigned(true);
  ref_typespec *rt = s.MakeRef_typespec();
  rt->VpiParent(c);  rt->Actual_typespec(ts);  c->Typespec(rt);
}
result = c;
```

`compileRanges` (`CompileExpression.cpp:3996-4055`) installs exactly that
object as the range's `Left_expr`. The sign it reads is
`CompileHelper::valueRange` (`CompileHelper.cpp:5540-5568`), whose switch names
`logic_typespec`, `bit_typespec` and `int_typespec` and reads `VpiSigned()` off
them — and nothing else. That is the rule § dimBoundLeafValueSignedTs89
(r10earl89) already transcribed as `paramValueSigned89` for the UNPACKED
dimension builder; this pass gives the PACKED one the same reader instead of a
second encoder.

### Arm A — `ExprEval.cpp:6170-6182`, EvalFunc's actual-to-formal stamp

```cpp
expr *ioexp = (expr *)args->at(index);
if (expr *exparg = reduceExpr(ioexp, invalidValue, modinst, pexpr, muteError)) {
  if (exparg->Typespec() == nullptr) { ...mint a ref_typespec on exparg... }
  exparg->Typespec()->Actual_typespec(tps);          // tps = the FORMAL's
}
```

The stamp lands on the object `reduceExpr` **RETURNS**, never on the argument
in the tree. `reduceExpr`'s `ref_obj` arm
(`~/git-repos/UHDM/templates/ExprEval.cpp:4806-4830`) first asks
`getValue(name, inst, pexpr)`; when the reference HAS a value in the scope being
evaluated it is replaced by a fresh constant and the stamp dies on that
temporary. Only a reference with NO value keeps the same object and shows the
stamp in the database.

## 4. THE GOLDEN GRID — 34 arms, `tools/probe/r11u48repro/grid`

`rungrid.sh` runs every arm through BOTH producers, records BOTH rcs (all 34
compile rc=0 on both sides; an arm whose compile fails teaches error recovery,
not golden), and reads `fcarg48` (call arguments) and `rbnd48` (range bounds)
off each database. `evidence/GRID.pristine.txt`, `evidence/GRID.patched.txt`,
`evidence/GRID.armscore.tsv`.

### h1-h18 — the folded range bound, `logic [P:0] x` in every arm

| arm | the localparam | golden | ours pristine | ours patched |
|---|---|---|---|---|
| h1 | `int P = $clog2(DEPTH)` | **TS** | TS | TS |
| h4 | `int P = (D>1)?$clog2(D):1` | **TS** | TS | TS |
| h5 | `int P = 4` | **TS** | TS | TS |
| h13 | `logic signed [7:0] P = 4` | **TS** | TS | TS |
| h16 | `int P = Q` (`Q` = `int unsigned`) | **TS** | TS | TS |
| h2 | `int unsigned P = (D>1)?$clog2(D):1` | BARE | TS | **BARE** |
| h3 | `int unsigned P = $clog2(DEPTH)` | BARE | TS | **BARE** |
| h6 | h2 with DEPTH=4 (the `$clog2` arm taken) | BARE | TS | **BARE** |
| h7 | `int unsigned P = (D>1)?2:1` | BARE | TS | **BARE** |
| h8 | `int unsigned P = 4` | BARE | TS | **BARE** |
| h9 | `byte P = 4` | BARE | TS | **BARE** |
| h10 | `integer P = 4` | BARE | TS | **BARE** |
| h11 | `shortint P = 4` | BARE | TS | **BARE** |
| h12 | `longint P = 4` | BARE | TS | **BARE** |
| h14 | `logic [7:0] P = 4` | BARE | TS | **BARE** |
| h15 | `int unsigned P = Q` (`Q` = `int`) | **TS signed** | TS UNSIGNED | **TS signed** |
| h17/h18 | a `$unit`-scope localparam | BARE | BARE, size 64 | unchanged |

The signing token alone decides. The FOLD does not (h1 vs h5), the initializer
shape does not (h2 vs h8), which ternary arm is taken does not (h2 vs h6), and
`byte`/`integer`/`shortint`/`longint` are BARE however signed the language calls
them — `valueRange`'s switch does not name their typespecs. h15 is the arm that
settled the RECURSIVE form: golden types an `int unsigned` localparam's bound
when its initializer is a bare reference to a SIGNED one, so the suppressing
intersection (`declared-signed AND value-signed`) would have been WRONG, and
h15's pristine head was exactly the `vpiSigned 1 / 0` flip.
h17/h18 are the `$unit` arm one branch above the one this pass gates; their
head is a pre-existing SIZE difference (64 vs 32) and is left alone.

### g1-g22 — the call argument

| arm | shape | golden | note |
|---|---|---|---|
| g1, g8 | the enclosing function's own FORMAL (`actual=io_decl`) | **STAMPED** | NestedCallsOfTheSameFunction's shape |
| g10 | a MODULE-level variable (Surelog's `logic_net`) | **STAMPED** | |
| g13 | a body-level **string** local, in the RETURN expression, never evaluated | **STAMPED** | uvm-1.2 `uvm_is_match`'s shape |
| g14, g16 | the same with an INTEGRAL local, assigned / initialised | **STAMPED** | |
| g2, g6, g7, g9, g15, g17, g21 | a body local in a for/while LOOP body | BARE | |
| g18 | a body local under an `if` — no loop at all | BARE | |
| g3, g4, g11, g20 | a body local in a function that IS constant-evaluated | BARE | |
| g12 | a class-method body local | BARE | |
| g22 | the MODULE-function twin of g16 | BARE | we emit nothing there either |

The split is the RETURN-EXPRESSION WINDOW and nothing else: not the variable's
type (g13 string, g14 int, both stamped), not the declaration form (g14
assigned, g16 initialised, both stamped), not the loop (g18 has none and is
bare). That window is already named in this tree —
§ pkgRetTopCallArgFormalTs8's `pkgRetTopExpr8` (`src/StmtEmit.cpp:5779`):
Surelog compiles the elaborated package with `Reduce::Yes` and `compileStmt`'s
`paRETURN` arm is the only arm that threads that reduce down, which is the only
place a never-evaluated body local reaches `EvalFunc` with no value of its own.

**A REFUTED HYPOTHESIS, RECORDED AS REFUTED.** The first spelling of arm A was
"a `*_var` actual is never stamped". It reads TRUE over the whole uhdm2rtlil
golden corpus — `evidence/CENSUS.golden.u2r.callarg.txt`, 28 var-bound call
arguments, 28 of them bare, 0 typed — and it is FALSE on the Surelog corpus,
where `uvm_is_match`'s
```
function bit uvm_is_match (string expr, string str);
  string s;
  s = uvm_glob_to_re(expr);
  return (uvm_re_match(s, str) == 0);
```
is stamped in golden (`ts=string_typespec actual=string_var`, MiniAmiq's golden
at `uvm_globals.svh:403:24`). That build was never swept: the a-priori
prediction (§6) named MiniAmiq, SeqDriver, SimpleUVM, BuildUVMPkg and
Scoreboard — five PROTECTED CONVERTED canary rows — before any sweep ran, and
the guard was narrowed to the measured window instead.

## 5. THE TWO SITES AND THE GATED LAW

* `src/TypeEmit.cpp` ~5469, the PACKED dimension bound builder: the arm minted
  `rt0 -> its0` unconditionally and only let the parameter's sign decide
  `VpiSigned`, so an `int unsigned` / `byte` / `integer` / `shortint` /
  `longint` / unsigned-vector bound carried a ref golden does not write and an
  `int_typespec` that is present and UNSIGNED — a combination golden never
  produces here. Now: `if (r11u48Off || paramValueSigned89(*boundParam, 0))`,
  and the minted typespec is always `VpiSigned(true)` because the producer only
  mints it in the `sval->isSigned()` branch.
* `src/ExprEmit.cpp` ~25245, the call-argument formal-typespec stamp: the
  condition is hoisted into `stampCond48` and gated by
  `subLocalRefArg48 && !pkgRetTopExpr8`, where `subLocalRefArg48` is "the
  actual is a bare `NamedValue` whose symbol is a `Variable` (not a
  `FormalArgument`) declared inside a `Subroutine`, reached through
  `StatementBlock`s only".

Both sites carry the A/B switch the tree already uses for this:
**`R11U48_OFF=1`** restores the pre-pass answer exactly and **`R11U48_DBG=1`**
names, on stderr, every cell whose answer CHANGES.

## 6. THE MOVER SET, PREDICTED BY NAME BEFORE THE PATCHED SWEEP

`predict48.py` re-runs EVERY arm of a pristine workdir with the PATCHED binary
under `R11U48_OFF=1 R11U48_DBG=1`, taking each arm's command line from its own
`cmds.txt` verbatim (binary and `-o` swapped, `shlex` so quoted flags survive)
and its cwd from the arm directory's `sha1[:8]`.

* **NEUTRAL (the positive control that the instrument is wired up at all):**
  uhdm2rtlil **1608 / 1608 SAME, DIFFER 0**; surelog **956 / 960 SAME**, the
  four not-SAME arms proved pristine-nondeterministic by three further runs of
  the PRISTINE binary alone (`evidence/NONDETERMINISM.surelog.txt`: four runs,
  four different databases).
* **PREDICTED MOVERS** (`evidence/PREDICT.u2r.tsv`, `evidence/PREDICT.surelog.tsv`):

```
packed_struct_array_fifo  testflags  R11U48B owner=work@…​.status_cnt_n par=ADDR_DEPTH old=0 new=0
cfg_func_width_loop       testflags  R11U48A arg=i call=q::maxw   (x2)
packed_struct_array_fifo  default    R11U48B …
cfg_func_width_loop       default    R11U48A arg=i call=q::maxw   (x2)
```
  **surelog: ZERO.** The instrument's positive control on that corpus is the
  FIRST, refuted build, whose identical trace named 17 cells across five rows
  there — the census zero is a measured zero, not an unwired one.

## 7. WHAT MOVED

* **byteverify** (SELFCHECK=1, against this pass's own pristine workdirs):
  uhdm2rtlil **MOVERS 4 / 1608** (SELFCHECK 1607/1608 flagged) — the four
  predicted databases and nothing else; surelog **MOVERS 4 / 960** (SELFCHECK
  959/960), which are MiniAmiq and SeqDriver in both modes, PREDICTED ZERO and
  attributed ORDER-BLIND to the documented 4-line `|UINT:` / `|vpiDecompile:`
  class — two runs of the PRISTINE binary alone on MiniAmiq/default and
  SeqDriver/testflags produce exactly that same 4-line class (the positive
  control). Their status stays CMP_EQUAL and `rowheads` reads 0 heads on
  SeqDriver, SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg and Earlgrey_0_1 in
  both modes.
* Attribution, order-blind (both dumps path-normalised and sorted), against the
  row's own golden:

| row | golden-vs-pristine | golden-vs-patched | the delta |
|---|---|---|---|
| `cfg_func_width_loop` ×2 modes | 136 | **122** | −14, PURE REMOVAL of the two `ref_typespec (q::maxw::i)` subtrees |
| `packed_struct_array_fifo` ×2 modes | 218 | **210** | −8, PURE REMOVAL of the one `ref_typespec (work@…​.status_cnt_n)` and its two `int_typespec` lines |

  Every removed line is an OURS-ONLY line. **TO-GOLDEN 22, AWAY-GOLDEN 0,
  STILL-WRONG 0.**

## 8. THE CONVERSION AND THE ADVANCE

`results/*.csv` is READ-ONLY here; the row that CONVERTS is quoted, not edited:

```
results/gate_uhdm2rtlil.csv   packed_struct_array_fifo,testflags,CMP_NOTEQUAL,decompile:,,
results/golden_uhdm2rtlil.csv packed_struct_array_fifo,default,CMP_NOTEQUAL,decompile:,,
```
both now `CMP_EQUAL`. Its dump column reads `differ`, which is exactly
r11u37's R0 content (4 golden-only `work@…​.FifoDepth.ADDR_DEPTH` naming lines
and 8 ours-only `packed_array_typespec` lines): that residue is DUMP-ONLY, not
Compare-visible, which is why the row converts with it still standing.

`cfg_func_width_loop` ADVANCES. Its head is now
```
LHS: logic_typespec: (q::mask_t) @16:11..16:25, |vpiInstance: package q, range 0 : INT 2
RHS: logic_typespec: (mask_t)    @16:11..16:25, |vpiTypedefAlias: …, range 0 : (NF - 1)
```
— the golden-vs-ours `q::mask_t` / `mask_t` naming plus an UNFOLDED range,
which is verbatim what
[tools/probe/r11u34repro/README.md:370](tools/probe/r11u34repro/README.md#L370)
R0 said sits behind this head. The cmp line count goes 8 -> 74 because the head
OBJECT changed and the new one has a big decompile.

## 9. REPRODUCING

```
g++ -O2 -std=c++17 tscen48.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
    -luhdm -lcapnp -lkj -o /tmp/tscen48          # likewise fcarg48, rbnd48
GDIR=grid SLB=<binary> OUT=<scratch> FC=/tmp/fcarg48 RB=/tmp/rbnd48 bash rungrid.sh
python3 predict48.py <pristine workdir> <patched binary> <out dir>
```


## 10. GATES

`evidence/GATES.r11u48.txt` carries every number. In one line: pristine
byte-identical to the main tree at the base; goldens 23/0 and /bin/false 0/23;
uhdm2rtlil 783/21/67 both modes against a pristine 782/22/67, ONE differing row
in each mode and it is the conversion; surelog 474/9 + 469/8 UNMOVED, the only
row-join difference being the SURELOG_FAIL detail string of LowMemLib/LowMemPkg,
which embeds the workdir path (status-only join: 0 lines); byteverify
4/1608 + 4/960 with both SELFCHECKs live; canaries 52 + 8 `changed=0`, ctcan2
PASS twice, canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0`; all six protected
databases byte-identical including both HARD pins; and the four fenced names
appear in 0 patch hunks.

## 11. RESIDUES

* **R0 — `cfg_func_width_loop`'s next head, and it is r11u34's own R0.**
  `logic_typespec` VpiName `q::mask_t` (golden) against `mask_t` (ours), on
  the typespec behind `sub`'s parameter `M`, plus a range golden has FOLDED to
  `0 : INT 2` and we leave as `0 : (NF - 1)`, plus an ours-only
  `vpiTypedefAlias` ref on our copy. Head quoted in
  `evidence/head.law.cfg_func_width_loop.default.cmp`. One test.
* **R1 — the `$unit`-scope folded bound's WIDTH.** Grid h17/h18
  (`localparam int [unsigned] UP = 4;` at file scope, `logic [UP:0] x`):
  golden folds at the parameter's declared width 32, we fold at 64. That is the
  `unitBoundParam` arm one branch ABOVE the one this pass gates, and this pass
  deliberately does not touch it — no corpus row is on it. Both arms also read
  golden BARE, which the `unitBoundParam` arm already gets right.
* **R2 — h15's remaining head, an ordering question in the design `Typespecs`
  vector.** With the law, h15's range bound matches golden field for field in
  BOTH listings (its old head, the `vpiSigned 1 / 0` flip, is gone) and the
  order-blind dump distance falls 7 -> 6; what is left pairs golden's bare
  signed `int_typespec` against the parameter's own located one at the same
  index of the design-level list. Synthetic arm only.
* **R3 — g3's call-argument over-fire, left standing.** g3 (`return w(k)` with
  a body local, in a package function that IS constant-evaluated) is a cell
  golden leaves bare and we stamp; the return-expression window keeps it, and
  its cmp head is elsewhere (an `io_decl` vector). No corpus row is on it; the
  fix needs the "is this subroutine constant-evaluated" half of the model,
  which this pass measured (g3/g4/g11/g20 vs g13/g14/g16) but did not encode.
