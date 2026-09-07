# r10v191 — ADVERSARIAL VERIFICATION of r10uvm191

`§ cloneNewArrayHierBaseBindsOwnDecl191`.  **VERDICT: ACCEPT, unchanged.**
Every headline number reproduced bit-for-bit on independently built
binaries; three new arms on the faces the implementer's grid did not cover
found **no** pristine-right → patched-wrong cell.

MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  BASE 6873bc3f.

---

## 1. Independent rebuild — bit-identical

Two fresh worktrees at 6873bc3f, `cmake --build -j 2`, md5 taken separately,
both frozen `chmod 555` before any sweep.

| binary | md5 | implementer claimed |
| --- | --- | --- |
| pristine | `fb17fb4d8223169f2abb2b55cf560ea2` | same |
| patched  | `38c6f72a288d129d4fa9ee0ec3377394` | same |

The patch (`md5 6365537ace5f7dee7de93bbe080acac0`, 4204 lines) applies to a
FRESH 6873bc3f with all three production files reported "cleanly", 0 conflict
markers.  Surface: `include/UhdmExporter.h`, `src/ExprEmit.cpp`,
`src/UhdmExporter.cpp`, `tools/probe/r10uvm191repro/` — 0 files outside that
set, 0 `results/` rows, 0 `scripts/` or `tests/` files.  The integration
cycle's four-name fence check reports 0/0/0/0 (the names are supplied from
outside and are deliberately not spelled in any probe artifact).

## 2. Gates, re-run from scratch

* **Goldens** — patched 23 PASS / 0 FAIL; pristine 23/0; `SLANG_UHDM=/bin/false`
  0 PASS / 23 FAIL.  `SLANG_UHDM` exported explicitly to EACH binary.
* **u2r**, testflags AND default, `--jobs 2`: 679 CMP_EQUAL / 50 SLANG_REJECT /
  2 SURELOG_FAIL on both binaries in both modes.  `ct8rows` PASS ×3 (committed
  baseline in my worktree FIRST, then my own pristine vs patched, both modes).
* **surelog**, `--mode both`, `--jobs 2`:
  `937 / 567 / 48 / 19 / 10 / 3 / 2 / 1 / 1` — **identical** pristine vs
  patched.  `ct8rows` PASS vs the committed baseline and vs my own pristine.
  **NO ROW CONVERTED** (19 CMP_NOTEQUAL on both sides).  `results/*.csv`
  untouched (`git status --short results/` empty in both worktrees).
  `GOLDEN_DEFER` UNSET.
* **`cmds.txt` audited BY BINARY PATH**, file-by-file, all four sweeps:

  | sweep | cmds.txt | names patched | names pristine | names MAIN TREE |
  | --- | --- | --- | --- | --- |
  | surelog patched | 1573 | 1523 | **0** | **0** |
  | surelog pristine | 1573 | 0 | 1523 | **0** |
  | u2r patched | 1462 | 1458 | **0** | **0** |
  | u2r pristine | 1462 | 0 | 1458 | **0** |

* **Canaries** — surelog `ok=52 changed=0`; u2r `ok=8 changed=0`; `ctcan2` PASS
  ×2; `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`.
* **Protected databases** — all SAME both modes; `SVSwitch 4842211c4030`,
  `YosysVerx 6ccda350c24a`.

## 3. Head — cleared, decoded from my own cmp logs

Pristine head, SeqDriver ×2 and MiniAmiq ×2, **55 cmp lines, one `^LHS:`**:

```
LHS  array_var: (uvm_pkg::uvm_phase::get_adjacent_predecessor_nodes::predecessors) @1664:8
RHS  <null>
```

the SINGULAR `SafeCompare` overload naming a VALUE (RESUME §9).  Patched:
**58 lines, still one `^LHS:`**, a NEW object —

```
LHS  int_var: (uvm_pkg::uvm_phase::sync::visited.exists::succ) @1896:9
RHS  ref_var: (adpcm_pkg::uvm_phase::sync::succ) @1906:34
```

r10uvm184's R2 family, exactly the R0 the pass names.  Every other row-mode
unchanged; `measured=12 SKIP-NOFILE=2 UNKNOWN-NAME=0` on both binaries.

## 4. Movers — predicted, then measured

`predict191.sh` on my OWN pristine sweep:
`LISTED=956 PROCESSED=956 NOGOLDEN=0 PREDICTED=4 CELLS=32`; u2r
`LISTED=1358 PROCESSED=1358 NOGOLDEN=0 PREDICTED=0 CELLS=0`.

