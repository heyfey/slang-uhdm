# r10v125 — adversarial verification of r10uvm125 (§ outArgConvLvalue125)

The verifier's report, verbatim (paths under /tmp were its scratch; the ten arms,
the scanner v125scan.cpp, the driver varm.sh, the boundary vbound.sh and the
scorer vscore.py are copied beside this file by the master at landing).

VERDICT: **ACCEPT as shipped** — `/tmp/r10uvm125.patch` (no `.verified.patch`; nothing needed fixing). Every headline number reproduced bit-for-bit from my own build. Two ranked residues below; one of them (R‑1) is new and the implementer's grid did not reach it, but it is **not** a regression and has **zero occurrences in either corpus**.

## 1. Independent reproduction — everything matched

Fresh worktrees `/tmp/wt_v125` (patched) and `/tmp/wt_v125pris` (pristine) at `b39fd59`; both configured and built myself at `-j 2`, frozen `chmod 555` at `/tmp/v125_bin/{pris,pat}.bin`.

| claim | my measurement |
|---|---|
| pristine md5 `6738536fb5b14c9db80873c8707411b5` | **identical**, and equal to the main tree's `build/slang-uhdm` |
| patched md5 `9eeb7f38678c006f7d2bb3ac4d9cfd84` | **identical** (build is bit-reproducible) |
| patch applies clean on fresh `b39fd59` | yes, twice (`git apply -3`, then `git apply --check` in a second clean worktree); surface = `src/ExprEmit.cpp` + `tools/probe/r10uvm125repro/` only; fence check 0/0/0/0; `results/*.csv` untouched; main tree clean |
| goldens 23/0 both binaries, `/bin/false` 0/23 | 23/0, 23/0, 0/23 |
| u2r 679/50/2 both modes both binaries | identical; ct8rows PASS vs committed baseline, vs own pristine tf, vs own pristine def |
| u2r byteverify 0/1358 | **0/1358**, PATH_SETS_IDENTICAL, SELFCHECK 1357/1358 |
| surelog 471/283/25/10/5 + 466/284/23/9/5/3/2/1/1 | identical, 1588 rows, ct8rows PASS vs baseline and vs own pristine, **no row converted** |
| surelog byteverify 9/956, all predicted | **9/956**, and my own a‑priori predictor (scan of all 956 **pristine** DBs for one-operand op82, run before the comparison) named exactly those 9 with counts 7/15/7/13/7 |
| kind delta `operation#82 −7/−13/−15`, `ref_typespec −1` | reproduced on all five row-modes, **every other kind 0** |
| heads 46→12 on SimpleUVM×2, Scoreboard/default, BuildUVMPkg×2; 28/28/240/268/0 unchanged | exact; the five untouched head logs are **byte-identical** pris vs pat; all 12 committed `head_*.cmp` artifacts match mine id-normalised |
| census +7/+13/+13 SAME, −same MOVED-WRONG, ONLY-* unchanged | reproduced with my own scanner/scorer on all five rows |
| wide boundary LISTED=3784 PROCESSED=3784 SAME 7266 NO_DB 294 BYTES_DIFFER 8 | **exact**, with my own driver; RC_DIFF=0, every NO_DB cell rc-equal, and the 8 are exactly `g125_{a_dirs,b_shapes,c_kinds,d_homes}.sv` × both views (the positive control) |
| canaries 52/8 changed=0; ctcan2 ×2 PASS; canaudit 29/0/0 | identical |
| pins | InterfaceModPort / BlackParrotComplex / YosysOldOr SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| cmds.txt by binary path | surelog 1523/1523 name `/tmp/v125_bin/pat.bin`; u2r 1458/1462 (the 4 without a `slang:` line are the 2 SURELOG_FAIL tests × 2 modes, golden-cache lines only); **0** name any main-tree or cross-binary path |

