# r10v186 — ADVERSARIAL VERIFICATION of r10uvm186 § `cloneNewArrayArgBindsOwnDecl186` — **ACCEPT**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang
was **NOT** patched; `results/*.csv` were **READ ONLY**; **NO CORPUS ROW WAS
CONVERTED**; `GOLDEN_DEFER` stayed unset; the four slang-fenced tests were
never dispatched and are named only inside `canaudit.sh`'s own fence list.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here.

| | |
|---|---|
| verdict | **ACCEPT**, no production change required. `/tmp/r10uvm186.patch` ships as-is; `/tmp/r10uvm186.verified.patch` is the same patch plus this evidence directory. |
| BASE | `362dcfa0` |
| pristine binary | built by the VERIFIER in its own fresh `362dcfa0` worktree, md5 `8b1777950b91feef705565e6f16e8b0a` — **equal to the implementer's** — frozen `chmod 555` before any sweep |
| patched binary | the implementer's patch applied to a second fresh `362dcfa0` worktree, md5 `85be7bc529abb997bc012034c968222b` — **equal to the implementer's** — frozen `chmod 555` |
| what was re-run | every headline gate, from the implementer's binaries' md5s down to the mover hashes, on the verifier's own builds and its own sweeps |
| third-tree rebuild | the verified patch applied to a THIRD fresh `362dcfa0` worktree and built there gives md5 `85be7bc529abb997bc012034c968222b` — the exact binary every number here was measured on |
| what was added | five NEW adversarial arms on decoded axes the implementer did not enter, a WHOLE-WINDOW census that sees the nested faces his scorer cannot, a second a-priori predictor built on it, and a mask experiment that settles the "31 → 62 / 31 → 9212" cascade question with the judge itself |

---

## 1. EVERY HEADLINE NUMBER REPRODUCED BIT-FOR-BIT

Both binaries were **built by this verifier** from fresh `362dcfa0` worktrees
(`/tmp/wt_v186pris` clean, `/tmp/wt_v186` with the patch applied by
`git apply -3`, which reported *Applied patch … cleanly* for all three
production files), frozen at immutable paths, and `SLANG_UHDM` exported
explicitly per binary for every invocation.

| gate | implementer claimed | verifier measured |
|---|---|---|
| pristine md5 | `8b1777950b91feef705565e6f16e8b0a` | **same** |
| patched md5 | `85be7bc529abb997bc012034c968222b` | **same** |
| goldens | 23/0 both, `/bin/false` 0/23 | **same** |
| `cmds.txt` audit BY BINARY PATH | surelog 1523/1523, u2r 1458/1458 | **same**, and zero `cmds.txt` in the four workdirs names any other binary |
| u2r, both modes, both binaries | 679/50/2 | **same**; `ct8rows` **0 differing rows** vs the committed baseline AND vs the verifier's own pristine, status AND dump column |
| surelog, both binaries | 937/567/48/19/10/3/2/1/1 | **same**; `ct8rows` **0 differing rows over 1588** vs the committed baseline AND vs own pristine. **NO ROW CONVERTED** |
| a-priori prediction | `LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4`, cells=5 | **same**; u2r `LISTED=1358 PROCESSED=1358 NOGOLDEN=0 PREDICTED=0` |
| byte movers | surelog 5/956, u2r 0/1358 | **same five rows**, and the four real movers' patched AND pristine hashes are identical to his (`4aeae3d22191`/`3f21e4797c99`, `075d0686d280`/`f455e1d2c25a`, `519b467361b2`/`35918bf3ae27`) |
| attribution | 26 plain = 26 order-blind, 24 content lines, twelve `vpiActual` markers + twelve targets | **same**, by name: `get_bytes::sz`, `get_ints::sz`, `get_physical_addresses::{n, local_addr}`, `io_decl (addr)` |
| Scoreboard/default | a COIN, 0 order-blind content lines | **same** — and caught in the act: this verifier's PRISTINE hash is `c09f5e4b3e5b` where the implementer's was `ac27eb73c45b`, while the PATCHED hash is byte-identical to his (`0d80f8f5d07e`). Two independent runs of the SAME two binaries landed the coin differently, and the order-blind diff is still 0 content lines (RESUME §9) |
| heads | SeqDriver ×2 / MiniAmiq ×2 **31 → 62, ONE head**; SimpleUVM 664681, Scoreboard 95, BuildUVMPkg 48, Earlgrey 31/17, Rggen CMP_EQUAL | **same** |
| canaries | ok=52/8 changed=0; ctcan2 PASS ×2; canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **same** |
| protected DBs | three SAME, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **same** |

