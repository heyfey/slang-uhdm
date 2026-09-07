**VERDICT: ACCEPT** — `/tmp/r10earl116.patch` (md5 `d958558011c93698bb34b70f47f4389d`) ships unchanged. No `.verified.patch`: I found no pristine-right→patched-wrong cell on legal SV, so there was nothing to fix.

## Every headline number reproduced bit-for-bit

Built both binaries myself in fresh worktrees at `65d82256`, froze them `chmod 555` before any sweep, exported `SLANG_UHDM` per binary.

| | claimed | measured |
|---|---|---|
| pristine md5 | `4712b6510f…` | **`4712b6510fb09e231f72919d866820c9`** |
| patched md5 | `50c2e7ca6b…` | **`50c2e7ca6b5d392f177d89f98e9dba64`** |
| goldens | 23/0 both, 0/23 negctl | identical |
| surelog def | 471/283/25/10/5 | identical |
| surelog tf | 466/284/23/9/5/3/2/1/1 | identical |
| u2r both modes | 679/50/2 | identical |
| `ct8rows` ×5 | PASS, 0 rows | **PASS, 0 differing rows. NO ROW CONVERTED** |
| census accounting | 956 / 1358 processed | identical |
| prediction (pristine only) | 58 cells, 2 rows | **identical, all golden-confirmed; u2r 0** |
| wide boundary | 5127/9834/28/392, rc symmetric | **identical, incl. `A/0 9471 A/3 376 A/4 391 A/139 16` = B** |
| earl115 re-score | AWAY 0, PX TO-GOLDEN 100 | **0 lines differ from `BOUNDARY_arms.txt`; TO-GOLDEN 100** |
| rowheads | Earlgrey/tf 92→36 | **92→36, one head; all 11 other cells identical** |
| canaries / pins | ok=52, ok=8, 10 pins | identical; `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` |

`cmds.txt` audit: 1573/1573 and 1462/1462 files per workdir name exactly one binary — mine — with **0** foreign `slang-uhdm` references anywhere.

**Gate (5) came out cleaner than the implementer's run**: `byteverify SELFCHECK=1` gave surelog **2/956**, not 3 — only the two predicted rows, with no `default/Scoreboard` flip. That independently corroborates their attribution of Scoreboard as the parallel-parse coin rather than a mover. u2r **0/1358**. SELFCHECK 955/956 and 1357/1358, so the comparator sees.

## I verified the decode at the source, not from the write-up