`byteverify SELFCHECK=1`: surelog **5 / 956**, u2r **0 / 1358**.  The four
predicted movers hash **identically to the implementer's**:

```
MiniAmiq  default+testflags  patched=3b159c20cfc2 pristine=035d062ecce0
SeqDriver default            patched=46bb51af242f pristine=135ec350c34e
SeqDriver testflags          patched=8585bcabf6f2 pristine=7ea31215a0f7
```

The fifth is Scoreboard/default, the documented `svunit_pkg` COIN: its
path-normalised **order-blind** dump diff is **0 content lines over 1 100 381
lines**.  My own Scoreboard hashes differ from the implementer's *and my
patched hash equals their pristine hash* — direct evidence the two states are
binary-independent.

Census on the real corpus (golden³ calibrated to all-zero first):

| row | UNTOUCHED | TOWARD | AWAY | MOVED-WRONG | ONLY-OURS-MOVED |
| --- | --- | --- | --- | --- | --- |
| SeqDriver/default | 68323 | **8** | **0** | **0** | **0** |
| MiniAmiq/default  | 70188 | **8** | **0** | **0** | **0** |

The 8 are 4 keys × 2 views, every one `HPBASE | NEWARG` in the `adpcm_pkg`
WILDCARD-IMPORT CLONE listing and none in the `uvm_pkg` HOME listing:
`predecessors` @1685:16 (the head), `successors` @1714:16, `local_addr`
@1467:19, `sys_addr` @1491:26.

**The class-property fence holds on the real corpus.**  `m_packed_size` at
`475:14 | NAME | NEWARG` — the `bits = new[m_packed_size]` cell
(uvm_packer.svh:475) that § 186 measured as golden-BARE — is BARE in golden,
BARE in pristine and BARE in patched, byte-identical rows.

## 5. Wide boundary

`LISTED=5108 FENCED_SKIPPED=0 PROCESSED=5108 MOVED=20 NO_OUTPUT_PAIRS=392
PROCESSED-ASSERT-OK` — the implementer's 5106/16 plus exactly my two new arms
× two views.  All 20 accounted for:

* **6** — the pass's own three arms (`g191_a/b/c`).
* **6** — the DECODED static-address false mover, three files
  (`r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`,
  `r10uvm185repro/grid185/g185_e_kinds.sv`).  I decoded it independently: the
  WHOLE diff is two constants, `22621945 → 22626041` and
  `22621089 → 22625185`, each appearing as a `vpiDecompile` + `UINT` pair and
  each shifting by **exactly 4096** — one page.  **NON-ADDRESS lines = 0** in
  both views of all three files, and the reference census moves **0 rows**.
* **4** — `r10uvm186repro/g186_a_argdecl.sv` and `r10v186repro/v186_c_kinds.sv`,
  which hold this law's own cells.  Re-scored against their own freshly built
  Surelog goldens at object identity: **TOWARD 4 / 2** and **TOWARD 10 / 6**,
  **AWAY 0, MOVED-WRONG 0, ONLY-OURS-MOVED 0** in all four cells — the
  implementer's numbers exactly — with the SAME head object on both binaries.
* **4** — my own arms D and E.

**Moved outside the law: 0.**

## 6. The three NEW arms — the faces the pass's grid did not cover

Each built ONE real Surelog golden per view with every rc recorded (no rc=139
read as a result), scorer calibrated golden³ to all-zero first.

### Arm D — `v191_d_ret.sv`, the RETURN-NAME axis and the DEEP PATH

def **TOWARD 34 / AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0**;
elab **TOWARD 14 / AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0**.

**§ retNameArgKeepsReturnVar184v HOLDS.**  A free subroutine's own RETURN NAME
written as the hier_path BASE inside `new[...]` — the one spelling the standing
law protects — is **byte-identical across golden, pristine and patched** at all
six cells: the clone binds § 171's RETURN VARIABLE (`array_var()@98:22`,
`array_var()@118:12` — unnamed, at the return declaration) and the home listing
stays BARE.  The patch cannot disturb it because `bind9` only ever fills a
null, and § 171 has already written that one.