Evidence: `GATES.r10v186.txt`, `MOVERS.r10v186.txt`.

---

## 2. THE HOLE IN THE IMPLEMENTER'S SCORER, AND WHAT CLOSING IT SHOWED

`ct186new` — the implementer's census, and the predicate his a-priori
prediction is built on — reports only refs whose **IMMEDIATE parent** is the
`new` call, i.e. the direct `Tf_call_args` faces. The gate the patch moves is
guarded by `newArrayArgDepth16 > 0`, which is a **WINDOW** covering every
nested expression in the argument list as well (an operation operand, a select
index, a nested call's own argument, a loop iterator — the emitter's own
comment at `src/ExprEmit.cpp:32611` says so). A regression at a nested face
would score nothing in his grid and nothing in his census.

`ct186v.cpp` here is the same census re-keyed on the whole window: one row for
every `ref_obj`/`ref_var` whose `VpiParent` chain **reaches** a `new`
`method_func_call`, carrying the ancestor DEPTH at which it does. Re-scored
with it (`ARMS186.r10v186.txt`), the implementer's own three arms read:

| arm | def | elab |
|---|---|---|
| `g186_a_argdecl.sv` | TOWARD 18 / **AWAY 0** / MOVED-WRONG 0 | TOWARD 14 / **AWAY 0** / MOVED-WRONG 0 |
| `g186_b_listing.sv` | TOWARD 4 / **AWAY 0** / MOVED-WRONG 0 | TOWARD 4 / **AWAY 0** / MOVED-WRONG 0 |
| `g186_c_chain.sv` | TOWARD 18 / **AWAY 0** / MOVED-WRONG 0 | TOWARD 18 / **AWAY 0** / MOVED-WRONG 0 |

`ONLY-OURS-MOVED 0` everywhere, calibrated golden-vs-golden-vs-golden at every
column 0 first. The nested faces move too, and golden's clone answer for each
is what the patched binary now writes. **The hole is empty.**

The same census run over the nine UVM row-modes (`CENSUS.r10v186.txt`):
SeqDriver ×2 and MiniAmiq ×2 **TOWARD 6 / AWAY 0 / MOVED-WRONG 0 /
ONLY-OURS-MOVED 0**; SimpleUVM ×2, Scoreboard/default and BuildUVMPkg ×2 all
zero and untouched; calibration every column 0 but UNTOUCHED on every row.

And as a **second a-priori predictor** over the whole comparable population,
the whole-window predicate names the **same four rows and no others**
(`LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4`, cells=10 each;
u2r `PREDICTED=0`). The law's entire nested-face population across 956 + 1358
databases is confined to SeqDriver ×2 and MiniAmiq ×2.

---

## 3. FIVE NEW ARMS ON AXES THE IMPLEMENTER DID NOT ENTER

Each is one real Surelog golden, both views, every rc recorded, scored with the
whole-window census and calibrated golden×3 first (`GRID.r10v186.txt`).
Names, numbers and orders are deliberately unlike the corpus' and unlike
r10uvm186's own arms.

### Arm A `v186_a_retname.sv` — RETURN NAME and FORMAL DIRECTION. TOWARD 10 / **AWAY 0** / MOVED-WRONG 0, both views.

The axis the brief pins: **§ `retNameArgKeepsReturnVar184v` MUST HOLD.**
`newArraySubScopeSym16` accepts a function's own return variable (a `Variable`
whose parent scope is the `Subroutine`), so a clone's `new[<function name>]`
is inside the lifted window and the standing law says a free subroutine's
return-name argument keeps § 171's RETURN VARIABLE.

**Golden agrees with the patch, and the law holds.** In the wildcard clone
(`package:Wainscot186v`) golden binds `new[quoin186v]`, `new[lintel186v]` and
`new[soffit186v]` to the RETURN VARIABLE `int_var()@23:22` / `@42:12` /
`@50:22` — the automatic flavour, the static flavour, and the flavour where the
return name is never assigned before the `new` — and the patched binary writes
exactly those. Not the receiver, not a body local, not a fresh mint.

