# v11u447 — adversarial verification of r11u447 (expression/parameter ground)

Base 34893117 (pass 445). Implementer's patch /tmp/r11u447.patch (md5
0728598808f21d59bdcdc70a7dc6efe0). Verified patch /tmp/r11u447.verified.patch.
The pass changes src/ExprEmit.cpp only; the verifier adds two refinements in the
same file.

**Verdict: VERIFIED WITH TWO PRODUCTION REFINEMENTS.** The law reproduces exactly.
The attack grid found one shape where the law moves a cell away from golden
(fixed as § nestedProcEnumValAbstain447v). It also found one shape where golden
mints no wire and the law does (§ noneNetTypeBareRef447v). Pristine exits 4 on
both shapes, so neither is a break of a passing cell. No gate row, probe case or
sv-tests row moves on either binary.

## Binaries

| binary | md5 | note |
|---|---|---|
| pristine | 58637f1e347839343e1068b18f4d5f92 | the main tree's build/slang-uhdm, frozen copy, case runs only |
| law | d2ac6e0b6b23d72fcd84fd0e37bc048f | rebuilt once from the implementer's patch; equals law5 |
| ver | f09d1efc0be579af80ab696ca1dc9cd4 | the final verified binary, swept |

All link slang 12.0.0+545f88b2e.

## Reproduction of the implementer's numbers

**The law sweep:** one full five-stage tests/sweep.sh --jobs 3 run, workdir
/tmp/v11u447swL, launched after three quiet readings, with the trace on.
- **probe:** EQUAL 4023 + STRICT_NOTEQUAL 64, 0/0/0. The csv is identical to the
  control's (/tmp/intr11u445).
- **surelog:** default 480 + 0 and testflags 474 + 0, 0/0/0. The csv differs
  from the control only in the two LowMem log-path texts.
- **uhdm2rtlil:** 803/1/67 in both modes, 0/0/0. The csv is identical.
- **downstream:** 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT.
  The csv is identical.
- **sv-tests:** EQUAL 1914, DIFFERENT 26, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; 0/0/0. The csv is
  identical to the control. The stage exits 1 only on the main tree's stale
  tests/LAWS.md, as on the implementer's run.
- **trace directory:** empty in all five stages.
- **byteverify** against the control (SELFCHECK=1): 0 of 962, 0 of 1608 and 0 of
  805 movers; the self-checks flag 961, 1607 and 804.
- **canaries:** ok=52 and ok=16, changed=0; both ctcan2 checks PASS.
- **binary audit** (fence-filtered cmds.txt): surelog 1523 of 1573 name the law
  binary and the other 50 hold only a Surelog line; uhdm2rtlil 1740 of 1740;
  sv-tests 2346 of 2346.

**The implementer's 37 UN grid lines:** reproduced exactly on exit code, uhdm-cmp
count, dump distance and strict verdict (the md5 column differs only because the
case directory path is in the database).

