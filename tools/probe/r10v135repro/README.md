# r10v135 — adversarial verification of r10uvm135 (§ assocIdxNameHoistNet135)

The verifier's report, verbatim (paths under /tmp were its scratch; its own arms
and tools are copied beside this file by the master at landing).

# r10uvm135 — VERDICT: **ACCEPT AS SHIPPED.** Land `/tmp/r10uvm135.patch` unchanged (no `.verified.patch`).

Every headline number reproduced **bit-for-bit** on my own build from a fresh `f08eee05` worktree. I found **no pristine-right → patched-wrong cell on legal SV that is not a provably inherited shared-pool residue** — each one I found, I refuted with a §130-family CONTROL run on the **pristine** binary. Two of my twelve adversarial arms **convert to CMP_EQUAL** under the official judge.

## 1. Reproduction (my own build, my own frozen binaries, my own sweeps)

| | claimed | measured by me |
|---|---|---|
| pristine md5 | `583b10a735e405dcfaeb2f49695d6632` | **identical** |
| patched md5 | `a8d181a5efe5cb64ae89d780f8ebadd2` | **identical** |
| goldens | 23/0, `/bin/false` 0/23 | patched **23/0**, pristine **23/0**, `/bin/false` **0/23** |
| uhdm2rtlil | 679/50/2 both modes both binaries | **identical**, all four sweeps |
| u2r `ct8rows` ×3 | PASS | **PASS ×3** (committed baseline + my own pristine tf + def) |
| u2r byteverify | 0/1358 | **MOVERS 0/1358**, `PATH_SETS_IDENTICAL`, selfcheck **1357/1358** |
| surelog | 1588 rows, CMP_NOTEQUAL 19 | **identical on both binaries**, per-mode histogram matches `GATES` §4 line-for-line; **no row converted** |
| surelog `ct8rows` ×2 | PASS | **PASS ×2** |
| surelog byteverify | 4/956, the four named | **MOVERS 4/956** — exactly `{default,testflags}×{SeqDriver-32af76aa, SimpleUVM-1dc93a62}`; `PATH_SETS_IDENTICAL` (956), selfcheck **955/956** |
| mover attribution | +13 / −0 each | **ADDED=13 REMOVED=0 on all four**, order-blind; every added line is the one `logic_net`@1664:21-1664:30, its parent/name/fullname/netType and three `vpiActual` edges |
| FENCE | HIT 4→0, OTHER 0, MIRROR 6 unchanged | `FENCE.pristine.surelog.tsv` and `FENCE.patched.surelog.tsv` **reproduce byte-for-byte**; MIRROR set byte-identical before/after; u2r fence **0/0/0** both binaries |
| golden-vs-golden calibration | EXPM_N=0, 471 rows | **5 pairs, 0 SKIP, 0 DIFFER, 471 rows, EXPM_N=0** |
| direction census | AWAY-GOLDEN 0, MOVED-WRONG 0 | **AWAY-GOLDEN 0, MOVED-WRONG 0** over the nine UVM databases |
| heads | SeqDriver 17→80, rest byte-identical | **confirmed**; all four shipped `.cmp` logs are **byte-identical** to mine, Scoreboard/default included (the coin did not flip) |
| canaries | ok=52 / ok=8 changed=0, ctcan2 ×2, canaudit 29/0/0 | **identical** |
| protected DBs | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **identical**, all five byte-identical pristine-vs-patched |

**Hygiene:** patch applies clean on a fresh `f08eee05`; regenerated `git diff` has the **identical file surface** (4 production files + `tools/probe/r10uvm135repro/` only, 192 insertions / 3 deletions); the four fenced names appear **0** times; `results/*.csv` untouched; `GOLDEN_DEFER` unset. **cmds.txt audit BY PATH: 1523 pristine + 1523 patched (surelog), 1458 + 1458 (u2r), and `grep -l 'build/slang-uhdm'` returns 0 files** — no main-tree binary anywhere. The `rm -rf` sites in the probe drivers are all `mktemp -d` handles or `${OUT:-/tmp/r10uvm135_*}` overridables; no shared scratch is hard-coded.

