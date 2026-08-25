# r10v128 — adversarial verification of r10uvm128 (§ macroSplitRecvIsAstChain128)

The verifier's report, verbatim (paths under /tmp were its scratch; its own arms
and tools are copied beside this file by the master at landing).

**VERDICT: ACCEPT AS SHIPPED.** `/tmp/r10uvm128.patch` (md5 `c125893a7094429efe8a192ad8c7ecf7`) unchanged. No `.verified.patch` — nothing went pristine-right → patched-wrong on any legal SV I could build.

## Reproduced bit for bit, in my own worktrees, from my own builds

`/tmp/wt_v128pris` + `/tmp/wt_v128` freshly checked out at `b7995eb`; patch applied with `git apply -3` (rc 0); production surface is `b/src/ExprEmit.cpp` and nothing else; `results/*.csv` untouched; fence check on all four slang-fenced names = 0 hits outside `canaudit.sh`.

| gate | implementer | **my measurement** |
|---|---|---|
| pristine md5 | `92184b36…` | **`92184b36c03d7e2f698a54f34bf5173a`** |
| patched md5 | `af9f894e…` | **`af9f894eb946239440803abed2945521`** |
| goldens | 23/0, `/bin/false` 23 FAIL | **23/0 patched, 23/0 pristine, 23 FAIL on `/bin/false`** |
| u2r testflags | 679/50/2 | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; ct8rows 0 rows vs baseline, vs own pristine (tf **and** default) |
| surelog histogram | 937/567/48/19/10/3/2/1/1 | **identical**; the two CSVs are byte-identical (`78826a929e12184c3e503430dd030bf7`); ct8rows 0 rows vs `results/golden_surelog.csv`; **no row converted** |
| `cmds.txt` audit | claimed | **6,070 files audited by binary PATH: 0 name any other binary** (slp 1573, slq 1573, u2rp 1462, u2rq 1462) |
| movers | 7/956, 0/1358 | **7/956 — exactly the seven `PREDICT` names — and 0/1358**; SELFCHECK 955/956 and 1357/1358 |
| mover direction | +20 / −0 | **+20 added, −0 removed, order-blind** (Scoreboard/default: ordered sides **112** vs order-blind **20** — the coin is visible and was not attributed) |
| canaries | ok=52 / ok=8 / PASS ×2 / audited=29 | **all reproduced, FENCE-BREACH 0**; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` |
| heads | SimpleUVM ×2 + Scoreboard/def 124→64, rest byte-identical | **reproduced exactly**; all three new head logs are `cmp`-identical to the shipped `head_pat_*.cmp`; new head is `uvm_object_defines.svh:1566` (the pass's own R0) |
| boundary | LISTED=3839 PROCESSED=3839 MOVED=12 | **LISTED=3843 PROCESSED=3843 MOVED=20** (3839 + my 4 arms; 18 movers are pass arms, 2 are `g22.sv`), PROCESSED-ASSERT-OK, no ASYMMETRIC_OUTPUT |

**The added 20 lines are golden's own.** I dumped `~/.cache/slang-uhdm-goldens/02575d101ccaaa38d155/golden.uhdm` (the SimpleUVM golden) and compared: `hier_path (local_data__.abstractions.size) 1978:44-1978:76` / `ref_obj local_data__ 1978:44-56` / `ref_obj abstractions 1978:57-69` / `method_func_call size 1978:70-74` — byte for byte what the patched binary now emits. The patched SimpleUVM database is deterministic (3 runs, one md5 `9d560df0a37e`, equal to the sweep's mover hash).

## Breaking the law — 6 arms, DEF and ELAB

`reg128.py` asks only `REGRESSED = (golden & pristine) − (golden & patched)`.

| arm | def | elab |
|---|---|---|
| A handles | REGRESSED **0**, GAINED 8 | REGRESSED **0**, GAINED 17 |
| B property × method | **0**, 6 | **0**, 12 |
| C operator × position | **0**, 16 | **0**, 32 |
| D home × instance count | **0**, 16 | **0**, 36 |
| E real UVM `` `uvm_field_aa_* `` vs uvm-1.2 | **0**, 9 | — |
| F hierarchical receiver | **0**, 2 | **0**, 4 |

