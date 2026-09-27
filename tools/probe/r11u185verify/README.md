# r11u185: second adversarial verification of passes 176 and 178 (verifier, measurement plus one refinement in fix.patch)

Base `459b7cdf` (branch matrix-1.87). Pass 178 (the expression/parameter ground: r11u175's three expression laws, two
laws of its own, r11v178's two refinements) landed at `80a1c2af`, on top of `312e26e2` (r11u182's refinement). Pass 176
(the module/type ground: r11u175's extern-prototype law, fourteen laws of its own, v11u176's refinement) landed at
`804e3b75`. Pass 181 landed after both, at `1eeff71d`. `459b7cdf` is a tools-only commit. Worktrees:

- `/tmp/wt_r11u185` is the base and the deliverable.
- `/tmp/wt_r11u185pre` is `312e26e2`, the commit before pass 178.
- `/tmp/wt_r11u185fix` is the base plus [fix.patch](fix.patch).

All three use the system-deps configuration. The base was built with `-j 2`; `pre.bin` and `fix.bin` were built
with `-j 1` after an out-of-memory kill of a `-j 2` compile, which was rebuilt.

This directory is the whole deliverable. Nothing under `src/`, `scripts/`, `results/`, `tests/` or `third_party/` is
edited. The refinement is [fix.patch](fix.patch), a `git diff 459b7cdf -- src` (`src/ModuleEmit.cpp` only) that applies
clean on a fresh `459b7cdf`. It is NOT applied here.

The brief speaks of "the canonicalisation patch you were given". No such patch was handed to this pass, and no
comparator defect was found, so `tools/uhdm-strictcmp` is not edited.

The cases name their laws in their first line (`// § law`). Because of that, `tests/LAWS.md` reads STALE in every
sweep. The base reads STALE too (the committed index predates the tools commit), and the landing regenerates the file.
That is the only red of every sweep below.

The slang-fenced tests are named nowhere in this directory (word-boundary scan: 0 files; the positive control finds a
planted name). [drivers/env.sh](drivers/env.sh) reads `$FENCED` from the `FENCED=` line of
`tools/probe/r11u107repro/canaudit.sh` and refuses to run without four names. Every driver here that reads corpus
sources or databases refuses without `$FENCED` (tested with `FENCED` unset: each prints its refusal). Each also skips
the four names by word boundary. No gdb was used. Only the gate sweeps dispatched fenced rows.

## Verdict

**One break, fixed in [fix.patch](fix.patch): § genericMpConnLowConnAtDecl176 and § genericPlainNamedView176 fire on
a generic port that Surelog reads as TYPED.**

In an ANSI port list, Surelog gives an `interface g` port the interface type of the port before it, when that port is
interface-typed:

- `module M (ConnectTB t, interface g)`
- `(ConnectTB.tb m, interface g)`
- `(ConnectTB.tb t, interface h, interface g)`, where the type passes through generic ports

Golden's definition view types `g` as `interface_typespec (ConnectTB)`, at the preceding port's type token, and binds
its LowConn to an `interface_inst`, never to a `logic_net`
([evidence/fix/break_definition_port_g.txt](evidence/fix/break_definition_port_g.txt)). So NetlistElaboration's two
generic legs never fire for it (`NetlistElaboration.cpp` 1602-1611 set `lowconn_is_nettype` only for a `logic_net`
actual; the legs follow at 1612 and 1653). As a result:

- The elaborated LowConn keeps the FORMAL-name span that line 1606 wrote (`fC->populateCoreMembers(formalId, formalId, rf)`).
- The connected instance lists no second copy of its signals.

Pass 176's laws key on slang's reading, which is generic, and move both fields AWAY from golden. Pristine was right on
both. Measured spans (from [evidence/fix/break_lowconn_spans.txt](evidence/fix/break_lowconn_spans.txt)):

| case | golden | law (HEAD) | pristine (both landings off) | fix |
|---|---|---|---|---|
| GV/v07 `ConnectTB t, interface g`, `.g(f)` | 13:15-13:16 | **13:14-13:19** + 29 copied-signal dump lines | 13:15-13:16 | 13:15-13:16 |
| GV/v08 `ConnectTB.tb t, interface g` | 13:15-13:16 | **13:14-13:19** | 13:15-13:16 | 13:15-13:16 |
| GV/v09 `ConnectTB.tb t, interface h, interface g` | 13:22-13:23 | **13:21-13:26** (58 dump lines) | 13:22-13:23 | 13:22-13:23 |
| GV/v10 the same in a program | 13:15-13:16 | **13:14-13:19** | 13:15-13:16 | 13:15-13:16 |
| GV/v11 `.g(f.tb)` (modport connection) | 13:15-13:16 | **8:34-8:35** (§ genericMpConnLowConnAtDecl176) | 13:15-13:16 | 13:15-13:16 |
| GV/v12 `interface h, ConnectTB t, interface g` | 13:22-13:23 | **13:21-13:26** | 13:22-13:23 | 13:22-13:23 |
| GV/v15 multi-line port list | 14:15-14:16 | **14:14-14:19** | 14:15-14:16 | 14:15-14:16 |
| PG/p04 program and module, `m, t, g` ports | 21:22-21:23 / 22:22-22:23 | **21:21-21:26 / 22:21-22:26** | = golden | = golden |
| GV/v13 `ConnectTB t, input logic y, interface g` (control) | 13:21-13:26 | 13:21-13:26 | 13:22-13:23 | 13:21-13:26 (law kept) |
| GV/v14 `interface h, interface g` (control) | 13:14-13:19 | 13:14-13:19 | 13:15-13:16 | 13:14-13:19 (law kept) |

Every broken case is stage 1 before and after, because our definition view types `g` generically (the residue in
section 8). So uhdm-cmp does not see the break, and neither does the strict walk. The downstream verdicts are the same
in every state: STATUS_DIFF, the plugin reading the Surelog lane and READ_FAILing on our generic port. The order-blind
dump sees it. So does the reachable-only dump judge: with the law, 29-58 golden lines are lost per cell and 0 are
gained.

**§ genericAfterTypedIfacePortTyped185v** is the fix. It lives in `src/ModuleEmit.cpp`, in a helper
`genericInheritsIfaceType185v` and at the three law sites in `emitInstance`. A generic ANSI interface port whose nearest
non-generic predecessor in the same ANSI list is an interface-typed port takes neither generic leg. That means neither
the location face (GENMPLOC, GENPLAINLOC) nor the variable copies (GENPLAINVARS). A non-interface port in between
leaves the port generic, as golden does (v13).

The switches are `R11V185_GENINHERIT_OFF` and `R11V185_OFF`. Each gives law.bin's bytes on all 16 moved case-modes,
and `R11V185_OFF` on all 226.

Fix measurements (section 4):

- fix vs law loses 0 golden dump lines on every moved cell, and fix vs pristine loses 0.
- The prediction, written from the HEAD databases before the fix sweep, names **0** corpus or probe databases.
- The fix sweep reads 0/0/0 in every stage, and its four csvs equal HEAD's (the LowMem detail path aside).
- byteverify moves 5 databases of 2560, all the UVM order coin. Probe movers are 0 of 4087.
- The boundary byte control over 9988 landed `tools/probe` cases reads 0 movers.

**No other law of the two landings moves a field away from golden on fresh legal SV.** There are 113 fresh cases, each
run in both modes (default and `--elabuhdm`):

