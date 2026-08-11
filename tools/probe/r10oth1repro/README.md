# r10oth1 — state transfer

**Pass result: TARGET A (InterfaceModPort) CONVERTED, CMP_NOTEQUAL -> CMP_EQUAL in
BOTH modes. TARGET B (YosysOldOr) NOT DONE — decoded, the brief's model REFUTED,
handed forward below with a ranked residue.** Base commit `6a3075a`, branch
`auto5h`.

Direction convention used everywhere in this file and in every note comment the
patch adds: **LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>` (PLAYBOOK §3).

Target A needed **four** laws, not one. The brief predicted one ADD; the cmp
head is only ever the FIRST divergence, and three more heads sat behind it. All
four are in the single patch.

---

## The four laws

### 1. `§ timeLitUintConst` / `§ srlgTimeLitVal` / `§ timeLitParamUint` / `§ timeLitParamIntTs`

Sites: `src/EmitHelpers.h` (`srlgTimeLitVal`, `declaredTimeLiteralParam`),
`src/ExprEmit.cpp` (`case ExpressionKind::TimeLiteral`), `src/ParamEmit.cpp`
(`timeLitInit9` -> value + `wantTs` + the param_assign-Rhs ts arm;
`timeLitUntyped9` in `makeParamTs`).

- **Direction: ADD.** Golden has a valued Rhs constant, a `ref_typespec` and an
  `int_typespec`; we had *nothing* — `ExpressionKind::TimeLiteral` was a
  `noteUnsupported` kind, so every time literal in the corpus emitted no object
  at all.
- **What Surelog actually does**, transcribed from
  `Surelog/src/DesignCompile/CompileExpression.cpp:699`
  (`case VObjectType::paTime_literal`) + `TimeInfo::unitFromString`: parse the
  numeric prefix as an INTEGER (`NumUtils::parseUint64` = `std::from_chars`, so
  `1.5ns` yields 1 — the fraction is dropped) and multiply by a FIXED per-unit
  factor **that ignores the timescale entirely**:
  `s 1e12 | ms 1e9 | us 1e3 | ns 1e6 | ps 1 | fs 1e-3`, unknown unit = ps.
  The table is not monotone (`us` < `ns`) and `fs` truncates, because the
  factors are doubles assigned back into a `uint64_t`. The constant carries
  `UINT:<val>` / `vpiUIntConst` / `vpiSize 64` and **no vpiDecompile**.
- **Proof of the value table (positive control for every arm):** purpose-built
  golden `t2_timeunits.v` (one untyped parameter per unit plus `1.5ns`).
  Surelog: `7fs->0  7ps->7  7ns->7000000  7us->7000  7ms->7000000000
  7s->7000000000000  1.5ns->1000000`. The transcription reproduces all seven.
  Golden also proves the *timescale-independence*: the InterfaceModPort golden
  is byte-identical between `default` mode (no timescale) and `testflags` mode
  (`-timescale=1ns/1ns`).
- **The gate, and why it is necessary:** `!typedParam`. An UNTYPED parameter
  takes the int_typespec default *even though slang types `5ns` realtime*;
  Surelog derives the implicit type from the DECLARATION, not from what the
  initialiser evaluates to. The gate is what keeps this off `parameter p =
  123.45` (a real literal, which really is `real_typespec` — same probe file,
  `t_real` row, **which the verifier had to ADD: this paragraph cited a control
  row that did not exist in `t2_timeunits.v`, so the claim rested on a missing
  asset. The claim itself was independently measured and HOLDS** — post-patch we
  still emit `real_typespec` + `REAL:123.450000`, byte-identical to golden) and
  off written `realtime`/`time` parameters, which keep their
  declared typespec through the arms above. `declaredTimeLiteralParam` reads the
  DECLARATOR SYNTAX, not `getInitializer()`, so an instance override cannot flip
  the answer (same reasoning as the existing `declaredStringLiteralParam`).
- **Witness:** InterfaceModPort `work@mem_interface.setup_time` and
  `hold_time` — golden `UINT:5000000` + `ref_typespec -> int_typespec 3:4-3:30`
  on the parameter, plus a `param_assign` Rhs `constant UINT:5000000 size 64
  constType 9` with its own `ref_typespec (work@mem_interface)` -> the same
  int_typespec. Both parameters are the same law and both are fixed by it (the
  brief's warning about the second instance was correct; no special-casing).
- Head 1 closed by this law.

### 2. `§ clockingSkewDelayControl`

Site: `src/ModuleEmit.cpp` (`UhdmExporter::emitClockingSkew` + three call sites:
`emitScopeClocking`'s default/global block, `emitNamedClockingBlocks`' named
block, and the per-signal `clocking_io_decl` arm). Declaration in
`include/UhdmExporter.h`.

- **Direction: ADD.** Golden has `vpiInputSkew` / `vpiOutputSkew`
  `delay_control` objects; we had none.
- Transcribed from `Surelog/src/DesignCompile/CompileHelper.cpp:4671`
  (the `paDefaultSkew_*` / `paClockingDir_*` arms) + `compileDelayControl`
  (`CompileHelper.cpp:3085`):
  * the object spans the `#<delay>` text INCLUDING the `#`;
  * its `vpiParent` is the CLOCKING BLOCK in both positions **IN THE DEF VIEW**
    — a per-signal skew hangs off the `clocking_io_decl` but still parents at
    the block. **SCOPE CORRECTED by the pass-47-era verifier: this is FALSE in
    the ELAB view**, where golden parents a per-signal skew at
    `clocking_io_decl: (d), line:18:16, endln:18:17` while we print
    `clocking_block: (work@mtop.i0.cb4)`. See R6 — it is dump-only, since
    `delay_control::Compare` reads only `Stmt` and `Delay`;
  * it carries **no `Delay` expression and no `Stmt`** — Surelog never compiles
    the skew expression;
  * `vpiDelay` is `#` + the LEADING DIGITS of the delay text, and only when the
    delay is a literal;
  * a written edge (`posedge #1`) sets `vpiInputEdge`/`vpiOutputEdge` — on the
    clocking_block for a default skew, on the io_decl for a per-signal skew.
