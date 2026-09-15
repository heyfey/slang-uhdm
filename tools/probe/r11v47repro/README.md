# r11v47 — ADVERSARIAL VERIFICATION of r11u47 (§ tpAnonAggParamTsNoStamp47)

Base commit `88cd5538`. Verifier worktrees `/tmp/wt_v11u47pris` (pristine) and
`/tmp/wt_v11u47` (patched). Both binaries built here, frozen `chmod 555`:

| binary | md5 |
|---|---|
| pristine (`/tmp/v11u47_bin/pris.bin`) | `6462baa4f897348bbd1dd5cd484dfcb2` — byte-identical to the main tree at `88cd5538` |
| law (`/tmp/v11u47_bin/law.bin`) | `bb429bfd6362775094b3e74909d02667` — the implementer's exact binary |

`git diff --cached 88cd5538` over the patched worktree reproduces
`/tmp/r11u47.patch` byte-for-byte (`d6c8e761b0ee0dea98fc999eeab1f2bd`), so the
patch applies clean on a FRESH `88cd5538` and builds to the measured binary.

**VERDICT: ACCEPT AS-IS.** No pristine-right → patched-wrong case was found on
legal SystemVerilog; no `.verified.patch` was needed.

---

## 1. What was re-measured, independently

* Both heads at `88cd5538`: `StructParamFieldRange` and `cva6_struct_param_field`,
  **166 lines / 1 head**, both modes; LHS `struct_typespec: , id:566,
  line:23:26, endln:23:32` (UNNAMED, no `vpiInstance`), RHS
  `struct_typespec: (it_t), id:331, line:23:26, endln:26:4` with `|vpiName:it_t`
  and `|vpiInstance: module_inst work@StructParamFieldRange`.
  (The TRIAGE2 "164-line" figure is the BLINDED text; the raw cmp is 166.)
* `typespec::Compare` order read from the pinned generated body
  (`~/git-repos/UHDM/build/generated/src/typespec.cpp:88-94`): `VpiName` first
  (setting both failed sides), then `Typedef_alias`, then `Instance`. Confirmed.
* The producer decode, read in the pinned Surelog v1.87 (`0445655ee7`):
  `compileTypeDef` is the ONLY writer of a `struct_typespec`'s `VpiName`
  (`CompileHelper.cpp:1094`, inside the function that spans `:501`–`~:1100`);
  the two `vpiInstance` stamps are `CompileHelper.cpp:1092` (package only) and
  `UhdmWriter::writeDataTypes` (`UhdmWriter.cpp:798-802`) which iterates the
  component's **DataTypeMap** only. The other `VpiName` writers in
  `CompileType.cpp` set `interface_typespec` / `class_typespec` /
  `unsupported_typespec`, never a struct. The implementer's claim stands.
* The implementer's 12-arm grid, re-run with the verifier's own binaries:
  cmp lines pristine → law **g1 166→54, g2 166→0, g3 36→36, g4 172→172,
  g5 90→90, g6 402→402, g7 163→163, g8 453→453, g9 166→0, g10 162→0,
  g11 86→86, g12 90→90** — bit-for-bit as reported. `g4`, `g6`, `g8`, `g11`
  databases byte-IDENTICAL.
* Residues (order-blind, path-normalised whole-dump diff):
  `445/629/667` with `it_t=60` → `388/572/630` with `it_t=15`;
  `cva6_struct_param_field` `445/60` → `388/15`; control
  `GenForStructParamBound` `448/0` unchanged; `packed_array_struct` `191/0` and
  `port_chained_type_param` `37/0` unchanged. See `evidence/RESIDUE.v11v47.txt`.

---

## 2. THE VERIFIER'S OWN GRID — 28 arms, `arms/v1`…`v31`

`run.sh` (fd-3 arm list, children `</dev/null`, `LISTED==PROCESSED` asserted,
every rc recorded; `WD`/`BIN`/`OUT`/`GOLDDIR` all overridable). Golden is
Surelog v1.87; the judge is the official `uhdm-cmp`. Full table in
`evidence/GRID.v11v47.txt`.

Faces covered (anonymous vs named-typedef binding × struct / packed union /
unpacked struct / enum × default / value-override / type-override × module /
package / interface / class / `$unit` / generate-for / generate-if / function
body × 1–3 instances):

