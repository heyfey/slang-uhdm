# r10v176 — the ADVERSARIAL VERIFICATION of r10uvm176, and the fix it needed

**VERDICT: ACCEPT WITH FIX.**  Every headline number in the implementer's
report reproduces **bit-for-bit** from an independent build, including its
central and correct claim that the brief's direction was **inverted**.  The law
itself is right.  But the window it opens exposes a silencer the emitter never
had at that site, and four cells of legal SystemVerilog go **pristine-right →
patched-wrong** because of it.  One line fixes them, plus two cells that were
already wrong before the pass.  Ship `/tmp/r10uvm176.verified.patch`.

**MEASUREMENT ONLY.**  Nothing in this directory is an acceptance judge.  The
official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities.  slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **no row converted**;
`GOLDEN_DEFER` stayed unset; the four slang-fenced tests were never dispatched
and are spelled nowhere here.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `76252556` |
| pristine | md5 `b49636170347560e90432e4e18a11f3b` — built by the verifier from a clean `76252556`, frozen `chmod 555`.  **Matches the implementer's.** |
| patched | md5 `10dc137e115d174d49de081277acb5c8` — `/tmp/r10uvm176.patch` (md5 `336bd5b348fc8a365f61d8cefbf57053`) applied with `git apply -3` to a FRESH `76252556`, rebuilt.  **Matches the implementer's.** |
| fixed | md5 `8c64d71a5ef2621aaf3f4a51fb58ac23` — the above plus § `classInBodyRecvCallArgNoBind52` SITE 5 |
| evidence | `GATES.r10v176.txt`, `GRID.patched.r10v176.txt`, `GRID.fixed.r10v176.txt`, `BOUNDARY.r10v176.txt`, five arms |

---

## 1. WHAT REPRODUCED

Independently, from the verifier's own worktrees, binaries and sweeps:

* both binary md5s, to the byte;
* goldens 23/0 on all three binaries, `/bin/false` 0/23;
* u2r testflags **679 / 50 / 2**, `ct8rows` **0 differing rows** for every pair
  measured — pristine and patched each against the committed baselines, and
  patched against the verifier's own pristine sweeps, status AND dump column;
* surelog **0 differing rows over 1588**, no conversion;
* byte movers **MiniAmiq ×2** with the implementer's exact hashes
  (`388fa4f0332b` → `227a5378c0d7`), **0/1358** on uhdm2rtlil;
* heads: MiniAmiq ×2 **29 → 33**, every other row's cmp log byte-identical;
* canaries ok=52 / ok=8 changed=0, ctcan2 ×2 PASS, canaudit PASS, SVSwitch
  `4842211c4030`, YosysVerx `6ccda350c24a`, the three protected DBs SAME;
* every one of the 3035 `cmds.txt` files per workdir names only the intended
  frozen binary; **zero** name the main-tree binary.

The verifier read 2 movers where the implementer read 3.  The third was
`default/Scoreboard`, the documented ~50/50 coin — it did not flip in either
verifier run.  Not a discrepancy; RESUME.md §9's coin law covers it.

**THE DIRECTION.**  The pristine MiniAmiq cmp log, read off the verifier's own
build, is

```
LHS: … io_decl: (a_test_name), line:91:51, endln:91:62 …
RHS: <null>
```

LHS is golden, so **golden BINDS and we left it BARE**.  The brief and
`RESUME.md` §3b line 185 said the opposite.  The implementer's inversion call
is CONFIRMED, and so is the R0 claim: strip the ids from the new MiniAmiq head
log and from SeqDriver's, and the two differ in four lines, all `uvm_pkg` vs
`svaunit_pkg`.  One object, two rows.

**THE LAW'S OWN EVIDENCE, re-read from the corpus.**  All ten `vpi_vif`
argument cells of `svaunit_vpi_wrapper.svh`, golden side: **BOUND** at 94:29
and 628:52 (control depth 0), **BARE** at 555, 575, 597, 619 ×2, 641, 664 (all
depth 1, inside `if (assertion != null) begin`) and at 78:31 (a class
property).  `a_sim_time` is the same formal, bound at 628 and bare at 619.

---

## 2. THE BREAK — § `classInBodyRecvCallArgNoBind52` HAS NO SITE IN THIS ARM