Every FORMAL DIRECTION, none of which the corpus exercises (its one `io_decl`
cell is an `input`): `input`, `output`, `inout` and `ref` all bind their own
`io_decl` in golden's clone, and so does the patch — plus a task's `output`
and `ref`. The PACKAGE variable stays bare on both sides (§ 16's symbol half).

### Arm B `v186_b_position.sv` — STATEMENT POSITION. TOWARD 19 / **AWAY 0** / MOVED-WRONG 0, both views.

The lifted conjunct carries no position test, while the silencers beside it in
the same OR (§ `controlBodyNoBind28`, the class-method silence) very much do.
Nineteen positions, every one bound by golden in the clone and matched by the
patch: an `if` body, an `else` body, an `if` body's own block local, a `case`
item, a `case default`, a `for` body, a `while` body, a `do`-`while` body, a
`repeat` body, a `fork` arm and a fork arm's own local, and every block-naming
shape — a NAMED-begin local, the function local read from inside a NAMED
begin, an UNNAMED-begin local, NAMED inside UNNAMED, the unnamed parent's local
read from the named child, UNNAMED inside NAMED, and the named parent's local
read from the unnamed child.

This settles the one shape that looked like a trap. Surelog's `bindVariable`
(`CompileStmt.cpp:3089`) has cases for `uhdmfunction`, `uhdmtask`, `uhdmbegin`
and `uhdmmodule_inst` and **none for `uhdmnamed_begin`** — the exact reason
§ `incDecBindSym21` and § `collArgNamedBlkLocalNoBind15` exclude named-block
locals. Measured on a real golden, the clone's `new[nblk186v]` **is** bound, to
`int_var(nblk186v)@58:11`. Golden's answer, not a prediction from the source.

### Arm C `v186_c_kinds.sv` — RECEIVER KIND and ARGUMENT TYPE. TOWARD 14 (def) / 12 (elab) / **AWAY 0** / MOVED-WRONG 0.

The corpus population is `int` arrays sized by `int` locals. This arm asks the
golden for a **STRING** dynamic array, a `byte` array, a 4-state `logic[7:0]`
array, a packed-STRUCT array, a CLASS-HANDLE array and a MULTI-DIMENSIONAL
dynamic array as the receiver; a **QUEUE** and an **ASSOCIATIVE** array as the
size source (`new[q.size()]`, `new[aa[key]]`, `new[q[0]]`), both as locals and
as `ref` formals; and the COPY SOURCE of `new[n](src)` for an `int` array and
for a `string` array. Every direct-argument cell moves to golden's clone answer
and none moves away.

Two nested faces here are STILL-WRONG on both binaries and belong to another
family: a built-in method's RECEIVER (`ring186v` in `new[ring186v.size()]`,
`rq186v` in `new[rq186v.size()]`) is bound by golden and bare in ours before
and after — it is built by the method-call builder, not by this gate. The
assoc SELECT INDEX (`key186v`, `k2186v`) is a nested face that DOES move, and
golden's clone answer is what the patch writes.

### Arm D `v186_d_listing.sv` — the LISTING axis, re-asked. TOWARD 10 / **AWAY 0** / MOVED-WRONG 0, both views.

Only the two WILDCARD-import clone listings moved — 5 keys each — and nothing
else in the file did: not the `$unit`-scope subroutine, not the MODULE-homed
subroutine, not the package that the MODULE imports directly (no clone listing
exists), and **not the EXPLICIT single-item import**.

That last one confirms **R1 as a real, untaken residue, measured on a golden by
the verifier too**: in `package:Echinus186v` (`import Ogee186v::reveal186v;`)
golden binds all five keys exactly as it does in the wildcard clone
(`int_var(loc186v)@29:11`, `io_decl(in_a)@27:47`, `array_var(src186v)@30:11`),
and BOTH binaries leave them bare-or-hoisted. Pristine-wrong → still-wrong: a
residue, not a regression. Corpus incidence stays zero — the superset
predictors, which cannot tell an explicit copy from a wildcard clone, name no
such cell in 956 + 1358 databases.

### Arm E `v186_e_instances.sv` — INSTANCE COUNT, i.e. the § 130 pool. TOWARD 6 / **AWAY 0** / MOVED-WRONG 0, both views.

The moved gate is read INSIDE the branch that also pushes the reference onto
§ `newArrayArgHoistNet130`'s hoisted-net pool (`ExprEmit.cpp` ~17348), so
making `newArrayArgNoBind16` false in a clone ALSO stops the clone emission
from pushing that pool entry — and § 130's whole job is to mint a wire in
EVERY module that hoists the body's package. With one module a lost push can
hide; with three it cannot. One importer reached through one module and through
a second module instantiated three times: the patched elab dump **removes
nothing at all** (0 removals, 24 additions), and the hoisted-net faces are
identical on both binaries at 1 and at 3 instances.