Faces: macro-declared local / hand-written property / formal / `this.` / `super.` / static / package-scoped / class-scoped / two- and three-handle chains / indexed handle / the same macro argument twice; queue, dynamic, assoc-by-string, assoc-by-class, string, scalar-with-no-method; `size` `num` `exists` `delete` `first` `next` and a user method; `==` `!=` `<` `&&` `||`, ternary, bare call statement, `if`/`while` conditions, `return`, a nested arithmetic tree; first / second / both operands; class method, the **real** `` `uvm_field_aa_string_string ``/`` `uvm_field_aa_int_string ``/`` `uvm_field_queue_string `` expansions, free package function, module `initial`, macro-invoking-macro; 1–3 instances. Arm E is the strongest single result: on real uvm-1.2 the pristine binary reports `unsupported: next, num, size` and the patched one reports **none**, gaining six hier_paths **span-exact against golden**. Controls all still: `r10buvm26repro` (2 arms), `r10uvm119repro` (8), `r10uvm124repro` (6), `r10buvm14repro` (1), `r10uvm89repro` (2), `r10uvm77repro` (9), `r10uvm84repro` (23), `r10uvm85repro` (23) — compiled by both binaries, both views, **none moved**.

Two faces have no golden at all: Surelog's parser rejects an escaped identifier as a receiver head (`\esc$h .q.size()`) and a call as one (`get_h().q.size()`).

## Ranked residues (mine, beyond the pass's R0–R3)

1. **A hierarchical receiver loses its instance path — judge-visible, corpus-empty.** `astDottedRecv128` takes `HierarchicalValueExpression::symbol.name`, the **leaf** name, so a receiver written `sub_v.st_v.q` is rebuilt as `"st_v.q"`. Measured (`v128_f_hier.sv`): golden `HP sub_v.st_v.q.size 116:19-116:38` with four elements; patched `HP st_v.q.size` with three (the `st_v`/`q` spans are golden's exactly — only the head is gone). **Not a regression** — pristine drops the operand there (`nops=1` vs golden's `nops=2`) — but `hier_path::VpiName` IS read by `Compare`, and the law's own invariant "each link is the name AS WRITTEN" does not hold for this kind. Conservative minimal form is one line: `case ExpressionKind::HierarchicalValue: return false;`. Zero corpus cells, so it is a next-pass item, not a landing blocker.
2. **The shipped law text is wrong about `this.`** — it says a chain containing `this` DECLINES; it does not. `NamedValue` accepts the implicit self variable (`symbol.name == "this"`, the same fact uvm84's F1 turns on), and arm A cell `f_thischain` proves the law fires: **only** the patched binary emits that operand, and what it emits is golden's own `constant` / `vpiDecompile:this`. Outcome right, sentence wrong, in both `README.md §4`/`R3` and the in-source decode at `src/ExprEmit.cpp:78`. Worth a one-line comment correction at integration so the next pass does not reason from a false gate.
3. **R1 confirmed, and confirmed pre-existing.** The `method_func_call` element END walks off a one-token macro-argument buffer: arm A prints ours `method_func_call:size:10:9-23:4` where golden writes `10:9-10:13`, and it is **identical on the pristine binary for the first operand of every cell**. Every one of my arms' NEW-WRONG rows is this and only this (names and `ref_obj` spans match golden). Line/col is not read by `Compare`, and the corpus head object is span-exact, so it does not bite — but it is the reason a span-keyed census over these arms can never reach zero.
4. **R2 is provable, not merely repeatable.** `r10buvm22repro/g22.sv` contains **zero backtick characters** — no `` `define ``, no `` `include `` — and the law's gate is `sm->isMacroLoc(start) && sm->isMacroLoc(end)`, which no location in a macro-free file can satisfy. The law cannot reach that file. The delta is a constant under the `vpiRightRange` of `typedef int ka_str_t[int];` at `70:28-70:34` whose UINT differs between binaries by exactly one page (22449657 / 22453753) — an address-shaped value leaking into the database, pre-existing and worth its own pass.
5. **Not independently re-measured** (not load-bearing for the landing, since the mover set bounds the blast radius exactly): the pass's R0 census figures (84 cells / 7 UVM DB-modes) and the 87-row negative control in `CENSUS.r10uvm128.txt`. The gate that matters — 7 movers, 0 rows moved on either corpus — I measured myself.

## Artifacts

- Verifier evidence patch (probe-only, **no production change**): `/tmp/r10v128.patch` (md5 `98ae47a8145a5b7b1ab339be367328ab`, 13 files, +847), applies clean on a fresh `b7995eb`, surface `tools/probe/r10v128repro/` only — `README.md`, `VERIFY.r10v128.txt`, `BOUNDARY.r10v128.txt`, `reg128.py`, `varm.sh`, `vattr.sh`, `v128_defs.svh`, `v128_{a,b,c,d,f}_*.sv`. The master may `git add` it alongside the pass, as §6's integration line allows.
- Worktrees `/tmp/wt_v128` (patched) and `/tmp/wt_v128pris`; frozen binaries `/tmp/v128_pris.bin`, `/tmp/v128_pat.bin`; sweeps under `/tmp/v128_wd`; head logs `/tmp/v128_heads_{pris,pat}`; boundary `/tmp/v128_bound2`. Superseded scratch pruned; `/tmp` at 12%. Main tree left clean, no stray files.
