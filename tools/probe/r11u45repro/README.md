# r11u45 — § typeParamChainBorrow45

**THE LAW.** A type parameter whose DECLARATION DEFAULT names an earlier type
parameter of the same list points at **that parameter's own typespec object**.
It does not mint one, and it does not re-parent what it borrows.

```
module dut #(
    parameter type id_t      = logic [1:0],
    parameter type resp_id_t = id_t            // <- borrows id_t's OBJECT
) ...
```

---

## 1. The head, re-measured at the base (2bbb8fae)

Four rows carry one head, `md5 7df37b083205` under `r11u44repro/sharedhead.sh`
(`NAMES="dut child"`), re-measured here on the base binary
(`md5 d82adeb552c6e4f42b50568702897292`) — the triage's md5 reproduces exactly:

| row | mode | cmp lines | heads | blinded md5 |
|---|---|---|---|---|
| `type_param_packed_dim` | default | 47 | 1 | `7df37b083205` |
| `type_param_packed_dim` | testflags | 47 | 1 | `7df37b083205` |
| `type_param_override_elem_sel` | default | 47 | 1 | `7df37b083205` |
| `type_param_override_elem_sel` | testflags | 47 | 1 | `7df37b083205` |
| `port_chained_type_param` | both | 120 | 1 | — (a `struct_typespec` head) |

The printed head is a whole `logic_typespec` carrying `vpiRange -> range
[UINT:1 : UINT:0]` with `RHS: <null>`
(`evidence/HEAD.pristine.type_param_packed_dim.default.cmp`).

**THE SLOT, NAMED FROM THE DATABASE, NOT FROM THE PRINTED TEXT.** Both
`SafeCompare` overloads print the same shape for two different causes (a null
`Ranges` VECTOR on the owner vs a null SINGULAR value) — `BaseClass.h:187` and
`:202`. `cmpid45` runs the OFFICIAL `design::Compare` and then asks which golden
`ref_typespec` targets `m_failedLhs` (`evidence/HEADSLOT.txt`):

```
type_param_packed_dim         failedLhs #86  logic_typespec 2:31..2:42
  ownerRef  ref_typespec (resp_id_t) full=work@dut.rt_t.resp_id_t
            refParent       packed_array_typespec 5:31..5:52
            refGrandparent  type_parameter (rt_t) 5:21..5:25
type_param_override_elem_sel  failedLhs #112 logic_typespec 32:17..32:28
  ownerRef  ref_typespec (id_t) full=work@child.rt_t.id_t
            refParent       packed_array_typespec 17:31..17:47
            refGrandparent  type_parameter (rt_t) 17:21..17:25
```

