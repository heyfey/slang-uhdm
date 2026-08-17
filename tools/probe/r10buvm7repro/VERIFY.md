# r10buvm7 — ADVERSARIAL VERIFICATION (r10vbuvm7)

Independent verifier: fresh worktrees `/tmp/wt_vbuvm7` (patched) and
`/tmp/wt_vbuvm7pris` (pristine) at BASE 5c132aa, BOTH BINARIES BUILT HERE at
`-j 2`.  LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.

**VERDICT: the production hunk is ACCEPTED UNCHANGED.**  Every headline number
in the implementer's report reproduced bit-for-bit; no `pristine-right ->
patched-wrong` cell was found on legal SystemVerilog in 17 adversarial arms
(129 inc/dec cells, 100 of them new here), and the corpus-scale REVERSE census
(below) finds ZERO wrong collapses over all 2311 databases of both corpora.

## 1. Reproduced bit-for-bit

| claim | implementer | measured here |
|---|---|---|
| pristine md5 | 8e90e5e318029d1336b1c447d9f8356e | SAME |
| patched md5 | 2a1259014e4c044da1e0ff9fe5caf7a1 | SAME |
| golden-cache census (3673 DBs) | incdec=69971 PLAIN=63794 SEL=990 PATH=3811 WIDEREF=1368 WIDESEL=0 OTHER=8 | SAME, RESTORE_FAIL=0 |
| prediction, surelog | MOVER=7 CLEAN=946 NOGOLD=0 | SAME, same 7 rows + per-row position counts |
| prediction, uhdm2rtlil | MOVER=0 CLEAN=1358 | SAME |
| goldens | 23/0 both binaries, /bin/false 0/23 | SAME |
| u2r rows | 679/50/2 per mode, 0 vs committed, 0 vs pristine (1462) | SAME |
| surelog rows | 470/10/5/284/25 and 466/7/5/3/1/286/23/1/2, 0 vs committed (1588), 0 vs pristine | SAME |
| byteverify surelog | 7 movers / 953 (named), SELFCHECK 952/953, SELFCHECK1 8 | SAME |
| byteverify u2r | 0 / 1358 | SAME |
| attribution | RESIDUE 0 on all 7 | SAME (7/7 OK) |
| BuildUVMPkg head | 66 -> 17 cmp lines, both modes, cross-mode byte-identical | SAME |
| ladder | 253 -> 251 both modes, diff = exactly 2 `ref_obj|VpiType|KIND:ref_obj>hier_path` rungs removed, 0 added | SAME |
| five-row wall | SimpleUVM 1405511, SeqDriver 1450011, Scoreboard 1399779, five cmp logs byte-identical | SAME |
| pins | SVSwitch 4842211c4030, YosysVerx 6ccda350c24a | SAME |
| boundaries | 145 protected arms MOVED=0 RESIDUE=0 (v79v1-v6 included) | SAME, own arm as positive control (460 lines / 17 flips / RESIDUE 0) |
| v1 grid | golden PATH=5 WIDEREF=18 WIDESEL=2, pristine PATH=25, patched PATH=7 WIDEREF=18, dumpdiff 673->242 | SAME |

## 2. The adversarial arms (`v7v_*.sv`, run with `v7v_arm.sh`)

| arm | what it attacks | result |
|---|---|---|
| A_scope | package-var base, class-static base, hierarchical `inst.arr[i].f++`, self-hier | 4/9 exact; hierarchical correctly NOT collapsed; `pkg::`/`C::` = RESIDUE R5 |
| B_escape | escaped names, incl. one CONTAINING BRACKETS (`\arr[0] `) and one CONTAINING A DOT (`\my.name `) | 5/5 exact KIND+NAME+FULLNAME (`arr[0]`, `my.name`); the four escaped cells' SPANS are unchanged from pristine and 4-9 cols short of golden's -> R8, an R1-family span residue, NOT a regression |
| C_index | `q[$]`, assoc string key, function-call index, `pkg::K` index, nested-select index, ternary index, 2 dims | 8/8 EXACT, arm reaches PASS_CMP (dumpdiff 286 -> 24) |
| D_member | union member, packed-struct member, member depth 3 | 6/6 EXACT |
| E_ctx | for-STEP position, ternary, concat, call arg, while/do-while/repeat/case/unique-case/assert action, package function, interface task, constructor, static method, generate-for, final, program | 20/20 EXACT |
| F_trail | trailing `[1]`, `[3:0]`, `[+:2]`, `[-:2]`, middle-select | R2 residues UNCHANGED from pristine (no regression); the two claimed cells convert |
| G_ref | inherited property, `this.`, `super.`, ref formal, automatic local | 6/8 exact; `this.` unchanged (golden BAD_SYMBOL); `super.` = RESIDUE R6 |
| H_super / I_pkgsel | the two residues in isolation, dump-distance measured | 26->17 and 135->135: patched is never FARTHER from golden |
| J_iface | handle chain, MULTI-LINE lvalue, macro-expanded lvalue, INTERFACE ARRAY element | 3/5 exact incl. multi-line and macro; interface array = RESIDUE R7 |
| L_mint | the SECOND law: out-of-body method, mint + SPAN | golden's 2 nets minted at the WHOLE-LVALUE span, pristine mints NONE, patched EXACT; PASS_CMP |
| M_order | mint ORDER: a plain read of the same property BEFORE / AFTER the inc/dec, two collapses on one name | golden mints at the INC/DEC's span, never the read's; patched EXACT on all three; PASS_CMP |
| N_param | parameterized class (the clone path), always_ff, program block, unnamed block | 5/5 exact; patched also REMOVES a spurious `work@topN.W` net pristine minted |
| O_macro | base from a macro, member from a macro, loose spacing, comment inside the lvalue | 4/4 EXACT, dump distance **0** |
| P_import | wildcard-imported package variable as base | exact |
| Q_unit | `$unit`-scope class (no home package -> no mint), `$root.`-qualified | Q1 exact and correctly mints nothing; `$root.` = RESIDUE R5 family |

## 3. The REVERSE census (`v7v_reverse.sh`) — the verifier's own instrument

The implementer's `predict7.sh` asks "where MUST we move?".  This asks the
adversarial question: **where did we collapse and golden did NOT?**  Joined on
line:col-span over every database of both patched sweeps:

```
surelog     rows=953   WRONGCOLLAPSE=0  MISSED=0  NOGOLD=0
uhdm2rtlil  rows=1358  WRONGCOLLAPSE=0  MISSED=0  NOGOLD=0
```

So on every joinable inc/dec position of both corpora the patched operand shape
now agrees with golden EXACTLY — including the 4 corpus occurrences of the
NON-collapsing `a.b[i].c++` shape (e.g. `uvm_factory.svh:1373`
`qc.queue[index].used++`), which stay hier_paths.

## 4. Nondeterminism: the implementer's `PERMUTED` mover, settled on the PRISTINE side

4 runs of the **PRISTINE** binary on `default/Scoreboard` produced THREE
distinct databases (`66db58c3ff12` x2, `95516c83d036`, `b5cb65c52e6b`); their
dumps differ by up to 170 raw lines with **multiset diff 0** (pure permutation).
The patched binary produced one md5 4/4 here, and this sweep's attribution reads
`SAME_ORDER RESIDUE=0`.  The phenomenon is therefore pre-existing and provably
independent of this law.

## 5. Ranked residues found by the verifier (all corpus-ZERO, none fixed)

* **R5 § lvIncDecFirstIdentName** — when the lvalue's FIRST identifier is not
  the base variable, golden names the collapsed ref after THAT identifier:
  `pkA::parr[2].used++` -> `ref_obj(pkA)` + a minted `work@top.pkA` net;
  `cstat::sarr[3].used++` -> `ref_obj(cstat)`; `$root.topQ.marr[1].used++` ->
  `ref_obj(topQ)`.  We name the base (`pkA::parr`) or keep the hier_path.
  ZERO occurrences in either corpus (validated grep).
* **R6 § lvIncDecSuperCollapse** — slang STRIPS `super.`, so `super.barr[2].used++`
  collapses here while golden emits `hier_path(super.@@BAD_SYMBOL@@)`.  Dump
  distance still improves (26 -> 17).  ZERO corpus occurrences.
* **R7 § lvIncDecIfaceArray** — `ifa[0].cnt++` on an INTERFACE INSTANCE ARRAY:
  golden collapses, we keep the hier_path (slang's base is not a NamedValue).
  Corpus-zero, proven by `MISSED=0` above.
* **R8 § lvIncDecEscapedSpan** — golden's whole-lvalue span for an lvalue
  containing ESCAPED identifiers is INFLATED past the visible text (+4 cols per
  escaped identifier: `\plain [1].used++` 10:5-10:**24** where the text ends at
  20; `\plain [2].\esc.mem ++` 13:5-13:**33** vs 24).  Ours is the true text
  span, IDENTICALLY in both binaries (pristine hier_path 10:5-10:20 = patched
  ref_obj 10:5-10:20), and the escaped variables' DECLARATIONS agree exactly, so
  this is R1's family on escaped identifiers, span-only and invisible to
  uhdm-cmp.  ZERO corpus occurrences.
* **HARDENING (not a defect today)** — the collapse arm returns before the
  `suppressConstParent` / `forceConstParent` restore.  Verified inert: the only
  writer above it is gated on `unaryLitOperand`, which requires a literal
  operand and is mutually exclusive with the MemberAccess operand this arm
  needs.  A future law that sets those flags for a non-literal operand would
  leak state through this return; restoring them before it is a zero-behaviour
  change worth making then.