- **Proof / characterisation (purpose-built golden `t3_clocking_skew.v`,
  five rows in one source):**
  | row | source | golden |
  |---|---|---|
  | cb1 | `default input #st output #ht;` (PARAM refs) | two delay_controls, **no** vpiDelay |
  | cb2 | `default input #1 output #2;` | delay_controls with `#1` / `#2` |
  | cb3 | `default input #1step;` | one delay_control, vpiDelay `#1` (not `#1step`) |
  | cb4 | `input #3 d;` (per-signal) | skew on the io_decl, **parented at the block** |
  | cb5 | module `default clocking` | same shape as cb1/cb2 |
  cb1-vs-cb2 is the measurement that produced the "vpiDelay only for a literal"
  rule; it is the InterfaceModPort shape (`#setup_time` / `#hold_time`), and it
  is why the delay_controls we emit are EMPTY. `vpiDelay` is **not** a Compare
  field (`delay_control::Compare` compares only `Stmt` and `Delay`) — it is
  transcribed so the DUMP matches too.
- Probe dump diff on `t3_clocking_skew.v`: **208 -> 38** lines.
  > CORRECTED BY THE PASS-47-ERA VERIFIER: the "before" figure said 112. Running
  > the SHIPPED `probe.sh` against a binary built from a pristine 6a3075a gives
  > **208**. The 38 is right. (Same script on `t2_timeunits.v`: 360 -> 27, and the
  > README's bare "27" for t2 is correct.) RE-MEASURE, DO NOT INHERIT A NUMBER.
- Head 2 closed by this law.

### 3. `§ ifaceDupSharesHomePorts`

Sites: `src/ModuleEmit.cpp` (`makeIfaceRefDup` now queues instead of minting),
`include/UhdmExporter.h` (`pendingIfaceDupPorts`), `src/UhdmExporter.cpp` (the
late drain, next to the `netTsAlias` drain).

- **Direction: REPLACE.** The col-0 interface tail dup carried FRESH name-only
  ports; it must carry the HOME view's fully-connected port objects (shared).
- **This law REFUTES a documented earlier claim** — session 19's "iface
  group-10 (dup **bare ports**, ...)" and the in-code comment "The dup lists the
  iface's HEADER PORTS as BARE ports (name + decl name span only) — Surelog."
  That claim was read off the DUMP, where golden prints the dup's port as
  `|vpiPort: \_port: (clk), line:4:29, endln:4:32` with **no body**. But
  `uhdm-dump` SUPPRESSES the body of an already-visited object
  (`vpi_visitor.cpp:5003`, `alreadyVisited`), and the dup lives in the
  `weaklyReferenced` tail, i.e. is always printed AFTER the home view. The empty
  body is a REVISIT of the home view's port, not a bare object.
- **Why the bug was invisible for 30+ passes** (this is the transferable
  lesson): `BaseClass::Compare` short-circuits on
  `m_visited.insert(this).second`. Whether the difference is even OBSERVED
  depends on which of the two paths reaches *golden's* port object first.
  `iface_internal_assign` (u2r, CMP_EQUAL) reaches the home first, golden's port
  is already visited, and the whole subtree returns 0 **without looking at our
  side at all** — that test is CMP_EQUAL *with a DUMP_DIFF at exactly these
  lines*. InterfaceModPort reaches the DUP first, so the fields are compared and
  our stub loses.
- **Proof the change is right and not just head-moving:** on
  `iface_internal_assign` the probe dump diff drops **62 -> 56** while cmp stays
  PASS_CMP (so golden agrees with sharing on the test that motivated the old
  claim), and the u2r corpus row set is byte-identical (below).
- Deferred because the home's ports are built by the `emitTopPorts` /
  `instSetPorts` drain, long after the dup exists. First attempt wrote the share
  inline in `makeIfaceRefDup` and measured ZERO (`home->Ports()` was still
  empty) — a null-reach that reads exactly like a refutation; the queue fixed it.
- Head 3 closed by this law.

### 4. `§ modportHdrPortNetKeyword`

Site: `src/ModuleEmit.cpp`, the modport-`io_decl` clone net for an
interface-HEADER port.

- **Direction: REPLACE** a hard-coded `vpiNetType(vpiNet)` (36) with the port's
  own net type (`netTypeFor`), keeping 36 as the fallback when `netTypeFor`
  returns 0 (a kind that prints no net type at all), so no net silently loses
  its tag.
- **Refutes the in-code claim `// 36 — SL's quirk for these`.** 36 is right only
  for a header port declared with a DATA type: `iface_internal_assign`'s
  `interface myif (input logic clk, input logic rst)` -> golden 36, unchanged by
  this patch. InterfaceModPort writes `interface mem_if (input wire clk)` and
  golden says **1** (`vpiWire`) in both modport clones
  (`...U_ctrl.sif.system.clk.clk` and `...U_model.mif.memory.clk.clk`).
  `netTypeFor` already implements exactly that wire-vs-logic split for every
  other net in the emitter; the clone site was the one place that bypassed it.
- Head 4 closed by this law; the test converted.

---

## Gates (all four ran; numbers are MEASURED, not inherited)

`SLANG_UHDM` exported to **this worktree's** build
(`.claude/worktrees/wf_d4eb1e2a-31b-1/build/slang-uhdm`) for every gate.

1. **Build** — `cmake --build build -j 4` -> `Built target slang_uhdm`.
2. **Goldens** — `bash tests/check_goldens.sh | grep -c '^PASS'` = **23**, FAIL
   0. Negative control `SLANG_UHDM=/bin/false` -> **PASS 0 / FAIL 23** (so the
   export is real; the trap in `verify_golden.py:52` / `check_goldens.sh:5` is
   defaulting to the MAIN-TREE binary).
3. **uhdm2rtlil corpus, both modes, --jobs 2** — `default` 679 CMP_EQUAL / 50
   SLANG_REJECT / 2 SURELOG_FAIL; `testflags` identical. Judged against the
   committed `results/gate_uhdm2rtlil.csv` (which holds the **testflags rows
   only**): whole-row diff (status *and* dump column) = **0 lines**. Dump column
   496 match / 183 differ / 52 blank — exactly the committed baseline. No
   match->differ, no status change, no improvement either.
   > SCOPE CORRECTION (pass-47-era verifier): those dump figures are
   > **testflags-only**, because the committed CSV holds only testflags rows. The
   > `default` mode measures **492 match / 187 differ / 52 blank** and has **NO
   > COMMITTED BASELINE**, so it was NOT row-checked. Stated rather than implied.
4. **surelog corpus, both modes, --jobs 2** — whole-row diff against the
   committed `results/golden_surelog.csv`, over all 1588 rows:
   ```
   < InterfaceModPort,default,CMP_NOTEQUAL,decompile:,,
   < InterfaceModPort,testflags,CMP_NOTEQUAL,decompile:,,
   ---
   > InterfaceModPort,default,CMP_EQUAL,,,differ
   > InterfaceModPort,testflags,CMP_EQUAL,,,differ
   ```
   **That is the ENTIRE diff.** Two rows, both the intended conversion. The
   known `Google,testflags` golden-side flake did NOT appear this run (baseline
   and new both read `TIMEOUT`); it is named here, not filtered.

**Canaries, checked individually** (66 surelog-corpus rows + 8 u2r rows matching
the named set): byte-identical to baseline. `InterfaceBinding` CMP_EQUAL +
DUMP=**match** and `InterfaceModExp` CMP_EQUAL + DUMP=**match** both hold — the
strongest available control on laws 3 and 4, since either would have flipped
those DUMPs to `differ` had they been wrong there. `Earlgrey_0_1` is a single row
(CMP_NOTEQUAL default / SLANG_REJECT testflags, unchanged); the sub-design names
the brief lists (hmac, sha2, aes_sbox, ...) are **not rows** in
`results/golden_surelog.csv`, so they could not be checked as rows — stated
rather than implied.

Neither baseline CSV was rebuilt, edited, or included in the patch. No sweep ran
concurrently with any build.

---

## Refutations (the valuable part)

1. **"17 lines, ONE head, the fix ADDS, lowest-risk single law."** The cmp head
   is only the first divergence — `uhdm-cmp` stops there. InterfaceModPort had
   **four** heads; two of the four fixes REPLACE rather than ADD, and two of them
   contradict claims already written into the code and HANDOFF.md.
2. **"dup bare ports" (session 19, and the in-code comment).** Wrong: the dup
   SHARES the home view's ports. The dump's empty body is `alreadyVisited`
   suppression. See law 3.
3. **"`vpiNetType(vpiNet)` // 36 — SL's quirk for these".** Wrong as a
   constant: it is the header port's own net type. See law 4.
4. **Source locations are NOT cmp-visible.** `BaseClass::Compare` compares only
   `VpiType`, `VpiName`, `VpiDefName` — no file/line/column. Six of the
   InterfaceModPort dump differences (interface scalar `logic` typespec spans
   27:3-27:8 vs 27:3-27:21, a port LowConn `ref_obj` location, `vpiFullName`
   differences on hier_path `ref_obj`s) are therefore **dump-only** and cost
   nothing for a surelog-corpus conversion. Reading the generated Compare code
   BEFORE theorising (PLAYBOOK method law) cut the estimated work for this test
   from ~7 laws to 4. Anyone triaging a surelog-corpus CMP row from a dump diff
   should classify each hunk against the generated `Compare` first.
5. **Target B's framing is REFUTED — see below.** Not "we fold every def-view
   port range at this site": we fold it only in the FULL-DESIGN compile, and the
   same site is cmp-EQUAL when its module is compiled with just its own deps.

---

## RANKED RESIDUE (most reachable first)

### R1. YosysOldOr (Target B) — HONESTLY NOT DONE. Direction: REPLACE. Depth: medium, but the search moved.
The head is a def-view port packed range `[dw-1:0]`: golden keeps `dw-1` as an
`operation` (`vpiOpType:11`, operands `ref_obj(dw)` + `constant UINT:1 sz64 ct9`),
we fold it to `constant INT:31 ct7`. What I MEASURED, which changes the target:

* **The def-vs-elab law is already correct in our emitter.** Compiling
  `or1200_du.v` with only its own deps (`b1_du_alone.sh`) is **PASS_CMP**, and we
  produce golden's exact split: DEF view keeps the `dw-1` operation, ELAB/top
  view folds to 31. Same for `or1200_ic_top.v` with its deps
  (`b2_ictop_alone.sh`): **PASS_CMP**.
* **So the brief's instruction — "find the predicate that makes THIS site fold
  when the common case does not" — has no answer at the site.** The site does
  not fold. It folds only in the FULL-DESIGN compile. This is a CONTEXT or
  OBJECT-SHARING defect, not a folding-rule defect.
* **Exactly ONE object differs.** With `b3_count113.sh` over both full-design
  dumps (pattern hits are 3 per operation object, 1 per folded constant):
  golden 6 hits = **2** unfolded operation objects at line 113, ours 3 hits =
  **1**; folded constants golden 8 / ours 9. Lines **111 and 112** of the same
  file (`input [aw-1:0]`, `input [dw-1:0]`) match golden exactly (3 hits / 5
  folded on both sides) — so it is not "output vs input" and not "line 113".
  One of `or1200_du` / `or1200_ic_top` loses its def-view unfolded bound *only*
  in the full design.
* Both files' line 113 is byte-identical source (`output\t[dw-1:0]\t\t<name>;`)
  so **the two candidates have IDENTICAL spans (113:8-113:16, op 113:9-113:13)**
  and cannot be told apart in a dump by location. Next step is instrumentation
  or an id walk (a cmptool-style program that loads both `.uhdm`s and prints the
  path to golden id 186092 / our id 214152), NOT more dump grepping.
* **The brief's "second, SEPARATE distinguisher" (golden UINT/ct9/sz64 vs our
  INT/ct7 on the minted operand constant) needs NO work**: our isolated runs are
  cmp-EQUAL, which means the constant our unfolded path already mints matches
  golden bit for bit. `vpiOpType 11` = the op golden uses; our isolated output
  already produces it.
