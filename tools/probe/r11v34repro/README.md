# r11v34 — adversarial verification of r11u34 (`§ pkgNestedPatElabNoExpandSize34`)

Base `3621c70e`.  Everything below was re-measured from scratch in the
verifier's own worktrees (`/tmp/wt_v11u34`, `/tmp/wt_v11u34pris`) with the
verifier's own binaries, frozen read-only before any sweep:

| binary | md5 |
|---|---|
| PRISTINE, fresh build at `3621c70e` | `eb63e166e8f297649e0cf6371e4f2be4` |
| PATCHED, `r11u34.patch` on a fresh `3621c70e` | `a7a1468f0d81ca9a1f62fc36c2da899a` |

Both reproduce the implementer's md5s exactly; the pristine one is the md5 the
brief pins for the base.  Every `cmds.txt` in all four sweeps was audited by
binary PATH: 1742/1742 uhdm2rtlil and 1531/1531 Surelog name the intended
frozen binary, none the main tree.

---

## 1. THE HEADS, THE GRID AND THE MOVER — reproduced

**The three K7 heads at `3621c70e`**, official `uhdm-cmp`, one head each
(`grep -c '^LHS:'` = 1), reproduce the implementer's quotes character for
character, and so do the two corrections:

* `cfg_func_width_loop` — `operation id:93` at `21:37` carries no `vpiSize` in
  golden; ours (`id:115`) carries `vpiSize:1`.  82 cmp lines.
* `iface_zero_width_field` — the head is a NAMELESS `ref_typespec id:90` whose
  `vpiActual` is the NAMED `struct_typespec (p::bus_t)`.  The triage's
  "nameless struct" is a misreading: the ref is what has no name.
* `typed_named_pattern` — golden's owner `operation id:102` is **`vpiOpType:67`
  over `vpiOpType:33`** (verified in the golden dump: the cast's operand is a
  concat whose operands alternate `ref_obj -> logic_net` and constant), in
  `uhdmallModules`.  It is **not** a `vpiOpType:75` row, so the triage's "all
  three heads sit on the same object" is wrong.

**The six-arm golden grid** (`r11u34repro/g1`..`g6`) reproduces cell for cell,
including the golden values `PA front 192 / PD both ends 192 / PV 4 / PU 64`
and the `vpiReordered` marks.  `adjustOpSize`
(`Surelog/src/DesignCompile/CompileHelper.cpp:5114-5203`) explains all three
numbers: a `packed_array_typespec` target falls to the ELSE branch and stamps
`Bits(whole)` (192), a `logic_typespec` stamps `fullSize/innerSize` (4), an
`array_typespec` stamps the ELEMENT's `Bits` (64).