## 2. The Surelog decode — read in the source, CONFIRMED

`compileRanges`'s `paConstant_expression` arm (`~/git-repos/Surelog/src/DesignCompile/CompileExpression.cpp:4060` in my checkout — the pass cites `:4166-4196`, the code is verbatim as described) does call `compileExpression` **first**, and only afterwards, under `rexp->UhdmType() == uhdmref_obj && reduce == Reduce::Yes && compileTypespec(...)`, builds the fresh `[UINT:0 : STRING:associative]` range and `continue`s — discarding the range and the already-pooled `ref_obj`. `getObject`'s `component->getDataType(name)` arm (`:249-253`) returns a **typespec** for every typedef, so no `ref_obj` is minted for one; `needLateBinding` is at `:5778`. Grammar `SV3_1aParser.g4:1195-1199` / `:1206-1216` matches. **The law's mechanism is real, not inferred.**

## 3. Breaking the law — 12 new arms, both views, 78/78 cells rc=0, all binaries audited by path

**Index-type faces beyond a1 (`v135_b1`)** — TO-GOLDEN 3, AWAY 0: an **interface class** → wire ✓, a **virtual/abstract class** → wire ✓, an **imported class name** → wire ✓; packed-struct typedef, unpacked-struct typedef, packed-union typedef, typedef-of-a-specialization, typedef-of-a-typedef-of-a-class → **none, matching golden** ✓.

**Collisions in the importing top (`v135_b3`) — CMP_EQUAL, 1 head → 0, both views.** Golden's implicit-net set and the patched set are **identical row for row**: the name also a `wire` → binds the declared net, **no duplicate**; also a `logic` **variable** → no duplicate (it lands in `Nets` as `netType 36` on both sides); also a `parameter` and a `localparam` → **suppressed** (§ `hoistedNetNeverOverAModuleParam117` holds for this reference kind); **two associative arrays with the same index class → ONE wire**, exactly golden's one.

**More collisions (`v135_b8`) — CMP_EQUAL, 1 head → 0, both views**, TO-GOLDEN 3: the index class name also naming a **module**, an **instance**, and a **genvar**.

**Yet more (`v135_b12`)** — TO-GOLDEN 3, AWAY 0, MOVED-WRONG 0: name also a top-level **port** (no duplicate), a top-level **function**, a top-level **typedef**; and the **same class indexed from two different packages** → **one wire**, golden's one.

**Homes (`v135_b2`, 16 homes)** — 1 NET + 4 AIDX TO-GOLDEN, AWAY 0, MOVED-WRONG 0; class property / static property / in-body formal / in-body local / `extern` prototype → **none**, controls hold.

**Multi-dimensional and mixed (`v135_b10`)** — TO-GOLDEN 3, AWAY 0: `[clsA][clsB]`, `[cls][string]`, `[string][cls]`, `[cls][*]` all land on golden's names **and golden's spans**.

## 4. The three AWAY/MISS families I found — each refuted as INHERITED by a pristine-binary control

1. **R-MULTI (`v135_b4`: MOVED-WRONG 1).** Three tops, one calls: golden mints in the caller only; patched also mints in the **importing-but-never-calling** top (pristine had none). Its head trades object rather than count (pristine head = the missing net in `topOneXray4`; patched head = `module_inst work@topTwoYankee4` Nets size). **CONTROL `v135_b6`**: the same three-top shape with a § 130 `new[<local>]` name — the **PRISTINE** binary mints `ctlSizeEcho6` in the non-calling top and golden does not. The spread is `collectMaterializedPkgs`'s, shared by §§107/117/130; a 135-only fix would contradict the shared pool and move committed control cells, so I did **not** fix it. **Zero corpus reach** (fence HIT and OTHER are both 0 after; MIRROR byte-identical).
2. **R-EXPLICITIMPORT (`v135_b7`: MISS, both binaries).** Under `import pkg::OneName;` golden mints the wire and neither binary does. **CONTROL `v135_b9`**: pristine misses § 130's own name under the same import form. Inherited.
3. **R-MODOWN / R-PKGVARHOIST (`v135_b11`, `v135_b5`: MISS, both binaries).** With a **distinct class name per home**, golden mints three wires in `work@topHomeDelta11` — for a **package-scope** associative variable (spanned at `9:20`), a **module** variable indexed by a module class (`17:20`), and one indexed by a `$unit` class (`18:21`) — and we mint none.