* Leading hypothesis to test first: a shared/cached typespec or range object
  reused across the two modules (or across a def and an elab view) in the
  full-design ordering — i.e. a MINT-SITE collision, which is exactly the class
  the PLAYBOOK warns measures as a "refutation".

### R2. Time-literal parameter in an ELAB module view. Direction: REPLACE. Depth: shallow.
An untyped time-literal parameter inside an INSTANTIATED module gets the wrong
elab-view Rhs constant: golden re-folds it (`vpiDecompile:<digits>`,
`vpiSize 32`), we keep the def-view form (no decompile, size 64). Visible in
`t2_timeunits.v` (the only residue left in that probe, 27 dump lines) — the
def-view row is already correct, and InterfaceModPort never hits it because
`mem_interface` is never instantiated, so it has NO elaborated view. It is
cmp-visible (`expr::Compare` compares `VpiDecompile` and `VpiSize`), so some
other test with an instantiated time-literal parameter would need it. Not a
regression: those sites emitted NOTHING before this patch.

### R3. `default clocking` blocks emit no `clocking_io_decl`s. Direction: ADD. Depth: shallow.
`emitScopeClocking` (the `default clocking` / `global clocking` path) emits the
block + event + (now) the skews, but never the io_decls;
`emitNamedClockingBlocks` does. Golden `t3_clocking_skew.v` cb5 carries
`clocking_io_decl (e)` with `vpiDirection:2`. Pre-existing, untouched.