| arm | face | cmp lines P→L | verdict |
|---|---|---|---|
| v1 | module body, anonymous packed struct | 68→68, DB moved | 12 `it_t` → 12 bare; golden all bare |
| **v2** | **NAMED typedef bound (CONTROL)** | 68→68, **DB IDENTICAL** | gate refuses; golden wants `named_t`, we still say `it_t` (R2) |
| v3 | anonymous packed union (clean compile) | 68→68, DB moved | names dropped |
| v4 | anonymous UNPACKED struct | **162→54** | names + instance dropped |
| **v5** | **anonymous ENUM** | 136→136, **DB IDENTICAL** | untouched (R1) |
| v6 | PACKAGE holder | 237→237, DB moved | names dropped, **package instance KEPT on exactly 2 — golden has 2** |
| v7 | INTERFACE holder | **166→54** | `interface_inst` dropped |
| v8 | ANSI port list, default + `ov_t` override, 2 instances | 322→322, DB moved | default clone un-named; **override clone keeps its name** |
| v9 | 3 instances, default + two typedef overrides | 476→476, DB moved | same, at 3 instances |
| v10 | generate-FOR | 94→92, DB moved | names dropped (golden emits `unsupported_typespec (it_t)` here — a separate Surelog limitation) |
| **v11** | **CLASS type parameter** | 17→17, **DB IDENTICAL** | already unnamed in ours; untouched |
| v12 | CHAINED `a_t→b_t→c_t` | **166→54** | names dropped |
| **v13** | **localparam with UNPACKED dims** (`it_t I [0:1]`) | 90→90, **DB IDENTICAL** | aggregate arm never reached (ours builds a `logic_typespec`) |
| v14 | function body uses of the type | 17→17, DB moved | names dropped |
| v15 | package type param, module localparam of it | 119→119, DB moved | names dropped, **3 package instances kept — golden has 3** |
| v16 | ANSI port list, 3 instances, different `W` | 90→90, DB moved | 25+3 named → 28 bare |
| **v17** | **NAMED typedef bound, in a PACKAGE (CONTROL)** | 92→92, **DB IDENTICAL** | gate refuses |
| v18 | NESTED anonymous struct | **166→54** | outer un-named, inner untouched |
| v19 | `typedef it_t alias_t;` aliasing the type parameter | 162→162, **cmp text byte-identical** | NEW RESIDUE (§4 R-A): golden names EVERY copy `alias_t` |
| v20 | type param OVERRIDDEN by another type param | 90→90, DB moved | names dropped; golden all bare |
| v21 | `$unit` (compilation-unit) scope | **162→33** | names dropped; no instance lost |
| v22 | generate-IF | 450→450, DB moved | names dropped |
| v23 | 3 instances inside a generate-for | 90→90, DB moved | 17+3 named → 20 bare |
| v27 | THREE type params in one module (struct + union + unpacked) | **166→54** | all three un-named; the pointer set holds multiple objects |
| v28 | function PORTS of the type | **166→54** | names dropped |
| v29 | module never instantiated (DEF view only) | 2670→2670, DB moved | names + `module_inst` dropped |
| v30 | a VARIABLE *and* a localparam of the type | 746→746, DB moved | golden still all-bare — a variable does not register the aggregate as a DataType |
| v31 | module type param defaulted to a PACKAGE type param | 119→119, DB moved | names dropped (R-B: we never had golden's package instance here) |

**No arm's cmp-line count increased. No arm's head object changed for the
worse. Five arms are byte-IDENTICAL and four of them are the controls the law
must not touch.**

**Determinism control:** every arm database is byte-reproducible across two
extra pristine invocations and two extra law invocations (0 NONDET of 28), so
every DB-MOVED reading above is the law and not noise.

---

## 3. LANDED-LAW WITNESS BATTERY — 122 arms, 0 status flips

`flatrun.sh` over every `*.sv` in `tools/probe/r11u{17,18,20,30,31,34,35,40,45}repro`
(the type-param and struct-param passes whose witnesses must stay):

* 122 LISTED == 122 PROCESSED, both runs.
* **70 arms CMP_EQUAL at pristine, 70 at law; ZERO `cmprc` flips.**
* 2 arms are `ourrc=3` (slang rejects them standalone) identically in both runs.
* **Exactly ONE arm's database moved: `r11u35repro/grid/g4_view35`** — this
  law's own shape — and **its cmp text is byte-identical**. Its shape moved
  toward golden (18 `it_t` + 2 `it_t`+`module_inst` → 20 bare, golden 31 bare),
  while the named package typedef `g4pk35::cfg_t` (21/15 bare, 6/4 package) is
  untouched.

---

## 4. CENSUS + PREDICTION (independent, a priori, with a positive control)

An independent SOURCE census of both corpora (`evidence/CENSUS.source.txt`,
17 236 files) for `[local]param[eter] type N = struct|union|enum` names
**8 test dirs**: the three surelog `StructParam*`, `cva6_struct_param_field`,
`packed_array_struct`, `port_chained_type_param`, `Ariane2024`, `cva6_equiv`.

* `packed_array_struct` declares only VARIABLES of the type and
  `port_chained_type_param` only PORTS — no `ParameterSymbol` of the type, so
  `makeParamTs`' aggregate arm is never reached (measured as the v30 / v8-v11
  faces). Predicted NOT to move; byte-identical.