## 5. Two claims in the write-up that my arms refute (facts, not defects)

* **README §3's a2 table rows "`pkgOoVarMap135` a PACKAGE variable → no wire" and "a `$unit`/module variable → none" are unsound as stated.** `g135_a2.sv` gives **every one of its twelve homes the same class name `idxPhiCls135`**, so the one-wire-per-name-per-module rule masks them: the wire already existed at the OOB formal's span. `v135_b11`, with one class name per home, shows golden **does** hoist for a package-scope and for a module-scope associative index name. This is the README's own warning ("an arm AGREEING with golden is not an arm TESTING the law") biting the arm that states it. It changes no verdict — both are MISSES with zero corpus reach — but it widens **R-PKGVARRANGE** into a hoist residue and gives **R-MODFN** two new site kinds.
* **The report prose's a4 bullet omits an AWAY cell that its own shipped `GRID.r10uvm135.txt` records**: `MOVED-WRONG NET g=0 pris=0 pat=2 work@topNovemberFree135 | KEYBRAVO135` — the R-MULTI spread again. Disclosed in the evidence file, not in the summary. (Also cosmetic: §6's "2 net + 16 index-name cells" — my re-run of `cen135.sh` counts **4** NET cells (2 distinct keys × 2 modes) + 16 AIDX; same cells.)
* The side-blind `pred135.sh` is blind in **both** directions (it named MiniAmiq ×2, which did not move, and missed SimpleUVM ×2, which did). The pass says so in its header and in §5, and the **FENCE** — which did predict exactly the four movers by name — is what byteverify was checked against. Accepted as documented.

## 6. Boundary — my own run over a COPY of the whole probe tree **plus my 6 new arms**, no filter

| run | PROCESSED / LISTED | REJECT pris / pat | DIFFER |
|---|---|---|---|
| file/def | 3943 / 3943 | 151 / 151 | 12 |
| file/elab | 3943 / 3943 | 165 / 165 | 12 |
| dir/def | 1580 / 1580 | 128 / 128 | 10 |
| dir/elab | 1580 / 1580 | 134 / 134 | 10 |

No `FATAL`, no `asym.txt` in any run; the 14 elab-view segfaults occur in **matched pristine/patched pairs**. Differing arms: this law's own (a1–a4 + my b1/b2/b3/b4/b5/b8); `r10uvm40repro/t57a/dut.sv` — **3 TO-GOLDEN / 0 AWAY / 0 MOVED-WRONG**, reproduced exactly, an earlier pass's arm moving toward golden; `r10buvm22repro/g22.sv` — **R-ADDRCONST verified verbatim**: 24 lines, two values, `22477569→22481665` and `22478425→22482521`, each shifted by exactly **4096 = 0x1000**, and that arm's only associative dims are `[string]`. Every dir-mode-only directory — **`r10uvm117repro`, `r10uvm130repro`, `r10v109repro`, `r10v117repro`, `r10v130repro`, `r10uvm75repro`, `r10uvm76repro`, the must-stay controls named in my brief** — is **ORDER-ONLY** (sorted dumps byte-equal in both views), and I proved the coin is the pristine binary's: **four runs of the pristine binary alone over `r10uvm75repro` produced four different dump hashes, all ORDER-ONLY to each other.**

## 7. Code review of the 15-line surface

