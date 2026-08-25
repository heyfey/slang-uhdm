# r10v132 — adversarial verification of r10uvm132 (§ macroPasteRecvMisreadIsAstChain132)

The verifier's report, verbatim (paths under /tmp were its scratch; its own arms
and tools are copied beside this file by the master at landing).

All measurements complete. Final report:

# r10uvm132 — VERDICT: **ACCEPT AS SHIPPED**. No fix was needed; no `.verified.patch` is produced.

Independent worktrees `/tmp/wt_v132` (patched) and `/tmp/wt_v132pris` (pristine) at `f611e1b`, plus a throwaway census worktree, all built and measured by me. `/tmp/r10uvm132.patch` (md5 `ae0d7e8b03bb86887f9238513b4028bf`) applies to a fresh `f611e1b` under **plain `git apply --check`** (not just `-3`). Surface audit: `src/ExprEmit.cpp` + `tools/probe/r10uvm132repro/` only — **0** files under `results/`, no slang patch, fence check 0/0/0/0, no stray files written outside my worktrees and `/tmp/v132_*`.

## 1. Bit-for-bit reproduction — every headline number

| claim | implementer | **my own measurement** |
|---|---|---|
| pristine binary md5 | `f102bcba68a7d9317c746b848792fda1` | **identical** |
| patched binary md5 | `38620ff3a1d1005fa8cdac79dd83c3a2` | **identical** |
| goldens pris / pat / `/bin/false` | 23-0 / 23-0 / 0-23 | **identical** |
| u2r testflags **and** default | CMP_EQUAL 679 / SLANG_REJECT 50 / SURELOG_FAIL 2 | **identical, both binaries** |
| surelog per-mode histogram | def 471/283/25/10/5; tf 466/284/23/3/9/2/5/1/1 | **identical, both binaries** |
| ct8rows vs committed baselines **and** vs own pristine | PASS ×4 | **PASS ×6** (sl, u2r_tf, u2r_def; baseline and pris-vs-pat) — 0 of 1588 and 0 of 731 rows differ, **no row converted** |
| byte movers | 7/956 sl, 0/1358 u2r | **identical**, same 7 paths, same md5 pairs |
| SELFCHECK | comparator can see | 955/956 and 1357/1358 |
| heads | SimpleUVM×2 + Scoreboard/def CLEARED; other 9 byte-identical | **identical** — and all 12 committed `head_pris_*.cmp` **and** all 3 `head_pat_*.cmp` reproduce **byte for byte, object ids included** |
| new head | `struct_var (uvm_pkg::uvm_reg_map_info::mem_range)` `uvm_reg_map.svh:29:27` | **identical on all three row-modes** |
| canaries / ctcan2 / canaudit | ok=52, ok=8, PASS×2, audited=29 UNCOVERED=0 FENCE-BREACH=0 | **identical** |
| protected DBs | SAME; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **identical** |
| wide boundary | LISTED=3881 FENCED_SKIPPED=0 PROCESSED=3881 MOVED=12 NO_OUTPUT_PAIRS=284 ASSERT-OK | **identical** |

`cmds.txt` audited **file by file, by binary path**: pris/sl 1523 lines all `/tmp/v132_bin/pris.bin`, pris/u2r 1458, pat/sl 1523, pat/u2r 1458 — **OTHER-BINARY = 0** in all four.

## 2. The census, re-measured with my OWN instrument (the shipped one is not reproducible)

The pass's census binary is not shipped. I built my own (`VCEN132`-gated `fprintf`, third worktree) and ran it through an adapted `cen132.sh` over my own pristine surelog workdir:

```
LISTED 1573  PROCESSED 1523  SKIPPED-NO-SLANG-LINE 50  SWAPFAIL/NODIR 0
```

| | README | **mine** |
|---|---|---|
| built-in receiver reads | 23,709 | **23,709** |
| `recv->syntax != NULL` | 0 | **0 of 23,709** |
| the law's gate fires | 84 (7 db-modes × 12) | **84**, and the 7×12 split is exactly SeqDriver def+tf, SimpleUVM def+tf, Scoreboard def, MiniAmiq def+tf |
| § `…AstChain128`'s own cells | 7 | **7** (1 per db-mode) |
| CORRECT macro-located reads | 739 | **739** |
| file-located reads mismatching | 0 | **0** (of 22,879) |
| chain declines | 1,793 | **1,793** |
| **mismatch where neither law fires nor is fenced** | 0 | **0** — the safety claim holds |