§ 52 is a SILENCER owed around the argument list of every receiver-qualified
call our emitter renders in **EXPRESSION position**.  Pass 52 raised it at
three `MakeHier_path` mints and its own integration note added a fourth
(`ExprEmit.cpp` ~21330, "FIVE mints, FOUR under `!callStmtCtx0`, and pass 52
windowed THREE").  The **interface-method-call arm mints no hier_path** — it
mints a `method_func_call` with a `Prefix` — so it was never counted, and it is
reached from ONE place for BOTH statement and expression position.

While `classMethodNoBind` silenced those arguments anyway the omission was
inert.  § `ifaceRecvCallArgTakesTheOrdinaryWindow176` lifts that silence, and
the omission becomes **a bind where golden is bare**.

It is invisible until you write a receiver that is not a plain one name: a
plain `lone.weigh(x)` in expression position is rendered as a hier_path
further up, where § 52's SITE 1/3 already fire.  A **subscripted** receiver
`row[2].weigh(x)` reaches the interface arm.  The implementer's arms wrote a
subscripted receiver only in STATEMENT position (arm C `c4_index`) and
expression position only with a plain receiver (arm A `a6`/`a7`), so the two
axes never crossed.

`v176_s_exprpos.sv`, one Surelog golden, DEF and ELAB, twelve cells:

| cell | shape | golden | pristine | PATCHED | FIXED |
|---|---|---|---|---|---|
| s1 `lone.set(a)` | STATEMENT, plain | BOUND | bare | **BOUND** ✓ | **BOUND** ✓ |
| s2 `row[2].set(b)` | STATEMENT, index | BOUND | bare | **BOUND** ✓ | **BOUND** ✓ |
| s3 `x = lone.weigh(c)` | assign RHS, plain | bare | bare | bare | bare |
| s4 `x = row[2].weigh(d)` | assign RHS, index | bare | bare | **BOUND ✗ AWAY** | bare ✓ |
| s5 `if (lone.weigh(e)==0)` | condition, plain | bare | bare | bare | bare |
| s6 `if (row[2].weigh(f)==0)` | condition, index | bare | **BOUND ✗** | **BOUND ✗** | bare ✓ |
| s7 `return lone.weigh(g)` | return, plain | bare | bare | bare | bare |
| s8 `return row[2].weigh(h)` | return, index | bare | bare | **BOUND ✗ AWAY** | bare ✓ |
| s9 `x = row[2].weigh(i)+3` | operand, index | bare | bare | **BOUND ✗ AWAY** | bare ✓ |
| s10 `lone.set(row[2].weigh(j))` | nested, index | bare | bare | **BOUND ✗ AWAY** | bare ✓ |
| s11 `lone.set(lone.weigh(k))` | nested, plain | bare | bare | bare | bare |
| s12 `row[2].set(l)` one body down | STATEMENT, index | bare | bare | bare | bare |

Four AWAY.  s6 is a **pre-existing** defect of the same shape (an if/case
condition clears `classMethodNoBind`, so pristine bound it), and the same
silencer takes it to golden too.  `v176_t_homes.sv` adds a sixth:
`t4_sink(duct[1].puff(charm))`, an interface call in the argument list of an
ORDINARY call — golden bare, pristine **BOUND**, fixed bare.

### the fix — SIX lines, one of them code

```cpp
RecvCallArgIf52 rca52I(recvCallArgDepth52, !callStmtCtx0);
```

plus the `RecvCallArgIf52` predicate form of the existing RAII, beside
`RecvCallArg52` itself.  The counter is § 52's OWN, so the gate that reads it
(`curSubClassScope9 && !curSubOob9 && recvCallArgDepth52 > 0`) is untouched and
no home outside an in-body class method can move.  `callStmtCtx0` and not the
member `callStmtContext`, for the reason `ExprEmit.cpp` ~22314 gives.

**Both corpus cells are statement position** — `svaunit_vpi_wrapper.svh:94`
and `:628` — so the law's own face is preserved exactly.

### the fix's gate boundary, MEASURED not assumed (`v176_t_homes.sv`)

| home | golden | pristine | FIXED |
|---|---|---|---|
| OUT-OF-BODY class method, expr, index | BOUND | BOUND | BOUND (§ 52's `!curSubOob9` is golden's own edge) |
| in-body class method, expr, index | bare | bare | bare |
| `$unit` class, in-body, expr | bare | bare | bare |
| MODULE function, expr, index | BOUND | BOUND | BOUND (untouched) |
| INTERFACE's own subroutine, expr, index | BOUND | BOUND | BOUND (untouched) |

---

## 3. THE FACES THE IMPLEMENTER'S ARMS DID NOT WRITE — all clean

`v176_p_modport.sv`, DEF and ELAB, **TOGOLD 6 / AWAY 0 / MOVED-WRONG 0**:

* a **MODPORT-typed** virtual interface (`virtual chan.drv_qq port_qq`),
  function AND task — golden BINDS, the pass moves it to golden;
* a class nested **inside a MODULE** — golden BINDS, moved;
* a **CONSTRUCTOR** home (`function new`, where § 144 also lives) — golden
  BINDS at depth 0, moved;
* **the distinguisher pair inside ONE subroutine**, which is the single
  strongest cell in this verification: `p5_pair` writes
  `full_qq.punch_qq(vellum_QQ)` at depth 0 and the identical call at depth 1
  inside an `if`.  Same formal, same receiver, same method, same body.  Golden
  **BOUND @47:24 / BARE @49:27**; pristine bare/bare; patched **BOUND/BARE** —
  golden's split reproduced exactly, § `controlBodyNoBind28`'s depth gate
  intact;
* the module-function control through an interface instance: BOUND on all
  three, before and after.

`v176_r_multi.sv` (1/2/3 module instances, three specialisations of one
parameterized class, a generate block, an interface calling a nested
interface): TOGOLD 1, AWAY 0.

---

## 4. RESIDUES the verifier adds or sharpens, ranked

* **RV1 — an ARGUMENT containing a dot poisons the receiver's NAME, and this
  is a live CORPUS defect.**  The arm finds the receiver with
  `raw1.find_last_of('.')` over the WHOLE call's source text, so any dot in an
  argument wins.  `hose.feed(box.lid, able)` gives our receiver `ref_obj` the
  name `hose.feed(box` where golden's is `hose`, and the `method_func_call`'s
  location moves with it.  Pre-existing and unchanged by the pass — and the new
  window correctly DECLINES on it, so those arguments stay bare where golden
  binds them.  **Six corpus rows carry it**, found by scanning the 37 319
  face rows of the pristine sweep: `get_cover_statistics_dpi(cover_info[index`
  ×4 and `control_assertion_dpi(a_sva` ×2 — which is precisely the "differ in
  SHAPE too" half of the implementer's residue R1, now with its mechanism
  named.  Fixing it means finding the receiver from the AST, not the text.
* **RV2 — R1 proper, the largest.**  A call inside an INTERFACE's own
  subroutine leaves its arguments bare where golden binds them: 15 face cells
  per MiniAmiq mode.  Confirmed at the stated size; the home conjunct
  deliberately declines there and it needs a pass of its own.
* **RV3 — the receiver NAME.**  Golden strips a subscript
  (`rack_ZZ[0]` → `rack_ZZ`) and trims whitespace; we write the raw text.
  Pre-existing, zero corpus cells, unchanged.
* **RV4 — a package-variable argument** (`board_ZZ::peg_ZZ`): golden BARE,
  ours BOUND, before and after.  Untouched (the implementer's R5, confirmed).
* **RV5 — `bound176.sh` defaults `BWD` to `/tmp/r10uvm176_bound` and
  `rm -rf`s it.**  It IS overridable and the default names this pass's own
  scratch, so the standing rule is met; the verifier ran it with `BWD` set.
  Worth keeping an eye on as the pattern propagates.

## 5. R0 — unchanged and re-confirmed

MiniAmiq ×2 and SeqDriver ×2 now share one 33-line head: `LHS: <null> / RHS:
constant 32'h04c11db6 @368:36` under a `param_assign`.  The implementer's
mirror owner-finder result stands — the differing singular is
`ref_obj(UVM_STR_CRC_POLYNOMIAL)@385:21 :: Actual_group` in
`uvm_misc.svh`'s `uvm_oneway_hash`, three control bodies down, and golden holds
one BOUND and one NULL copy of it.  The next law is **which copy binds**;
direction SUPPRESS.

## 6. Files

`v176_p_modport.sv` (modport / module-nested class / constructor / the
in-one-subroutine pair / 1-3 instances), `v176_q_argtext.sv` (the receiver-text
stress that caught the break), `v176_r_multi.sv` (multiplicity and the
non-virtual controls), `v176_s_exprpos.sv` (the regression face isolated),
`v176_t_homes.sv` (the fix's gate boundary).  Scored with the implementer's own
`grid176.sh` / `ct176cen.cpp` / `score176.py` / `cen176.sh` / `bound176.sh`,
which the verifier read line by line first.
