# r10v218 — ADVERSARIAL VERIFICATION of r10uvm218 (§ `uninstIfaceBodyBindsInMethodWindow218`)

**VERDICT: ACCEPT.** Every headline number in the implementer's report was
reproduced bit-for-bit from binaries this verifier built itself at `5c4eb804`;
six new arms attacking the law's faces found **no pristine-right → patched-wrong
cell on legal SV**, and one new residue.

**MEASUREMENT-ONLY.** Nothing here is an acceptance judge; the official
`uhdm-cmp` and `scripts/verify_golden.py` are. slang was NOT patched,
`results/*.csv` were READ ONLY and NOT EDITED, no row was converted,
`GOLDEN_DEFER` stayed unset, and no driver here dispatches a slang-fenced test.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `5c4eb804`, own worktrees, own builds |
| pristine binary | md5 `9ba51a177d67154a84ed9a462f38448d` — the implementer's value, reproduced |
| patched binary | md5 `5ec486e65d0ed6c8f7f6ed6a29b1b81c` — the implementer's value, reproduced from `/tmp/r10uvm218.patch` applied to a FRESH `5c4eb804` |
| both frozen | `chmod 555` copies before any sweep; every `cmds.txt` audited by binary PATH |

---

## 1. What was reproduced, independently

* **The head.** `rowheads.sh`, own sweeps: pristine **MiniAmiq ×2 = 29 cmp
  lines / 1 head** (SINGULAR `SafeCompare`, `LHS: io_decl (a_sva_type)@255:103`,
  `RHS: <null>`); patched **20 lines / 1 head**, a new object family
  (`unsupported_typespec (a_lof_sva)`@198:15 vs our `class_typespec
  (svaunit_concurrent_assertion_info)`@196:45). Every other control row
  unchanged: SeqDriver ×2 `1327330/1`, SimpleUVM ×2, Scoreboard/default,
  BuildUVMPkg ×2, Earlgrey_0_1 ×2, Rggen/default all `0/0` at `rc=0`.
* **The population.** With this verifier's OWN census (`cenv.py`, which records
  the vpiActual's **name and line**, not only its kind), `work@svaunit_vpi_interface`:
  calibration null (`303/303`), pristine `SAME 219 / MISSING 21 / EXTRA 16 /
  OTHER 70` → patched `239 / 1 / 16 / 70`; the **EXTRA and OTHER cell lists are
  byte-identical** (86 lines each). The 20 moved cells are **10 `io_decl`,
  9 `bit_var`, 1 `enum_var`** and each lands on golden's own object — a
  kind-only census could not have told a right target from a wrong one; this one
  can, and every one is right. The single survivor is `a_sim_time`@383:56 (R1).