Source claims verified verbatim, not from memory: `sv_vpi_user.h:394` `vpiAssignmentOp 82`; `AssignmentExpressions.cpp:449-453` `isLValueArg()`; `Expression.cpp:289-297` `bindLValue`; `CompileExpression.cpp:2459-2528` (the op82 arm fires only on a `paExpression` sibling and always pushes a second operand; a call argument takes `result = variable`). Golden holds **0** op82 objects of any operand count in all five UVM goldens (measured). Corpus sites confirmed: `uvm_mem.svh:2074` `ok &= uvm_hdl_read(hdl_path, slice)` with `uvm_reg_data_t slice` at `:2072` against the DPI formal `output uvm_hdl_data_t value` (`uvm_hdl.svh:121`), and the differential control at `:2068` (`val`, matching type) is byte-identical golden-vs-ours in **both** binaries. R0 confirmed: `uvm-1.2 src/reg/sequences/uvm_reg_bit_bash_seq.svh:68` is `` string mode[`UVM_REG_DATA_WIDTH]; ``.

**Corpus-wide fact stronger than the pass claimed:** after the patch, **0** one-operand op82 arguments remain in **all 956** patched surelog databases (the pass only measured the nine UVM rows).

## 2. Breaking the law — 10 arms, 5 faces × 6 call kinds × 8 shapes × 3 homes, DEF and ELAB

`/tmp/v125_arms/v{1..10}_*.sv`, driver `/tmp/v125_tools/varm.sh`, my own scanner `/tmp/v125_tools/v125scan.cpp` and multiset scorer `/tmp/v125_tools/vscore.py` (join on call-span × arg index; payload = kind|span|parent-kind@span; ids never in the key). Golden = Surelog, LHS always.

| arm | what it faces | pristine | patched |
|---|---|---|---|
| v1_ports | output/inout **port connections**, converting and matching, named and positional | — | **DBs byte-identical, both views** |
| v2_faces | input / output / inout / **ref** / **const ref**, matching and converting, onto locals and class properties and `this.` | 5 wrong | 1 (span-only) |
| v3_shapes | bare / bit-sel / part-sel / indexed part-sel / member / array elt / dynamic index / unpacked elt / concat lvalue; **same var written then read next line** | 10 wrong | **0** |
| v4_kinds | DPI import function, **DPI import task**, pkg function, pkg task, `method_func_call`, `method_task_call`, `$value$plusargs`, `$sscanf`, `$fscanf`, `$cast` | 8 wrong | **0** |
| v5_homes | module task / module function / initial / always / generate, × **3 parameterised instances** | 6 wrong | **0** |
| v6_exotic | real/shortreal/enum/struct/string formals, two outputs in one call, **named binding**, defaulted trailing formal, queue and dynamic-array elements | 10 wrong | 1 (R‑1) |
| v7_recv | **virtual** method, plain method, **static** method, **chained** receiver, `super.`, `this.`-rooted both ends, **interface modport task** | 5 wrong | **0** |
| v8_ctx | `ok &= f(x)`, if / while / case conditions, both operands of a binary op, `void'()`, fork, for-loop, package-qualified actual | 11 wrong | 1 (span-only) |
| v9_double | enum / int-enum / int / real formals × narrower, wider, int, byte, integer, real actuals | 10 wrong | **4 (R‑1)** |
| v10_stream | **streaming-concat lvalue** `{>>{a,b}}`, plain concat lvalue, nested call, streaming as input | 1 wrong | **0** |

Totals, DEF view: **66 pristine-wrong cells → 7**, **AWAY-GOLDEN 0**, ONLY-GOLDEN and ONLY-OURS **0 in every arm, before and after**. ELAB scores the identical conversions with its ONLY-OURS column unchanged. Re-running the implementer's own four arms with my instruments reproduced their table exactly (9/6→15/0, 16/10→25/1, 11/6→17/0, 8/8→16/0).

**No pristine-right → patched-wrong cell exists anywhere in the grid, the corpora, or the 3784-arm boundary.**

The structural risk I set out to convict — `Expression::bindLValue(expr, type, …)` is *also* how slang binds **output/inout port connections** (`PortSymbols.cpp:83`, `bindExplicitConnection`), so the widened predicate could have reached them — is **refuted by measurement**: slang's AST for `v1_ports.sv` really does mint `Conversion(EmptyArgument)` for three converting port connections (so the arm tests rather than merely agrees), and both DB views are byte-identical between the binaries. Port connections never route through this arm. Separately, `EmptyArgumentExpression` is minted at only four sites in slang and only `bindLValue` puts one on an `AssignmentExpression`'s right, so the predicate cannot fire on a user-written assignment.

## 3. Ranked residues

**R‑1 (NEW, judge-visible, not a regression) — the DOUBLE-CONVERSION copy-back.** slang can wrap the placeholder **twice**: `Assignment(lhs, Conversion(Conversion(EmptyArgument)))`. slang's own `isLValueArg()` strips only ONE level, so `src/ExprEmit.cpp:9096` still falls through to the `argCtx9` branch and mints the one-operand op82 wrapper for those shapes — golden gives the plain ref. Measured in 5 cells (`v9_double` ×4, `v6_exotic` ×1), confirmed against slang's AST JSON:

- `output <enum>` formal ← narrower packed actual, ← `int` actual
- `output <int-based enum>` formal ← `byte` actual
- **`output int` formal ← `logic [1:0]` actual** — no enum involved, the most ordinary shape of the five

Pristine was wrong the same way, so this is a **residue of the law's own statement** ("whether or not the copy-back needs a conversion"), not a regression. It has **zero occurrences in either corpus** (0 one-operand op82 in all 956 patched surelog DBs; 0/1358 u2r movers), which is why it costs no row today. Minimal fix for a later pass, at the same one line, requiring a full re-gate:

```c++
const Expression* r = &ae.right();
while (r->kind == ExpressionKind::Conversion) r = &r->as<ConversionExpression>().operand();
if (r->kind == ExpressionKind::EmptyArgument) return emitExpr(ae.left(), parent, prefix, netMap);
```

**R‑2 (confirmed and widened; judge-invisible) — qualified-actual SPANs unmasked by the wrapper's removal.** The pass's R‑B is real: `hier_path(this.narr)` / `hier_path(this.tt)` carry golden's span over the whole `this.x` where ours stops at `this.`. I found a **second member of the same family**: a package-qualified actual `Ctx_Pkg::pkgVar` — golden `28:15-28:24`, ours `28:15-28:30`, same kind, same name, same parent. Both are dump-only: no generated `Compare` reads `VpiFile`/line/col. Pre-existing, merely revealed.

**R‑3 (documentation nit).** The README's "TO-GOLDEN 7/13/15" conflates op82 object counts with census movement. For MiniAmiq the join moves **+13/−13**, not 15: 2 of the 15 removed wrappers sit at `get_cover_statistics_dpi @512:56` indices 1 and 2, where golden has **no argument at all** (an ONLY-OURS cell) — so those two can never be "TO-GOLDEN". The pass's own `CENSUS.r10uvm125.txt:71` already records `+13 (-13)` and flags the two `<absent>` cells, so only the summary sentence is loose. SeqDriver 13 and the three 7s are exact.

**R‑4 (= the pass's R‑C, verified).** The three bare-`EmptyArgument` pre-unwrap sites at `src/ExprEmit.cpp:18166`, `:18222`, `:18695` are redundant, not wrong: a miss re-enters this arm with the same parent and returns the same object, and the neighbouring `isLiteralExpr(*arg)` branch cannot be perturbed because an lvalue is never a literal.

## 4. Evidence

Frozen binaries `/tmp/v125_bin/{pris,pat}.bin` · sweeps `/tmp/v125_wd/{sl_pris,sl_pat,u2r_pris,u2r_pat}` + six CSVs · heads `/tmp/v125_heads_{pris,pat}` · a‑priori prediction `/tmp/v125_predict.txt`, post-patch corpus scan `/tmp/v125_post.txt` · boundary `/tmp/v125_bound/cells.raw` (7568 cells) · arms `/tmp/v125_arms/`, results `/tmp/v125_wk2/`, implementer's arms re-scored in `/tmp/v125_wk3/` · instruments `/tmp/v125_tools/{v125scan.cpp,vscore.py,varm.sh,vbound.sh}` · worktrees `/tmp/wt_v125`, `/tmp/wt_v125pris`. Nothing was written outside those paths; the main tree is clean at `b39fd59`.