That generalises: over 5053 boundary arms and 2314 corpus databases the patch
**adds `vpiActual` edges and removes nothing**, with the single measured
exception in §5.

---

## 4. THE "31 → 62" AND "31 → 9212" CASCADE, SETTLED WITH THE JUDGE

A bigger cmp line count after a patch has the same shape as a regression, and
RESUME §9 says a count is not comparable across a change that removes a cascade
mask. `ct186vseed.cpp` asks the judge directly: pre-seed into
`CompareContext::m_visited` **every golden ref inside a `new[...]` window** —
the whole surface this law can touch, cells it fixes and cells it does not —
and re-run the OFFICIAL `design::Compare` against BOTH our databases. With the
window masked, nothing the patch wrote is reachable.

**The corpus, all four moving row-modes** (`ARMS186.r10v186.txt`):

```
UNMASKED pristine  head int_var(sz)@485:7-485:9 / <null>          <- the cleared head
UNMASKED patched   head constant()@1664:20-1664:21 / operation()@1664:21-1664:30
MASKED   pristine  head constant()@1664:20-1664:21 / operation()@1664:21-1664:30
MASKED   patched   head constant()@1664:20-1664:21 / operation()@1664:21-1664:30
```

The patched head is **the pristine database's own next failure**, reached with
the law's window masked out. It is pre-existing and merely unmasked — and it is
independently the R0 the implementer names: `bit predecessors[uvm_phase];`
(uvm-1.2 `uvm_phase.svh:1664`), golden a `constant`, ours an `operation`, a
both-sides compare and not a null.

**Arm A of r10uvm186, the 31 → 9212 elab jump**, gives the identical answer:
masked, pristine and patched both land on `module_inst work@top186a` — a
both-sides compare that was already there. The def view masks to
`logic_net(m_stash)@45:5` on both binaries. Every one of this verifier's five
arms reports the same head on both binaries, masked or not.

---

## 5. THE ONE THING THE PATCH GETS WRONG — R-V1, and why it is not fixed

`RESIDUE_RV1.r10v186.txt`. In arm A's **ELAB view only**, the ref for the
RETURN NAME of an **out-of-body class method** used as a `new[...]` size
argument in a wildcard clone (`dyn186v = new[sill186v];` at 74:19) **loses its
`vpiFullName`**. Golden carries
`Wainscot186v::Newelpost186v::sill186v::sill186v`; the pristine binary carried
the same string; the patched binary carries none. Its `vpiActual` is unchanged
on both binaries — only the fullname moves. This is the **only** dump line the
patch removes anywhere in 5053 arms and 2314 databases.

It is invisible to the judge, verified from the generated source rather than
carried forward: `ref_obj::Compare`
(`~/git-repos/UHDM/build/generated/src/ref_obj.cpp`) reads `VpiType`,
`VpiName`, `VpiDefName`, `VpiGeneric`, `Actual_group` and `VpiStructMember` —
and **no** generated `Compare` body in `UHDM/build/generated/src/*.cpp` reads
`VpiFullName` at all. Corpus incidence is **zero**: the order-blind attribution
of all four real movers has no removal line.

**Not fixed, deliberately.** One face, one view, a field the judge cannot read,
zero corpus incidence — a production fix would add surface no gate can score.
r10uvm186's own R2 measured the same axis in the other direction (keeping the
clone's fullname costs one AWAY per key in the elab view) and refused it for
the same reason; this is that residue's mirror and belongs with it.

---

## 6. THE WIDE BOUNDARY

`BOUNDARY.r10v186.txt`. A copy of the WHOLE `tools/probe` tree, both binaries,
both views, dumps compared byte-for-byte; fd-3 list, children `</dev/null`,
`PROCESSED` asserted, scratch keyed on the RELATIVE path, this verifier's own
`BWD`.

```
LISTED=5053 FENCED_SKIPPED=0 PROCESSED=5053 MOVED=14 NO_OUTPUT_PAIRS=384
PROCESSED-ASSERT-OK          ASYMMETRIC_OUTPUT: 0
```

The 14 moved arm-views are r10uvm186's three arms and this verifier's four (a
focused second run adds arm E, `LISTED=22 PROCESSED=22 MOVED=16
PROCESSED-ASSERT-OK`). **Everything else in the tree is byte-identical**,
including, by name and by file:

* § `cloneBuiltinMethodArgBindsReceiver184`'s arms `g184_a_recv.sv` and its
  **receiver-kind fence** `g184_b_kinds.sv` — 0 moved;
* § `retNameArgKeepsReturnVar184v`'s arms `gv184_g_retname.sv`,
  `gv184_h_retpin.sv`, `gv184_i_minimal.sv` (and `gv184_c/d/e/f`) — 0 moved;
* uvm185's prototype arms and both inheritance fences (`r10uvm185repro` 5,
  `r10v185repro` 5) — 0 moved;
* uvm181 (4), uvm182 (4), uvm183 (6), uvm82 (7), uvm91 (5), buvm3 (4),
  buvm15 (9), sd8 (37), sd12 (108) — 0 moved.

---

## 7. RANKED RESIDUES

1. **R0 (the implementer's, independently confirmed by the mask experiment on
   all four row-modes).** The RANGE of an associative array whose index is a
   CLASS, in the clone listing: `bit predecessors[uvm_phase];`
   (uvm-1.2 `uvm_phase.svh:1664`). Golden a `constant`
   (`vpiDecompile:associative`, `vpiConstType:6`, `ref_typespec ->
   class_typespec (uvm_phase)`), ours an `operation` (`vpiOpType:11`) over
   `ref_obj (uvm_phase)` plus `constant INT:1`. 62 cmp lines, ONE `^LHS:`, the
   same object in all four row-modes, a both-sides compare.
2. **R1 — the EXPLICIT-import copy**, now measured on a verifier golden too
   (arm D, `package:Echinus186v`): golden binds `import P::fn;`'s copy exactly
   as it binds the wildcard clone, five keys × two copies, both views, and the
   law's gate (`pkgImportCloneEmit`) deliberately does not name it. Corpus
   incidence zero on two independent superset predictors. The cheapest next
   widening of this family if a corpus row ever needs it.
3. **R-V1 — the clone `new[...]` return-name argument's `vpiFullName`** in the
   elab view of an out-of-body class method (§5). Judge-invisible, corpus
   incidence zero, the mirror of the implementer's R2.
4. **R3' — a built-in method's RECEIVER under a `new[...]` in a clone**
   (arm C: `new[ring186v.size()]`, `new[rq186v.size()]`). Golden binds the
   receiver (`array_var`, `io_decl`), we leave it bare on both binaries; built
   by the method-call builder, outside this gate. Joins the implementer's R3
   (select BASE, foreach INDEX).
5. The implementer's R2 / R4 / R5 / R6 stand as written and were not disturbed.

---

## 8. REPRODUCING

```sh
g++ -O2 -std=c++17 ct186v.cpp     -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186v
g++ -O2 -std=c++17 ct186vseed.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186vseed
g++ -O2 -std=c++17 ct186vmask.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186vmask

CTV=./ct186v CTN=<ct186new> ./v186grid.sh v186_a_retname.sv   <pris.bin> <pat.bin> <wd>
CTV=./ct186v CTN=<ct186new> ./v186grid.sh v186_b_position.sv  <pris.bin> <pat.bin> <wd>
CTV=./ct186v CTN=<ct186new> ./v186grid.sh v186_c_kinds.sv     <pris.bin> <pat.bin> <wd>
CTV=./ct186v CTN=<ct186new> ./v186grid.sh v186_d_listing.sv   <pris.bin> <pat.bin> <wd>
CTV=./ct186v CTN=<ct186new> ./v186grid.sh v186_e_instances.sv <pris.bin> <pat.bin> <wd>
python3 scorev186.py <wd>/win.g.<view>.txt <wd>/win.a.<view>.txt <wd>/win.b.<view>.txt
./ct186vseed <golden.uhdm> <pristine.uhdm> <patched.uhdm>      # the mask experiment
CT186NEW=./ct186v ../r10uvm186repro/predict186.sh <PRISTINE workdir> <out.txt>
CT186NEW=./ct186v ../r10uvm186repro/cenall186.sh  <pris wd> <pat wd> <outdir> SeqDriver MiniAmiq SimpleUVM Scoreboard BuildUVMPkg
PRI=<pris.bin> PAT=<pat.bin> ROOT=<copy of tools/probe> BWD=<own scratch> ../r10uvm186repro/bound186.sh
```

Every arm must read **AWAY 0, MOVED-WRONG 0 and ONLY-OURS-MOVED 0 in both
views**, its calibration golden×3 must read every column 0 but UNTOUCHED, and
`ct186vseed` must report the SAME masked head for both binaries.