- `cont_assign::DeepClone` gate at [clone_tree.cpp:803](../../git-repos/UHDM/templates/clone_tree.cpp#L803) is verbatim as quoted.
- `bit_select final : public ref_obj` ([bit_select.h:41](../../.local/include/uhdm/bit_select.h#L41)) and `var_select` likewise — so `any_cast` (IS-A) passes and `Actual_group<struct_var>` fails, exactly as claimed.
- `bool flatten = false;` at ExprEval.cpp:823 is **never assigned**, so `VpiFlattened(true)` at :937 is dead. `VpiFlattened` is genuinely not the distinguisher.

**The brief's framing is refuted, and I confirmed it on the real golden database.** Across all occurrences of the two Earlgrey carriers:

```
golden 108:26-119:6 (whole-name Lhs) : ALL-TAGGED 30 , NONE-TAGGED(flat) 58
golden 240:29-251:6 (select Lhs)     : ALL-TAGGED 59 , flat 0
```

Ten `tagged_pattern` operands on both, eleven lines apart in one module — golden flattens one 58 times and the other never. The Lhs shape decides; the operand-loop bail never fires here.

## Adversarial arms — I attacked three faces the implementer never tested

`/tmp/vearl116_arms/{va1_hier116,va2_rep116,va3_ord116}.sv`, scored in this pass's family **and** in earl115's, both views.

1. **Hierarchical whole-name Lhs** (`va1`) — my primary attack. `patFlat9` tests `ExpressionKind::NamedValue`, but slang gives an out-of-module reference `HierarchicalValue`, so I expected golden to flatten where the patch would not. **Refuted**: golden emits a hierarchical reference as a `hier_path` too, failing UHDM's *first* gate. Both sides agree; the two cells moved **TO golden**.

2. **Replicated / type-keyed / `default:`-only / mixed / nested, under both Lhs shapes** (`va2`) — these make slang's `memberSetters` a different length from the operand vector, probing the `ops.size() != memberSetters.size()` guard that is now the only thing protecting the widened call. Guard holds; three more cells TO golden, zero AWAY.

3. **The positional index join, out of order** (`va3`) — my strongest attack. The patch moved `flattenPatternCaRhs` to the wider `patStruct9`, so its `ops[i]` ↔ `memberSetters[i]` join now runs on a **tagged** list it never saw before. If slang ordered setters by source and operands by declaration, a reversed-key pattern would bind `hier_path::Root_value` — a judged field — to the wrong member. I wrote keys reversed, rotated, drawn from two different root arrays (so a mis-join changes the *name*), under select and member Lhs, at 1 and 3 instances. Order-blind multiset of every `(key → value, ROOT)` triple:

```
golden&pristine AGREED triples      : 18
REGRESSION (agreed, lost by patch)  :  0   <EMPTY>
TO-GOLDEN (patch newly matches gold): 39
PATCHED - GOLD                      :  <EMPTY>
```

Not one triple the patched binary produces is absent from golden. The join is order-correct.

All three arms score **AWAY 0 / MOVEDWRONG 0 / NOGOLD_MOVED 0** in earl115's own families; `va3` elab adds **TO-GOLDEN 48** there, so the interplay with earl115's element-bind suppress is right, not merely unbroken. Golden-vs-golden calibration on all 20 earlier-pass arm/views is **100% `SAME_AGREE`, zero phantoms**.

I also confirmed the two arms going fully CMP-EQUAL — `w1_memlhs` and `w4_selmem`, **428/1 → 0/0** elab *and* **416/1 → 0/0** plain — and that the 16 `rc=139` segfaults in the wide boundary are the same 16 files on both sides.

## Collateral: clean

Surface is `src/ModuleEmit.cpp` + `tools/probe/r10earl116repro/` only. 0 `results/*.csv`, 0 slang files, `GOLDEN_DEFER` unset, and the four fenced names appear in **0** files outside `canaudit.sh`'s own `FENCED=` line (`canaudit` audited=29, UNCOVERED=0, FENCE-BREACH=0).

## Ranked residues

1. **R0 (confirmed pre-existing, not created).** The new head is the unfolded genvar in the pattern operand's bit-select index at `tlul_socket_m1.sv:241:32` — golden a folded `constant` (`UINT:0`, `vpiSize:64`, `vpiConstType:9`), ours `ref_obj('i')` on the gen instance's genvar `parameter`. I read the *pristine* head's RHS: the identical unfolded `ref_obj` is already there under `vpiIndex`, one level below where the judge then stopped. The head advanced to a strictly deeper object. Highest-value next target (earl112's genvar-fold family).
2. **R1 (verified, largest remaining population).** The `default` view never flattens — golden is TAGGED for *every* Lhs shape, which my census measured directly as the 30 ALL-TAGGED occurrences at line 108. One corpus `STILLWRONG` row. Needs a view-gated suppression; widening this gate to reach it is cut A, which loses earl114's landed law.
3. **R2 (independently reproduced).** A `struct_net` Lhs fails the same exit; golden TAGGED, we flatten. My `va1` v1 and `va2` r5/r7 hit it. I confirmed there is no clean emission-time predicate: in `va1`, a gen-local struct_net is golden-TAGGED while a module-scope struct_net written from a gen scope is golden-FLAT — the same slang kind on both. Correctly left unshipped; no corpus population.
4. **R3/R4/R5** — as stated; nothing I measured contradicts them.

**One caveat for the integrator, not a defect:** the main tree has advanced to `6ee26f73`. The patch is against `65d82256` and I confirmed `git apply -3` rc 0, 60 files, 0 conflict markers on a fresh `65d82256` — but it has *not* been proven to apply at `6ee26f73`, and the `flattenPatternCaRhs` / `emitBlock` gen-scope region is a known hotspot for sister passes. Re-run the apply and the gate battery at whatever HEAD you land on.

Evidence: worktrees `/tmp/wt_vearl116{,pris}`, frozen binaries `/tmp/vearl116_bin/{pristine,patched}`, workdirs `/tmp/vearl116_wd/`, wide boundary `/tmp/vearl116_wide/W.*`, boundary re-score `/tmp/vearl116_b115/{MYBOUNDARY,CALIB}.txt`, my arms `/tmp/vearl116_arms/`.