**The 16 trace-census files** (the implementer's probe-tree census): verified
binary byte- and exit-identical to the law on all 16. The refinements fire on
none of them (evidence/v11u447_census16.tsv). The refinements can only fire
where the law's module branch is reached, and that branch is logged on every
reach, so this list bounds them.

**The two basejump rows** (scripts/svtests/svtests_matrix.py --keep-golden, rows
alone):
- **ver, production:** both DIFFERENT (rc 0).
- **The implementer's scratch admission binaries** (XPERIMENT447_ADMIT=1):
  - xadmit (pristine + admission): nonsynth_mem_1rw_sync_assoc EQUAL
    (IDENTICAL); scheduler_dataflow rc 4 DB_WITH_ERRORS, which would read
    SURELOG_ONLY;
  - xlaw7 (law + admission): both EQUAL, strict equal.
- **Consequence for the sister.** An admission landed WITHOUT this pass turns
  scheduler_dataflow from DIFFERENT into a goal-1 regression. The admission
  needs this pass first.
- **The refinements cannot fire on that row.** None of its twelve source files
  holds `default_nettype` or an enum in bsg_scheduler_dataflow.sv, so
  ver + admission writes xlaw7's bytes there.

**black-parrot:** bp_unicore alone on ver, with its sweep command line, exits 3 in
12.5 s at 830 MB maxrss (`basic_string::substr`, § macroVecLitTokenText403's
guard). The guard stays.

## The attack grid (cases/VA, VI, VN, VP: 66 case dirs; evidence/v11u447_grid.tsv)

- Every case is accepted by upstream slang (`slang dut.sv --single-unit`, exit
  0). Two further drafts with a defaulted parameter were rejected by upstream
  slang and dropped.
- Goldens come from `surelog -parse -nobuiltin -nocache -sv dut.sv`, all exit 0
  except VA/va05 (exit 4, see below).
- Downstream (ds.one, both lanes) on all 41 case dirs whose bytes move, across
  both grids: IDENTICAL on pristine and on ver (NO_GATES on both lanes, since a
  never-instantiated definition synthesizes nothing).

**pristine -> ver on the 66:**
- **28 rc 4 -> 0 STRICT_EQUAL:**
  - cont-assign shapes: va03 conditional, va04 call argument, va08 the module's
    own name, va09 two reads plus a port-connection wire, va10 interleaved
    port-connection wires, va12 delay, va13 two definitions, va14 a nested
    module, va17 a mix with implicit LHS wires, va20 a comparison;
  - LATEDECL: va15 a later variable, va16 a later net;
  - interface: vi04, vi05 (procedural LHS), vi06, vi08, vi11;
  - nested-scope values that golden still mints: vn02 a generate localparam,
    vn03 a generate net, vn05 a package name, vn06 a genvar, vn08 a task formal,
    vn09, vn11 a block static;
  - vn14 a class enum, vn15 an enum in a generate-block function, vn17 a
    generate typedef enum;
  - va05 (see § noneNetTypeBareRef447v).
- **6 rc 4 -> 0, closer:**
  - vi03, an interface named block (the un19 residue: we emit an unnamed begin,
    golden `named_begin nb`, so the ref is named work@ifc.u_x for golden's
    work@ifc.nb.u_x);
  - vi12, the interface cont-assign LHS (un31's residue);
  - vn10, vn13, vn20: enums golden mints a wire for, closer at other faces;
  - vn12, the interface bare ref right, a function-local enum_var residue.
- **32 byte-identical to pristine:**
  - the 6 enum cases the refinement restores;
  - the 12 VP process shapes, unreachable without the admission;
  - the law's abstentions or unreached sites: va07 a generate-block name, va19 a
    class method, va22 a sequence, vi01 and vi02 interface subroutines, vi07 an
    interface later declaration, vi09 an interface generate block;
  - pristine-rc-0 controls: va01, va02 net declaration assignments, va11
    replication, va18, va23, va24, vn04 a later $unit parameter, which slang
    binds.
- **None further.**

**law -> pristine on the same 66 (the law's own effect):** 7 cells moved AWAY,
fixed below:
- va06, vn01, vn07, vn16, vn18 and vn19: dump distance +1 or +2, with uhdm-cmp
  56 -> 514 on vn01 and vn16;
- va05: distance 6 -> 9.

## Refinements (src/ExprEmit.cpp, inside § undeclaredReadImplicitNet447)

Both are read through `fixOn(447, ...)`. `R11U447_OFF` drops them with the law.

### § nestedProcEnumValAbstain447v (R11V447_ENUMVAL_OFF)

**The face.** Take a name that a named block or a subroutine of the module body
declares as a constant of an ANONYMOUS enum: `initial begin : b enum {UX, UY} e;
... end` with `assign w = UY;`. Golden binds the read to that constant:
`ref_obj (work@m.UY)` with vpiActual `enum_const (UY)` INT:1, and no wire.

**What the law did.** It minted `logic_net work@m.UY`.

**Where golden still mints the wire:**
- a typedef'd enum's constant in a function (vn13) or a named block (vn20);
- a class's enum (vn14);
- any enum in or under a generate block (vn10, vn15, vn17).

**What the refinement does.** It walks statement blocks and subroutines only.
It abstains on a TransparentMember wrapping an EnumValue whose enum no typedef
of that scope names. The cell returns to pristine (exit 4).

**Cases:**
- va06 (a function enum variable);
- vn01 (a named block);
- vn07 (a function, two names);
- vn16 (a based enum logic [1:0]);
- vn18 (a task);
- vn19 (a named block inside a function).

All six are byte-identical to pristine again; controls vn10, vn13 to vn15, vn17
and vn20 keep the law's bytes.

**Two intermediate verified builds, neither swept.**
- The first matched EnumValue directly and never fired, because slang exposes an
  enum's constants in the enclosing scope as TransparentMember.
- The second walked every scope and overreached on vn14 and vn15, where it
  undid the law's STRICT_EQUAL.

### § noneNetTypeBareRef447v (R11V447_NONENET_OFF)

**The face.** Under `` `default_nettype none `` Surelog reports `[ERR:EL0535]
Illegal implicit net` and writes the read as a bare ref_obj with no vpiActual
and no wire.

**What the law did.** It minted the wire.

**What the refinement does.** It writes the bare ref when the definition's
default net type is slang's error net type.

**Case:** va05, distance pristine 6, law 9, ver 0 (strictcmp STRICT_EQUAL). No
gate compares such a pair, since Surelog exits nonzero. upstream slang
accepts, so the row would read SLANG_ONLY and the exit 0 is the goal-1 gain.

## Switches (drivers/switches.sh over all 103 case dirs of both grids, plus the two dropped drafts)

- `R11U447_OFF` gives pristine's bytes on 105 of 105.
- `R11V447_OFF` gives the law's bytes on 105 of 105.
- `R11V447_ENUMVAL_OFF` gives the law's bytes everywhere except va05, which the
  other fix holds.
- `R11V447_NONENET_OFF` gives the law's bytes everywhere except the six enum
  cases.

## The verified sweep (workdir /tmp/v11u447swV, after three quiet readings, trace on)

- **Every csv:**
  - probe, uhdm2rtlil and downstream are equal to the law sweep's;
  - surelog differs only in the two LowMem log-path texts;
  - svtests is identical to the control.
- **Stage counts:** the same as the law sweep's, all 0/0/0.
- **trace directory:** empty.
- **byteverify:**
  - against the control: 0 of 962, 0 of 1608 and 0 of 805 (self-checks 961,
    1607, 804);
  - against the law sweep: 0 movers in all three.
- **canaries:** ok=52 and ok=16; both ctcan2 checks PASS.
- **binary audit:** surelog 1523 of 1573 (the other 50 a Surelog line only),
  uhdm2rtlil 1740 of 1740, sv-tests 2346 of 2346 naming ver.
- **determinism:** three concurrent ver runs on vn01, va05, un26 and va10 read
  one hash each.

## Under the admission (evidence/v11u447_grid_admission.tsv; xadmit / xlaw7, measurement only)

The VP process shapes:
- **6 to STRICT_EQUAL:** vp03, vp04, vp05, vp06, vp08, vp12.
- **Closer:** vp01 (the named-block residue), vp09, vp10 and vp11 (rc 4 kept).
- **Identical:** vp02 (`@(u_ev)`, rc 4).
- **Further:** vp07, the named-block enum, which the refinement now covers.

**vp09 is a defect that appears only once the admission lands.** The read sits
in a process at 3:28 and again in a continuous assignment at 4:14. Golden mints
the wire at the FIRST SOURCE reference (3:28) and lists it before `w`. Ours
emits continuous assignments before processes, so the wire is minted at 4:14 and
listed after `w`. The law takes its location from emission order. Before an
admission lands, the mint should take the earliest source reference.

## Residues (ranked; all wrong on pristine too)

1. The sister's admission (UhdmExporter's Bad404 `abstain-unbound`). It converts
   both basejump rows on top of this pass (measured with xlaw7). Without this
   pass, scheduler_dataflow regresses.
2. **vp09:** first-reference location when a process read precedes a
   cont-assign read (admission-contingent).
3. **Enum-constant binding** (va06, vn01, vn07, vn16, vn18, vn19): golden's
   `enum_const` copy under the ref (INT value, vpiSize 64, parent the ref_obj,
   no location). The refinement abstains (exit 4).
4. The implementer's list: generate-block reads (un10, un25, and vi09 in an
   interface); selects, dotted names and calls (un07, un20 to un22); un15;
   named blocks (un19, vi03, vp01); un13; concatenations (un18, un34); the
   interface cont-assign LHS (un31, vi12); un37 and VT/vt14.
5. **Not reached:**
   - interface subroutine bodies (vi01, vi02);
   - an interface later declaration (vi07);
   - a module generate-block name read (va07);
   - a class method (va19);
   - a sequence body (va22);
   - `@(undeclared)` (vp02);
   - a later localparam (vp11).

## Sister-ground faces (reported, not written)

- **UhdmExporter's Bad404 admission** (the implementer's report stands). This
  pass must land before it, or with it: xadmit alone turns
  bsg_scheduler_dataflow into rc 4.
- **ModuleEmit's emission order** of continuous assignments before processes in
  a never-elaborated definition. This is vp09's location face once processes
  are admitted.

## Process

- **Over the budget on builds by two, within it on sweeps.** There was one law
  build and three verified builds, of which only the last was swept. The first
  two were used on case grids only, never swept (reasons above).
- **Sweeps:** one five-stage sweep each on law and ver. Each started after three
  quiet readings and overlapped no other sweep. The sister v11u446's sv-tests
  stage was live until 10:21 and was waited out.
- **No pristine build and no pristine sweep:** the control /tmp/intr11u445 is
  the pristine reading.
- **Fence:** the fence list was read into a file by a program without printing
  it, and every tree-wide list (cmds.txt audit) was filtered on it first. No
  fenced test was named, opened or run.
- No other agent's process was touched. The one TaskStop stopped this
  verifier's own build task.

## Files

- cases/VA, VI, VN, VP/*/dut.sv: 66 case dirs, first line `// § <law>`.
- drivers/:
  - grid.sh (the implementer's driver);
  - switches.sh;
  - summarize.py.
- evidence/:
  - the grid on pristine / law / ver;
  - the admission grid;
  - downstream;
  - census16;
  - byteverify for both sweeps;
  - the refinement diff.