## 3. My own a-priori mover prediction — 0 false positives, 0 false negatives

Written from the **pristine databases only**, before any pris-vs-pat comparison: a DB moves iff its pristine dump holds a `hier_path`/`ref_obj`/`method_func_call` whose **first name component is not a legal SV name**. (Two earlier cuts over-fired — index decompiles carry spaces (`q[i + 1]`) and fullnames carry `work@top` / `pkg::cls::f`; that is a census trap worth recording.) Over 956 databases it named **exactly seven**, and they are exactly the seven `byteverify` found. The misread token `ZE(ARG` appears in **7 pristine DBs and 0 patched DBs**.

Attribution, path-normalised, id-stripped, **order-blind** (Scoreboard/default is the coin), all seven:
`OUT=75 IN=75 · AWAY(added-not-golden)=0 · MOVED-WRONG(removed-is-golden)=0`.

## 4. Breaking the law — 9 adversarial arms × DEF/ELAB, plus 12 committed control arms

Arms in `/tmp/v132_scratch/arms/`, scored by my own independent multiset census (`vscore132.py`, keyed on KIND|NAME|SPAN) and a regression detector (`vreg.py`: rows the **pristine matched golden on that the patched lost**).

| arm | what it varies | def PRIS→PAT (SAME/ONLY-G/ONLY-O) | elab | **regressions** |
|---|---|---|---|---|
| v1_space | paste × bare / dotted / `h2 . qi` (spaces) / `h3/*c*/.qi` (comment) / arg-used-twice / 3-deep nest | 46/43/35 → **78/11/11** | 91/87/71 → **156/22/22** | **0** |
| v2_kinds | queue prop / method local / `ref` formal / assoc (`exists`,`delete`,`num`) / user method / pkg var / module var / `initial` / `always` | 36/63/63 → **98/1/1** | 76/136/137 → **206/6/6** | **0** |
| v3_idx | uvm128's `m_streams[k].qs.size()` control, in plain source **and** inside a paste; queue-of-queue `q[0].size()` | 17/15/8 → **25/7/0** | 33/31/17 → **50/14/0** | **0** |
| v4_home | macro **defined in the same file as its use**; names of 3 lengths; 3 instances | 16/26/14 → **42/0/0** | 46/122/74 → 132/36/36 | **0** |
| v5_fence | `this.` / `super.` / `pkg::` receivers, all inside a paste | **0 dump lines differ** | **0** | **0** |
| v6_esc | escaped id as a macro **argument** | slang rejects — identical rc and identical stderr on both binaries | " | **0** |
| v7b_more | **3-component** receiver through a paste; the macro **argument is itself a macro** | 9/17/12 → **26/0/0** | 17/35/25 → **52/0/0** | **0** |
| v8_esc | escaped id in a macro **body** through a paste (slang-only) | **0 dump lines differ** | **0** | **0** |
| v9_odd | multi-line macro argument; struct-member receiver; static class property; virtual-interface receiver | 18/42/26 → **48/12/4** | 36/85/53 → **97/24/8** | **0** |

Committed control arms, both views, **0 dump lines differ in every one**: uvm128's `g128_a_handles`/`b_props`/`c_ops`/`d_homes`/`e_inst`; uvm124's `g124_a_kinds`/`b_meths`/`c_homes`/`d_chain`/`e_expr`/`f_fence`; buvm14's `a1_dims14`.

The three "LOST" rows `vreg.py` flagged in ELAB (`int_var`/`string_var` on `v2`, `v3`, `v7b`) are **not regressions**: they are inlined `vpiActual` back-references whose kind flips once the receiver name resolves — golden holds 5×/6× `array_var` where pristine held 2×/2× and patched holds **5×/6×**, net strictly toward golden.

The two non-arm wide-boundary movers (`r10buvm22repro/g22.sv`, 12 lines each view) are a **binary-layout constant**, re-confirmed here across three binaries × two runs each: pris `22466073`, pat `22470169`, main-tree `22478425` — deterministic per binary, steps of 4096, not this law's.

## 5. Reasoning check on the gate itself