* `Ariane2024` is SLANG_REJECT / NO_DATABASE — non-comparable.
* `cva6_equiv` has no `dut.sv` and is NOT a discovered corpus row (0 rows in
  either CSV) — the implementer's census omits it harmlessly.

**POSITIVE CONTROL for the census instrument:** a first cut of the regex
(`\bparam\s+type`) was blind to the ANSI `parameter type` form and missed
`port_chained_type_param`; the corrected `param(?:eter)?` finds it. The
instrument is therefore demonstrably able to see the construct.

**PREDICTED MOVERS, BY NAME, BEFORE THE SWEEP: `StructParamFieldRange`,
`StructParamFuncBodyFieldCompare`, `StructParamPatternInitCast`,
`cva6_struct_param_field` — 4 tests / 8 databases. 0 CONVERT** (every one of
them carries residue beyond the head, so the arithmetic gives ADVANCE).
**MEASURED: exactly that.**

Note on the implementer's `census_db.sh`: it strips only a trailing `.`-segment
from a `type_parameter` name, so a PACKAGE-scoped clone named `pk::it_t` would
not be flagged. Their source census and this one close that gap; no additional
comparable row exists.

---

## 5. GATES (re-run end to end by the verifier)

1. **Build.** Pristine md5 `6462baa4f897348bbd1dd5cd484dfcb2` == main tree at
   `88cd5538`; law `bb429bfd6362775094b3e74909d02667`. No new compiler
   warnings (20 in both logs, identical text). Every `cmds.txt` audited by
   binary PATH: `/tmp/v11u47_wdP/{u2r,sl}` → 1742 + 1596 lines, all
   `/tmp/v11u47_bin/pris.bin`; `/tmp/v11u47_wdL/*` all `law.bin`. No main-tree
   leakage.
2. **Goldens.** law 23 PASS / 0 FAIL; pristine 23 PASS / 0 FAIL; negative
   control `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL.
3. **uhdm2rtlil, both modes.** 782 / 22 / 67 under BOTH binaries. `ct8rows.sh`
   law vs committed `results/gate_uhdm2rtlil.csv`, law vs own pristine
   (testflags AND default): `PASS: every row byte-identical`.
4. **surelog, both modes.** **474 / 9** default and **469 / 8** testflags in
   the pristine sweep, the law sweep and the committed baseline. `ct8rows.sh`
   law vs committed and law vs own pristine: the ONLY differing rows are
   `LowMemLib,testflags` and `LowMemPkg,testflags`, whose `SURELOG_FAIL` detail
   text embeds the workdir path (they differ in the pristine sweep too).
   STATUS and DUMP-column histograms IDENTICAL in every comparison. The
   Earlgrey dump-column coin the implementer drew did not come up here.
5. **byteverify `SELFCHECK=1`, law vs the verifier's OWN pristine workdirs.**
   * uhdm2rtlil `PATH_SETS_IDENTICAL (1608)`, **MOVERS 2 / 1608** — both
     `cva6_struct_param_field`, both predicted. Selfcheck 1607/1608.
   * surelog `PATH_SETS_IDENTICAL (960)`, **MOVERS 11 / 960** — the 6 predicted
     `StructParam*`, plus `MiniAmiq`×2, `SeqDriver`×2 and
     `BuildUVMPkg/testflags`. Selfcheck 959/960.
   * **All five unpredicted movers are attributed with a PRISTINE-ONLY
     control.** `MiniAmiq`, `SeqDriver`, `BuildUVMPkg` are byte-unstable per
     INVOCATION under the pristine binary alone: two serial pristine runs of
     MiniAmiq give `41984f0e64c8` / `a7b0fe6bc1db`; five of SeqDriver give
     `2fb39f8b4130`×4 then `bbd8194e9f37`; **BuildUVMPkg's own pristine sweep
     produced TWO different hashes from the IDENTICAL command line**
     (`default` `429a14a60924`, `testflags` `34f3e0775714`) and two
     SIMULTANEOUS pristine invocations give `84055835c7eb` vs `9db2aa6c2775`.
     The order-blind path-normalised whole-dump diff names the class: four of
     the five are the documented **0-or-4-line line-number class**
     (`|UINT:0`/`|vpiDecompile:0` against a line number); BuildUVMPkg's four
     lines are a `class_defn` / `class_typespec (this_type)` presence flip,
     reproduced on the pristine binary under load. Size deltas 44, −45, 5, 4,
     87 — none a 4096 page boundary. **All five rows stayed CMP_EQUAL.**
   * **MOVED-WRONG 0 / AWAY 0.**
6. **Canaries.** `canaries.sh` surelog law `ok=52 changed=0` (pristine control
   the same); u2r law `ok=8 changed=0`. `ctcan2.sh` PASS on both corpora
   (`ok=58` / `ok=1`). `canaudit.sh` → `audited=29 UNCOVERED=0
   FENCE-BREACH=0`. The three battery scripts are byte-identical to the
   `r10uvm221repro` generation. **Protected databases, PRISTINE == LAW in every
   case, both modes:** SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`,
   InterfaceModPort `59a365f3ce2c`, BlackParrotComplex `e3e354129d5a` /
   `73a10e8217e5`, YosysOldOr `d68e0796d62c`, Earlgrey_0_1 `8bdf25272e08` /
   `59d0ee6d10c3` — every OPS pin met on the nose.
