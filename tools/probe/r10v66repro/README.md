# r10v66 — ADVERSARIAL VERIFICATION of r10earl66 (§ elabConnEnumConstFold66)

**VERDICT: ACCEPT-WITH-FIX.**  The law is real, the head clearance is real and
every headline number reproduces bit-for-bit.  One position the shipped grid
never tested — **a read inside a tf_call ARGUMENT LIST** — was
*pristine-RIGHT -> patched-WRONG* on legal SV at every depth.  Fixed here
(`§ connCallArgKeepsEnumRef66v`, one clause), re-gated in full, and **byte-inert
on both corpora relative to the shipped patch** (0/956 and 0/1358 movers).

Base `f7cc5ad`.  Binaries built in this verifier's own worktrees and frozen 555:

| binary | md5 | note |
|---|---|---|
| pristine (`/tmp/wt_v66pris`) | `b10a3f6e195760bb08a26b9e13b79060` | **reproduces the pass's claim exactly** |
| shipped patch (`/tmp/wt_v66` + `/tmp/r10earl66.patch`) | `aa09dc513ae0d50e02708833ede679bb` | **reproduces the pass's claim exactly** |
| verified (shipped + this dir's fix) | `135dcb54233a7c20c33f2733d6ca230c` | `/tmp/r10earl66.verified.patch` |

---

## 1. What reproduced, bit-for-bit

| claim | verifier's measurement |
|---|---|
| binary md5s | **IDENTICAL** to the pass's two md5s |
| goldens 23/0, `/bin/false` 0/23 | 23/0 on all three binaries; 0/23 negative control |
| u2r tf + def 679/50/2 | 679/50/2 both modes, all three binaries |
| `ct8rows` u2r vs committed + vs own pristine | **PASS, 0 rows** (status AND dump) |
| byteverify u2r | **MOVERS 0/1358** |
| surelog status histogram identical | identical (470/466 CMP_EQUAL, 11/9 NE) |
| `ct8rows` surelog vs committed `golden_surelog.csv` | **PASS, 0 rows** |
| Earlgrey head BEFORE | **36 cmp lines, 1 head**, both modes, `flash_phy_core.sv:163:17` `reqs[PhyRead]`, golden `constant HEX:0 sz3 ct5 3'h0` vs our `ref_obj -> enum_const` |
| Earlgrey head AFTER | **46 lines, 1 head**, both modes, the two AFTER cmp logs **byte-identical** (`d0da4ae6…`), head = `flash_phy_rd.sv:142:34` `req_tree[C0]` — exactly `PREDICT_R0.txt` |
| golden-vs-golden calibration | **0 differing / 162,259 cells**, golden re-read byte-identical |
| Earlgrey whole-design census | **32 TO-GOLDEN, 0 AWAY-GOLDEN, 0 MOVED-WRONG**, both modes |
| arm scores `g1/g2/g3` | reproduced cell-for-cell (g1 elab 236/199/23/1/2; g1 plain 235/206/17/5; g2 100/83/3/7) |
| the 3 AWAY/MOVED cells in `g1` | verified: all are `G <none>` keys where golden reduced the WHOLE High_conn — wrong before, wrong after |
| `rowheads` | **only Earlgrey moved** (36 -> 46); SeqDriver/SimpleUVM/Scoreboard/MiniAmiq 12, BuildUVMPkg 152, Rggen 36 unchanged |
| canaries / ctcan2 / canaudit | ok=52 changed=0, ok=8 changed=0, PASS/PASS, audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr SAME; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |
| `Scr1SvTests` fence | CMP_EQUAL both modes on all three binaries |
| `cmds.txt` by binary PATH | 1458 u2r + 1523 surelog lines per binary, every one the intended frozen path |
| uvm75/76/88 "order coin" | **independently confirmed**: 3 runs of the SAME pristine binary give 3 different hashes on 75 and 76, 2 on 88 |

Two claims did **not** reproduce as stated — see §4.

---

## 2. The break: § connCallArgKeepsEnumRef66v

`v9_argdepth66.sv`.  `vf9(q) = q ^ 8'h5a` is the one written shape Surelog
leaves as a `func_call` in the elaborated High_conn, so its compiled arguments
stay visible in golden.  **Golden keeps `ref_obj -> enum_const` at EVERY depth
inside the argument list** (`GOLDEN_ARG66v.txt` is the raw evidence):

```
HC/arg[0]                 bare argument
HC/arg[0]/idx             bit-select index inside the argument
HC/arg[0]/op29[0], [1]    operation operands inside the argument
HC/arg[0]/op33[1]         concat operand inside the argument
HC/arg[0]/op67[0]         cast operand inside the argument
HC/arg[0]/b               indexed-part-select base inside the argument
HC/b/op28[0]/arg[0]       argument of a call that is itself the ips base
```

The shipped patch folded all eight: **AWAY-GOLDEN 8 / 15 cells** in that arm's
elab view.  The corpus-shaped instance is arm 2's `.x12(vf2(PH))`
(`v2_pos66.sv`), where golden's elaborated `work@vtop2.u_p` port `x12` holds
`func_call vf2 -> vpiArgument ref_obj PH -> enum_const` while the port next to
it, `.x13(PH)`, is a folded `constant HEX:3` — one instantiation, both answers.

**Mechanism.**  `NetlistElaboration::high_conn_` compiles the actual with
`pexpr = nullptr` (earl65's sentence).  `CompileHelper::compileTfCallArguments`
(`src/DesignCompile/CompileHelper.cpp:4340`) compiles every argument with
`pexpr = call` instead, and the identifier arm under a non-null `pexpr` binds
through `bindVariable(component, pexpr, …)` and never reaches the `getValue`
substitution (`CompileExpression.cpp:1132-1150`, the only place a member name
becomes a constant).  So the reference survives the whole `Reduce::Yes` walk.

**The fix** is one clause on the pass's own gate — `callArgDepth == 0` — placed
with the rest, plus the law comment.  `callArgDepth` already counts user calls
(ExprEmit ~14598) and system calls (~16570).  Golden reduces `$clog2(E)` and
`$signed(E)` WHOLE to a constant (arm 8), which neither binary reproduces, so
leaving system-call arguments alone is exactly the pristine behaviour there.

After the fix: `v9` is **15/15 STILL-RIGHT** (elab), `v8` has **zero movers**,
and every TO-GOLDEN the pass earned is untouched.

---

## 3. The arms (9 files, both views, rc recorded, scored with a NO-SPAN payload)

`vscore66.py` is `score66.py` with every `span=`/`tsspan=` token **stripped from
the payload** before the multiset join (RESUME §9 / earl60's `attrv60` lesson);
`tscen66`'s raw line keeps a span for eyeballing only.

| arm | what it breaks | shipped patch | verified patch |
|---|---|---|---|
| `v1_enc66` | 12 written member forms (hex/bin/sized-dec/octal/auto/signed-dec/untyped/int-base/byte-base/8-bit) as a bit-select index | 11 TO-GOLDEN, 1 MOVED-WRONG | same |
| `v2_pos66` | 14 positions: idx, ips base `+:`/`-:`, ips width, part-select bounds, concat, replication, operation, ternary, cast, nested select, **call arg**, bare | 7 TO-GOLDEN, **1 AWAY-GOLDEN** | 7 TO-GOLDEN, **0 AWAY** |
| `v3_home66` | module-local / `$unit` / wildcard / explicit / qualified `pkg::` enums x module body, gen-for, gen-if, gen-case, nested gen, 3 instances, instance array | 30 TO-GOLDEN, 0 AWAY | same |
| `v4_iface66` | interface instance, interface-port child, **modport-rooted actual**, hierarchical `u_if.sig[E]` | 5 TO-GOLDEN, 0 AWAY | same |
| `v5_odd66` | X/Z members, expression-valued, localparam-valued, negative `int`, typedef'd base, 64-bit | 1 TO-GOLDEN, 9 MOVED-WRONG (all R2, see §5) | same |
| `v6_dir66` | output/inout actuals, POSITIONAL connections, gate primitive terminals, class-scope enum read `pkg::cls::CE` | 6 TO-GOLDEN, 0 AWAY | same |
| `v7_deep66` | part-select bound under an operation, call arg inside a concat, param override `#(.P(E))` | 2 TO-GOLDEN, 2 MOVED-WRONG | 2 TO-GOLDEN, 1 MOVED-WRONG |
| `v8_call66` | 9 call shapes incl. `$clog2`/`$signed`, call in an ips base, 2-arg call | 3 MOVED-WRONG | **0 movers** |
| `v9_argdepth66` | depth under a call argument (the break) | **8 AWAY-GOLDEN / 15** | **15/15 STILL-RIGHT** |

Negative controls that held on both: every `cont_assign` and procedural read,
the DEF view, and `part_select` bounds.

## 4. Where the pass's report is wrong

1. **`byteverify` surelog is 3/956 here, not 2/956.**  The third is
   `testflags/SeqDriver` (`3ff72b2e648d` patched vs `d4ae9418b90f` pristine).
   It is **content-identical**: the workdir-normalised `uhdm-dump`s are
   **1,817,233 lines each with an ORDER-BLIND diff of 0** — the only raw
   difference is the listing order of `uvm_reg_addr_t` / `uvm_reg_data_t`.  The
   `uhdm-cmp` verdict, the head (12 lines / 1 head) and the whole CSV row
   (status AND dump column) are unchanged, and the SHIPPED and VERIFIED
   binaries produce the identical bytes (byteverify fix-vs-shipped = 0/956), so
   the law is not involved.  It is reproducible through the harness per binary
   (pristine 2/2, patched 2/2) but not by hand (8 parallel runs of either
   binary give the pristine hash), i.e. an emission-ORDER effect of the changed
   code layout, of the documented class.  **It should have been named.**
2. **Wide boundary "8 differing".**  With this verifier's 9 arms added the list
   is 2,949 files (`PROCESSED == LISTED`, both views, `RC_DIFF_CELLS = 0` over
   5,898 cells) and the differing set is **22 = 11 files x 2 views**: the pass's
   3 arms, `r10earl61repro/g2_earl61.sv` (scored: wrong before, wrong after)
   and 7 of this verifier's 9.  `v8_call66.sv` and `v9_argdepth66.sv` are
   **identical to pristine under the verified patch** — which is the fix's own
   positive control.  Per-directory: 1,362 dirs, `RC_DIFF_CELLS = 0` over 2,724
   cells, 8 differing = the two arm dirs x2 + the `r10uvm75/76repro` coin x2.

## 5. Ranked residues (measured, none a regression)

* **R2 — our `enum_const`'s own encoding** (the pass ranked it; confirmed and
  widened).  Golden's `enum_const` for an OCTAL member is `UINT:<decimal>`
  (`TB = 6'o21` -> `UINT:17`, decompile `6'o21`) where ours is `OCT:21`; an
  expression-valued member is `UINT:3` where ours is `BIN:0011`; a
  localparam-valued member is `HEX:9` where ours is `INT:9`.  The fold copies
  the member verbatim — correctly — so it inherits the error.  9 cells in
  `v5_odd66`, 1 in `v1_enc66`, 0 in either corpus.
* **R-QUAL (new) — a QUALIFIED read is folded by an OLDER law with the WRONG
  decompile.**  `bus[vpk3::QD]` in an elaborated High_conn is already a
  constant on the PRISTINE binary, but with `dec=4'd9` where golden re-mints
  `dec=9` (`v3_home66`, 8 cells, every home).  `constant::Compare` reads
  `VpiDecompile`, so these are judge-visible.  § elabConnEnumConstFold66's
  re-mint rule is exactly the missing half; the qualified path never reaches
  this gate.  **This is the cheapest next sweep in the family.**
* **R-WHOLE — golden reduces the WHOLE High_conn expression** (`{4'b0,E}`,
  `8'(E)`, `E|E`, ternaries, `(E1==E1)`): golden holds one constant where we
  hold an operation.  Wrong before, wrong after; owns every remaining
  MOVED-WRONG in `v2/v5/v7` and `r10earl61repro/g2_earl61.sv`.
* **R-SYSCALL — `$clog2(E)` / `$signed(E)` in an elaborated High_conn**: golden
  is a single constant (`UINT:2`; `INT:3` with a `logic_typespec`), ours is a
  `sys_func_call`.  `v8_call66` cells c2/c7.  Zero corpus cells.
* **R-UNITENUM (unproven, structural)**: `unitEnumUnresolvedHere` guards the
  BARE-actual fold in `ModuleEmit` but there is no equivalent guard on this
  gate, so a `$unit` enum that Surelog cannot resolve in the instantiating root
  file would be folded here if it were read NESTED.  `Scr1SvTests` only
  exercises the bare form, and the shape has no corpus instance; recorded so the
  next pass in this family knows where the seam is.

## 6. Files

`v1..v9_*.sv` the arms · `vrun66.sh` one arm, Surelog + both frozen binaries,
both views, rc per cell · `vscore66.py` the no-span 3-way multiset scorer ·
`vwide66v.sh` / `vdir66v.sh` the recursive and per-directory boundaries (list on
fd 3, children `</dev/null`, PROCESSED asserted, rc recorded per cell) ·
`BOUNDARY_*.{tally,diff,signal}` + `BOUNDARY_rc.txt` · `GOLDEN_ARG66v.txt` the
raw golden evidence for the carve-out · `GATES66v.txt` the gate transcript.
