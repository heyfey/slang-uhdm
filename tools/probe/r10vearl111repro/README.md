# r10vearl111 — VERDICT: **ACCEPT** (no fix needed; no `.verified.patch` shipped, because no pristine-right → patched-wrong cell exists)

`/tmp/r10earl111.patch` is sound. Every headline number reproduced **bit-for-bit** from my own fresh worktrees (`/tmp/wt_v111`, `/tmp/wt_v111pris` at `62e24789`) and my own builds. I also broke the law on eleven faces it had not been tested on; it held on all but one wrong→wrong payload cell with zero corpus population (R-V1 below).

## 1. Bit-for-bit reproduction

| | implementer | mine |
|---|---|---|
| pristine binary md5 | `a09a72d01f72de09bd863bd5d20943d4` | **identical** |
| patched binary md5 | `82ecb5ca0ee9caf5bdbaec83db901e6e` | **identical** |
| production sources | — | md5-identical to `/tmp/wt_r10earl111`'s (`src/ExprEmit.cpp` `011492a5…`, `include/UhdmExporter.h` `096a585e…`) |
| patch | clean on fresh `62e24789` | **clean, 0 conflict markers, 0 `results/` edits, 0 fence hits on all four names, `GOLDEN_DEFER` unset (one README mention)** |
| goldens | 23/0, `/bin/false` 0/23 | **23/0, 0/23** |
| u2r both modes, both binaries | 679/50/2 | **679/50/2 ×4** |
| `ct8rows` u2r | PASS ×3 | **PASS ×3, "0 differing ROWS"** |
| `byteverify` u2r | 0/1358 | **0/1358**, `SELFCHECK` 1357/1358, `SELFCHECK1` **exactly 1** (I used the newer `r10yoo1repro/byteverify.sh`; the pass carried the older r10oth4 copy, which lacks the single-corruption control) |
| surelog | 471/10 + 466/9 | **471/10 + 466/9**, pristine == patched |
| `ct8rows` surelog | PASS ×2 | **PASS ×2, 0 differing ROWS** (committed baseline and my own pristine) |
| `byteverify` surelog | 2/956 | **2/956 — `default/Earlgrey_0_1`, `testflags/Earlgrey_0_1`, nothing else** |
| prediction from PRISTINE census only | 44 → MOVE 12 / RISK 32, NO-GOLDEN-KEY 0 | **44 → MOVE 12 / RISK 32, NO-GOLDEN-KEY 0, rows = exactly those two** (my own `censweep111.sh`: LISTED 1573/PROCESSED 956 and 1462/1358, ACCOUNTING PASS, CENFAIL 0) |
| heads | 142/142, 664681/664681, 95, 116/116, 52/52, 31, **17 → 364**, Rggen 0 | **all identical, ONE head each**; 11/12 cmp logs byte-identical; my BEFORE/AFTER Earlgrey-testflags logs are **byte-identical to the committed `HEAD_*` files** |
| mover attribution | ADDED 696 = ELAB 609 + TAIL 87, REMOVED 0 (both DBs) | **same both DBs; REMOVED 0 in the RAW order-sensitive diff too**; all 696 are the seven `ref_typespec`/`int_typespec`/re-printed-constant spellings |
| canaries / ctcan2 / canaudit | 52+8, PASS, 29/0/0 | **ok=52 changed=0, ok=8 changed=0, ctcan2 PASS ×2, canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs | 10 SAME + 2 pins | **10 SAME, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`** |
| census calibration | 20888 / 259 keys, 0 DIFF | **same** |
| wide boundary | LISTED=PROCESSED=4955, identical 9486, DIFFERING 44, no_output 380 | **exactly those five numbers**, rc split identical side for side (A/B: 9141, 364, 389, 16) |

`cmds.txt` audited by binary PATH in all four workdirs: 1523/1523 surelog and 1458/1458 u2r rows carry the frozen `/tmp/v111_{pris,pat}.bin`, **0 carry the main-tree binary**; the four u2r rows with no slang line are the two `SURELOG_FAIL` tests × 2 modes. The head object at `tlul_socket_m1.sv 73:14-73:26` is GONE; the new head is the `hier_path` `tl_h_i[0].a_valid` vs `tl_h_i[i].a_valid` (the pass's R0).

## 2. Breaking the law — four new arms, twenty arm-views

Arms in `/tmp/wt_v111pris`-staged `tools/probe/r10vearl111repro/` (`vA1_rhs111.sv` the RHS-object axis, `vA2_scope111.sv` `$unit`/interface/3-instance, `vA3_sock111.sv` the head shape at 1 and 3 instances, `vA4_bare111.sv` the AWAY hunt: parameter port list + override, generate-IF body, hierarchy).

- **AWAY = 0** — no cell where golden is BARE at a joined key and the patch stamped — across **my 20 arm-views, the pass's 12, the 32 foreign arm-views, and all 2314 corpus databases**. This is also structural, not just measured: `compileParameterDeclaration` always gives an EXPLICIT `int` a typespec, so an admitted golden cell is never bare — golden either stamps it or emits no constant at all.
- **Every changed cell everywhere is `IPS.width`** (84 arm cells, 12 corpus cells; 0 in `IPS.base`/`PS.left`/`PS.right`/`BS.index`/`RNG.*`) — the four predecessor laws' own sites are untouched.
- Wins the pass did not claim: **three per-instance values (1/2/3) matched field for field** on the socket shape at both 1 and 3 instance counts; a dotted read through an **interface port**; the **width-1 mint** (earl55's family) and the `$clog2` shape.
- Corpus census, my own run: surelog **12 changed, all TO-GOLDEN, AWAY 0, MOVED-WRONG 0**; u2r **0 changed**; patched-vs-golden **EDGE 0 in both corpora**.
- Foreign boundary re-scored against golden: **head object IDENTICAL in all 32 arm-views**; 18/32 logs byte-identical, the other 14 added-only `+14/−0` (`r10earl_repro/vc` is `+28/−0` with arena `id:` masked). The two SHAPE `MOVEDWRONG 1` flags (`r10earl65/g2_hier65`, `r10earl84/g3_pos84`) are confirmed multiplicity artifacts — golden has ONE stamped copy, pristine had THREE bare, patched has ONE with golden's exact payload plus two still-bare. `earl104` (16 arms incl. the twelve KEEPs and vb2/vb4), `earl106` (5), `earl109` (6) and `r10vearl109` (4): **byte-identical dumps, 0 arm-views moved**.

## 3. Residues I add (ranked)

- **R-V1 — the RHS-object exception; the "field for field" claim is narrower than stated.** `localparam int unsigned B = pk::PK;` used as the folded width: golden's stamp is the **package parameter's own object** (`int_typespec inst='pk' sg=1`), because `CompileExpression.cpp:2900/2969` copies the declaration typespec only when the cloned RHS carries none (`res->Typespec() == nullptr`) — and here the clone already carries the package's. This law mints a bare `sg=0` one, differing in `Instance` and `VpiSigned`, both judge-read. **Not a regression** (the cell was BARE, so wrong→wrong, never right→wrong) and **corpus population 0**. Right fix is R1's: a module-side parameter-object map plus a test on whether the clone would carry its own typespec. Reproduced at `vA1_rhs111.sv:33`, both views.
- **R-V2 — the pass's R4 over-fold reaches three more scopes than `g3_scope111` measured**: a `$unit`-scope localparam, a read inside an interface, and a **generate-IF body**. Golden emits a `ref_obj` in each, so the cell already fails on `VpiType`; the patch adds a typespec to a constant golden does not have. Pre-existing (pristine emits the same constants), population 0. It is what moves `vA4`'s head to its line 31 after the pass's own family clears — one head, on an object the pristine binary was already wrong about.
- **R-V3 — bookkeeping**: `g5_neg111` c2 is written up as "stamped, golden's object exactly". The typespec payload does match, but golden's constant there is `vpiConstType 7` where ours is `9`, so the cell is still unequal for a pre-existing reason and the two sides do not join on the census key. Nothing moved; the claim is just narrower than written.

## 4. Artifacts

- Implementer's patch verified as-is: `/tmp/r10earl111.patch` (unchanged, ACCEPT).
- Verifier evidence patch (probe-only, applies clean on fresh `62e24789` **and** on a tree with the pass applied): `/tmp/r10vearl111.patch`, md5 `e36cc3c0f770555a55695243126dbc99`, 18 files under `tools/probe/r10vearl111repro/` — README, the four arms + `TOPS.txt`, `vaway111.py`, `vcorpus111.py`, `GRID_SCORE`, `FOREIGN`, `BOUNDARY_WIDE.*`, `MOVER_*`, `PREDICT`, and my own `HEAD_{BEFORE,AFTER}_Earlgrey_testflags.cmp`.
- Frozen binaries `/tmp/v111_pris.bin` / `/tmp/v111_pat.bin` (`chmod 555`); sweep workdirs `/tmp/v111_wd_{pris,pat}` and CSVs left in place; large scratch (dumps, wide stage, probe copy) pruned. Worktrees `/tmp/wt_v111`, `/tmp/wt_v111pris` left in place, both clean apart from the pass's two production files in `/tmp/wt_v111`.