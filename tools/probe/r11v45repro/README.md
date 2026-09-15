# r11v45 — adversarial verification of § typeParamChainBorrow45

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's report
reproduces bit-for-bit from binaries this verifier built and froze itself. One
face of the law is measured WIDER THAN GOLDEN'S and moves two legal-SV arms
AWAY from golden; the fix is § typeParamChainBorrowShadow45v, one predicate in
`src/ParamEmit.cpp`, and it is corpus-neutral (`byteverify` fixed-vs-patched
reads **0 movers / 1608** on uhdm2rtlil).

---

## 1. What reproduced, from this verifier's own binaries

| thing | implementer | re-measured here |
|---|---|---|
| pristine binary at `2bbb8fae` from a fresh worktree | `d82adeb552c6e4f42b50568702897292` | SAME, and byte-identical to the main tree |
| patched binary | `55e4aca38634f547edf62d756883edb2` | SAME (independent configure + build) |
| blinded head md5 on all four C1 rows | `7df37b083205` | SAME (`sharedhead.sh`, `NAMES="dut child"`) |
| cmp lines, pristine | 47 / 47 / 47 / 47 / 120 | SAME (+ `type_param_unpacked_port` 208) |
| `type_param_packed_dim` after | 47 → **42** both modes | SAME |
| golden grid g1..g15 | `evidence/GRID.pristine.txt`, `GRID.patched.txt` | **byte-identical** to my re-runs |
| committed `HEAD.*.cmp` evidence | 6 files | **byte-identical** to my re-runs |
| u2r | `781/23/67` both modes | SAME, `ct8rows` PASS ×4 |
| byteverify u2r | 6 / 1608, all predicted | SAME six paths, same hashes |
| goldens | 23/0, `/bin/false` 0/23 | SAME |
| surelog | `474/9` + `469/8` | SAME, on pristine AND fixed |

## 1a. The five gates, on the FIXED binary `5d388643b8854aa2478f1ea0df27071c`

1. pristine from a fresh worktree = `d82adeb552c6e4f42b50568702897292`, byte-identical to the main tree; the implementer's patched tree rebuilt independently = `55e4aca38634f547edf62d756883edb2`, their md5 to the digit.
2. goldens `23 PASS / 0 FAIL`; `SLANG_UHDM=/bin/false` → `0 / 23`.
3. uhdm2rtlil `781 / 23 / 67` both modes; `ct8rows` PASS against the committed gate CSV, the committed default subset, and my own pristine CSVs (all four). All 1742 `cmds.txt` audited by binary PATH.
4. surelog `474 / 9` + `469 / 8`; vs my own pristine CSVs **2 differing rows, both the `SURELOG_FAIL` detail string that embeds the WORKDIR PATH** (`LowMemLib`, `LowMemPkg`, testflags); vs the committed baseline the same two plus `Earlgrey_0_1`/testflags' DUMP COLUMN going blank — **which reads identically on my PRISTINE sweep**, so it is the documented `uhdm-dump` timeout draw, not this patch. Status and dump histograms identical in every cell. All 1531 `cmds.txt` audited.
5. byteverify uhdm2rtlil **6 / 1608**, every one predicted by name; surelog **6 / 960**, every one attributed by a NULL SWEEP (`evidence/SURELOG.movers.txt`). `SELFCHECK` armed on every run (`1607/1608`, `959/960`).
   Canaries: `canaries.sh` uhdm2rtlil `ok=8 changed=0`; surelog vs my own pristine `ok=52 changed=0` (vs committed `ok=51 changed=1`, the Earlgrey dump column above). `ctcan2.sh` PASS on both corpora. `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0`. `results/*.csv` untouched; no fenced name appears outside `canaudit.sh`'s own list.

**The producer quotes are VERBATIM.** `CompileHelper.cpp` at the base carries
`typespec* tps = compileTypespec(...)` (`:3509`), `if (tps == nullptr) {` with
the "`parameter type A = B` where B is ANOTHER type parameter of the same list"
comment (`:3590`), the `for (UHDM::any* prev : *parameters)` chain walk, and
`p->Typespec()->Actual_typespec(tps ? tps : borrowed_tps); if (tps)
tps->VpiParent(p);` under the "A borrowed typespec still BELONGS to the
parameter it was declared on" comment. Nothing was paraphrased into existence.

**The share is proved by IDS, independently.** `vid45v.cpp` is written from
scratch (it covers interfaces, interface children, packages and class defns,
which `tpid45` does not) and interns pointers inside ONE database:

```
g1  GOLDEN   work@dut.id_t ts#1 2:31..2:42 ranges=1 | work@dut.resp_id_t ts#1   <- ONE OBJECT
g2  GOLDEN   a_t ts#1 | b_t ts#1 | c_t ts#1          <- depth 2 reaches the FIRST
v15 GOLDEN   t1..t4 all ts#1                          <- depth 4 likewise
g14 GOLDEN   a_t/b_t ts#1, c_t/d_t ts#6               <- the record is per-NAME
g11 GOLDEN   b_t ts#4 != a_t ts#1                     <- a WRITTEN dim does NOT borrow
```