So in BOTH rows the failing slot is the **element ref of `rt_t`'s
`packed_array_typespec`** (§ typeParamNamedElemPackedDim31's object), and the
judged field is the element typespec's `Ranges`. The two rows reach that state
by DIFFERENT producers — see §5.

## 2. The producer, decoded, and the share proved by IDS

`CompileHelper::compileParameterDeclaration`'s `paTYPE` arm runs three steps in
order (Surelog `src/DesignCompile/CompileHelper.cpp`):

1. `:3508` `tps = compileTypespec(component, fC, Data_type, ..., Reduce::No, ...)`
2. `:3520-3586` the written-packed-dimension detector (pass 31's law)
3. `:3589-3612` **only if both produced nothing** — the chain resolve:

```
// `parameter type A = B` where B is ANOTHER type parameter of the same list.
// compileTypespec is called with no instance here, so its paExpression case
// cannot bindTypespec(B) and returns null ... B is already in `parameters` if
// it was declared earlier, so resolve the chain directly against that list.
for (UHDM::any* prev : *parameters) { ...
    borrowed_tps = ((type_parameter*)prev)->Typespec()->Actual_typespec(); }
```

and writes it at `:3621-3624`, with the no-re-parent rule spelled out in the
producer's own comment:

```
// A borrowed typespec still BELONGS to the parameter it was declared on —
// point at it without re-parenting, or the original loses its owner and the
// chain breaks in the other direction.
p->Typespec()->Actual_typespec(tps ? tps : borrowed_tps);
if (tps) tps->VpiParent(p);            // <- only the MINTED one
```

**THE GATE IS THAT `compileTypespec` RETURNED NULL**, and it returns null on
exactly one shape: a bare name denoting a TYPE PARAMETER. A typedef, a
package-qualified type, an enum, a struct or a keyword all compile, so none of
them borrows (grid arms g7, g11 below).

**THE SHARE IS PROVED BY POINTER IDENTITY**, never by dump text: `uhdm-dump`
elides a repeated subtree, so a share and a copy print alike. `tpid45` interns
each pointer in first-seen order inside ONE database and prints every type
parameter's actual (`evidence/IDCEN.rows.txt`, `type_param_packed_dim`):

```
GOLDEN   AllModules work@dut.id_t       ts#1 logic_typespec 2:31..2:42 ranges=1
         AllModules work@dut.resp_id_t  ts#1 logic_typespec 2:31..2:42 ranges=1   <- ONE OBJECT
PRISTINE AllModules work@dut.id_t       ts#1 logic_typespec 2:31..2:42 ranges=1
         AllModules work@dut.resp_id_t  ts#2 logic_typespec 3:32..3:36 ranges=-1  <- minted, NO Ranges
PATCHED  AllModules work@dut.id_t       ts#1 logic_typespec 2:31..2:42 ranges=1
         AllModules work@dut.resp_id_t  ts#1 logic_typespec 2:31..2:42 ranges=1   <- borrowed
```

`tslist45` (the SHAPE LISTER) names the reach of golden's one object: `RT #136
work@dut.id_t`, `RT #137 work@dut.resp_id_t`, `RT #139 work@dut.rt_t.resp_id_t`
and three port/var refs all resolve to `ts#82`.

## 3. The golden grid (15 arms, every arm's rc recorded)

`gridrun.sh` (pass 31's runner, unchanged) against Surelog v1.87; `BIN` is never
defaulted. `evidence/GRID.pristine.txt`, `evidence/GRID.patched.txt`;
the per-arm identity census is the table below.

| arm | shape | golden borrows? | pristine | patched | cmp lines pris→pat | rc |
|---|---|---|---|---|---|---|
| g1 | depth-1, `logic [1:0]` element | YES | mints | **borrows** | 0 → 0 | 0/0 |
| g2 | depth-2 chain `a_t→b_t→c_t` | YES, **both links reach the FIRST object** | mints ×2 | **borrows ×2** | 0 → 0 | 0/0 |
| g3 | source default is a TYPEDEF name | YES | already shares | unchanged | 17 → 17 | 0/0 |
| g4 | source default is an anon PACKED STRUCT | YES | mints | **borrows** (kind still wrong — C3) | 90 → 90 | 0/0 |
| g5 | source default is an anon ENUM | YES | mints | **borrows** (kind still wrong) | 82 → 82 | 0/0 |
| g6 | FORWARD reference (`b_t = a_t` before `a_t`) | — | **slang REJECTS** | rejects | — | 0/**3** |
| g7 | default names a TYPEDEF, no chain | no | — | unchanged | 17 → 17 | 0/0 |
| g8 | chain in a PACKAGE parameter list | YES | mints | **still mints** (boundary, R1) | 69 → 69 | 0/0 |
| g9 | chain among module BODY localparams | YES | mints | **still mints** (boundary, R1) | 0 → 0 | 0/0 |
| g10 | chain under an instantiation OVERRIDE | YES (def half) | mints | **borrows** | 0 → 0 | 0/0 |
| g11 | written dim on the chained name | NO (pass-31 wrapper) | wrapper | **wrapper kept** | 60 → 60 | 0/0 |
| g12 | `int` and `real` chained | YES | mints ×2 | **borrows ×2** | 0 → 0 | 0/0 |
| g13 | chain in an INTERFACE parameter list | — | mints | **borrows** (judge-blind, both equal) | 0 → 0 | 0/0 |
| g14 | TWO independent chains in one list | YES | mints one, shares other | **borrows, per-NAME** | 17 → 17 | 0/0 |
| g15 | SIGNED element | YES | mints | **borrows** | 0 → 0 | 0/0 |

No arm's cmp-line count moved in either direction. g6 is an ERROR-RECOVERY arm
(`ourrc=3`): it teaches nothing about golden and is recorded as such. g1, g2,
g9, g10, g12, g13, g15 are judge-BLIND on this face (already `cmplines=0` on the
pristine binary) — an arm agreeing is not an arm testing, so those arms are
scored by the IDENTITY census above, not by the cmp count.

## 4. Corpus reach, predicted BY NAME before the patched sweep

`scan45.pl` reads every `.sv/.v/.svh/.vh` in both corpora (15 654 files) and
reports each `[local]param type A = B` whose `B` is a bare identifier naming a
type parameter declared EARLIER in the same list. Ten sites
(`evidence/SCAN.predicted_movers.txt`); of those:

* `cva6_equiv/wrappers/*` (5 sites) — `cva6_equiv` has no `dut.sv` and no
  `project.f`, so `discover_uhdm2rtlil` never makes it a row: corpus-invisible.
* `Ariane2024` (1 site) — `SLANG_REJECT` / `NO_DATABASE` in the baseline, so it
  writes no `slang.uhdm` in either mode: no byte can move.
* **`port_chained_type_param`, `type_param_packed_dim`,
  `type_param_unpacked_port`** — the three predicted movers, both modes.

**PREDICTION: exactly 6 movers / 1608 on uhdm2rtlil, 0 / 956 on surelog.**
`byteverify.sh` measured exactly those six and no others, with the comparator's
own negative control armed (`SELFCHECK 1607/1608 flagged`).

## 5. Direction, and the printer trap

The whole-dump diff is POLLUTED whenever a pass changes SHARING: `uhdm-dump`
prints a shared object in full the first time and abbreviated afterwards, and
re-prints it once per referrer. Judging a share by dump text manufactures
AWAY-GOLDEN phantoms (`evidence/TOGOLD.dumptext.txt` shows exactly that:
`TO-GOLDEN 15 / AWAY-GOLDEN 11` where every "away" line is an indentation or
abbreviation flip on an object whose CONTENT now matches golden).

`shapecen45.py` reduces each database to a multiset of JUDGE-VISIBLE facts —
`RT <vpiFullName> <vpiName> -> <kind> <span> ranges=<n>` — with parenthood,
object counts and print order OUT of the key (no generated `Compare` reads
`VpiParent` and none counts objects). `evidence/SHAPECEN.movers.txt`:

| row | mode | differing facts before → after | TO-GOLDEN | AWAY-GOLDEN |
|---|---|---|---|---|
| `type_param_packed_dim` | both | **11 → 5** | 7 | 1 |
| `port_chained_type_param` | both | 18 → 18 | 5 | 5 |
| `type_param_unpacked_port` | both | 17 → 17 | 0 | 0 |

* `type_param_packed_dim` — the only real move. The single residual "+1" is
  `RT work@dut.resp_id_t -> logic_typespec 2:31..2:42`: we carry TWO type
  parameter objects (definition + elaborated) where golden shares ONE, so the
  fact is counted twice on our side. That is the campaign's standing
  "clone, never share" divergence, present before and after, and invisible to
  the judge (each listing is walked separately and each has exactly one).
* `port_chained_type_param` — LATERAL, not away. The count is flat; `req_t`,
  `in_i` and `out_o` move from our minted `logic_typespec 3:32..3:41` to our
  `noc_req_t` object `logic_typespec 2:32..2:90`. Golden's is a
  `struct_typespec 2:32..2:38` either way — the remaining error is `noc_req_t`'s
  OWN kind (the anonymous-packed-struct default, TRIAGE2's C3 neighbourhood),
  untouched here. The SHARE is now golden's: golden's `noc_req_t` and `req_t`
  are one object, and so are ours.
* `type_param_unpacked_port` — judge-neutral. The object was already shared
  (via the canonical-typedef fallback); what changed is that we no longer
  RE-PARENT the borrowed object, so the shared `pk::resp_t` struct keeps
  `type_parameter(base_resp_t)` instead of being stolen by `resp_t`. `VpiParent`
  is not judged.

**THE HEAD MOVED where the law reaches.** `type_param_packed_dim`, both modes:
47 lines → **42**, and the head OBJECT CHANGED — the typespec head is gone and
the new head is the def-view `sys_func_call ($bits)` inside
`DEPTH = (1 << $bits(resp_id_t))`
(`evidence/HEAD.patched.type_param_packed_dim.default.cmp`). The other two rows'
heads are byte-unchanged (47 and 120), as predicted.

## 6. Residues

**R0 — the def-view chain borrow does not fire outside a module/interface
HEADER.** Golden borrows for a chain declared in a PACKAGE (grid g8) and among
module BODY localparams (g9); we do not, because the def-view default syntax is
read only from `ModuleDeclarationSyntax::header->parameters` in
`ParamEmit.cpp`'s type-parameter loop. Same boundary
§ typeParamNamedElemPackedDim31's R1b already records for its wrapper; neither
arm moved in this pass, and neither is reachable from either corpus (the ten
scanned sites are all module headers).

**R1 — `type_param_override_elem_sel` is NOT a member of this law, and its head
is not what TRIAGE2's C1 prose says.** Measured here, not inherited: golden and
ours agree byte-for-byte on that design's def-view type parameters
(`id_t` unranged `15:31..15:36` on both sides — there is no chained default in
it at all). The failing slot (§1) is the ELEMENT of the DEF listing's `rt_t`
`packed_array_typespec`, and golden resolves it to the OVERRIDE's
`logic_typespec 32:17..32:28` because **golden SHARES one
`packed_array_typespec` between the module definition and its sole instance**
(`tpid45`: golden `AllModules work@child.rt_t` and
`TopModules work@dut.u.rt_t` are the same pointer), so
`elabTypeParameter_`'s in-place element re-resolve is visible in the DEFINITION
listing. Ours builds two objects, and the def one keeps the declaration
element. The fix is a def/elab SHARING change driven by a single instance — a
different, and much more dangerous, law than this one. Not attempted here.

**R2 — golden's ELAB chained parameter does NOT follow the override.** Grid g10
(`a_t = logic` overridden with `logic [3:0]`, `b_t = a_t`): golden's
`work@dut.u.a_t` actual is the override `10:16..10:27 ranges=1` while its
`work@dut.u.b_t` actual is still the DEFAULT-chain object
`4:26..4:31 ranges=-1`. Ours points both at the override. Pre-existing on both
binaries, judge-blind on this arm (`cmplines=0`), unchanged by this pass.

**R3 — the borrowed object's KIND is still ours.** Grid g4/g5: the chain now
shares correctly, but the object it shares is our `logic_typespec` spanning the
written `struct`/`enum` text where golden has a `struct_typespec` /
`enum_typespec`. That is the def-view anonymous-aggregate default
(TRIAGE2's C3 neighbourhood and `port_chained_type_param`'s standing head), and
it is the next thing in the way of those rows.

## 7. Files

| file | what |
|---|---|
| `tpid45.cpp` | type-parameter ACTUAL-TYPESPEC identity census (proves the share by pointer id) |
| `tslist45.cpp` | the SHAPE LISTER — every typespec and ref_typespec with id, kind, span, range count, parent |
| `cmpid45.cpp` | runs the official `design::Compare` and names the failing SLOT (owner ref, its parent and grandparent) |
| `shapecen45.py` | the judge-visible fact multiset; TO-GOLDEN / AWAY-GOLDEN without the printer's sharing artefacts |
| `togold45.sh` | the raw dump-text direction census (kept as the counter-example of §5) |
| `scan45.pl` | a-priori mover prediction over both corpora |
| `gridrun.sh`, `g1..g15.sv` | the golden grid |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the canary battery (carried forward) |

Build the C++ instruments with
`g++ -O2 -std=c++17 <f>.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o <f>`.

---

## 8. Gates (all five, on the DELIVERED binary)

Binaries frozen at immutable paths before every sweep; every `cmds.txt` audited
by binary PATH.

| gate | reading |
|---|---|
| 1 build | pristine from a fresh worktree at `2bbb8fae` = `d82adeb552c6e4f42b50568702897292`, **byte-identical to the main tree**. Patched = `55e4aca38634f547edf62d756883edb2` (reproducible: a second build of the same tree gives the same md5). |
| 2 goldens | `23 PASS / 0 FAIL`; negative control `SLANG_UHDM=/bin/false` → `0 PASS / 23 FAIL`. |
| 3 uhdm2rtlil | `781 / 23 / 67` in BOTH modes, unchanged. `ct8rows` PASS against the committed `gate_uhdm2rtlil.csv`, against the committed default subset of `golden_uhdm2rtlil.csv`, and against this pass's own pristine CSVs. |
| 4 surelog | `474 / 9` default + `469 / 8` testflags, unchanged. `ct8rows` vs this pass's pristine CSVs: **2 differing rows, both the `SURELOG_FAIL` detail string that embeds the WORKDIR PATH** (`LowMemLib`, `LowMemPkg`, testflags) — identical text on the pristine binary. Against the committed baseline the same two plus `Earlgrey_0_1`'s DUMP COLUMN going blank in both modes, which reads **identically on the pristine binary** (the documented `uhdm-dump` timeout draw; the DATABASE byte-compare is the pin and it holds). Status histograms identical in every cell. |
| 5 byteverify | uhdm2rtlil **6 movers / 1608**, every one PREDICTED BY NAME before the sweep (§4). surelog **3 movers / 960**: `MiniAmiq` ×2 and `SeqDriver`/default, all attributed to the family's pristine nondeterminism by a NULL SWEEP positive control (`evidence/NONDET.uvm.txt`). `SELFCHECK` armed on every run (`1607/1608`, `959/960`). |

**Comment-neutrality of the final edit.** The last edit to `ParamEmit.cpp` was
comment-only, yet it shifted 60 `.text` bytes (the build is otherwise
reproducible — a second build of the unchanged tree reproduces `55e4aca3…`), so
the gates were NOT assumed to carry: both corpora were re-swept with the
delivered binary. `byteverify` final-vs-pre-comment reads **0 movers / 1608** on
uhdm2rtlil and **957 / 960 identical** on surelog (the 3 exceptions are the same
nondeterministic UVM databases).

**Protected databases, byte-compared against this pass's own pristine workdirs**
— `SVSwitch 4842211c4030` both modes and `YosysVerx 6ccda350c24a` both modes
(the HARD pins), `InterfaceModPort 59a365f3ce2c` both modes,
`BlackParrotComplex` and `YosysOldOr` SAME both modes,
`Earlgrey_0_1` `8bdf25272e08` (default) / `59d0ee6d10c3` (testflags) SAME,
`CMP_EQUAL` in both modes. Every UVM-family row stays `CMP_EQUAL`
(`Scoreboard`/testflags stays its baseline `SLANG_REJECT`).
`canaries.sh` uhdm2rtlil `ok=8 changed=0`; surelog `ok=50 changed=2`, the two
being `Earlgrey_0_1`'s dump column above, identical on the pristine binary.
`ctcan2.sh` PASS on both corpora; `canaudit.sh` `audited=29 UNCOVERED=0
FENCE-BREACH=0`. `results/*.csv` untouched; the four fenced names appear
nowhere in the patch.

## 9. THE SCOREBOARD DID NOT MOVE — NO ROW CONVERTS

**Say it loudly: this pass converts ZERO rows.** `781/23/67` and `474/9 +
469/8` are exactly the base readings. What it buys is the head of
`type_param_packed_dim` in both modes — 47 cmp lines → **42**, with the head
OBJECT CHANGED from the borrowed typespec's `Ranges` to the def-view
`sys_func_call ($bits)` of `DEPTH = (1 << $bits(resp_id_t))`, which is the next
law in the way of that row (an unfolded def-view `$bits` call where we fold).
`port_chained_type_param` and `type_param_override_elem_sel` keep their heads at
120 and 47 — neither was ever this law's row (§5, R1).