7. **UVM family + Earlgrey heads** (`rowheads.sh` on the law sweep): SeqDriver,
   SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg, Earlgrey_0_1 all `cmp rc=0`,
   0 heads, both modes; Rggen/default 64 lines / 1 head. Status table for the
   whole family identical pristine vs law.
8. `results/*.csv` untouched (`git diff --stat -- results/` empty in both
   worktrees). No `git stash`. No shared `/tmp/ctl_wd_*` read or written. Fence:
   0 files in the patch spell any fenced name.

---

## 6. RESIDUES the verifier adds (none is a regression)

* **R-A — a NAMED TYPEDEF THAT ALIASES THE TYPE PARAMETER makes golden name
  every copy after the TYPEDEF.** `arms/v19`: with `localparam type it_t =
  struct packed {...}; typedef it_t alias_t;`, golden's copies are
  `alias_t` (20 bare + 3 `module_inst`) — there is no unnamed copy at all.
  Ours named them `it_t` before and leaves them unnamed after; both are wrong
  against `alias_t`, the cmp text is byte-identical before and after, so this
  is a lateral move, not a regression. It is the one measured face where the
  law's blanket "unnamed" is not golden's answer, and it needs the OWNER test
  widened to "is this aggregate ALSO the definition of a named typedef".
* **R-B — a module type parameter defaulted to a PACKAGE type parameter loses
  the package instance.** `arms/v31`: golden 6 bare + **2 `package: pk`**;
  ours 12 bare, 0 package, before and after. `aliasPkg` is computed from the
  declared alias's own parent scope, which is the module, so the package link
  is never made. Pre-existing; untouched by this pass.
* **R-C — the localparam written with UNPACKED DIMS never reaches the
  aggregate arm.** `arms/v13`: golden `struct_typespec` (13 unnamed), ours a
  `logic_typespec`. A different site; the gate correctly does not fire.
* **R-D — a generate-FOR block's type parameter is an `unsupported_typespec`
  in GOLDEN.** `arms/v10`: golden emits `unsupported_typespec: (it_t)` where
  ours emits a `struct_typespec`. The KIND differs before `VpiName` is read,
  so this law neither helps nor hurts there.
* The implementer's R0 (member-bound FOLD, gated on the typespec-POOL COPY
  COUNT) is confirmed as the new head on all 4 witness rows: golden
  `constant |INT:63` against our `operation |vpiOpType:11` over
  `hier_path (Cfg.XLEN)`, 74 lines, both corpora, both modes.

### One evidence weakness in the implementer's pack (not a defect)

`arms/g2` (their union arm) compiles with `ourrc=4` (`expression kind:
Invalid`) — an arm whose compile fails teaches error recovery, not golden, so
its "cmp EQUAL after the law" reading is on a degraded database. The union face
is nonetheless covered here by `arms/v3`, which compiles `rc=0` and moves in
the right direction.

---

## 7. Files

```
run.sh              per-directory arm runner (fd-3 list, </dev/null children,
                    LISTED==PROCESSED; WD/BIN/OUT/GOLDDIR overridable)
flatrun.sh          the same for flat .sv witness files (LIST on fd 3)
resid.sh            order-blind path/number-normalised whole-dump residue
arms/v1..v31        the 28 adversarial arms
evidence/GRID.v11v47.txt              per-arm cmp lines + head + DB identity
evidence/RESIDUE.v11v47.txt           both corpora, both binaries
evidence/WITNESS.122arms.{pristine,law}.txt   the landed-law battery
evidence/CENSUS.source.txt            the independent source census
```