## 2. THE FINDING — the gate is "no typedef of that name is visible", not
"the name denotes a type parameter"

The report's gate is *"`compileTypespec` returns null on exactly one shape: a
bare name denoting a TYPE PARAMETER"*. The producer's own gate is
`if (tps == nullptr)`, and `compileTypespec` binds a bare name to a **typedef**
whenever one is visible — so a type parameter that SHADOWS a typedef of the
same name never reaches the chain arm. Four golden arms, all legal SV, all
`slrc=0 ourrc=0`:

| arm | the shadowing typedef | golden's `b_t` actual | pristine | patched (unfixed) |
|---|---|---|---|---|
| `v17` | `$unit`, SAME width | the TYPEDEF's named clone `logic_typespec (a_t) 6:9..6:20` | the same object — **17 cmp lines** | `a_t`'s parameter object — **116** |
| `v20` | `$unit`, written AFTER the module | the typedef clone `9:9..9:20` | the same object — **17** | the parameter object — **116** |
| `v19` | WILDCARD package import | the package typedef `4:11..4:22` | the same object (name `pk::a_t`) — 126 | the parameter object — 120 |
| `v3` | `$unit`, DIFFERENT width `[7:0]` over `[1:0]` | the typedef clone `4:9..4:20` | a fresh mint — 76 | the parameter object — 116 |

`v17` and `v20` are the convicting pair: **pristine holds golden's own object
and misses only its `Typedef_alias` link (17 lines); the unfixed patch replaces
it with a different object (116 lines).** That is MOVED-WRONG on legal SV.
`v3` shows the choice is by NAME, not by structure — golden takes the 8-bit
typedef over the 2-bit parameter.

### The fix — § typeParamChainBorrowShadow45v

One predicate in the borrow guard: refuse the borrow when a `TypeAlias` of that
name has already been emitted from a scope a bare name can reach from a module
header (compilation unit, package, root). Refusing falls through to the
pre-existing `makeTypeParamDefaultTs`, so a refused site keeps EXACTLY the
database it had before this pass. Measured after the fix:

```
v17 116 -> 17    v20 116 -> 17    v19 120 -> 126   v3 116 -> 76     (all = pristine)
g1..g15          every cmp count = pristine = unfixed patch
v8  42           the corpus shape's gain KEPT
byteverify fixed vs patched:  0 movers / 1608   (u2r, SELFCHECK 1607/1608)
```

The shape is **not reachable from either corpus**: an independent scan
(`vscan45v.pl`, 15 651 files over `uhdm2rtlil/test`, `Surelog/tests` and
`Surelog/third_party/tests`) finds 55 chain sites and **zero** where a typedef
of the source name also exists. So the fix costs nothing today and makes the
landed law match the producer.

## 3. Second finding — the mover prediction's instrument under-scans

`scan45.pl` reports 10 sites; this verifier's scan reports **55**. The 45 extra
are CLASS parameter lists (`class c #(type REQ = ..., type RSP = REQ)`), which
`scan45.pl`'s `param type` key cannot see: `SimpleClass1`, `ExtendClassMember`,
`ClassExtendParam` in `Surelog/tests`, and the `Tnoc` / `Ibex` UVM libraries in
`third_party`. **The prediction still holds** — every one of those rows is
`SLANG_REJECT` (no database is written at all), and the law cannot fire in a
class scope anyway because `defTypeSyn` is read only from
`ModuleDeclarationSyntax::header->parameters`. Recorded because a prediction
instrument that cannot see a construct is not evidence that the construct is
absent.

## 4. The two refutations in the report — both CONFIRMED here

* **`port_chained_type_param` is not this face.** Its head is
  `struct_typespec 2:32..2:38` (golden) vs `logic_typespec 2:32..2:90` (ours)
  on `noc_req_t`, the FIRST parameter — an object-KIND difference on the
  anonymous packed-struct default. 120 cmp lines before and after.
* **`type_param_override_elem_sel` is not this face either.** Measured with
  `vid45v`: that design has NO chained default (`id_t`'s default is bare
  `logic`), its def-view type parameters are identical to golden's, and
  **golden shares ONE `packed_array_typespec` between `AllModules
  work@child.rt_t` and `TopModules work@dut.u.rt_t` (tp#6 / rt#5 / ts#4 on both
  listings)** while ours builds two (tp#6 vs tp#15). The failing element is the
  override's, visible in the DEFINITION listing only because of that share.
  **So TRIAGE2's C1 has ONE member, not two** — the master should re-rank the
  dispatch queue accordingly.

### 4a. What R1 actually needs, decoded here

`evidence/DEFELAB.sharing.txt`, by pointer identity on six arms plus the corpus
row: **an instance's `type_parameter` IS the definition's object unless THAT
parameter was OVERRIDDEN at the instantiation, in which case golden builds a
fresh one.** `v7`'s `u1.b_t` and `u2.b_t` are both the definition's `tp#5`
while each instance's overridden `a_t` is fresh; `g10`, `v13`, `v6` and `v1`
agree; and `type_param_override_elem_sel`'s `rt_t` (a localparam, never
overridden) is shared while its overridden `id_t` is fresh. We build two
objects in every case. That, and not a chain borrow, is why golden's
DEFINITION listing shows the instance's re-resolved element.