**The mover.**  `byteverify.sh SELFCHECK=1`, patched against the verifier's own
pristine workdir: uhdm2rtlil **MOVERS 2 / 1608**, both
`cfg_func_width_loop` — the set predicted a priori by the verifier's own census
of its own PRISTINE workdir (`pred.py`: one test, two cells per mode,
`line:21:37=1;line:21:55=1`, zero golden cells corpus-wide).  The whole-dump
diff of that database is **exactly two removed lines**, both `|vpiSize:1`, and
its package listing then matches golden cell for cell (TO 2 / AWAY 0 per mode).
The head clears and the next head is a different object (the pass's R0), cmp
lines 82 → 17.

`pred.py`'s POSITIVE CONTROL was re-run by the verifier: it finds 5 golden
cells on `g1`, 2 on `g4`, 1 on `v2`.  A zero golden column is a fact about the
corpus, not about the instrument.

---

## 2. BREAKING THE LAW — sixteen arms, AWAY-GOLDEN 0

`arm.sh` runs one `.sv` through Surelog v1.87 and BOTH frozen binaries;
`lister.py` prints every assignment-pattern operation per DUMP SECTION with its
nesting depth, `vpiSize` and `vpiReordered`, so the module listings and the
DEFINITION package listing are scored beside the elaborated one.  Every arm
below reports `slrc=0 slerr=0 prisrc=0 patrc=0`.

(Three earlier drafts of `v3`/`v5`/`v7` wrote `q::PA[0].e` in a constant
context; Surelog v1.87 rejects that as `Undefined user task/function "q::PA"`
(`[ERR:CP0337]`), so those arms taught error recovery and were rewritten with
whole-name reads before being scored.)

### The AWAY hunt — every candidate refuted

| arm | the only reader of the package pattern params | golden | patched | verdict |
|---|---|---|---|---|
| `v1` | a bare `PA[0].e` in the package's OWN localparam | NONE | NONE | TO 4 |
| `v10` | a bare WHOLE-name `PA` in the package's own localparam | NONE | NONE | TO 4 |
| `v11` | wildcard-imported bare `PA` in a module localparam | NONE | NONE | TO 4 |
| `v3` | `q::PA` only inside a MODULE-BODY localparam | NONE | NONE | TO 4 |
| `v5` | `q::PA` only inside ANOTHER PACKAGE's localparam | NONE | NONE | TO 4 |
| `v6` | wildcard-imported whole read in a cont-assign | NONE | NONE | TO 4 |
| `v12` | THREE-level nesting, no reader | NONE | NONE | TO 4 |
| `v14` | nested-op and constant operands MIXED, no reader | NONE | NONE | TO 4 |
| `v13` | NAMED-KEY (structured) nested pattern, no reader | NONE | NONE (pristine too) | no move |

`v1`, `v10` and `v11` are the arms that matter for the producer story: they aim
straight at `getValue`'s two BARE-NAME `expandPatternAssignment` arms
(`CompileExpression.cpp:1012` and `:1114`), the ones the implementer's "exactly
one road" paragraph omits.  Golden stamps nothing in any of them, so the
predicate is right even though the source argument is incomplete — the
production comment now carries that correction.

### Per-parameter granularity — golden agrees with the gate

`v2` declares `PA`, `PB`, `PV` in one package and reads only `q::PB`.  Golden
stamps **PB alone** (`7:33=192`); `PA` and `PV` stay bare.  The gate is keyed
on `pkg::name`, so it removes exactly `PA`'s and `PV`'s cells and keeps `PB`'s.
TO 4 / AWAY 0.  A per-PACKAGE predicate would have been wrong here.

### The READ face is untouched — four positive controls

`v4` (an INSTANCE PARAMETER OVERRIDE `#(.W(q::PA[0].e))`), `v8` (a cont-assign
inside a GENERATE block), `v15` (three-level nesting read scoped) and `v16`
(mixed operands read scoped) all STAMP in golden, and the patched database is
byte-identical to the pristine one in all four.  `g1`/`g4` likewise.

### The over-approximation (a residue, never an AWAY)

`v9` reads `q::PA` / `q::PV` ONLY from `always_comb`.  **Golden stamps
nothing** — but the syntax predicate counts the read, so we keep four cells
golden does not have.  Patched == pristine there, so this is STILL-WRONG, not
AWAY.  `v8` against `v9` places the boundary: a CONTINUOUS assign (even inside
a generate block) triggers Surelog's reduce; a PROCEDURAL statement does not.
`v7` (a gen-if condition plus an `always_comb`) is on the same side as `v9`.

### Views

The DEFINITION package listing (`|uhdmallPackages:`) already agreed with golden
(no stamp) on both binaries in every arm, and the module listings are
byte-identical pristine-vs-patched in every arm — the `topView` half of the
gate is warranted and the law reaches nothing else.

---

## 3. GATES, re-run by the verifier

1. **Build.**  Pristine `eb63e166…` (the brief's base md5), patched
   `a7a1468f…`, 0 errors each, `-j 2`, md5s taken separately, both frozen
   `chmod 555` before any sweep.
2. **Goldens.**  Patched PASS 23 / FAIL 0; pristine PASS 23 / FAIL 0;
   `SLANG_UHDM=/bin/false` PASS 0 / FAIL 23.
3. **uhdm2rtlil, both modes, both binaries: 772 CMP_EQUAL / 32 CMP_NOTEQUAL /
   67 SLANG_REJECT** — the baseline exactly.  `ct8rows.sh` PASS against
   `results/gate_uhdm2rtlil.csv` and against the verifier's own pristine sweep
   in both modes; a name+status join against both mode-halves of
   `results/golden_uhdm2rtlil.csv` differs on **0 rows**.
4. **Surelog, `--mode both`: default 474/9, testflags 469/8**, histograms
   identical in every bucket between the two binaries.  `ct8rows.sh` patched
   against the verifier's own pristine flags exactly two rows, both the
   workdir path inside a golden-side message, status unchanged:

   ```
   < LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/v11u34_pris/sl/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,
   > LowMemLib,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/v11u34_pat/sl/testflags/LowMemLib-f068a766/slpp_all/surelog.log".,,
   < LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/v11u34_pris/sl/testflags/LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   > LowMemPkg,testflags,SURELOG_FAIL,[INF:CM0023] Creating log file "/tmp/v11u34_pat/sl/testflags/LowMemPkg-ef3ec0d8/slpp_all/surelog.log".,,
   ```

   Against the committed `results/golden_surelog.csv` one more row appears, and
   it appears identically in the verifier's PRISTINE sweep:
   `Earlgrey_0_1,testflags,CMP_EQUAL,,,differ` → `,,,` — the dump COLUMN blank
   on a `uhdm-dump` timeout draw.  (The implementer reported this blank in both
   modes; this machine drew it in testflags only.  It is a draw, and the
   DATABASE pin below is the actual gate.)
5. **byteverify `SELFCHECK=1` against the verifier's own pristine workdirs.**
   * uhdm2rtlil: PATH_SETS_IDENTICAL (1608), MOVERS **2 / 1608**, both
     `cfg_func_width_loop`, SELFCHECK 1607/1608.
   * Surelog: PATH_SETS_IDENTICAL (960), MOVERS **5 / 960** — `MiniAmiq/default`,
     `Scoreboard/default`, `SeqDriver/default`, `SeqDriver/testflags`,
     `SimpleUVM/default`.  (The implementer's sweep drew four, a different
     subset; that difference is itself the coin.)  **All five attributed by
     measurement, not assertion:**
     - ORDER-BLIND sorted-dump diff: `Scoreboard/default` **0 lines** (a pure
       ordering flip); the other four **4 lines each**, all of the documented
       `UINT:n` / `vpiDecompile:n` macro-buffer line-number class
       (`1087↔1237`, `1215↔557`, `830↔0`, `1482↔0`).  No `vpiSize` anywhere.
     - RE-DRAW with the UNCHANGED PRISTINE binary, three runs each on the
       sweep's own command line, fresh output path every run, rc checked:
       `SeqDriver` → `13b34eb363fe`, `2fb39f8b4130`, `2fb39f8b4130` (sizes
       18074289 / 18074287 / 18074287); `MiniAmiq` → `a7b2c93258f9`,
       `069b4973fc24`, `f7f3639405d4`; `SimpleUVM` → `49d8efe2729b` ×3, which
       is the PATCHED sweep's draw while the PRISTINE sweep drew
       `eb6d2e1e4c3d`.  One binary, several hashes: the difference is the draw.
   * Every UVM row and `Earlgrey_0_1` stays `CMP_EQUAL` in both modes on both
     sweeps.  **MOVED-WRONG 0 / AWAY-GOLDEN 0** on both corpora and on all
     sixteen arms.
6. **Protected databases, patched vs the verifier's own pristine, all SAME and
   all on the brief's pins:** `SVSwitch 4842211c4030` (both modes),
   `YosysVerx 6ccda350c24a` (both modes), `InterfaceModPort 59a365f3ce2c`,
   `BlackParrotComplex` (def `e3e354129d5a`, tf `73a10e8217e5`),
   `YosysOldOr d68e0796d62c`, `Earlgrey_0_1` def `8bdf25272e08` / tf
   `59d0ee6d10c3`.
7. **Canaries.**  Surelog `ok=52 changed=0` and uhdm2rtlil `ok=8 changed=0`
   against the verifier's own pristine; against the committed surelog CSV the
   single change is the Earlgrey dump-column blank of gate 4.  `ctcan2.sh` PASS
   on both corpora.  `canaudit.sh canaries.sh ctcan2.sh` —
   `audited=29 UNCOVERED=0 FENCE-BREACH=0`.
8. **rowheads** on the patched Surelog workdir: `SeqDriver`, `SimpleUVM`,
   `Scoreboard/default`, `MiniAmiq`, `BuildUVMPkg`, `Earlgrey_0_1` — every one
   `0 cmp lines, 0 heads, rc=0`; SKIP-NOFILE on `Scoreboard/testflags` and
   `Rggen/testflags`; `Rggen/default` CMP_NOTEQUAL on both binaries as at the
   baseline.
9. **Surface.**  `git diff 3621c70e` from the applied tree is byte-identical to
   the delivered patch (index lines aside); it applies with a plain
   `git apply --check` on a fresh `3621c70e`; `results/*.csv` untouched; the
   four fenced test names appear 0 times.  `GenIfIfaceParamStructField` — the
   witness of the parameter-declaration caveat this law inherits — stays
   `CMP_EQUAL`.

---

## 4. WHAT THE VERIFIER CHANGED

Comment-only, and the rebuilt binary comes back at the same
`a7a1468f0d81ca9a1f62fc36c2da899a`:

* `include/UhdmExporter.h`, the `§ pkgNestedPatElabNoExpandSize34` PRODUCER
  paragraph — "exactly one road" is not provable from the Surelog source:
  `expandPatternAssignment` has six call sites, THREE of them inside
  `CompileExpression.cpp` (`:941` the `pkg::NAME` arm, `:1012` an instance's
  netlist `param_assigns` by bare name, `:1114` `component->getParam_assigns()`
  by bare name, whose `component` is the PACKAGE for an expression compiled
  inside one).  The corrected paragraph says what is measured instead, and
  names the arms that measure it.
* The same declaration gains a BOUNDARY paragraph recording the sixteen arms:
  per-parameter granularity (`v2`), the refuted AWAY candidates, and the
  procedural-read over-approximation (`v9` against `v8`).

## 5. RESIDUES the verifier adds to the pass's own R0-R3

* **V1 — the procedural-read over-approximation.**  A `pkg::NAME` read that
  occurs ONLY in a procedural statement leaves golden unstamped while the
  syntax predicate keeps our stamp (`v9`: 4 cells; `v7` the same).  The refined
  trigger is "a constant/continuous-assign context", not "a `ScopedName`
  anywhere outside a parameter declaration".  No corpus cell is on this face
  (the census finds zero), so it costs nothing today; it is the first thing to
  tighten if a corpus row ever lands on it.
* **V2 — the positive half is still unlanded (the pass's R3, confirmed).**  On
  the READ face our value is 1 where golden's is `Bits(whole)` (192, or 256 on
  the three-level `v15`), and we stamp BOTH ends where golden stamps one, and
  we never stamp the unpacked-array face at all (`g1` PU: golden 64, ours
  none), and we do not reorder where golden does.  All four are pre-existing
  and untouched by this patch.
* **V3 — `pred2.py` (the R1 census instrument) swallows a `uhdm-dump`
  TIMEOUT with a bare `continue`**, so a timed-out row reads as "no row" rather
  than as a hole.  `pred.py`, the instrument this law's census actually rests
  on, prints `TIMEOUT` and does not have the defect.