The DEEP PATH is where § pkgCloneMember10 newly fires through the hop, and
patched matches golden **element for element** on a three- and a four-element
path — including the trailing PARENS-LESS `ref_obj(size)`, which golden leaves
BARE and we leave BARE because its predecessor is a `typespec_member`, not an
array object (§ 182's decoded gate).  That is the pass's R2 residue actually
exercised, and it comes out right.

### Arm E — `v191_e_shape.sv`, the STATEMENT-SHAPE axis and MULTIPLICITY

def **TOWARD 64 / AWAY 0 / MOVED-WRONG 0**;
elab **TOWARD 4 / AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0**.

The whole-dump path-normalised diff pristine → patched is **purely additive**:
every changed line is a NEW `vpiActual` edge, with no `<` line anywhere except
the filename header.  **The change can never repoint or remove a binding that
was already correct.**

Cells that all match golden exactly: a `new[...]` inside a **TASK** (`ownerTf9`
reaches `uhdmtask` through the hop — bare in the home, bound in both clones);
two windows in ONE statement; a select INDEX that is itself a path base; the
copy form's second argument; a `while` body; a two-blocks-deep `if`; the same
face repeated **once, twice and three times**; and the same home body cloned
into **TWO different wildcard importers**, both bound, home still bare.

**The one column that is not 0 — and why it is not a regression.**  arm E def
reports **ONLY-OURS-MOVED 4**, the scorer's own regression column, on
`HPINNER | NEWARG | 87:28 | jx191` in both clone listings × both views —
the foreach index of `new[hull191[jx191].strake191.size()]`.  Decoded:

* golden keys that reference at face **SELBASE**, ours at **HPINNER**, so the
  join sees two different keys.  The face differs because our index `ref_obj`
  carries `vpiParent -> hier_path` where golden's carries
  `vpiParent -> bit_select`.  **That shape is identical on pristine and
  patched** (the pass's R4) and `vpiParent` is read by NO generated `Compare`
  (RESUME §9).
* the VALUE moved `BARE → ref_var(jx191)@86:22` — **exactly the object golden
  binds at that same source position**.  The only remaining difference is the
  `ref_var`'s own `vpiFullName` prefix, and `VpiFullName` is judge-invisible.

So it is a TOWARD wearing an ONLY-OURS-MOVED label.  The implementer's
"ONLY-OURS-MOVED 0 in all 12" is true of their arms but is not a property of
the law: a foreach-index cell inside the window makes it read 4, and reading
it correctly needs the face decode above.  `uhdm-cmp` output for this arm is
**byte-identical** between the two binaries.

### Arm F — `v191_f_shadow.sv`, the SHADOWING axis (object identity)

def **TOWARD 22 / AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0**;
elab **TOWARD 2 / AWAY 0 / MOVED-WRONG 0 / ONLY-OURS-MOVED 0**.

This is the arm that could have convicted a hop landing on the wrong rung.
Arms A/B/C give every declaring scope a UNIQUE name, so a mis-aimed hop would
still have produced the right object there.  Here ONE name is declared at FOUR
nesting levels and read under `new[...]` at each.  Golden and patched agree on
**all ten shadowed cells, object for object**:

| cell | face | golden = patched |
| --- | --- | --- |
| `keg191` @56:18 | function level | `array_var(keg191)@46:16` |
| `keg191` @62:20 | outer block | `array_var(keg191)@60:11` |
| `keg191` @66:22 | inner block | `array_var(keg191)@64:13` |
| `keg191` @78:20 | foreach block | `array_var(keg191)@76:11` |
| `stave191` @57:18 | the FORMAL | `io_decl(stave191)@44:49` |
| `stave191` @71:22 | block local shadowing the formal | `array_var(stave191)@69:13` |
| `spar191` @84:20 | first sibling foreach | `array_var(spar191)@82:11` |
| `spar191` @89:20 | second sibling foreach | `array_var(spar191)@87:11` |
| `hasp191` @99:18 | function local, after the loop | `array_var(hasp191)@47:16` |
| `hasp191` @96:28 | foreach LOOP VAR shadowing it | `ref_var(hasp191)@95:22` |

Four distinct `keg191` objects, two distinct `spar191` objects, a formal and
the block local that shadows it, and a loop variable that shadows a function
local — each bound to its own declaration.  The innermost-first climb through
the hop lands on the correct rung at every level.  The HOME listing
(`Ashlar191`) is BARE on all eleven `NEWARG` rows in golden and in patched,
byte-identical.

## 7. Faces with NO golden (Surelog itself rejects them)

Not defects, and not reachable by any corpus row — recorded so no later pass
re-spends the time.  Both our binaries accept all three with rc=0.

* an OUT-OF-BODY class method's RETURN NAME as a path base under `new[...]`
  (`luff191 = new[luff191.size()]`) — `[ERR:UH0725] Unresolved hierarchical
  reference "luff191.size"`.  The free-function and IN-BODY spellings both
  resolve, which is itself the § 184v split.
* a `new[...]` in a DECLARATION INITIALISER (`Rove191 init191 = new[q.size()];`)
  — `[SNT:PA0207] Syntax error: missing ';' at '['`.
* a CLASS PROPERTY `.size()` read in a `return` expression at ELAB —
  `[ERR:UH0725] Unresolved hierarchical reference`.

## 8. Code reading — why no fill-null pass can regress here

`bind9` returns early on `actOf37(e9)` non-null, `bindBuiltin182` on
`r182->Actual_group()`, `bindMember10` likewise: the pass **only ever fills a
null**.  Arm E's purely additive whole-dump diff is the empirical confirmation.
A pristine-RIGHT cell therefore cannot become patched-WRONG; the only reachable
regression is a cell golden leaves BARE that we newly bind, which is what arms
A/C (class property, package variable) and arms D/E/F (return name, home
listing, task, every shadowed scope) close.

`up191` is consulted at exactly two sites and hops only when `VpiParent()` is
already null, so a live chain is never diverted.  The map is keyed on
`method_func_call` objects minted under `pkgImportCloneEmit` alone, so a
home-listing or elaborated-module `new` finds nothing and dies where it always
did — measured: the home listing is BARE in every arm and in the corpus.  The
climb terminates because the hop's target (the enclosing assignment) is an
ancestor of the subroutine the walk is looking for, never a descendant of the
call, so no cycle exists; empirically the corpus, both u2r modes and 5108
boundary files × 2 views all completed with no new timeout.

## 9. Residues, ranked

* **R0** (the pass's own, confirmed) — the new head: an ARRAY receiver's
  built-in method binds its argument to an `int_var` named after the ARGUMENT
  and spanned at the RECEIVER's declaration
  (`int_var (…::sync::visited.exists::succ) @1896:9`), r10uvm184's R2 family.
* **R5, promoted** — the pointer-valued constant. `r10buvm22repro/g22.sv`,
  `r10uvm154repro/l154_noenum.sv` and `r10uvm185repro/grid185/g185_e_kinds.sv`
  each carry constants whose VALUE IS A STATIC ADDRESS: they shifted by exactly
  one 4 KiB page here purely because the patched binary grew 4112 bytes.
  `vpiDecompile` **IS** read by the generated `Compare` (RESUME §9), so this is
  judge-visible in principle; it reaches no judge today only because those
  three arms have no corpus golden.  **Every future pass that changes the
  binary's size will see these three files as boundary movers** — the tell is
  NON-ADDRESS lines 0 and census rows 0, both of which I measured.  Worth
  fixing at the source rather than re-decoding each time.
* **R4, sharpened** — the foreach-index SHAPE.  Our index `ref_obj` under a
  `bit_select` inside a longer hier_path carries `vpiParent -> hier_path` where
  golden carries `vpiParent -> bit_select`.  Identical on both binaries and
  judge-invisible, but it splits the census key (SELBASE vs HPINNER) and so
  turns a TOWARD into an ONLY-OURS-MOVED for any pass that binds such an index.
  Note it does NOT affect a foreach index that is a select base directly
  (arm F `hasp191` @96:28 keys SELBASE on both sides).
* **R1** the explicit-import copy (`importCloneEmit`), corpus incidence zero —
  the a-priori predictor is a superset and named none.
* **R3** uvm186's clone `vpiFullName`, judge-invisible.
* **Three faces with no golden**, §7 above.

## 10. Files here

* `v191_d_ret.sv`, `v191_e_shape.sv`, `v191_f_shadow.sv` — the three arms.
* `d_*`, `e_*`, `f_*` `cen.{g,a,b}.def.txt` — the three-way censuses
  (golden / pristine / patched) each arm was scored from; `d_hp.g.def.txt` is
  golden's per-element `new[...]` hier_path listing for arm D.
* `ct191hpb.cpp` — the census/owner-finder, taken verbatim from
  `r10uvm191repro` and rebuilt here; the scorer is `r10uvm191repro/score191.py`
  and the arm driver `r10uvm191repro/grid191.sh`, both reused unmodified.

Build and run:

```sh
g++ -O2 -std=c++17 ct191hpb.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o ct191hpb
CT191=$PWD/ct191hpb bash ../r10uvm191repro/grid191.sh v191_f_shadow.sv \
    <pristine> <patched> <workdir>
python3 ../r10uvm191repro/score191.py <wd>/cen.g.def.txt <wd>/cen.g.def.txt \
    <wd>/cen.g.def.txt        # calibrate: all columns but UNTOUCHED must be 0
python3 ../r10uvm191repro/score191.py <wd>/cen.g.def.txt <wd>/cen.a.def.txt \
    <wd>/cen.b.def.txt
```
