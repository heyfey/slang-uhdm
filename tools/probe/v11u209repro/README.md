# v11u209: adversarial verification of r11u209 (pass 209, the module/type ground)

**Verdict: ACCEPT-WITH-FIX.** The delivered patch reproduces every headline number bit for bit, but fresh cases found
three breaks: two in § modportOpOrphanReparent209 and one in § ifacePortDeclTsAtPortDecl205. In each, the pristine
binary matched golden and the patch moved records away from it on legal SV. Three refinements fix them, each behind its
own switch. `R11V209_OFF=1` drops all three and gives the delivered bytes; `R11U209_OFF=1` still gives pristine bytes.
None of the three fires on any corpus row or probe case. The verified sweep therefore writes the delivered law's bytes
on every corpus, probe and downstream-lane database, except two known storage-order coins, and its three csvs carry the
same verdicts. The verified patch is `/tmp/r11u209.verified.patch`.

**Base** `6e39a3fc`. Worktrees: `/tmp/wt_v11u209pris` (pristine) and `/tmp/wt_v11u209` (the patch plus this
verification). Scratch is `/tmp/v11u209_*`. A probe case is called a case throughout. The four slang-fenced tests are
never named here. Every driver reads them from the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh` and fails
closed.

## 1. Binaries (built here, `-j 2`, frozen `chmod 555` in `/tmp/v11u209_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `b81dbfaca6fdd916dbc1aa17af48e42e` | `6e39a3fc`, byte-identical to the main tree's `build/slang-uhdm` |
| `law.bin` | `e207001d247c7a03b3b8c25422989ea9` | `6e39a3fc` + `/tmp/r11u209.patch` (md5 `fe80018d…`, applies clean), byte-identical to r11u209's `law8.bin` |
| `fix4.bin` | `35026d29ad22004627cf2490fdafb760` | + the three refinements below (the verified patch's source) |

Every `slang:` line of every `cmds.txt` names that sweep's binary by path: 3273 per sweep, no other binary. The
downstream lane records no command, so its binary is shown by bytes instead. In the lane, 1 database moves against
pristine (TypedefPackedDimensions, as predicted) and 0 move against the law sweep.

## 2. The headline numbers, reproduced (sweeps `tests/sweep.sh --jobs 3`, same-length workdirs)

| stage | pristine `/tmp/v11u209_sP` | delivered `/tmp/v11u209_sQ` | verified `/tmp/v11u209_sF` |
|---|---|---|---|
| probe | 3363 + 724, 0/0/0 | **3396 + 691: 33 conversions, 4 changes (all shorter), 0 regressions** | identical csv |
| surelog | 0/0/0 | **3 conversions, 12 changes, 0 regressions** | identical verdicts (only the LowMem detail text differs, an environment effect) |
| uhdm2rtlil | 0/0/0 | 0/0/0 | identical csv |
| downstream | 803 / 66 / 2 / 0 | 803 / 66 / 2 / 0, verdicts identical | verdicts identical |

The sweep's `law_index --check` reads STALE at the base worktree, which is pre-existing. It reads current on the
delivered patch, and on the verified patch after the regeneration included in it.

The converted rows, quoted from the verified sweep's csv:

    HierPathTypespec,testflags,CMP_EQUAL,,,equal
    InterfaceStructMemberPort,default,CMP_EQUAL,,,equal
    InterfaceStructMemberPort,testflags,CMP_EQUAL,,,equal

The changes are exactly the implementer's:

| row-mode | before | after |
|---|---|---|
| Earlgrey_0_1 d/t | `fullname(76)` | `endcol(45)` |
| Rggen d | `defname(142)` | `file(4)` |
| BuildUVMPkg d/t | `line(11)` | `line(74)` |
| MiniAmiq d/t | `file(71)` | `file(78)` |
| SeqDriver d/t | `fullname(65)` | `fullname(64)` |
| SimpleUVM d/t | `fullname(95)` | `fullname(259)` |
| Scoreboard d | `fullname(103)` | `fullname(211)` |

- **Probe conversions:** the 33 are the 20 r11u93/r11v93/r11u90 interface-port cases, 12 r10uvm139/145/148 cases and
  their verifiers' cases, and r10earl53 v5.
- **Probe changes:** r10earl53 v2 and three r11u93/r11v93 cases (`pb10`, `pb19`, `v15`), each with a smaller count.

**Movers, predicted by name.** The firing census (`drivers/census.sh`, frozen as
`evidence/movers/predicted_fix4.txt`, md5 `2eab14f0…`) is byte-identical to the implementer's frozen prediction.

- **Corpus:** byteverify (`SELFCHECK=1`, 959/960 and 1607/1608 flagged, path sets identical) finds 22 movers, exactly the
  predicted 22.
- **Probe:** 37 movers. Probe databases carry the worktree path, so `drivers/pmov.sh` compares path-normalised
  dumps. All 37 were predicted. Four predicted cases do not move, the same four the implementer named.

**Away-moved census** (map 12's method, `drivers/away.py`, all 59 movers): **LOST 0 on every mover.**

- GAINED: Earlgrey 3411 per mode, Rggen 138, SeqDriver 109, MiniAmiq 92, SimpleUVM 89, BuildUVMPkg 73, Scoreboard 72,
  InterfaceStructMemberPort 6 per mode, HierPathTypespec t 1, and each probe mover 2 to 34.
- Positive control: the same census run with the two sweeps swapped reads 144 lost on InterfaceStructMemberPort + Rggen
  (`evidence/movers/away_positive_control.txt`).

**UVM order-blind distance** (`drivers/uvmdist.sh`, per mode):

| row | pristine | delivered |
|---|---|---|
| MiniAmiq | 6634 | 6608 |
| SeqDriver | 5194 | 5163 |
| SimpleUVM | 2074 | 2051 |
| Scoreboard | 1526 | 1508 |
| BuildUVMPkg | 776 | 757 (the implementer did not report this row) |

The verified sweep reads the same as the delivered one.

**First records** (`evidence/uvm/first_records_default.txt`):

- The pristine first records are unchanged: MiniAmiq's `uvm_severity` file, SimpleUVM's and Scoreboard's
  `UVM_MACRO_NUMFLAGS` ref_typespec, SeqDriver's `uvm_event_pool` raw full name.
- BuildUVMPkg's `uvm_action` record `#3245` has the same content in both databases (golden `9704:72`, ours `8075:9`).
  The comparator stops reporting it only because its mode-4 span excuse (`PairCtx`, uhdm-strictcmp.cpp) pairs spans
  over the whole aligned walk. The longer walk now pairs golden's `uvm_action` copies with our span as well, so the
  record is excused, not fixed. It remains in residue 5.

**Canaries:**

- `canaries.sh`: surelog ok=43 changed=9 (the nine predicted movers); uhdm2rtlil ok=16 changed=0.
- `ctcan2.sh`: PASS for surelog (`EXPECT_UNKNOWN=1`) and uhdm2rtlil (`EXPECT_UNKNOWN=6`), on both the delivered and the
  verified sweep.

**Determinism** (`drivers/det.sh`, three concurrent runs per binary per row-mode; `evidence/determinism/`):

- Earlgrey_0_1, SeqDriver, SimpleUVM and BuildUVMPkg give one hash per mode for all three binaries.
- MiniAmiq draws `f334cf…` / `d80c40…` with the law binaries. Their dumps are identical even in order, so this is the
  known storage coin; the pristine binary draws `dd9e7e…`.
- Scoreboard default draws two or three hashes with every binary: 94 ordered dump lines, 0 sorted (the known svunit
  coin).
- No new coin appears.

**Twin determinism** (§ twinElemOnlyNoRange209, `evidence/twin/rebuild_check.txt`). With the law on, six different
builds write one database each on `r11u209repro/cases/TW/qr01` and `r11u196repro/cases/V191/qr01`. With
`R11U209_OFF=1`, four builds write four different databases.

**OFF control:** `R11U209_OFF=1` on the verified binary gives pristine bytes on all 4087 probe databases (0 differ).
Positive control: one case run with the law on reads exactly 1 differing database.

## 3. The breaks (pristine right, patch wrong, legal SV)

All the cases below are in `cases/IM` and `cases/PD`. Each case's first line names its law.

**B1: § modportOpOrphanReparent209 fires on a CONCATENATION.**

- Cases: IM v02 `.a({sub.req.wen, sub.trn, sub.req.wdt[5:0]})`, and v21 with the concatenation alone.
- Golden keeps the concatenation of hier_paths and makes no orphan. The Surelog source shows why: CompileExpression's
  `paConcatenation` branch compiles operand by operand with no member reduction, so `needsUnreduced` never sees a
  struct_net.
- Golden's `struct_net req` stays `work@top.w.sub.sub.req.req` and `trn` keeps its name, as in pristine. The law
  cleared both names and their ref_typespecs.
- Effect: 4 records lost in both views; the strict first field `fullname` is the same before and after.
- Downstream: IDENTICAL in all three binaries.

**B2: § modportOpOrphanReparent209 overrides a LATER bare member connection.**

- Cases: IM v19 `.b(sub.req.wen & sub.trn), .c(sub.trn)`, and v22 with `.b(sub.trn)` in a later instance.
- Surelog's port-actual loop runs the connections in source order. The later actual reduces to the view object itself
  and re-parents it at its own port (golden `work@top.w.u.c.trn`), which § ifaceSigConnNamedByChildPort155 already
  writes.
- The law's post-pass re-parents the object at the orphan afterwards. Effect: 2 records lost in both views.
- The orphan does win when it is the last writer: v20 and v25 put the bare connection first, and both convert.

**B3: § ifacePortDeclTsAtPortDecl205 relocates a shared NAMED typedef listing.**

- Case: PD v01, `output [7:0] o; my_t o;` with a `$unit` `typedef logic [7:0] my_t`.
- The port's typespec is `my_t`'s listing object, so the law moves `my_t` (and every reader of it, the top module's
  `my_t z` included) from `2:9-20` to the interface's `4:10-15`. Golden keeps `my_t` at `2:9` and gives the port its
  own unnamed typespec.
- The case is stage-1 (judge-unequal) at the base and after the patch, so no gate sees the move. It is a dump-level
  move away from golden on every reader of the typedef.

**Fixes** (each under its own switch; `R11V209_OFF` drops all three; each switch also stops under `R11U209_OFF`):

| law | switch | site | rule |
|---|---|---|---|
| § mpOrphanSkipConcat209v | `R11V209_MPCONCAT_OFF` | UhdmExporter, inside § modportOpOrphanReparent209 | a triggering connection whose operation is a concatenation, multiple concatenation, assignment pattern or streaming operation is left alone |
| § mpOrphanLaterWriter209v | `R11V209_MPLATER_OFF` | ModuleEmit § ifaceSigConnNamedByChildPort155 notes each logic_net / logic_var view object's last bare or one-select writer position (a record only, no byte moves); UhdmExporter § modportOpOrphanReparent209 skips a view object whose writer comes after the operation | covers IM v19 and v22. A struct_net is not noted: a later whole-struct connection `.r(sub.req)` recompiles unreduced and golden's orphan stays (IM v28, where the law was right and stays right) |
| § pdTsNotTypedefListing209v | `R11V209_PDNAMED_OFF` | ModuleEmit § ifacePortDeclTsAtPortDecl205 | a port typespec with a name (a typedef's listing) is not relocated; golden's unnamed port typespec is a stage-1 face this law does not model |

`R11U209_TRACE` also traces all three.

**Prediction.** The census of the verified binary shows the three refinements firing on no corpus row and no probe case,
so the verified sweep was predicted byte-identical to the delivered one. It was: 0 movers, apart from the MiniAmiq
default and Scoreboard default coins, whose dumps are identical even in order.

## 4. The fresh grid (`cases/`, 102 cases, 204 case-views; `evidence/grid/grid_pris_law_fix.tsv`)

The cases are judged by uhdm-cmp and uhdm-strictcmp against the v1.87 pin, in both views.

| verdict, pristine -> verified | case-views |
|---|---|
| a STRICT_NOTEQUAL cell -> EQUAL | **90** (38 fullname, 34 col, 6 type, 6 endcol, 4 defname, 2 line) |
| EQUAL -> EQUAL | 8 |
| strict unchanged, still STRICT_NOTEQUAL | 29 |
| strict line -> endcol | 2 (PD v04, residue 2) |
| strict fullname -> depth | 2 (IM v29, v30: the walk now reaches a pre-existing structural record; lost 0) |
| stage 1 -> stage 1 | 73 |
| leaves EQUAL | **0** |

- **Away census, pristine -> verified:** 0 lost on every case-view, 496 gained
  (`evidence/grid/away_cases_pris_to_fix.txt`).
- **Pristine -> delivered:** lost on exactly the 8 IM case-views of B1 and B2.
- **Switch controls:** `R11U209_OFF` gives the pristine bytes on all 204 case-views; `R11V209_OFF` gives the delivered
  bytes on all 204.
- **Return codes:** rc is recorded on every case-view. 196 read 0; 8 read 4 in all three binaries (LS v02, v05, v06 and
  IM v18 in both views: "unsupported constructs" with a database written).

**The implementer's grid** (`r11u209repro/cases`, 52 cases, 104 case-views; `evidence/grid/r209_grid_pris_law_fix.txt`,
one line per case-view with the pristine, delivered and verified verdicts and bytes):

- 62 convert: 36 fullname, 16 col, 6 type, 2 endcol, 2 defname.
- 18 stay EQUAL and 18 stay stage-1.
- 4 stay `fullname`; 2 go `col -> name`.
- Every figure matches the implementer's, and the verified binary writes the delivered bytes on all 104 case-views.

**Downstream** (the gate's own `one()`, `drivers/dsfaces.py`, `evidence/downstream/`, 102 cases):

- No case leaves IDENTICAL in either the delivered or the verified binary. 90 stay IDENTICAL.
- LV d01 and LV v11 go EQUIVALENT -> IDENTICAL with both binaries.
- The other 10 keep their pristine verdict: 7 EQUIVALENT, 2 DIVERGENT, 1 STATUS_DIFF.

### Faces per law (every case judged by both comparators and downstream)

- **§ tfItemInitLocalAtType209** (LV, 23 cases):
  - Convert in both views (v01-v03, v05, v07-v13, v15, v16, v19, v21, d01, d02): struct, enum and class typedef
    locals with initializers; `automatic`; two declarators; unpacked; signed; a package typedef; a task with a body
    `output`; string/real; queue; an interface function; a class handle from a static call; a package specialization
    with `new`; a multi-line initializer; two synthesizable functions with a body `input`.
  - Stage-1 at the base and after: v04 `const`, v06 `var int`, v14 (typedef locals with and without an initializer),
    v17 (implicit `var`), v18 (a generate-block function), v20 (a program function). v18 and v20 match golden's
    variable spans in the dump.
  - Downstream: d01 and v11 go EQUIVALENT -> IDENTICAL.
- **§ tfItemLocalSpecAtName209** (LS, 6 cases):
  - Convert: v01 (package function), v03 (named and type arguments), v05 (task with body `input`).
  - v02 (a generic imported from another package) is not reached, pristine = law.
  - v04 and v06 are stage-1.
- **§ classTdPkgEnumMemberShares209** (CS, 15 cases):
  - Convert: v03 (enum imported from another package), v07 (nested struct), v15 (package-qualified enum that is also a
    function formal).
  - v05 (a class in a module) gains 6 records and 0 lost.
  - Module contexts (formal, return, local, union, typedef alias: v01, v06, v08-v12) do not fire at all (trace empty)
    and stay as they were. BlackBePipeInt's firing is in an unreachable clone: its dump is byte-identical in the two
    binaries.
  - Stage-1 before and after: v02, v04, v06, v09-v14.
- **§ pkgArrTdElemClone209** (HP, 10 cases):
  - The elaborated view gains 1-7 records and loses 0. The first cells stay pre-existing faces (an unnamed elaborated
    packed_array_typespec; HP v03's file).
  - Downstream is unchanged, including HP v01 and v09 (synthesizable: member reads, writes and enum compares).
- **§ portConnOpLeafChain209** (IM v12-v18):
  - Convert: v13 (struct input port member), v15 (three-level path).
  - Unchanged: v12 (hierarchical reference into a sibling), v14 (interface array element), v17 (inside a call), v18
    (stage-1).
- **§ modportOpOrphanReparent209** (IM v01-v11, v19-v30):
  - Convert: v01 (ternary), v03 (local operand), v04 (`^` with replication), v05 (a bit-select member), v06
    (equality), v09 (for-generate), v24 (two member paths of one struct), v20/v25 (orphan last), v26 (concatenation
    then binary operation), v27 (a later three-element member connection).
  - With the verified binary, the breaks B1 (v02, v21) and B2 (v19, v22) also convert.
  - Stay `fullname`: v07 (a second instance with `|`) and v08 (positional); their elaborated views are stage-1.
  - Stage-1: v10 (plain interface port), v11 (nested member and a second reader), v28.
  - Residue: the kept-reduced unary/concatenation face in a later connection (v23, v29, v30).
- **§ genConnTrailSelChain205** (GS, 7 cases):
  - Convert in both views: v06 (hierarchical child path), v07 (clocked register-file shape).
  - Stage-1 cases (operation index, two trailing selects, case-generate, interface array, generate-scope interface
    instance) move toward golden's name and span, apart from the index text: ours keeps `[k + 1]` where golden folds
    `[1]`.
- **§ defGenTargetIpsDefName205** (IP):
  - Convert: v02 (three-level path), v03 (case-generate).
  - v01 (a parameter base, `b.d[P+:4]`) is not reached, pristine = law.
- **§ ifacePortDeclTsAtPortDecl205** (PD):
  - Converts v03 (two declarators).
  - v04 (two packed dimensions) moves `line -> endcol`: residue 2.
  - v07 (a comment inside a multi-line declaration) and v08 (`output reg`) stay EQUAL.
  - B3 on v01.

## 5. Switches

`drivers/switches.sh`, over the 204 case-views: every switch alone moves only case-views where that switch's own law
traced (`evidence/grid/switches.txt`).

    R11U205_GENIDXSEL_OFF (genConnTrailSelChain205): moved=14 untraced=0
    R11U205_IPSNAME_OFF (defGenTargetIpsDefName205): moved=4 untraced=0
    R11U205_PORTDECLTS_OFF (ifacePortDeclTsAtPortDecl205): moved=8 untraced=0
    R11U209_TWINELEM_OFF (twinElemOnlyNoRange209): moved=0 untraced=0
    R11U209_ARRTDCLONE_OFF (pkgArrTdElemClone209): moved=20 untraced=0
    R11U209_OPLEAFCHAIN_OFF (portConnOpLeafChain209): moved=52 untraced=0
    R11U209_MPORPHAN_OFF (modportOpOrphanReparent209): moved=38 untraced=0
    R11U209_TFINITTYPE_OFF (tfItemInitLocalAtType209): moved=48 untraced=0
    R11U209_TFSPECNAME_OFF (tfItemLocalSpecAtName209): moved=10 untraced=0
    R11U209_CLSENUMMEM_OFF (classTdPkgEnumMemberShares209): moved=14 untraced=0
    R11V209_MPCONCAT_OFF (mpOrphanSkipConcat209v): moved=6 untraced=0
    R11V209_MPLATER_OFF (mpOrphanLaterWriter209v): moved=4 untraced=0
    R11V209_PDNAMED_OFF (pdTsNotTypedefListing209v): moved=2 untraced=0

The twin law moves nothing on this grid, since no case has a dynamic-container return twin. Its own control is
`evidence/twin/rebuild_check.txt` (section 2).

## 6. Residues, ranked

1. **The r11u209 residues stand as reported**: Earlgrey's remaining records (mostly ground A), the kept-reduced
   connection operation (IM m05/g05 and here v23, v29, v30), the genvar-based indexed part select target, the
   typedef writer-order family (MiniAmiq #899, BuildUVMPkg #3245), anon_struct_packed_dim, ibex_tracer,
   OutputSize..., cfg_func_width_loop and V2.
2. **A two-dimensional packed interface port declaration** (PD v04 `output [1:0][3:0] o;`): golden's typespec ends at
   the FIRST dimension (`3:10-15`); § ifacePortDeclTsAtPortDecl205 ends at the last (`3:20`). This matches pass 202's
   module-port rule "no keyword before the packed dimensions: end at the first dimension". Pristine was further away
   (line), so no record is lost.
3. **A port declaration redeclared with a typedef** (PD v01, stage-1): golden gives the port its own unnamed
   logic_typespec at the port declaration, where ours reads the typedef listing. § pdTsNotTypedefListing209v now
   declines; the face remains.
4. **A later whole-struct connection and a struct_net view object**: not noted by the refinement, since golden keeps the
   orphan in IM v28. A member connection to a non-logic view object (int_var and the like) is not noted either, and is
   unmeasured.
5. **BuildUVMPkg #3245**: its content is unchanged; it is excused by the comparator's span pairing (section 2), not
   fixed.
6. **An implicit-type `var` local** (LV v17 `var v = 1'b1;`): the location becomes zero-width at `var`. Golden writes
   no variable for it; stage-1, no reader.
7. **Index text in an elaborated generate-connection select name**: ours keeps `[k + 1]` where golden folds `[1]`
   (GS v01, v04; stage-1). This is ExprEmit's fold, the sister's ground.

## 7. Fence and process

- The fence: every driver reads it from `canaudit.sh` and fails closed. The census and the away census filter or
  refuse fenced names ("fenced hits 0 0 0 0"). No fenced source or database was read, run, decoded or grepped outside
  the two gate sweeps' own dispatch. A grep of this directory for the four names reads 0.
- Builds: `-j 2`. The pristine binary was frozen before any source edit.
- Scratch: `/tmp/v11u209_*` only. No stash, `GOLDEN_DEFER` unset, nothing under `results/`, `tests/probe/` or
  `third_party/` edited. No process that another agent started was killed.
- Integration note: on the current HEAD `4acbe8a5`, the patch's `src/` applies cleanly and `tests/LAWS.md` conflicts,
  since it is generated. Regenerate it with `python3 scripts/law_index.py` at landing.

## 8. Files

- **`cases/`:** CS 15, GS 7, HP 10, IM 30, IP 3, LS 6, LV 23 (v01-v21, d01, d02), PD 8. Each case names its law in its
  first line: the refinement cases name § mpOrphanSkipConcat209v (IM v02, v21), § mpOrphanLaterWriter209v (IM v19,
  v22, v28) and § pdTsNotTypedefListing209v (PD v01); the rest name the pass-209 law they break.
- **`drivers/`:**
  - `env.sh`: the pins and the fence.
  - `case.sh`, `grid.sh`, `join.sh`, `caseaway.py`: one case, a grid, and the per-case away census.
  - `census.sh`: the predictor.
  - `away.py`, `pmov.sh`: the corpus away census and the probe dump movers.
  - `dsfaces.py`, `det.sh`, `uvmdist.sh`, `switches.sh`, `sweep.sh`.
- **`evidence/`:**
  - `sweeps/`: the three sweep logs.
  - `movers/`: byteverify outputs, probe movers, the away census and its control, the frozen prediction and firings.
  - `grid/`, `downstream/`, `determinism/`, `uvm/`, `twin/`.