* **The decode**, read in `~/git-repos/Surelog`: `lateBinding` is called at
  `UhdmWriter.cpp:1304` (`writePackage`), `:1575`/`:1623` (`writeModule`),
  `:2072` (`writeElabProgram`) and `:4785` (elaborated instance) — and is
  **COMMENTED OUT at `:1067` in `writeClass`**, which is § classMethodNoBind
  itself. `writeInterface` spans `1626-1794` and **contains no call at all**;
  `writeProgram` (`1795-1900`) contains none either (the implementer's R2).
  `CompileHelper::bindVariable` is at `CompileStmt.cpp:3089` with
  `if (scope == nullptr) return nullptr;` at `:3093`. The model is read from the
  producer, not inferred.
* **The grid.** `grid218.sh` re-run on BOTH binaries: 10 arm-views, 0
  NO-DATABASE, calibration null in all 10. `a2_window` parse `MISSING 12 → 0`,
  `a4_dpi` parse `8 → 0`, and `a3_muststay`'s **CELL LIST is byte-identical
  between the two binaries in both views**. Diffing the two runs' cell lists
  arm by arm yields **no new disagreement line anywhere**.
* **The gates.** goldens `23/0` on both binaries and `0/23` on `/bin/false`;
  uhdm2rtlil `679/50/2` in both modes on both binaries, `ct8rows` PASS three
  ways, `byteverify SELFCHECK=1` **0 / 1358**; surelog **475/6 default +
  469/6 testflags, status column identical cell for cell over all 1588 rows —
  NO ROW CONVERTED**; the seven protected CMP_EQUAL row-modes all `CMP_EQUAL`
  at `0 lines / 0 heads / cmp rc=0`; canaries u2r `ok=8 changed=0`, ctcan2 PASS
  ×2, `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0
  FENCE-BREACH=0`. Protected databases: **InterfaceModPort SAME** (`59a365f3ce2c`
  both modes both binaries — it is an interface test and it did not move),
  BlackParrotComplex SAME, YosysOldOr SAME, **SVSwitch `4842211c4030`**,
  **YosysVerx `6ccda350c24a`**.

### Two cells where this verifier's run differs from the implementer's — both settled

1. **`byteverify` surelog reads 3 / 956 here, not 2.** The third is
   **Scoreboard/default**, which RESUME §9 names as the ~50/50 coin. Attributed
   ORDER-BLIND as the law requires: sorted, path-normalised, id-normalised dumps
   differ by **0 content lines** (only the dump banner naming the workdir). It is
   the coin, not the law. MiniAmiq ×2 are the other two — exactly the predicted
   pair, and no others.
2. **`ct8rows` surelog reports ONE differing row**, against the committed
   baseline *and* against this verifier's own pristine sweep:
   `Earlgrey_0_1,testflags,CMP_EQUAL,,,differ` → `CMP_EQUAL,,,`. **The status is
   unchanged and the database is byte-identical** (`92bf7b7facdcf4fca15d5710960e8c64`
   on both binaries — it is not a byteverify mover). `verify_golden.py`'s
   `compare()` returns `''` for the dump column on `subprocess.TimeoutExpired`
   of `uhdm-dump`; re-dumping that exact file afterwards succeeds (`rc 0`) and
   hashes to `f731f7ca…` against golden's `d6624210…`, i.e. **`differ`, the
   baseline value**. It is a dump-timeout flake under this verifier's CPU load
   (the wide boundary was running), the same Earlgrey testflags dump-column cell
   earlier landings recorded. The pristine sweep of the same corpus reads
   `ok=52 changed=0`; the patched one reads `ok=51 changed=1` and that one
   changed row is this cell.

---

## 2. Breaking the law — six new arms, both views, one real Surelog golden each

`gridv.sh` builds golden, then BOTH binaries, in one directory per arm-view,
records every rc, counts a missing database as NO-DATABASE, runs the
golden-vs-golden calibration first, and scores with `cenv.py`.

| arm | what it attacks | result |
|---|---|---|
| `arms/b1_kinds` | TASK formals incl. `output`/`inout`/`ref`; `static` and `automatic` locals; a local **SHADOWING an interface member**; struct member; constant select; enum local; the **function return name**; ternary operands; a SYSTEM-task argument; a **DPI-import** call argument; `case` condition and case ITEM; **immediate assert** condition; `repeat` count; `foreach` variable; unnamed block at DEPTH TWO; `return` operand | parse `MISSING 23 → 0`; `EXTRA 1 → 1` and `OTHER 4 → 4` **unchanged**; elab `32 → 9`, EXTRA/OTHER unchanged. The shadowing local binds its OWN declaration (`work@if1v.f1v.shad1v`@43:11), not the interface member. The return name does not move. |
| `arms/b2_shapes` | uninstantiated interface WITH A MODPORT; a PARAMETERIZED interface with a PORT; a **CLASS declared inside** an uninstantiated interface; an **INSTANTIATED** interface; an uninstantiated MODULE | parse `13 → 6`, elab `17 → 10`, **EXTRA 0 → 0, OTHER 4 → 4**. The interface's own member/net/parameter/port stay BARE in every window. **Nothing in the instantiated interface, the module, or the inner class moves at all.** |
| `arms/b3_nest` | nested call arguments two deep; select INDEX in an argument and in a condition; member + formal in one argument; two refs in one condition; the **virtual-interface corpus shape** (a class holds `virtual if3v`) | parse `10 → 0` — **the whole arm closes**; elab `12 → 2`; EXTRA 0 → 0 |
| `arms/b4_ctl` | **MIS-TARGETING**: three subroutines in two interfaces all using the formal name `a_n` and the local name `l4v` | parse and elab both `12 → 0`, `SAME 18/18`. Each of the twelve binds the right one of `if4v_a.f4v.l4v` / `if4v_a.g4v.l4v` / `if4v_b.f4v.l4v`. A kind-only census is blind here; this one is not. |
| `arms2/b5_odd` | a **modport-IMPORTED** function; `void'()` cast call; a **CHAINED receiver** (`h.self().take(x)`) in statement position and in a condition; nested call + local in one argument | parse `8 → 0`, elab `9 → 1` — **and one cell moves `OTHER → EXTRA-OURS`: the new residue below** |
| `arms3/b6_reach` | how far `defAllInstCount == 0` reaches: an interface instantiated only inside a **never-instantiated module**; an interface that **instantiates another interface**; a **generate-block** function; a **clocking block** | parse and elab both `6 → 2`, `EXTRA 1 → 1`, `OTHER 0 → 0`. An interface with a real instance (even under a dead module) is untouched. |

**Byte-level, every arm-view, ids normalised: ADD-ONLY.** The only removed line
in any diff is `uhdm-dump`'s own banner naming the input file (`a.uhdm` vs
`b.uhdm`) — b1 `+47`, b2 `+15`, b3 `+21`, b4 `+25`, b5 `+19`, b6 `+9`, and
MiniAmiq `+40 / −0`. No object is created, removed or reshaped anywhere.

