# r11u47 — § tpAnonAggParamTsNoStamp47

**THE LAW.** *A parameter declared with a TYPE PARAMETER whose default is an
ANONYMOUS aggregate carries that aggregate's typespec **UNNAMED** and takes **no
module or interface `vpiInstance`** — only a PACKAGE holder instances it. The
name (`it_t`) belongs to the `type_parameter`, never to its typespec.*

Base commit `88cd5538`. Target: TRIAGE2's **C3**
([tools/probe/r11u44repro/TRIAGE2.md:233](tools/probe/r11u44repro/TRIAGE2.md#L233)),
named field for field a landing earlier by
[tools/probe/r11u35repro/README.md:375](tools/probe/r11u35repro/README.md#L375) R1.

---

## 1. The head, re-measured at 88cd5538

`StructParamFieldRange` (surelog) and `cva6_struct_param_field` (uhdm2rtlil) are
the same design modulo the module name, and carried the **same 166-line head**
in both modes (`uhdm-cmp` writes it to STDERR; `grep -c '^LHS:'` = 1 per run).
Quoted from [evidence/HEAD.StructParamFieldRange.default.pristine.txt](evidence/HEAD.StructParamFieldRange.default.pristine.txt):

```
LHS (golden)                                     RHS (ours, pristine)
struct_typespec: , id:566, line:23:26,           struct_typespec: (it_t), id:331, line:23:26,
                        endln:23:32                                     endln:26:4
|vpiParent:                                      |vpiParent:
\_ref_typespec: (work@…​.I), id:565               \_ref_typespec: (work@…​.I), id:240
|vpiPacked:1                                     |vpiName:it_t
|vpiTypespecMember:                              |vpiInstance:
\_typespec_member: (x) …                         \_module_inst: work@StructParamFieldRange …
  \_ref_typespec: (work@…​.I.x)                   |vpiPacked:1
                                                 \_typespec_member: (x) …
                                                   \_ref_typespec: (work@…​.I.it_t.x)
```

`typespec::Compare` (the pinned generated body,
`~/git-repos/UHDM/build/generated/src/typespec.cpp`) walks `VpiName` first —
setting BOTH `m_failedLhs` and `m_failedRhs`, which is why the head renders both
objects in full — then `Typedef_alias`, then `Instance`. So `VpiName` is what
stopped the judge and the `vpiInstance` sat behind it. The `it_t` segment in the
member `ref_typespec` full names is the same fact one level down; no generated
`Compare` reads `VpiFullName`, so that part is dump-visible only.

**The object is NOT the type parameter's own typespec.** Ours already builds
that one unnamed (`struct_typespec: , 23:26..23:39`, dump line 736). The
offending object is the clone `makeParamTs` builds for the **localparam `I`**,
whose declared type names the type parameter.

---

## 2. The producer, decoded on both sides

**Golden.** A `struct_typespec` gets a `VpiName` in exactly one place —
`CompileHelper::compileTypeDef`, `ts->VpiName(name)`
(`~/git-repos/Surelog/src/DesignCompile/CompileHelper.cpp:1094`), i.e. a
TYPEDEF — and a `vpiInstance` in two: `UhdmWriter::writeDataTypes`
(`src/DesignCompile/UhdmWriter.cpp:799-802`,
`if (!tps->Instance()) tps->Instance((instance*)parent)`), which walks the
component's **DataType map** (again the typedefs), and `CompileHelper.cpp:1092`'s
package-only `Reduce::Yes` stamp. An ANONYMOUS aggregate written as a type
parameter's default is built by `compileTypespec`'s `paStruct_union` arm
(`src/DesignCompile/CompileType.cpp:1639-1662`) called straight from
`compileParameterDeclaration`'s `paTYPE` arm (`CompileHelper.cpp:3510`,
hard-coded `Reduce::No`, NULL instance). It is never a DataType, so neither
stamp reaches it — `populateCoreMembers(type, type, result)` also explains the
span: the `struct`/`union` keyword alone (`23:26..23:32`).

**Ours.** `UhdmExporter::makeParamTs` ([src/ParamEmit.cpp:21009](src/ParamEmit.cpp#L21009)), aggregate arm:
the param's declared type is a `TypeAliasType` (slang models `parameter type T`
as one), so `alias = "it_t"`, `memberScope = syntaxRefPrefix + "." + alias`, and
`its->VpiName(alias)` stamps the name. The module/interface `vpiInstance` is
added later, at the elab param site ([src/ParamEmit.cpp:22605](src/ParamEmit.cpp#L22605), the
struct/union block that ends in `its->Instance((UHDM::instance*)par)`).

---

## 3. The golden grid (12 arms, `arms/g1`…`arms/g12`, every arm's rc recorded)

`bash run.sh` (defaults `WD=arms`, `BIN=/tmp/r11u47_bin/pris.bin`,
`OUT=/tmp/r11u47_grid/res_pris`); it reads the arm list on **fd 3**, runs every
child with `</dev/null`, and asserts `LISTED == PROCESSED` (12/12 both runs).
`lister.py <golden> <ours>` is the SHAPE LISTER beside it: a depth-keyed
multiset census of every struct/union/enum typespec, keyed
`(kind, line..endln, VpiName, vpiInstance)`, counts kept, never deduplicated.

| arm | shape | slang rc | golden's aggregate | ours, pristine | ours, law |
|-----|-------|---------|--------------------|----------------|-----------|
| g1 | module body `localparam type it_t = struct packed`, + `localparam it_t I` | 0 | 13 × UNNAMED, no instance | 8 bare + **11 `it_t`** + **1 `it_t` + module_inst** | 20 bare, 0 instanced |
| g2 | same, `union packed` | 4 (`expression kind: Invalid`; database still written) | 11 × UNNAMED | 8 bare + 7 `it_t` + 1 instanced | **cmp EQUAL** |
| g3 | same, anonymous `enum` | 0 | UNNAMED, unlocated | 4 `it_t` + 1 instanced | unchanged (R1) |
| g4 | **CONTROL** — NAMED typedef bound: `localparam type it_t = named_t` | 0 | `named_t` (12) + `named_t`+inst (2); **no `it_t` object at all** | `it_t` (11) + `it_t`+inst (1) | **unchanged, 172-line head both runs** |
| g5 | ANSI parameter port list | 0 | 13 × UNNAMED | 11 `it_t` + 1 instanced | head unchanged (a `logic_typespec`, §5) |
| g6 | g5 + an instantiation OVERRIDE `#(.it_t(ov_t))` | 0 | 13 × UNNAMED | 11 `it_t` + 1 `module_inst: work@sub` | head unchanged |
| g7 | **PACKAGE** holder | 0 | 8 bare + **2 carrying `package pk`**, all ten UNNAMED | 7 `pk::it_t` + 2 `pk::it_t`+package | name dropped, **package instance kept** |
| g8 | a VARIABLE `it_t v`, no localparam of the type | 0 | 6 × UNNAMED | 9 × UNNAMED — already clean | unchanged |
| g9 | INTERFACE body | 0 | 13 × UNNAMED | 11 `it_t` + 1 `interface_inst` | **cmp EQUAL** |
| g10 | UNPACKED anonymous struct | 0 | 13 × UNNAMED | 8 `it_t` + 1 instanced | **cmp EQUAL** |
| g11 | a PORT typed by the parameter | 0 | 7 × UNNAMED | 5 × UNNAMED — already clean | unchanged |
| g12 | CHAINED `parameter type b_t = a_t` | 0 | 14 × UNNAMED | 11 `b_t` + 1 instanced | head unchanged |

Full before/after listings: [evidence/GRID.shapes.txt](evidence/GRID.shapes.txt).
cmp line counts, pristine → law: g1 166→54, g2 166→**0**, g3 36→36, **g4
172→172**, g5 90→90, g6 402→402, g7 163→163, g8 453→453, g9 166→**0**, g10
162→**0**, g11 86→86, g12 90→90.

**What the grid settles.**
* The holder does not matter for the NAME: module, interface, ANSI port list,
  package, override and chain all leave it UNNAMED. Only the PACKAGE holder
  instances it, and that is `makeParamTs`' own `aliasPkg` link, already correct.
* g8 and g11 prove the producer is the PARAMETER path alone — a variable or a
  port typed by the same type parameter is already unnamed in our emitter.
* **g4 is the caution the brief asked for, answered by measurement.** A NAMED
  typedef bound to a type parameter must keep a name — and the name golden gives
  it is the TYPEDEF's (`named_t`), not the parameter's. The gate below decides
  from the OWNER of the aggregate's own declaration, so g4 is not touched: its
  head is byte-identical before and after. (Our naming it `it_t` there is a
  SEPARATE residue, R2.)
* **The verifier's census question about `port_chained_type_param` is answered:
  NO, one producer does NOT serve both forms.** g5/g11/g12 show the ANSI
  parameter-port-list form fails EARLIER and elsewhere — golden builds a
  `struct_typespec` where we build a bare `logic_typespec`
  (`makeTypeParamDefaultTs`'s "anonymous aggregate default is left on the
  logic_typespec fallback", [src/TypeEmit.cpp:6172](src/TypeEmit.cpp#L6172)). That is a different site
  and a different law. **This law is worth 4 tests, not 5**;
  `port_chained_type_param` is NOT claimed and did not move (byte-identical).

---

## 4. The change

[src/ParamEmit.cpp:21661](src/ParamEmit.cpp#L21661), `makeParamTs`' aggregate arm — the
gate, asked of the OWNER:

```cpp
const bool tpAnon47 =
    ps.getDeclaredType() &&
    ps.getDeclaredType()->getType().kind == SymbolKind::TypeAlias &&
    typeParamOfAlias(ps.getDeclaredType()->getType().as<TypeAliasType>()) &&
    isTypeParamAnonAggDefault35(*aggScope47);
```

`typeParamOfAlias` ([src/EmitHelpers.h:644](src/EmitHelpers.h#L644)) answers "this alias IS a type
parameter" (its syntax is a `TypeAssignment`, never a `TypedefDeclaration`);
`isTypeParamAnonAggDefault35` ([src/TypeEmit.cpp:12037](src/TypeEmit.cpp#L12037), pass 35's
own predicate, reused unchanged) answers "this aggregate is written inside a
`TypeParameterDeclaration`". Both are structural; neither reads a name string.
When the gate fires: `alias` is cleared (no `VpiName` call at all — the field is
never written, so no discarded string enters the serializer's table),
`memberScope` becomes the calling context's `syntaxRefPrefix` with the
parameter-name segment dropped, and the object is recorded in
`tpAnonAggParamTs47`, which the elab param site ([src/ParamEmit.cpp:22597](src/ParamEmit.cpp#L22597)) tests
before stamping the module/interface instance. `aliasPkg` is untouched, so g7's package
instance survives.

Member ref full names follow for free and land exactly on golden's strings
(g1, measured both sides): golden `work@dut.I.x` / `work@dut.x`, ours pristine
`work@dut.I.it_t.x` / `work@dut.it_t.x`, ours law `work@dut.I.x` / `work@dut.x`.

**The span is NOT changed.** `typespec::Compare` never reads line/column, and
our two span families (`23:26..23:39` on the type parameter's own object,
`23:26..26:4` on the param clone) come from two different sites, so it does not
ride free here. It is R3.

---

## 5. Rows: what moved, and the prediction it was scored against

**PREDICTED LOUDLY, BEFORE THE SWEEP: 4 tests / 8 rows MOVE, 0 CONVERT.**

The two head tests carry residues beyond the head, so the arithmetic predicted
ADVANCE, not conversion, for every one of them.

| row | pristine | law | verdict |
|-----|----------|-----|---------|
| `StructParamFieldRange` default | CMP_NOTEQUAL, head 166 lines, `struct_typespec` | CMP_NOTEQUAL, head **74** lines, `constant` (the member-bound FOLD) | **ADVANCE** |
| `StructParamFieldRange` testflags | same 166 | same 74 | **ADVANCE** |
| `cva6_struct_param_field` default | CMP_NOTEQUAL, head 166 | CMP_NOTEQUAL, head **74** | **ADVANCE** |
| `cva6_struct_param_field` testflags | CMP_NOTEQUAL, head 166 | CMP_NOTEQUAL, head **74** | **ADVANCE** |
| `StructParamFuncBodyFieldCompare` ×2 | head 36 (a constant) | head 36, unchanged | behind-head residue cleared |
| `StructParamPatternInitCast` ×2 | head 15 | head 15, unchanged | behind-head residue cleared |

The C3 head is GONE on both witness tests. What stands in its place is the
member-bound FOLD — golden's `constant INT:63` against our
`op11(hier_path Cfg.XLEN, 1)` — i.e. exactly the half
[tools/probe/r11u35repro/README.md:361](tools/probe/r11u35repro/README.md#L361)
R0 gates on the typespec-POOL COPY COUNT, which the brief forbade chasing here.

**The 60-line `it_t` footprint the triage measured is now 15 lines in each of
the three surelog designs — a constant −45, exactly as a shared law predicts**
(`resid.sh`, order-blind path-normalised whole-dump diff,
[evidence/RESIDUE.wholedump.txt](evidence/RESIDUE.wholedump.txt)):

```
PRIS StructParamFieldRange            total=445  it_t-lines=60
PRIS StructParamFuncBodyFieldCompare  total=629  it_t-lines=60
PRIS StructParamPatternInitCast       total=667  it_t-lines=60
LAW  StructParamFieldRange            total=388  it_t-lines=15
LAW  StructParamFuncBodyFieldCompare  total=572  it_t-lines=15
LAW  StructParamPatternInitCast       total=630  it_t-lines=15
```

The 15 that remain are the `type_parameter`'s OWN name (correct in both) and the
`work@…​.it_t.XLEN` leaf names inside the type parameter's own member ranges (R3).
`GenForStructParamBound`, CMP_EQUAL with `dump=differ`, is unchanged at 448 —
the residue instrument is not measuring noise.

---

## 6. Census: the mover set predicted BY NAME, a priori, from PRISTINE databases

`census_db.sh <pristine-sweep-workdir>` flags a database that holds a
struct/union typespec whose `VpiName` is ALSO a `type_parameter` name in that
same database — the object this law un-names.

**POSITIVE CONTROL** (`arms/g1`, `g4`, `g8`, `g11` pristine databases): the
census flags `g1 it_t=12` and `g4 it_t=12` and is silent on `g8` and `g11`. It
therefore sees the construct, and it OVER-predicts by design — it cannot read
the owner, so it also flags the named-typedef shape (g4) that the gate refuses.
Movers must be a SUBSET of it.

* **uhdm2rtlil** ([evidence/CENSUS.uhdm2rtlil.txt](evidence/CENSUS.uhdm2rtlil.txt)), all 1608 databases:
  `cva6_struct_param_field` (`it_t=12`, both modes) and `struct_member_cfg_width`
  (`fu_data_t=13`, both modes). The second is the g4 shape — `fu_data_t` is a
  NAMED typedef in `top` passed as an override (`dut.sv:29-32`) — so it was
  predicted **not** to move, and it did not.
* **surelog** ([evidence/CENSUS.surelog.txt](evidence/CENSUS.surelog.txt)), all 960 databases:
  `StructParamFieldRange`, `StructParamFuncBodyFieldCompare`,
  `StructParamPatternInitCast`, both modes — 6 rows, `it_t=12` each.
  Two cells came back `DUMP-FAIL`: `Earlgrey_0_1` in both modes (uhdm-dump
  timeout). **A census zero needs a positive control and a census hole needs
  closing**: re-run at a 3000 s timeout, both Earlgrey databases dump clean and
  flag NOTHING ([evidence/CENSUS.Earlgrey.txt](evidence/CENSUS.Earlgrey.txt)).
* `census_src.sh` is the independent source-level cross-check (every file in
  either corpus writing `[local]param type N = struct|union`); its positive
  control is the grid. It names the same tests plus `packed_array_struct`,
  `port_chained_type_param` (both declare only PORTS of the type — the g11 shape)
  and `Ariane2024` (SLANG_REJECT / NO_DATABASE, non-comparable). All three were
  predicted not to move; all three are byte-identical.

**PREDICTED MOVER SET: `StructParamFieldRange`, `StructParamFuncBodyFieldCompare`,
`StructParamPatternInitCast`, `cva6_struct_param_field` — 4 tests, 8 databases.**

---

## 7. Gates (all green)

1. **Build.** Pristine built in this worktree is byte-identical to the main tree
   at `88cd5538`: md5 `6462baa4f897348bbd1dd5cd484dfcb2`. Law binary md5
   `bb429bfd6362775094b3e74909d02667`. Both frozen `chmod 555` before any sweep;
   every `cmds.txt` in both sweeps audited by binary PATH — one path each,
   `.../pris.bin` and `.../law.bin`, no leakage to the main-tree binary.
2. **Goldens.** `SLANG_UHDM=<law> tests/check_goldens.sh` → PASS 23 / FAIL 0.
   Negative control `SLANG_UHDM=/bin/false` → PASS 0 / FAIL 23.
3. **uhdm2rtlil, both modes.** `ct8rows.sh` vs the committed
   `results/gate_uhdm2rtlil.csv` and vs this pass's own pristine sweep:
   `PASS: every row byte-identical` for testflags AND default. No row moved.
4. **surelog, both modes.** `474 CMP_EQUAL / 9 CMP_NOTEQUAL` (default) and
   `469 / 8` (testflags) — identical in the pristine sweep, in the law sweep and
   in the committed baseline. `ct8rows.sh` vs the committed baseline reports
   THREE differing rows, quoted in full, and the pristine sweep is the control
   that separates them:
   * `LowMemLib,testflags` and `LowMemPkg,testflags` — `SURELOG_FAIL` whose
     detail text embeds the workdir path. They differ in the PRISTINE sweep too.
   * `Earlgrey_0_1,testflags,CMP_EQUAL,,,differ` → `CMP_EQUAL,,,` — the DUMP
     COLUMN read blank (the documented uhdm-dump timeout draw). **STATUS stayed
     CMP_EQUAL, and the DATABASE is the pin:** `59d0ee6d10c3` testflags and
     `8bdf25272e08` default, byte-identical under BOTH binaries. Identical
     databases cannot differ because of the law.
5. **Byte verification, SELFCHECK on, against this pass's OWN pristine workdirs.**
   * uhdm2rtlil: `PATH_SETS_IDENTICAL (1608)`, **MOVERS 2 / 1608** —
     `default/cva6_struct_param_field`, `testflags/cva6_struct_param_field`.
     Both PREDICTED. Selfcheck 1607/1608 flagged.
   * surelog: `PATH_SETS_IDENTICAL (960)`, **MOVERS 10 / 960** — the 6 PREDICTED
     `StructParam*` databases, plus `MiniAmiq` and `SeqDriver` in both modes.
     Selfcheck 959/960 flagged.
   * **The 4 unpredicted movers are attributed, not excused.** A SECOND run of
     the PRISTINE binary on those two tests produces four more distinct hashes
     (`MiniAmiq/default` `0a5d7de389b4` → `304cd11b6d34`; `SeqDriver/default`
     `f81f8fd52d72` → `2fb39f8b4130`; `MiniAmiq/testflags` `27419f6011b4` →
     `c052aa13e5d3`; `SeqDriver/testflags` `67091facb810` → `080e164001ea`), so
     they are byte-unstable per INVOCATION, not per binary. The order-blind
     path-normalised whole-dump diff names the class: pristine-run-1 vs law is
     **4 lines** (`|UINT:0` / `|vpiDecompile:0` against a line number), and
     pristine-run-1 vs pristine-run-2 is **the same 4 lines** — the documented
     0-or-4-line line-number class of the UVM family. Size deltas 0 / −1 / +45 /
     −4, none a 4096 page boundary. All four rows stayed CMP_EQUAL.
   * **MOVED-WRONG 0 / AWAY 0**: every mover is a predicted row that moved
     TOWARD golden (head 166 → 74, residue 60 → 15), or a coin.
6. **Canaries.** `canaries.sh` surelog `ok=51 changed=1` — the one CHANGED is the
   Earlgrey dump column of gate 4, whose database is the byte pin; the pristine
   control reads `ok=52 changed=0`, so it is a draw of the same coin.
   `canaries.sh` u2r `ok=8 changed=0`. `ctcan2.sh` PASS on both corpora
   (`EXPECT_UNKNOWN=1` / `=6`). Protected databases by md5, PRISTINE = LAW in
   every case: SVSwitch `4842211c4030` (hard pin, both modes), YosysVerx
   `6ccda350c24a` (hard pin, both modes), InterfaceModPort `59a365f3ce2c`,
   BlackParrotComplex `e3e354129d5a` / `73a10e8217e5`, YosysOldOr `d68e0796d62c`.
   `canaudit.sh canaries.sh ctcan2.sh` → `audited=29 UNCOVERED=0 FENCE-BREACH=0`.
7. **UVM family + Earlgrey heads.** `rowheads.sh` on the law sweep: SeqDriver,
   SimpleUVM, Scoreboard, MiniAmiq, BuildUVMPkg, Earlgrey_0_1 all `cmp rc=0`,
   0 heads, both modes; Rggen/default 64 lines / 1 head. The pristine sweep
   reads exactly the same. (SKIP-NOFILE on Scoreboard/testflags and
   Rggen/testflags is expected.)
8. `results/*.csv` untouched (`git diff --stat -- results/` empty). No
   `git stash`, no writes outside the worktree and `/tmp/r11u47_*`.

---

## 8. Residues and R0

* **R0 — THE NEXT HEAD, and it is the one the brief fenced: the MEMBER-BOUND
  FOLD, gated by the typespec-POOL COPY COUNT.** Both witness rows' new head is
  golden's `constant INT:63` against our `op11(hier_path Cfg.XLEN, 1)` at the
  member range bound (74 lines, both corpora, both modes,
  [evidence/HEAD.StructParamFieldRange.default.law.txt](evidence/HEAD.StructParamFieldRange.default.law.txt)).
  Golden folds SOME copies of the member's `logic_typespec` and keeps others;
  ours carries a different number of copies, so no fold can be AIMED until the
  count closes. That count is
  [tools/probe/r11u35repro/README.md:361](tools/probe/r11u35repro/README.md#L361)
  R0/R4's residue, unchanged by this pass: for `StructParamFieldRange` golden
  holds 18 copies of the anonymous `struct_typespec` and we now hold 20 (8 at
  the type parameter's span + 12 at the param clone's), all of them UNNAMED and
  UNINSTANCED after this landing. **It is one census of the copy sets away, and
  it now carries the whole remaining head on 4 rows.**
* **R1 — the same law for an anonymous ENUM default.** Grid g3: golden's enum
  typespec for `localparam type it_t = enum logic [1:0] {...}` is UNNAMED and
  UNLOCATED; ours is `enum_typespec (it_t) 2:19..2:67` with a `module_inst`,
  minted by `makeParamTs`' SEPARATE enum arm ([src/ParamEmit.cpp:21602](src/ParamEmit.cpp#L21602),
  `buildEnumTs` + `ecl->VpiName(aliasNm)`), which carries its own landed laws about named
  enum clones. g3's head is elsewhere (an `enum_const` value/encoding), no
  corpus row is behind it, and widening this pass into that arm would have been
  an unmeasured change — so it was left standing, with the arm committed.
* **R2 — a NAMED typedef bound to a type parameter takes the PARAMETER's name
  instead of the TYPEDEF's.** Grid g4: golden names the clone `named_t` and
  instances it; we name it `it_t`. 172-line head, unchanged by this pass by
  construction (the gate refuses it). The corpus shape is
  `struct_member_cfg_width`'s `fu_data_t` override (u2r), CMP_NOTEQUAL with its
  own head.
* **R3 — the anonymous aggregate's SPAN.** Golden: the `struct`/`union` keyword
  alone (`23:26..23:32`). Ours: `23:26..23:39` on the type parameter's own
  object and `23:26..26:4` (to the closing brace) on the param clone — two
  different sites. `typespec::Compare` never reads line/column, so nothing is
  judged here; it is dump-column only, and it did not ride free on this site.

---

## 9. Files

```
run.sh          the golden grid runner (fd-3 list, </dev/null children,
                LISTED==PROCESSED assertion); WD/BIN/OUT all overridable
arms/g1..g12    the 12 grid arms, one directory each
lister.py       SHAPE LISTER — depth-keyed multiset census of every
                struct/union/enum typespec (kind, span, VpiName, vpiInstance)
census_db.sh    the a-priori mover census, run on PRISTINE databases
census_src.sh   the independent source-level cross-check
headcmp.sh      per-row cmp line count + head object over a sweep workdir
resid.sh        order-blind path-normalised whole-dump residue + `it_t` count
canaries.sh ctcan2.sh canaudit.sh   the battery, run from this directory
evidence/       heads before/after (both corpora), the grid shapes, the three
                censuses, the residue table, the per-row head tables
```