`assocIdxNameHoistable135` is the only gate and it is correct for every face I tested. `ClassPropRef::ref == nullptr` is dereferenced in exactly one place, and that place is the new `if (cpr.ref)` guard — the other two readers (`ExprEmit.cpp:15935` back-patch tests `back().ref == r7`; `ParamEmit.cpp:22336` only splices) are null-safe; `ModuleEmit.cpp:27715`'s `pr9.ref->` is `pendingModportExprRefs`, a different struct. `bind9` is never null where it is written. `emitIoRanges34` has two call sites; the pure-virtual prototype site (`:2822`) takes the 4-arg default `hoist135=false`, the `extern` listing (`:4870`) passes `!protoOf` — matching golden's unbound `uvm_phase.svh:593:86`. `idxName135` duplicates `in0`'s text extraction verbatim; harmless (its `else` branch is unreachable for hoisted entries, which require `IdentifierName`) — a candidate for the deferred helper-extraction pass, not now.

## 8. Ranked residues

* **R0 — the new SeqDriver ×2 80-line head**, as the pass names it: `uvm_phase.svh:1730`, `foreach (successors[s].m_predecessors[pred])` — golden's `foreach_stmt` carries `ref_var (…::successors)`@1730:16 with its `ref_typespec` onto the `array_typespec`@1724:15; we carry the whole `hier_path (successors[s].m_predecessors)`@1730:16-44. **Head text byte-identical to the shipped `head_pat_default_SeqDriver.cmp` on my build.** A foreach-over-a-hier-path family.
* **R1 — R-MULTI**, the hoisting-module count. New witness `v135_b4`; control `v135_b6` proves it pre-existing on § 130's family. Shared-pool; fixing it touches §§107/117/130's cells. Zero corpus reach.
* **R2 — R-MODOWN / R-PKGVARHOIST** (new, mine): golden hoists a **package-scope** and a **module-scope** associative index name into the owning/importing module (`v135_b11` three wires, `v135_b5` two); we hoist neither. Corrects README §3's a2 rows. Zero corpus reach.
* **R3 — R-EXPLICITIMPORT** (new, mine): the pool's module set is keyed on wildcard-imported packages; golden also reaches a top that imports a single name explicitly (`v135_b7`), and a fully scoped no-import top reaches neither. Control `v135_b9` proves it inherited.
* **R4 — parameterized-class OOB method** (`v135_b5`, `dfltKeyCls5`@19:27): our wire for that site is masked by a pre-existing over-mint of the same name at the specialization argument `41:18`, so the span is wrong but the **count matches and no generated `Compare` reads a span** — judge-invisible today.
* **R5 — R-ADDRCONST**, § 130's: an **address-valued** `UINT`/`vpiDecompile` in the SIZE-range constant our emitter mints for an associative **typedef** (`typedef C ka_cls_t[string];`). It makes the whole-tree boundary gate permanently noisy for *any* recompile, since the value tracks `.bss` layout. Zero corpus reach today, but it is a latent UB-shaped defect worth a pass of its own.
* **R6 — a mixed packed-then-name dimension** (`bit x[7:0][cls]`) reaches neither `makeAssocArrayVar` arm on either binary (`v135_b10` cell x05). Uncovered, unchanged.
* *(probe hygiene, not production)* `bound135.sh` in `MODE=dir` lists the probe **root** as `.`, whose scratch key is empty, so it runs `rm -rf "$OUT/."` — GNU `rm` refuses and the run is unharmed (`PROCESSED == LISTED` held in both dir runs), but the next copy of that script should guard the empty key.

**Artifacts:** worktrees `/tmp/wt_v135` (patched) and `/tmp/wt_v135pris`; frozen binaries `/tmp/v135_bin/slang-uhdm-{pris,pat}`; sweeps `/tmp/v135_wd/{sl,u2r}_{pris,pat}*`; my twelve arms and every census/score/cmds log under `/tmp/v135_scratch/` (`arms/v135_b1..b12.sv`, `w_b*/`, `w_t57a/`, `bound_*.txt`, `fence.*.tsv`, `cen_mine.txt`, `heads_{pris,pat}/`).