For a **single-name** receiver the gate reduces to *(written span width == bound name length) && (rawText != bound name)*. Pristine's name is `rawText`, so a fire implies pristine was already wrong unless **golden** spelled the written token rather than the symbol — impossible here, because Surelog compiles the **preprocessed** stream where the receiver is spelled as the symbol. Escaped identifiers and scoped names fail the width test (fit=2), measured. `this`/`super` are excluded by name. So the only reachable fire-and-be-wrong shape is span placement, and `Compare` does not read line/col. `astDottedRecv128` is now invoked for every macro-located receiver (pristine short-circuited on the two-buffer test) — it is side-effect-free, the vector is cleared off both laws, and the 128 branch's condition is character-for-character the pristine one; measured 0 change on all uvm128 arms.

## 6. Ranked residues

1. **R0 (the pass's own, confirmed and bounded)** — the call-name END span wherever *neither* law fires: 739 correct macro-located reads are exposed to the same raw-offset walk. My arms reproduce it independently: v1's declined cells read `method_func_call size 5:25-15:4` where golden writes `5:25-5:29`. **The biggest remaining head-adjacent population.**
2. **R-A (NEW, mine)** — a dotted receiver written with **whitespace or a comment** around the dot inside a paste (`h2 . qi`, `h3/*c*/.qi`) is *declined*, so its call spans stay on R0's fallback. Not a regression (pristine identical), but the README's "the paste is the discriminator" grid does not cover this shape, and it is the one place where `recvText.size()` could change and shift `mStart9`/`methodParensWritten77` if the gate ever widened.
3. **R-B (NEW, mine)** — a **virtual-interface receiver** (`iv9.qif132.size()`) inside a paste: we emit **no `hier_path` at all** where golden emits one plus two elements (12 ONLY-GOLDEN rows, arm v9). **Pre-existing in both binaries**, untouched by this law, and a clean next-head candidate.
4. **R-C (NEW, mine)** — `setColSpan132` forces `VpiEndLineNo == VpiLineNo`. A receiver whose written span crosses a line inside one expansion buffer would be collapsed. Census says 0 such cells on either corpus, and `Compare` does not read line/col, so this is dump fidelity only.
5. **R-D (evidence hygiene)** — `MOVERS.r10uvm132.txt` says "13 DISTINCT added / 28 DISTINCT removed" for SimpleUVM/default; my whole-dump, id-stripped, order-blind diff gives 54 / 52 on all seven (their count is scoped to the 837-line region). Both give **75 out / 75 in, AWAY 0, MOVED-WRONG 0** — the conclusion is unaffected; only the bookkeeping line deserves a scope note.
6. **R-E (reproducibility)** — the census binary is not shipped, so §5's table is not reproducible from the committed artifacts alone. I closed this by rebuilding an equivalent instrument; the numbers all hold. `cen132.sh`'s shared-`>>`-redirect trap is real and its `PROCESSED+SKIPPED+FAIL == LISTED` assert **caught my own polluted-scratch rerun**, which is a good sign for the guard.
7. R1–R4 as the implementer states them (user-method twin, out-of-body ELAB fullname/three-copies, `this.`/`super.` in a paste, the `VAL` argument's `ref_obj` end span) — all confirmed pre-existing and identical pristine and after.

**Artifacts kept:** frozen binaries `/tmp/v132_bin/pris.bin`, `/tmp/v132_bin/pat.bin`, `/tmp/v132_bin/cen.bin`; workdirs `/tmp/v132_wd_pris`, `/tmp/v132_wd_pat` (available for control rotation); heads `/tmp/v132_scratch/heads_pris`, `/tmp/v132_scratch/heads_pat`; census `/tmp/v132_scratch/cen2_sl.tsv`; predictor output `/tmp/v132_scratch/pred3_sl.txt`; adversarial arms and scorers `/tmp/v132_scratch/arms/`, `/tmp/v132_scratch/vscore132.py`, `/tmp/v132_scratch/vreg.py`, `/tmp/v132_scratch/varm.sh`, `/tmp/v132_scratch/vattr.sh`, `/tmp/v132_scratch/vcen.sh`. Boundary and attribution scratch (3.8 GB) pruned; census worktree removed and `git worktree prune` run. The main tree was never written to.