## 5. Direction, on a judge-faithful key

`dircen45v.py` keys on the TP facts with POINTER IDS *and SPANS* removed — no
generated `Compare` reads `VpiParent`, `VpiFile` or a source location, and
`VpiName` is read:

| row | differing facts pristine → fixed | verdict |
|---|---|---|
| `type_param_packed_dim` | **2 → 0** | TO-GOLDEN 2, AWAY 0 |
| `port_chained_type_param` | 4 → 4, no fact changed | judge-NEUTRAL (the span moved; the span is not judged) |
| `type_param_unpacked_port` | 0 → 0 | judge-NEUTRAL (only the removed re-parent moved bytes) |

`v11` (an unpacked-array port over the chained name) reads 76 → 116 cmp lines
on both the patched and the fixed binary. It is **not** an AWAY: the LHS head
object is unchanged (golden's port `array_typespec`), and what grew is OUR
side's print, because the element we now point at is golden's ranged
`logic_typespec 3:26..3:37` instead of an unranged mint. The residual failure
is the missing unpacked `array_typespec` — `type_param_unpacked_port`'s own
face, untouched here.

## 6. Boundary — every earlier pass's arms

`PROCESSED=136 == LISTED=136`, one mover, and that mover is the deliberate
POSITIVE CONTROL (`type_param_packed_dim/dut.sv` dropped into the arm set so a
green reading proves the gate can see). 135 arms from
`r11u{17,18,20,21,26,29,30,31,34,40,41,42,43}repro` are byte-identical on
pristine and fixed, with identical rc on both sides. The pass-31 grid
(`r11u31repro/g1..g12`) is byte-identical line for line on both binaries,
`golddump`/`ourdump`/`cmplines` included.

## 7. Residues carried forward (the implementer's, verified)

* **R0** — the borrow does not fire in a PACKAGE list (g8) or among module BODY
  localparams (g9); golden shares there (`ts#1` twice) and we mint. Confirmed
  by identity census; neither shape exists in either corpus.
* **R1** — `type_param_override_elem_sel` needs the DEF/ELAB SHARING change
  (§4 above), not this law.
* **R2** — golden's ELAB chained parameter does NOT follow the override
  (g10: `work@dut.u.b_t` keeps the default-chain object `4:26..4:31 ranges=-1`
  while `a_t` takes the override); ours points both at the override, on the
  PRISTINE binary too. Pre-existing, unchanged, judge-blind on that arm.
  Re-confirmed on three further arms here — `v6` (a hierarchy hop), `v7` (two
  instances with different overrides, golden's `u1.b_t` and `u2.b_t` both
  `ts#1`) and `v13` (an override with a package struct).
* **R3** — the borrowed object's KIND is still ours: g4/g5 now share exactly as
  golden does, but share a `logic_typespec` where golden has
  `struct_typespec` / `enum_typespec`.
* **R4** — `type_param_packed_dim`'s new head is golden's
  `sys_func_call ($bits)` over `ref_obj work@dut.resp_id_t` against our folded
  `constant UINT:2`. Quoted in
  `evidence/HEAD.fixed.type_param_packed_dim.default.cmp`.

## 8. New residues from this verification

* **R5v** — the shadow gate is asked of the typedefs ALREADY EMITTED, and a
  package typedef that is not imported here is counted too. Both imprecisions
  only ever REFUSE a borrow, i.e. fall back to the pre-existing path, so
  neither can move a database away from golden; a name-exact visibility test
  through slang's own lookup chain would be tighter.
* **R6v** — `v5` (a CLASS chain, `class c #(type a_t = int, type b_t = a_t)`)
  shows golden SHARING `ts#1` across the two class type parameters while we
  build two `int_typespec`s. 141 cmp lines, unchanged by this pass — the class
  half of this same law, and the reason the corpus's 45 class sites would move
  if it were ever implemented.

## 9. Files

| file | what |
|---|---|
| `v1..v20.sv` | the adversarial grid (chain depths × default/override × element kinds × dims × views × SHADOW) |
| `vid45v.cpp` | independent type-parameter identity census + SHAPE LISTER |
| `vscan45v.pl` | independent corpus scan, with a SHADOW column |
| `dircen45v.py` | judge-faithful direction census (ids and spans out of the key) |
| `gridrun.sh` | the arm runner (unchanged copy; `BIN` never defaulted, every rc recorded) |

Build the census with
`g++ -O2 -std=c++17 vid45v.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o vid45v`.