### R4. `input output` clocking item direction. Direction: REPLACE. Depth: trivial.
Surelog's io_decl writes `vpiOutput` for a `paClockingDir_InputOutput` item
(`CompileHelper.cpp:4869`); we map slang's `ArgumentDirection::InOut` to
`vpiInout`. Not exercised by any corpus test I saw — found while transcribing
law 2, recorded so it is not re-discovered.

### R5. InterfaceModPort DUMP is still `differ` (CMP_EQUAL). Direction: mixed. Depth: NOT shallow.
**REWRITTEN — the pass-47-era verifier measured this residue and the original
text understated it by an order of magnitude and mis-classified it.** It is
**479 diff lines in 26 hunks** (default and testflags identical), golden 3717
dump lines vs ours 4104. Only ~46 lines are golden-only; **433 are OURS-ONLY**,
dominated by whole extra weak-tail subtrees: 15 extra `interface_inst
work@mem_if` headers, 9 `modport`, 8 `io_decl`, 40 `logic_var`, 49
`logic_typespec`. So the dominant direction is **REMOVE**, not the
span/fullname polish the original text implied.

It is also **not purely location/fullname**: golden emits `logic_net:
(work@interface_modports.U_model.mem)` where we emit a `logic_var`, and a
hier_path element differs in **`vpiName`** (golden
`work@memory_model.mem.addr_mem`, ours `addr_mem`) — a real KIND difference and
a real NAME difference, either of which a future Compare change could make
cmp-visible. The original location/fullname classes (interface scalar `logic`
net typespec spans, a port LowConn `ref_obj` location, hier_path `vpiFullName`s)
are a MINORITY of the residue, not the whole of it.