### The wide boundary, re-run

`bound218.sh` over this verifier's own probe tree: **LISTED = PROCESSED = 5491,
RC_DIFFS = 0, MOVED_ARMS = 17** = the implementer's 12 (6 of them this pass's own
grid arms, the positive control) + 4 of this verifier's own new arms + **one
extra, `./r10vrgg3repro/xi_iface_param_type/dut.sv elab`, which is NOISE, not the
law**: that arm's interface `itf` declares **no subroutine at all**, so
`hasSubs9` is false, the patched block in `emitInterfaceDef` is never entered and
`uninstIfaceSubBody218` is never set — the patch is provably inert on it. Measured
too: run standalone the two binaries agree byte-for-byte, and under load the
**pristine** binary produced the boundary's `a=` hash while 60 quiet pristine runs
and 135 patched runs produced the other — RESUME §9's parallel-parse
nondeterminism, seen on both binaries.

All six FOREIGN movers were re-scored here against a real Surelog golden
(`rescore_v.sh`, `RESCORE.boundary-movers.r10v218.txt`). Every one is the SAME
shape — a reference in an uninstantiated interface's subroutine body, in a
window — and every one moves **exactly one cell MISSING-OURS → SAME onto
golden's own object**, with EXTRA-OURS and OTHER unchanged and a `+2 / −0` dump
delta. The §216 arm `g216_d_iface_top` moves its cell `a`@25:16 onto
`io_decl(a)@23:39`, golden's own value; §216's own cells are untouched. Two of
the six (`w7v_pkgclsts2`, `v144_a_homes`) have goldens whose Surelog compile
returns **rc=4** — the implementer flagged this themselves; per uvm215 those two
teach error recovery, not golden, so they are counted here as *not-a-regression*
rather than as TO-GOLDEN credit. Neither shows any new disagreement.

---

## 3. Residues this verification adds or confirms

* **RV1 (new).** In an uninstantiated interface, a **chained-receiver** call in
  statement position (`h5v.self().take(a_o);`, arm b5 `o06`) — golden emits the
  inner `self()` call and the `h5v` ref but **no argument reference at all**,
  while we emit one; pristine left that extra ref bare, patched gives it a
  vpiActual. `EXTRA-OURS 0 → 1`, `OTHER 2 → 1` — the same cell, reclassified.
  This is **not** pristine-right → patched-wrong: the reference itself is a
  pre-existing shape residue on an object golden does not have, so no golden
  value is contradicted, and it is corpus-invisible (MiniAmiq's EXTRA/OTHER cell
  lists are byte-identical). The upstream defect is the outer call's argument
  emission, not the binding law; fencing on "the receiver is itself a call"
  would risk a2's `w26` (`h218.take(a_x)`, one-level receiver, statement
  position), which golden BINDS. Left standing, ranked below R1.
* **RV2 (new, pre-existing).** An interface that instantiates another interface
  (`if6v_host`) is emitted by us as a **`module_inst`** where golden emits an
  `interface_inst` (arm b6). Identical on both binaries; nothing to do with this
  pass.
* **R1 confirmed** — `a_sim_time`@383:56, the receiver-qualified call's sibling
  argument, is the one corpus cell not taken. MISSING, never AWAY.
* **R0 confirmed** — the new MiniAmiq head is the `foreach` header's array
  typespec, 20 lines, both modes.

---

## 4. Files

| | |
|---|---|
| `gridv.sh` | the verifier's grid: golden + BOTH binaries per arm-view, every rc recorded, calibration first |
| `rescore_v.sh` | re-scores boundary movers against a real golden; prints `GOLDEN-COMPILE-FAILED-rc=N` LOUDLY (uvm215) |
| `cenv.py` | reference-actual census recording the actual's **kind, name and line** — catches a right-kind/wrong-target bind |
| `arms/`, `arms2/`, `arms3/` | b1…b6 |
| `GRID.*.txt`, `RESCORE.*.txt`, `BOUNDARY.r10v218.txt` | the measurements above |