- **Crashes:** none (every rc is 0 or the case's constant rc 3/4 in every state).
- **Strict equality:** no cell loses it. Strict-equal ALLOFF → ON goes 4 → 34 (default) and 6 → 30 (`--elabuhdm`).
- **uhdm-cmp:** no line count grows.
- **Aligned walks:** 0 FAWAY.
- **Flagged stage-1 cells:** every one was read object by object (section 3). They are multiset artifacts of an object
  moving to golden's reading, except:
  - the break above;
  - the known import-parameter-copy trade of pass 176 (residue R2, disclosed at landing);
  - one wrong-to-wrong reading of § pkgPatUnqualReadTsNoParent178 on a task-body read, where golden keeps the tagged
    listing and our pre-existing flattening is the face.

**Composition: additive; no pair of laws cancels another's error** (section 5).

- **Status level:** probe 84 conversions both off → HEAD. OWN176 is 61 and OWN178 is 18, both as claimed. JOINT is 5:
  pass 176's integration conversions that need r11u175's expression laws (the FSPAN × expression-law share).
- **Byte level over 6647 databases:** CANCEL 0.
- **Record level:**
  - The only status-level "cancel" (v194_e_explclone) is an unmasking (divergence #66 → #200).
  - Every UVM "cancelled" record pairs with the golden record H gained, the other landing having fixed another field of
    the same object (field-additive). Examples: the default reference `UVM_NO_COVERAGE`, whose name 178 fixes and whose
    location 176 fixes; and `uvm_reg_bus_op` copies, which 178 adds and 176 relocates.
- **R11U175 per ground:** FSPAN (176's ground) owns 59 probe conversions and moves 114 databases. The three expression
  laws (178's ground) own 22 and move 92. 5 conversions need both.

**Changes: unmaskings or strict improvements** (section 6). This covers pass 178 at `312e26e2` and pass 176 at
`80a1c2af`, both reconstructed by switches and proven equal to the real `312e26e2` build (0 of 4087 probe databases
differ, and only the UVM coin in the corpora).

- Pass 178, probe: 18 conversions, 28 subsets, and 36 unmaskings with every new record at or after the old
  divergence. Surelog: 1 conversion and 12 subsets. uhdm2rtlil: 2 subsets.
- Pass 176, probe: 66 conversions and 34 subsets. Surelog: 5 conversions, 14 subsets, and SVSwitch an unmasking
  (#3314 → #3398). uhdm2rtlil: ibex_pmp **MIXED**. It removes 13 records and introduces 3 before the same divergence;
  that is the import-parameter copy, residue R2, disclosed at landing.

**Downstream:** every row the landings converted is byte-identical to golden's lane in every state, and so are
`ibex_pmp` and `iface_zero_width_field`. The HEAD and all-off downstream csvs are byte-identical to
`results/downstream_uhdm2rtlil.csv`.

**Fence and process** (section 9): nothing rests on a fenced reading. Both passes' predictions reproduce byte for byte
from reconstructed pristine bases, and every claimed mover is inside them. Four drivers of the evidence directories
are not fail-closed on an empty `$FENCED`, and two directories' drivers source scratch env files that no longer exist
(section 9).

## 1. Binaries and states (frozen `chmod 555` in `/tmp/r11u185_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `law.bin` | `d0519110f1f72bc00dcc51de37f89dd0` | worktree build of `459b7cdf` = the main tree's `build/slang-uhdm` (the brief's `d0519110f1f7`) |
| `pre.bin` | `1c321cd5ce346cefdde18703cd2f56f6` | build of `312e26e2`, the commit before pass 178 (= r11u182's `fix.bin`, as `312e26e2` is that fix) |
| `fix.bin` | `1354f99567724e6e73122e6f97f8e2b5` | `459b7cdf` + [fix.patch](fix.patch) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `predict176`, `predict178`, `predgen`, `idxpar` | built by `../r11u176repro/drivers/cc176.sh` / `../r11u175uvm/drivers/cc175.sh` | the two passes' predictors, this pass's fix predictor [drivers/predgen.cpp](drivers/predgen.cpp), r11u178's index-parent census |

State wrappers ([drivers/mkstate.sh](drivers/mkstate.sh)), all law.bin under switches:

| wrapper | switches | the state it reproduces |
|---|---|---|
| `alloff.sh` | `R11U175_OFF R11U176_OFF R11U178_OFF R11V178_OFF` | both landings off (pass 181 on) |
| `off176.sh` | `R11U175_FSPAN_OFF R11U176_OFF` | pass 176 off (`R11U176_OFF` also drops `R11V176_TDKEYUNRES_OFF`'s refinement; there is no `R11V176_OFF`) |
| `off178.sh` | `R11U178_OFF R11V178_OFF` | pass 178 off (`R11U178_OFF` also drops r11u175's three expression laws) |
| `preoff.sh` | alloff + `R11U181_OFF R11V181_OFF` | `312e26e2` |
| `st80a.sh` | off176 + `R11U181_OFF R11V181_OFF` | `80a1c2af` (pass 178 landed) |
| `st804.sh` | `R11U181_OFF R11V181_OFF` | `804e3b75` (pass 176 landed) |
| `st5e.sh` | preoff + `R11V182_OFF` | `5e8d08d9`, pass 178's pristine base |
| `st72.sh` | st5e + `R11U174_OFF R11V177_OFF` | `72fd3061`, pass 176's pristine base |
| `others.sh` | `R11U172_OFF R11U171_OFF R11V171_OFF R11U174_OFF R11V174_MOPPKG_OFF R11U181_OFF R11V181_OFF R11V177_OFF R11V182_OFF` | the other landings and refinements off, 176/178 on |
| `wide.sh` | alloff + others | everything of the brief's composition list off |
| `off175F.sh` / `off175E.sh` | `R11U175_FSPAN_OFF` / `R11U175_MULT_OFF R11U175_FULLNAME_OFF R11U175_ESPAN_OFF` | each ground's share of R11U175 |

**Switch completeness:**

- On the cases, PREOFF gives `pre.bin`'s bytes on **226 of 226** case-modes
  ([evidence/grid/preoff_equals_pre.txt](evidence/grid/preoff_equals_pre.txt)).
- On the full sweeps, `swX` (pre.bin) vs `swP` (preoff):
  - the probe databases are 0 of 4087 different, and `probe.csv` and `uhdm2rtlil.csv` are identical;
  - the corpus shows 5 of 2560 byteverify movers, all UVM coin (order-blind 4/4/4/4/0 dump lines,
    [evidence/sweeps/pre_vs_preoff_coin.txt](evidence/sweeps/pre_vs_preoff_coin.txt));
  - the surelog csv differs only in the LowMem detail text and one Earlgrey `differ:?`, an environment flake of the
    comparator under load (the bytes are identical).
- The reconstructed historical states reproduce the committed histories' counts exactly
  ([evidence/composition/state_counts.txt](evidence/composition/state_counts.txt)):
  - `st72`: probe EQUAL 2768 and uhdm2rtlil 777. These are pass 176's pristine figures.
  - `st5e` / `preoff`: 2796 and 783. These are pass 178's pristine figures.
  - `st80a`: 2814, surelog 450 + 447 (pass 178's claim).
  - `st804`: 2880, 453 + 449 (pass 176's integration).
  - HEAD: 2886, 455 + 451.

## 2. Sweeps (`tests/sweep.sh --jobs 3`, [drivers/sweep.sh](drivers/sweep.sh) / [drivers/queue.sh](drivers/queue.sh); `/tmp/r11u185_sw?`, same-length names)

Every sweep's `cmds.txt` files name its own binary or wrapper on all 3273 `slang:` lines
([evidence/sweeps/cmds_audit.txt](evidence/sweeps/cmds_audit.txt)). Summaries are in
[evidence/sweeps/](evidence/sweeps) (`sw?_summary.txt`). All goldens came from the cache.

| sweep | state | stages | probe EQUAL / regr vs results | surelog d+t CMP_EQUAL | u2r d/t | downstream |
|---|---|---|---|---|---|---|
| swH | law.bin | all four | 2886, **0/0/0**, `probe.csv` byte-identical to `results/golden_probe.csv` | 455 + 451, **0/0/0** | 783/783, **0/0/0** | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0; csv byte-identical to `results/downstream_uhdm2rtlil.csv` |
| swA | alloff | all four | 2802 | 452 + 448 | 783 | csv byte-identical to swH's |
| sw6 / sw8 | off176 / off178 | probe, surelog, u2r | 2820 / 2863 | 452 + 449 / 455 + 450 | 783 | - |
| swP / swR / swS | preoff / st80a / st804 | probe, surelog, u2r | 2796 / 2814 / 2880 | 450+446 / 450+447 / 453+449 | 783 | - |
| swW / swQ | wide / others | probe, surelog, u2r | 2755 / 2838 | 446+443 / 449+446 | 777 / 777 | - |
| swF / swE | off175F / off175E | probe, surelog, u2r | 2827 / 2864 | 455 + 451 | 783 | - |
| sw7 / sw5 | st72 / st5e | probe, surelog, u2r | 2768 / 2796 | 450 + 446 | 777 / 783 | - |
| swX | pre.bin | probe, surelog, u2r | 2796 (= swP) | 450 + 446 | 783 | - |
| swZ | fix.bin | all four | 2886, **0/0/0** | 455 + 451, **0/0/0** | 783/783, **0/0/0** | 803/66/2/0, not excused 0; byte-identical to swH's |

Canaries on swH and swZ ([evidence/sweeps/canaries_H_Z.txt](evidence/sweeps/canaries_H_Z.txt)):

- `r11u107repro/canaries.sh`: surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0.
- `ctcan2.sh` with `EXPECT_UNKNOWN=1` (surelog): ok=58, PASS.
- `ctcan2.sh` with `EXPECT_UNKNOWN=6` (uhdm2rtlil): ok=2, PASS.

## 3. The fresh cases and the per-law reading

There are 113 cases in [cases/](cases), in 15 groups. None is in the grids of r11u176repro, v11u176repro, r11u175uvm,
r11u178repro or r11v178repro. The first line of each case names the laws it attacks.

[drivers/case.sh](drivers/case.sh) builds the golden with the pinned Surelog. It uses check_probe's arguments, or
`-elabuhdm` with `EL=1`. A `files` list names several root files, and the golden is cached by the md5 of every file.

[drivers/grid.py](drivers/grid.py) runs each case in both modes under these states:

- ON;
- each named law's own switches (a refinement also under its parent's);
- each landing off;
- every pair of named laws (group X);
- ALLOFF;
- PREOFF.

Readings:

- **grid.py:** UNFIRED / TOWARD / AWAY / MIXED / UNMASK / BYTES-ONLY, and for stage-1 cells the order-blind dump
  distance.
- **[drivers/fieldscore.py](drivers/fieldscore.py):** the per-walk-index field sets. It reads **0 FAWAY** over every
  aligned cell (383 FTOWARD, 387 FSAME).
- **[drivers/recaway2.py](drivers/recaway2.py):** the chain-keyed strict records.
- **[drivers/dumpaway2.py](drivers/dumpaway2.py)** (new): the uhdm-dump line multisets of the REACHABLE dump only, cut
  at `\_weaklyReferenced`. The full-dump judge ([drivers/dumpaway.py](drivers/dumpaway.py)) flagged the unreachable tail
  of PG/p03, where the view modports that § progLowConnDefModport176 orphans drop out of the dump. No reader walking
  from the design reaches them.
- **[drivers/dd.sh](drivers/dd.sh)** (new): the object-level diff behind every flagged cell.
- **[drivers/idxcmp.sh](drivers/idxcmp.sh)** (new): index parents against golden.

| group | cases | laws attacked (the brief's shapes) |
|---|---|---|
| XP | 8 | § externProtoFormalsFromPrototype175: defaults in both prototype and definition naming another package's parameter (x01); typedef formals of another package with a qualified enum default (x02); `extern virtual` with a default overridden in a derived class, plus `extern static` task with output and queue formals (x03); the definitions in an INCLUDE file (x04); a parameterized class with `N - 1` default and an unpacked `T a [N]` formal (x05); a definition that ADDS a default (x06); `ref` / `const ref` and two declarators in one direction, plus an extern constructor with a default (x07); an enum return from another package with defaults (x08) |
| CC | 8 | § castRhsClonePerInst176: two casts in one right side and a cast of a cast (c01); a cast to a TYPE parameter, instances with different types (c02); casts in a generate for and if, instantiated twice (c03); indexed part-select and concatenation left sides (c04); a macro-written assign and a macro left side (c05); `X'( )`, `(X+2)'( )`, `unsigned'( )` (c06); two assigns in one statement (c07); synthesizable RTL with ports, instantiated twice (c08) |
| PG | 6 | the program-port laws: a modport port and a plain typed port together (p01); two generic ports by name, one to a modport and one to a plain instance (p02); programs inside generate if / for (p03); a program and a module with the same three ports (p04); a parameterized interface, two program instances (p05); two modport-typed ports connected by name out of order (p06) |
| GV | 15 | the generic-port laws: named to an array element (v01), to a modport of an array element (v02), positional to an array element and to a modport (v03), a parameterized interface, named plain and modport (v04), a program with array-element modport and plain (v05), nets and variables with parameters (v06); **v07-v12, v15 the inheritance break, v13-v14 its controls** |
| TW | 16 | the typedef-writer laws: nested class with static and extern (w01); two packages with one type name (w02); class and module formal at one position in two files (w03); qualified formal from an imported package beside a module writer (w04); writers in three containers (w05); two same-named typedefs through imports (w06); the refinement's shape as a program function (w07), a module task with a union output (w08), an interface function beside a class (w09); DEFTOPSPLIT with a program task (w10), an interface and two inside writers (w11), an output task and a defaulted qualified formal (w12); class writers in two packages alone (w13); a qualified formal from an imported package, class writers only (w14); a qualified struct `ref` in an interface task (w15); a qualified union in a module function (w16) |
| TD | 4 | § tdEndMoveModuleOrder176: `Zm` / `am` (ASCII order) against file and instance order (d01); § tdMoveKeyResolved176: explicit against wildcard import (d02), enum task outputs (d03), a package function and a class method at one position (d04) |
| UD | 6 | § udpFormNetLvalueFirst176: an operation first (u01), a select of a select (u02), a member through an interface port (u03), instance arrays (u04), one statement with a literal-first and a net-first instance (u05), a literal and a literal-in-concatenation first (u06) |
| GE | 6 | the else-begin-if laws: three depths (e01), gate arrays in every branch with three parameterisations (e02), a named else block with an inner if-else (e03), an if with begin-end plus a gate in an unnamed else (e04), an else-if with nested generate for (e05), gate arrays with a declared net in the else body (e06) |
| IC | 5 | § importCloneBodyLocalCopies175: two initialized locals (i01), a local shadowing the formal in a nested block, and a local array in an if (i02), a class static method and an automatic method (i03), `static` in an automatic function and `automatic` in a static one (i04), a task with struct and array locals and two importer packages (i05) |
| FN | 7 | § refFullNameThroughNamedExpr175: defaults naming a package parameter qualified and through an import (n01), last call argument a select (n02), a select index that is a select (n03), enum-member defaults in module, interface and class (n04), extern and in-body class defaults of the same package (n05), an interface method call with a select argument inside a function (n06), select indices as a path's last element in a class method (n07) |
| DW | 6 | the do-while laws: a condition that is a call, a method call, a system call (w01); a parenthesized macro condition (w02); trailing comments inside and after the condition (w03); nested do-whiles (w04); a class task with declared locals (w05); in a function (w06) |
| HP | 9 | § hierPathSelIdxAtPath178: three-select chains (h01), method-call and `$size` indices (h02), an index that is a path with its own index (h03), member-select lvalues in `always_ff` (h04), constant and parameter indices (h05), streaming lvalue and rvalue (h06), inc/dec with two selects (h07), elaborated continuous assignments with an operation over a two-select path (h08), compound-assignment lvalues (h09) |
| HK | 3 | § hierPathSelIdxCloneKeepsElem178v: pre-increment, post-decrement, pre-decrement read, post-increment read (k01); clone right sides that are a cast, a concatenation, a call, a cast of an operation (k02); compound assignments in `always_comb` (k03) |
| PU | 7 | § pkgPatUnqualReadTsNoParent178: a nested struct member read (u01), a read in a package TASK (u02), package variable dimensions (u03), a `default:` key pattern (u04), a positional and a named pattern (u05), a whole-value copy, `$bits` and a member read together (u06), a read from another package and in a package function (u07) |
| X | 7 | cross-ground pairs (section 5): x01 § hierPathSelIdxAtPath178 × § genericMpConnLowConnAtDecl176 (`.intf(arr[K-1].tb)`); x02 the same × § progLowConnDefModport176; x03 § importCloneBodyLocalCopies175 × § externProtoFormalsFromPrototype175 (extern task and function bodies with locals, two importers); x04 § tfArgClassMethodOrder176 × § refFullNameThroughNamedExpr175 (class-method defaults naming package parameters); x05 § castRhsClonePerInst176 × § hierPathSelIdxCloneKeepsElem178v (`8'(m.w[i+1].v)` in a module instantiated twice); x06 § udpFormNetLvalueFirst176 × § genCaFoldTsChainNamed169 (generate-loop positional connections); x07 § tdMoveKeyResolved176 × § tdMoveCarriesFile172 × § mlArgLocFileAtActual177v (formals born in a macro in three files) |

The table below covers every law, both modes, each against its own switch
([evidence/grid/lawtable.txt](evidence/grid/lawtable.txt); every cell is in
[summary_default.txt](evidence/grid/summary_default.txt) and [summary_elabuhdm.txt](evidence/grid/summary_elabuhdm.txt)).
In the "cmp up" column, "down" means fewer uhdm-cmp lines with the law.

| law | cells | unfired | strict gained / both not-equal / lost | cmp up | flagged cells and their object-level reading | downstream (ON vs OWN) | verdict |
|---|---|---|---|---|---|---|---|
| § externProtoFormalsFromPrototype175 | 18 | 0 | 3 / 15 / 0 | 0 | x08, x05: multiset artifacts (the class-body listing equals golden's counts exactly; the lost lines are the package listing's pre-existing depth) | same | holds; x04 keeps 12 pre-existing typespec-copy file records (`byte_t` in `c_impl.svh`, r11u183dec's family) |
| § castRhsClonePerInst176 | 20 | 8 | 3 / 8 / 0 | 0 | - | same (c08 IDENTICAL) | holds; declared left sides and generate scopes share (unfired), as golden's leg 1 |
| § progTypedPortLowConnUnlocated176 | 10 | 0 | 2 / 8 / 0 | 0 | - | same | holds |
| § progLowConnDefModport176 | 16 | 0 | 2 / 14 / 0 | 0 | p03 full-dump only: the orphaned view modports leave the unreachable tail | same | holds |
| § progPlainPortViewUnparented176 | 8 | 2 | 0 / 6 / 0 | 0 | - | same | holds |
| § genericMpConnLowConnAtDecl176 | 32 | 26 | 0 / 6 / 0 | 0 | **v11: AWAY** | same | **BREAK** (fixed) |
| § genericPlainNamedView176 | 28 | 8 | 0 / 20 / 0 | down 2 | **v07, v08, v09, v12, v15, p04: AWAY** (29-58 golden lines) | same | **BREAK** (fixed) |
| § tfArgQualOutsideWriter176 | 10 | 2 | 6 / 2 / 0 | 0 | - | - | holds (w05: three containers decline, as modelled) |
| § tfArgClassMethodOrder176 | 18 | 12 | 3 / 3 / 0 | 0 | x04 MIXED: 13 references toward, 5 away. The away ones are the import-parameter copy `pb::DEF` (golden 4:3, law 12:23): pass 176's disclosed residue R2 | same | holds, with R2 standing |
| § tfArgDefTopSplit176 | 12 | 6 | 1 / 5 / 0 | 0 | - | - | holds (w02, w05, w06 decline: class writers beside, three containers, two imports) |
| § tdEndMoveModuleOrder176 | 2 | 0 | 2 / 0 / 0 | 0 | - | - | holds (ASCII order: `Zm` < `am` < `dut`) |
| § tdMoveKeyResolved176 | 16 | 12 | 0 / 4 / 0 | 0 | - | - | holds (d04 toward, d02 same) |
| § tdKeyKeepsUnresolved176v | 8 | 4 | 0 / 4 / 0 | 0 | - | - | holds (w07, w08 stage 1 same) |
| § udpFormNetLvalueFirst176 | 14 | 10 | 0 / 4 / 0 | 0 | u06, x06: artifacts (the elaborated HighConn now equals golden's; the lost lines were the swallowed concatenation's) | **EQUIVALENT → IDENTICAL on u06 and x06** | holds |
| § genElseBeginIfDepth176 / § genElseIfGateArrayPath176 | 12 / 6 | 8 / 4 | 4 / 0 / 0, 2 / 0 / 0 | 0 | - | same | holds; e03-e06 unfired, pre-existing generate faces (section 8) |
| § importCloneBodyLocalCopies175 | 12 | 2 | 3 / 6 / 0 | 0 | i02, i05, x03 UNMASK | same | holds |
| § refFullNameThroughNamedExpr175 | 16 | 8 | 2 / 6 / 0 | 0 | - | - | holds (n01, n03, n04 unfired: the "have is want minus ancestors" guard declines) |
| § doWhileSpansToCloseParen175 | 12 | 0 | 12 / 0 / 0 | 0 | - | - | holds, every cell converts |
| § doWhileEndsAtCondEnd178v | 12 | 10 | 2 / 0 / 0 | 0 | - | - | holds (w03's comment before `)`) |
| § hierPathSelIdxAtPath178 | 30 | 8 | 15 / 6 / 0 | 0 | h06 elaborated: artifact (all four index names equal golden's, [evidence/grid/index_parents.txt](evidence/grid/index_parents.txt)) | same | holds; index parents equal golden's on every case but h03 (R1) and h06 (V1, 6 → 4) |
| § hierPathSelIdxCloneKeepsElem178v | 14 | 6 | 3 / 2 / 0 | 0 | - | same | holds: parents 0 off golden with it, 6-16 without (h07, h08, k02, x05) |
| § pkgPatUnqualReadTsNoParent178 | 14 | 2 | 0 / 12 / 0 | down 2 | u05, u06, u07: artifacts (the elaborated B listing equals golden's object; golden's C listing is tagged, ours a reference, pre-existing); **u02 wrong-to-wrong**: a read in a TASK's for-loop bound leaves golden's listing tagged (`CompileExpression.cpp` 1093-1115 reduces only through `getValue`), ours flattens (pre-existing) and the law unparents the flattened reference that golden does not have | same | holds; u02 residue |

The pairs of group X are in section 5.

## 4. The break and § genericAfterTypedIfacePortTyped185v ([fix.patch](fix.patch))

**Decode:**

- Golden's definition view of `module M (ConnectTB t, interface g)` gives port `g` the `interface_typespec (ConnectTB)`
  at 7:11-7:20, the first port's type token. Its LowConn `ref_obj` binds an `interface_inst`
  ([evidence/fix/break_definition_port_g.txt](evidence/fix/break_definition_port_g.txt)). Ours binds a `logic_net`,
  the generic form.
- `NetlistElaboration.cpp` 1602-1611 sets `lowconn_is_nettype` only for a `logic_net` actual. Both generic legs (1612
  modport, 1653 interface instance) require it.
- Line 1606 has already moved the existing LowConn to the formal-name span.
- Variant grid ([evidence/fix/break_lowconn_spans.txt](evidence/fix/break_lowconn_spans.txt) and the Verdict table): the type
  inherits only through interface ports. `input logic y` in between stops it (v13), and it chains through generic
  ports (v09, v12).

**Rule:** `genericInheritsIfaceType185v(ip)` holds when `ip` is a generic ANSI interface port whose predecessors in
the body's port list, walking back over generic ANSI interface ports only, reach an interface-typed ANSI port. Such
a port is excluded from:

- § genericMpConnLowConnAtDecl176 (the location);
- § genericPlainNamedView176's location face;
- § genericPlainNamedView176's variable face (the view is still re-pointed and, in a program, still unparented by
  § progPlainPortViewUnparented176, as a typed plain port would be).

**Measurements:**

- **Cases** ([evidence/fix/fixcases_bytes.txt](evidence/fix/fixcases_bytes.txt),
  [break_dump_diff_on_vs_fix.txt](evidence/fix/break_dump_diff_on_vs_fix.txt)):
  - fix moves exactly the 16 case-modes of v07-v12, v15 and p04. The controls v13 and v14, and every other case, keep
    law.bin's bytes (210 of 226).
  - Reachable dump, fix vs law: 0 golden lines lost, 1-58 gained (v09: 58, p04: 30). fix vs pristine: 0 lost.
  - uhdm-cmp line counts are unchanged (16, 22 and 221: the stage-1 definition face).
  - `R11V185_GENINHERIT_OFF=1` gives law.bin's bytes on the 16 moved case-modes
    ([evidence/fix/switch_geninherit.txt](evidence/fix/switch_geninherit.txt)). `R11V185_OFF=1` gives them on 226 of 226.
- **Prediction, written before the fix sweep**
  ([evidence/fix/prediction_fix.txt](evidence/fix/prediction_fix.txt), [drivers/predgen.cpp](drivers/predgen.cpp)):
  - The trigger is a port list in which a generic-form port (unsupported_typespec) follows an interface_typespec port
    through generic ports only.
  - Over the 6647 HEAD databases (8 fenced excluded), it names **0** databases.
  - The positive control fires on every broken case and not on v01, v13 or v14
    ([prediction_fix_positive_control.txt](evidence/fix/prediction_fix_positive_control.txt)).
- **Gate sweep swZ:** 0/0/0 in all three stages. Its csvs equal swH's (the LowMem detail path aside). The downstream
  csv is byte-identical, 0 slang-lane netlists moved, and the canaries pass.
- **byteverify swZ vs swH** on fence-clean mirrors (`mirrored=2560 fenced_skipped=8`, PATH_SETS_IDENTICAL, SELFCHECK
  2559/2560, [evidence/fix/byteverify_Z_vs_H.txt](evidence/fix/byteverify_Z_vs_H.txt)): 5 movers, none predicted, all
  the UVM coin.
  - MiniAmiq d/t, SeqDriver d and SimpleUVM d each differ by 4 `UINT` lines order-blind.
  - Scoreboard d differs by 0 lines order-blind.
  - Source: [evidence/fix/uvm_coin_Z_vs_H.txt](evidence/fix/uvm_coin_Z_vs_H.txt).
  - Probe: 0 of 4087.
- **Boundary byte control** ([drivers/boundary.sh](drivers/boundary.sh),
  [evidence/fix/boundary_summary.txt](evidence/fix/boundary_summary.txt)): every single-file `tools/probe/**/dut.sv`
  outside this directory, fenced paths refused.
  - Listed 9988, processed 9988: **9850 SAME, 0 MOVER**, 138 NODB. NODB means no database from either binary.
  - The 3 segfaults are the same on both binaries: `r10v226repro` b13_modportproc, `r11v105repro`
    v09_A_nested_program_in_sub, `v11u112repro` m07_hdr_enum_default. v11u176 listed the same three.
  - The other 135 are slang rejections (rc 3) on both.
- **Downstream:** the moved cases read the same verdict with fix as with law, pristine and OWN
  ([evidence/downstream/cases_FIX.txt](evidence/downstream/cases_FIX.txt)). The break is downstream-invisible because
  the plugin already fails on our generic form (the residue in section 8).

## 5. Composition ([evidence/composition/](evidence/composition))

**Status level** ([compose_H_A_6_8.txt](evidence/composition/compose_H_A_6_8.txt): H = swH, A = swA, 6 = sw6,
8 = sw8; the 1588 surelog rows are 1596 minus the 8 fenced, skipped unread):

| stage | conversions A → H | owner | changes | cancel |
|---|---|---|---|---|
| probe | 84 | OWN176 61, OWN178 18, JOINT 5 (g32a3, v6ctx8, g195_e_head, g86_a3_nest, v195_b_reads) | OWN176 23, OWN178 48, JOINT 10 | 1: v194_e_explclone, an unmasking (below) |
| surelog | 6 | OWN176 5 (OneNetModPort d/t, OneNetModPortGeneric d/t, UnsizedParam d), OWN178 1 (LocalScopeHierPath t) | OWN176 5, JOINT 11 (the UVM rows, SVSwitch) | 5: CoresSweRV / CoresSweRVMP d (SURELOG_FAIL ↔ TIMEOUT, uncached producer under load) and Earlgrey d `differ:?` in sw6 (bytes identical to swH's: a comparator flake) |
| uhdm2rtlil | 0 | - | OWN176 2 (ibex_pmp d/t), OWN178 2 (iface_zero_width_field d/t) | 0 |

The 5 JOINT probe conversions were not EQUAL at `st80a` and were EQUAL at `st804` (swR → swS): pass 176's
integration conversions, 61 + 5 = 66 (2814 → 2880). They need FSPAN (176's ground) and r11u175's expression laws
(178's ground) together.

**Byte level** ([bytecancel_H_A_6_8.txt](evidence/composition/bytecancel_H_A_6_8.txt)), over 6647 databases:
SAME 6421, OWN176 109, OWN178 80, BOTH 37, **CANCEL 0**.

**Record level, the share proof** ([drivers/joint.py](drivers/joint.py),
[joint_share_proof.txt](evidence/composition/joint_share_proof.txt),
[field_additive_traces.txt](evidence/composition/field_additive_traces.txt)). It covers every JOINT conversion and
JOINT change, bad = ours-not-golden records and miss = golden-not-ours records.

- **The 5 JOINT conversions:** each landing removes its own disjoint records. Overlap 0, introduced 0. g32a3 is
  fix176 10 + fix178 1; v6ctx8 is 4 + 4; g86_a3_nest is 30 + 2. g195_e_head and v195_b_reads are 3 + 0: there 178
  completes the walk structure (miss 25 → 0 and 49 → 0).
- **v194_e_explclone** is the status-level "cancel": fullname(3) in both H and A, but with different bytes.
  - A diverges at #66. MULT removes that divergence, and FSPAN removes the #137 / #139 line records it unmasks.
  - H diverges at #200. The record counts match by coincidence.
- **The JOINT probe changes:** g193_d_propfence, g198_a_homes and g207_e_head show 2, 4 and 8 records that pass 178
  adds. They come with 46, 32 and 104 golden records gained (miss 66 → 20, 38 → 6, 119 → 15). These are the MULT
  copies of locals: new objects golden has, a few with a wrong field. No record is cancelled.
- **UVM rows:** 84 "cancelled" records on BuildUVMPkg d/t, SimpleUVM d/t and Scoreboard d, 85-111 on
  MiniAmiq/SeqDriver. Each is paired with the golden record H gained for the same object, each landing fixing another
  field:
  - `ref_obj UVM_NO_COVERAGE` (the `uvm_mem::new` default): 178 fixes the full name (`...::new::has_coverage::...`),
    176 the location of one of the three (72578:57, the prototype).
  - The unpaired 24 / 16 on MiniAmiq / SeqDriver are `struct_typespec uvm_reg_bus_op` references. 178's copies add 24
    at the declaration (83 → 107), and 176 relocates 50 of them to `uvm_reg_map.svh 50:42`. HEAD holds 57 + 50 against
    golden's 57 + 56.
  - None is an error cancelled by another error.
- **SVSwitch:** fix176 12 + fix178 2, disjoint.

**Cross-ground pairs** (group X, each pair off together; grid readings in
[evidence/grid/grid_default.txt](evidence/grid/grid_default.txt)):

| case | first law | second law | reading |
|---|---|---|---|
| x01 `.intf(arr[K-1].tb)` | § hierPathSelIdxAtPath178: unfired (a constant-foldable port index) | § genericMpConnLowConnAtDecl176: unfired (an array-element actual is not in the scope's modport map) | both unfired; stage 1 on a pre-existing face (index parents 3 off in every state) |
| x02 `TESTBENCH t0(arr[K-1])` | unfired | § progLowConnDefModport176: STAGE1-CLOSER | additive |
| x03 extern bodies with locals, two importers | MULT: UNMASK | FSPAN: BYTES-ONLY | the pair is UNMASK = MULT alone; FSPAN moves the prototype listing only |
| x04 class-method defaults `e_t e = pa::DEF` | § tfArgClassMethodOrder176: MIXED (R2) | § refFullNameThroughNamedExpr175: unfired (a qualified default keeps its `pa::` name) | the R2 trade only |
| x05 `8'(m.w[i+1].v)`, two instances | § castRhsClonePerInst176: unfired (declared output left sides take leg 1) | § hierPathSelIdxCloneKeepsElem178v: TOWARD (index parents 16 → 0) | STRICT_EQUAL with everything on |
| x06 generate-loop positional `{1'b0, w[g][P]}` | § udpFormNetLvalueFirst176: TOWARD (downstream EQUIVALENT → IDENTICAL) | § genCaFoldTsChainNamed169: unfired | additive |
| x07 formals from a macro in three files | § tdMoveKeyResolved176: unfired | § tdMoveCarriesFile172, § mlArgLocFileAtActual177v: unfired | the macro-born formals are not relocation writers in any state (file(n) residue, same bytes in every state) |

**With passes 171, 174, 181 and the refinements off** ([additive_H_A_Q_W.txt](evidence/composition/additive_H_A_Q_W.txt)).
The 176/178 delta is read on HEAD's base (A → H) and on the base with the others off (W → Q).

- Probe: 165 against 164 rows, 159 with the same (from, to) pair.
  - g123_c_otherpkg converts only on HEAD's base. It needs a law of the other passes: a dependency.
  - v134_4bodies moves only on the off base, and v158_d only on HEAD's base.
  - Four probe rows move differently only because their heads are other passes' faces.
- Surelog: 22 against 22 rows, 6 conversions on both.
- uhdm2rtlil: the rp32 rows move only on the off base, where 176's laws relocate `riscv_isa_pkg::isa_t` (17 records).
  On HEAD's base pass 171's laws have already written the same field, so both laws fix the same record: an overlap,
  0 records introduced.
- Bytes: 226 against 234 movers, 225 on both.
- Nothing cancels.

**Each ground's share of R11U175** ([share175_H_F_E.txt](evidence/composition/share175_H_F_E.txt)), on HEAD's base:

| drop | probe conversions owned | corpus rows moved | byte movers |
|---|---|---|---|
| `R11U175_FSPAN_OFF` (TaskFuncEmit, pass 176) | 59 (= pass 176's 54 for the law alone + the 5 JOINT) | 0 strict verdicts (the UVM rows and ApbSlave move bytes behind their heads) | 114 (probe 103; ApbSlave, BuildUVMPkg, MiniAmiq, Scoreboard, SeqDriver, SimpleUVM) |
| `R11U175_MULT_OFF R11U175_FULLNAME_OFF R11U175_ESPAN_OFF` (StmtEmit / ExprEmit, pass 178) | 22 (= pass 178's 17 for the three alone + the 5 JOINT) | 11 (the UVM rows and SVSwitch, one or three records each) | 92 (probe 81) |
| both | the 5 JOINT | - | 32 |

## 6. The CHANGE lines ([evidence/changes/](evidence/changes), [drivers/unmask.py](drivers/unmask.py), [unmaskpos.py](drivers/unmaskpos.py), [unmaskposrow.py](drivers/unmaskposrow.py))

**Pass 178 at `312e26e2` (swP → swR)** is [unmask_178_swP_to_swR.txt](evidence/changes/unmask_178_swP_to_swR.txt).

- Probe: 82 rows. CONVERSION 18, SUBSET 28, and 36 more (UNMASK 14, BOTH-DIVERGED 22). In each of the 36, every
  record the law adds sits at or after the off walk's divergence ([unmaskpos_178.txt](evidence/changes/unmaskpos_178.txt):
  36 of 36 UNMASK).
- Surelog: CONVERSION 1 (LocalScopeHierPath t) and SUBSET 12 — BuildUVMPkg d/t line(94) → line(69), MiniAmiq and
  SeqDriver d/t file(29) → file(26), SimpleUVM d/t and Scoreboard d fullname(45) → fullname(42), SVSwitch d/t
  fullname(11) → file(9). That is 11 as claimed, plus Earlgrey t, the environment flake: the same 436 records.
- uhdm2rtlil: SUBSET 2 (iface_zero_width_field d/t, fullname(4) → fullname(3)).
- MiniAmiq walked records 413,992 → 428,722 of golden's 435,569. SeqDriver 462,179 → 471,999 of 475,526
  ([evidence/uvm/uvmdist_P_R_S.txt](evidence/uvm/uvmdist_P_R_S.txt)). The record dumps list 10 more records than the
  comparator's `objects` line on both sides (golden 435,569 against 435,559), so these are the claimed 413,982 → 428,712.
- MiniAmiq's `(type, name, file)` excess grows 3832 → 4549 at this step while the order-blind distance falls
  15848 → 14587. That is the new MULT copies. Pass 176 then takes the excess to 3539 (swS).
- At HEAD: 639 new wrong records against both-off. 577 of them have a missing golden twin with the same type, name and
  full name, so another field differs; 20,836 golden records are gained.

**Pass 176 at `80a1c2af` (swR → swS)** is [unmask_176_swR_to_swS.txt](evidence/changes/unmask_176_swR_to_swS.txt).

- Probe: 100 rows, CONVERSION 66 and SUBSET 34. That is 66 = 61 + 5, and 34 changes as claimed.
- Surelog: CONVERSION 5 and SUBSET 14 — BuildUVMPkg line(69) → fullname(24), MiniAmiq file(26) → fullname(9),
  SeqDriver file(26) → fullname(8), SimpleUVM / Scoreboard fullname(42) → fullname(24), FuncStructVal t,
  FuncStructValSimple d/t, InterfaceModPort d/t.
- SVSwitch d/t: BOTH-DIVERGED, an unmasking. The off walk diverged at #3314 and on runs to #3398; the 11 new records
  sit at #3375-#3398, all after #3314.
- uhdm2rtlil ibex_pmp d/t: **MIXED**. Both walks diverge at #13972. The law removes 13 records (golden reads the moved
  `pmp_cfg_t` at `ibex_pmp.sv 114:47`) and introduces 3, at #4375, #5655 and #7760, before the divergence: golden's
  `work@ibex_pmp.PmpCfgRst` import copy reads the unmoved `ibex_pkg.sv 433:11`, and ours shares the moved object
  ([evidence/residues/importcopy_ibex_pmp.txt](evidence/residues/importcopy_ibex_pmp.txt)).
  - This is pass 176's own residue 2, stated in its README ("the module's imported copy the reverse").
  - It is downstream-invisible: ibex_pmp's three netlists are byte-identical to golden's lane.
  - Fresh case X/x04 reproduces it: 4 `pb::DEF` references plus 1 constant reference, golden 4:3, law 12:23
    ([importcopy_x04.txt](evidence/residues/importcopy_x04.txt)).

**The first records** ([evidence/uvm/first_records_H.txt](evidence/uvm/first_records_H.txt)) match pass 176's claim:

- MiniAmiq's first record is #770, SeqDriver's #753 and BuildUVMPkg's #1135. Each is `ref_typespec <in>uvm_reg_byte_en_t`,
  the typespec-identity full name N0164.
- MiniAmiq's second record is #899 `uvm_severity` (golden `uvm_globals.svh 271:61`, residue 1).
- SimpleUVM's first record is #458 and Scoreboard's #466, `UVM_MACRO_NUMFLAGS` (N0682).

## 7. Downstream ([evidence/downstream/](evidence/downstream))

- **Rows the landings converted** (surelog-corpus tests, not downstream-gate rows), through the harness's `one()`
  ([drivers/dsrow.py](drivers/dsrow.py), [surelog_rows_ON_ALLOFF.txt](evidence/downstream/surelog_rows_ON_ALLOFF.txt)).
  In each row the slang lane's three netlists have the same md5 with both landings on and off:
  - OneNetModPort and UnsizedParam: IDENTICAL, with the same md5 as golden's lane.
  - OneNetModPortGeneric: IDENTICAL; both lanes READ_FAIL (the plugin and generic ports), and `_nohier.il` is identical.
  - LocalScopeHierPath: IDENTICAL, both lanes READ_FAIL.
- **uhdm2rtlil rows** (swH, [swH_rows_netlist_md5.txt](evidence/downstream/swH_rows_netlist_md5.txt)): `ibex_pmp`,
  `iface_zero_width_field`, `OneNetModport`, `ExpressionInIndex` and `packed_struct_array_shift` have `.il`,
  `_nohier.il` and `_synth.v` byte-identical between the lanes. The rows read:
  `ibex_pmp,IDENTICAL,OK,OK,52,52,,`, `iface_zero_width_field,IDENTICAL,NO_GATES,NO_GATES,0,0,,`,
  `OneNetModport,IDENTICAL,NO_GATES,NO_GATES,0,0,,`. swA's `downstream.csv` is byte-identical to swH's.
- **Own cases** ([cases_ON_ALLOFF_OWN.txt](evidence/downstream/cases_ON_ALLOFF_OWN.txt); 66 single-file cases of CC,
  PG, GV, UD, GE, HP, HK, PU and X, in states ON, ALLOFF and OWN):
  - Every case reads the same verdict in all three states, except UD/u06 and X/x06, which go **EQUIVALENT → IDENTICAL**
    with § udpFormNetLvalueFirst176.
  - No case leaves IDENTICAL.
  - Pre-existing non-identical verdicts, the same in every state: CC/c02, GV/v02, GV/v11, X/x01 EQUIVALENT; GE/e04 and
    the GV inheritance cases STATUS_DIFF; **PU/u06 and UD/u04 DIVERGENT** (section 8).
- **UVM file facets, order-blind** ([evidence/uvm/uvmdist_H_A.txt](evidence/uvm/uvmdist_H_A.txt); `all_file_away`
  counts (type, name, file) triples ours holds more often than golden). Both landings off → HEAD:

  | row | all_file_away | order-blind distance |
  |---|---|---|
  | MiniAmiq | 3823 → 3530 | 15741 → 10001 |
  | SeqDriver | 4026 → 3326 | 14506 → 8130 |
  | SimpleUVM | 2832 → 1701 | 9720 → 3252 |
  | Scoreboard d | 2326 → 1403 | 8576 → 2588 |
  | BuildUVMPkg | 452 → 426 | 7363 → 1775 |

  The `method_func_call` file facets are 15 on both sides (0 on BuildUVMPkg).

## 8. Residues

### Re-measured at the base, pass 181 on top ([evidence/residues_at_base.txt](evidence/residues_at_base.txt); both modes, HEAD and both landings off)

| source | residue | at 459b7cdf |
|---|---|---|
| pass 176, 1 | UVM relocations beside other writers (F3/s08, s13; PQ/q11 two containers; F3/s04, s14 unpacked; PQ/q12 alias) | **stands**: line(n) on every case in both states; MiniAmiq's #899 `uvm_severity` file record stands |
| pass 176, 2 | import-parameter copies share the moved typedef | **stands**: ibex_pmp d/t `file(5)`, and the fresh X/x04 (section 6) |
| pass 176, 3 | typespec-identity full names (N0164) | **stands**: MiniAmiq #770, SeqDriver #753, BuildUVMPkg #1135 first records; Earlgrey_0_1 d/t `fullname(436)` |
| v11u176, 1 | the implementer's predictor trigger was narrower than § tdMoveKeyResolved176 | process note; the refinement landed; no TDKEY firing in any corpus row |
| v11u176, 2 | writer order across unit kinds (TT/t9) | **stands**: file (both states) |
| v11u176, 3 | class writers in two packages (CM/c20); likewise fresh TW/w13 | **stands**: line |
| pass 178, R1 | a path nested in another path's select index (hp/h09) | **stands**: col; fresh HP/h03 stage 1, index parents 2 / 4 off golden in every state |
| pass 178, R2 | a call as a select index spans its name (cs/c01, c02, hp/m07, h08) | **stands**: endcol; fresh HP/h02 endcol |
| pass 178, R3 | the struct members under the unparented reference (pz/z01, z02, z04, z07; iface_zero_width_field `fullname(3)`) | **stands**: fullname |
| r11v178, V1 | the streaming lvalue keeps the bit_select | **stands**: hk/k06 stage 1; fresh HP/h06 col, index parents 4 off golden |
| r11v178, V2 | the inc/dec path's own records (hk/k01) | **gone**: STRICT_EQUAL in both modes, fixed by pass 181 (INCDECMIX, LVCHAIN) |
| r11v178, V3 | multi-dimensional member selects (hx/x05), genvar-folded generate paths (hx/x08) | **stands**: x05 stage 1, x08 fullname |

### New, found here (none is a break of the two landings except the first, which is fixed)

1. **The generic port after an interface-typed port** (the break, fixed). The type inheritance itself stands, and it
   is downstream-visible. Our definition view emits `g` as a generic port where Surelog types it. That keeps every
   such case at stage 1, and the downstream verdict at STATUS_DIFF: the plugin reads golden's typed port and fails on
   ours. The next law would type such a port in the definition view like its predecessor (ModuleEmit, the definition
   port and LowConn).
2. **The import-parameter copy (pass 176's residue 2)** is the one away-movement the landings still make. It covers 3
   records on ibex_pmp and 5 references on X/x04, and it is downstream-invisible. A fix needs the import copy to keep a
   pre-move typedef object (a clone at the import-parameter copy site, ModuleEmit `importParamCopy82` / ParamEmit, when
   the elaborated package typedef has been relocated by a formal writer).
3. **A member read of a package pattern parameter in a task body** (PU/u02) leaves golden's elaborated listing tagged,
   with no reference on the operation. Ours flattens (pre-existing) and § pkgPatUnqualReadTsNoParent178 unparents that
   reference. Wrong to wrong ([evidence/residues/pattern_task_read_u02.txt](evidence/residues/pattern_task_read_u02.txt)).
4. **Downstream-visible, pre-existing in every state:**
   - PU/u06 (a whole-value copy `C = B` beside `$bits(B)` and `B.D`: golden expands C's listing to tagged patterns,
     ours keeps a reference) reads DIVERGENT.
   - UD/u04 (UDP-form instance arrays `ch a1 [1:0] (w1, w2, o)`) reads DIVERGENT.
5. **Unfired generate shapes** of § genElseBeginIfDepth176, stage 1 in every state:
   - GE/e03: a named else block with an inner if-else (golden `genblk1` gen_scope_array under the named block).
   - GE/e04: a gate beside an if in an unnamed else (the gate listing order).
   - GE/e05: a generate for nested in an else-if (the genvar index folding in the gate terminals).
   - GE/e06: a net declared in the else body.
6. **§ refFullNameThroughNamedExpr175's guard** declines qualified and imported-name defaults (FN/n01, n04, X/x04).
   Golden's full name for those was not decoded here (stage 1 or line faces on those cases).
7. **XP/x04**, a definition in an include file: 12 typespec-copy file records (`byte_t` golden `c_impl.svh`, ours
   `dut.sv`) in every state. This is the typespec-copy file family of r11u183dec.

## 9. The fence and the process

**No law, case or number here rests on a fenced reading.**

- Every case is this directory's.
- Every corpus reading is a non-fenced row, read through a fail-closed driver or a gate sweep:
  - [drivers/bvmirror.sh](drivers/bvmirror.sh): `fenced_skipped=8` on every mirror.
  - [predgen.sh](drivers/predgen.sh): `fenced_excluded 8`.
  - unmask.py, joint.py, unmaskposrow.py, compose.py, bytecancel.py, additive.py, share175.py, uvmdist.sh, dsrow.py
    and coin.sh skip or refuse fenced names.

**Two laws of each pass, re-derived from this directory's cases and Surelog's source only.** These are the ones
nearest the fenced tests' parameter and path shapes.

- **§ castRhsClonePerInst176.** `UhdmWriter.cpp` 2219-2240 is leg 3: `rhs` is an operation with its own `Typespec()`,
  cloned with `clone_tree`, `assign->VpiParent(m)`, and the operands replaced by `flattenPatternAssignments`. Only a
  cast carries a typespec (`CompileExpression.cpp` 2685-2708, `vpiCastOp`). Legs 1 and 2 (2121-2218) take a declared
  or typed left side first. The cases agree:
  - CC/c07 and c08 convert. c01 and c02 move closer. c04 and c05 move bytes on the implicit and select left sides.
  - c03, c06, HK/k02 and X/x05 do not fire: declared nets and outputs take leg 1, and generate scopes do not reach it.
- **§ genericPlainNamedView176** (this pass's break). `NetlistElaboration.cpp` 1600-1686 is the decode in section 4.
- **§ pkgPatUnqualReadTsNoParent178.** `CompileExpression.cpp` 1093-1115, the component branch of `getValue`: a
  parameter read by bare name inside its component is expanded and written back to the `param_assign` only when
  `getValue` runs. The cases agree:
  - PU/u04 converts its B listing. u05 and u07 read golden's object.
  - u02 (a task body, never reduced) keeps golden tagged: residue 3.
- **§ hierPathSelIdxAtPath178.** The index-parent census ([drivers/idxcmp.sh](drivers/idxcmp.sh) over r11u178's
  `idxpar.cpp`, [evidence/grid/index_parents.txt](evidence/grid/index_parents.txt)) against golden on 12 fresh HP/HK/X
  cases in both modes. With every law on, the parents equal golden's everywhere except h03 (R1), h06 (V1, 6 → 4) and
  x01 (3 in every state). With the law off they are 2-20 off.

**Drivers of the four evidence directories** ([evidence/process/driver_fence_audit.txt](evidence/process/driver_fence_audit.txt)):

- **r11u176repro and v11u176repro** read `$FENCED` from RESUME.md by a text PATTERN (`for n in ...;`), not from
  canaudit.sh and not by line number, with a four-name count check. The pattern yields the canaudit set at 459b7cdf
  (compared as sorted-set md5). v11u176's drivers source `/tmp/v11u176_env.sh`, a scratch copy that no longer exists,
  so they cannot run from the tree.
- **r11u178repro and r11v178repro** read canaudit.sh's `FENCED=` line, from the pruned worktrees `/tmp/wt_r11u178` and
  `/tmp/wt_v11u178`. Their env.sh now refuses. r11v178's drivers source `/tmp/v11u178_env.sh`, which is gone.
- **Not fail-closed on an empty `$FENCED`** (they read corpus rows or databases):
  - **r11u176repro/drivers/row.sh**: sources env.sh with `.`, has no count check, and its refusal loop is empty.
  - **r11v178repro/drivers/coin.sh** and **rowsoff.sh**: they source the gone scratch file without `|| exit`.
  - v11u176 `boundary.sh` and r11v178 `ds.sh` are closed only by accident: an empty pattern drops, or refuses, every
    path.
  - Everything else refuses without four names or reads cases and probe only.
- A word-boundary scan of the four directories for the four names finds 0 files.

**The predictions were written before their sweeps, as far as the tree can show.** The passes' scratch is pruned. What
is reproducible:

- **Pass 176:** the committed `predict176.cpp`, run over `sw7` (the `72fd3061` state, probe EQUAL 2768 = pass 176's
  pristine), reproduces `evidence/prediction/pred_final.txt` **exactly: 6647 rows, 0 differing lines**
  ([evidence/process/pred176_rerun.txt](evidence/process/pred176_rerun.txt)). The 30 corpus movers of its
  byteverify evidence are all inside the prediction's 44 corpus names.
- **Pass 178:** the committed `predict178.cpp`, run over `sw5` (the `5e8d08d9` state, 2796 = pass 178's pristine),
  reproduces `evidence/predict_pristine.txt` **exactly: 6647 rows, 0 differing lines**
  ([pred178_rerun.txt](evidence/process/pred178_rerun.txt)). Its 25 corpus movers are all inside the prediction's 29
  corpus names.
- Both predictions are functions of the pristine databases alone, so they could not have seen the law sweeps.
- **v11u176's withdrawn `ver1.bin`:** the directory holds sweep summaries for `swP`, `swL` and `swV` only, and no
  `ver1` sweep or byte file. `pred176v_before_swV.txt` carries its own stamp (02:39:52), against the README's `swV`
  start at 02:41.

**r11v178's refinements hold on every shape written here** (index parents 0 off golden with them, positive without;
[evidence/grid/index_parents.txt](evidence/grid/index_parents.txt)):

| shape | case | with refinement | law without it | pristine |
|---|---|---|---|---|
| pre-increment, post-decrement, pre-decrement and post-increment reads | HK/k01 | 0 | 0 | 0 (0 in every state: pass 181's inc/dec laws now build these operands) |
| inc/dec with two selects | HP/h07 | 0 | 6 | 2 |
| compound assignment | HK/k03, HP/h09 | 0 | 0 | 2 / 0 |
| clone right side: cast, concatenation, call, cast of an operation | HK/k02 | 0 | 8 | 10 |
| clone right side: operation over two-select paths | HP/h08 | 0 | 6 | 8 |
| clone right side: casts, in a module instantiated twice | X/x05 | 0 | 16 | 12 |

(k01 and h09 read 0 in every state; the refinement is exercised by h07, h08, k02 and x05.)

**Operations of this pass, disclosed:**

- A first `pre.bin` build named the wrong CMake target.
- The second was killed by the kernel (out of memory under three sweeps) and rebuilt with `-j 1`.
- A first prediction run wrote to a relative path and printed 0 databases from an empty list. It was re-run with an
  absolute path before the fix sweep.
- Up to three sweeps ran concurrently at `--jobs 3`.
- No process this pass did not start was touched, and the live pairs' worktrees were not touched.
- `/tmp/strict_sweep` (named by the brief as the 459b7cdf sweeps) is dated 2026-09-24. It predates the base, so it was
  not used.

## 10. Files

- [fix.patch](fix.patch): § genericAfterTypedIfacePortTyped185v (`git diff 459b7cdf -- src`).
- `cases/{CC,DW,FN,GE,GV,HK,HP,IC,PG,PU,TD,TW,UD,X,XP}/`: 113 cases. The first line names their laws. TD/d01-d04,
  TW/w03, w07-w09 and X/x07 carry a `files` list; XP/x04 includes `c_impl.svh`.
- `drivers/`:
  - `env.sh`, `laws.py` (law → switch map), `mkstate.sh`, `sweep.sh`, `queue.sh`.
  - `case.sh`, `grid.py`, `gridall.sh`, `gridsum.py`, `lawtable.py`, `precheck.sh`, `residues.sh`.
  - `fieldscore.py`, `recaway2.py`, `dumpaway.py`, `dumpaway2.py`, `dd.sh`, `idxcmp.sh`.
  - `compose.py`, `bytecancel.py`, `joint.py`, `additive.py`, `share175.py`, `unmask.py`, `unmaskpos.py`,
    `unmaskposrow.py`, `uvmdist.sh`, `bvmirror.sh`, `coin.sh`.
  - `dscase.py`, `dsrow.py`.
  - `predgen.cpp` / `predgen.sh`, `fixcases.sh`, `boundary.sh`.
  - Drivers copied from r11u182verify / r11u177verify say so in their headers.
- `evidence/`: `grid/`, `fix/`, `composition/`, `changes/`, `downstream/`, `uvm/`, `process/`, `residues/`, `sweeps/`,
  `residues_at_base.txt`.