### R6. Per-signal clocking-skew delay_control parents differently in the ELAB view. Direction: REPLACE. Depth: shallow. Dump-only.
Found by the pass-47-era verifier while checking § `clockingSkewDelayControl`'s
stated parent rule. Golden's elab view parents a per-signal skew at the
`clocking_io_decl` (`(d), line:18:16, endln:18:17`); we parent at the
`clocking_block` (`work@mtop.i0.cb4`) in both views. Invisible to cmp
(`delay_control::Compare` reads only `Stmt` and `Delay`), so it is a DUMP_MATCH
phase-3 item, but it means the law as written has an UNMEASURED HALF.

### R7. Three PRE-EXISTING defects the arms exposed (base binary reproduces all three; NOT caused by this patch).
Recorded by the pass-47-era verifier.
1. `parameter realtime R = 5ns` -> golden emits a **`time_typespec`**; we emit
   `real_typespec`. **The new in-code comment in `makeParamTs` asserts that
   `realtime R = 5ns` -> `real_typespec` as if that were correct, and it is
   not** — fix the comment before it misleads the next pass. Direction: REPLACE.
2. `parameter p = 5ns + 1` -> golden puts **no `vpiValue`** on the parameter at
   all; we put `REAL:6.000000`. In the ELAB view golden folds the whole
   expression to `constant UINT:5000001` where we keep the (now correct in the
   def view) `operation` opType 24. Direction: mixed.
3. `bit clk = 0` in a module -> golden `logic_net`, we `bit_var`. Direction:
   REPLACE. Same family as the already-known interface `output reg` finding.

---

## Assets in this directory

| file | what it is |
|---|---|
| `probe.sh` | one-source probe driver (Surelog + ours, dump-diff + cmp). REQUIRES `SLANG_UHDM` — it deliberately has no default, so it can never silently measure the main-tree binary. |
| `t2_timeunits.v` | purpose-built golden for `§ srlgTimeLitVal`: one untyped parameter per time unit plus `1.5ns`, plus a real-literal and an int-literal control row (`t_real`/`t_int`, ADDED by the pass-47-era verifier audit — the README cited them before they existed). |
| `t3_clocking_skew.v` | purpose-built golden for `§ clockingSkewDelayControl`: param-ref / literal / `1step` / per-signal / `default clocking` skews in one source. |
| `b1_du_alone.sh` | Target B: `or1200_du.v` + deps alone -> PASS_CMP (the refutation). |
| `b2_ictop_alone.sh` | Target B: `or1200_ic_top.v` + deps alone -> PASS_CMP. |
| `b3_count113.sh` | Target B: counts folded vs unfolded line-111/112/113 range forms in two dumps (the "exactly one object differs" measurement). |
