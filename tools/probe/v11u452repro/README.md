# v11u452 — adversarial verification of r11u452

Base ccfaa1698, the implementer's patch /tmp/r11u452.patch (module/type ground:
src/ModuleEmit.cpp, src/TypeEmit.cpp, src/TaskFuncEmit.cpp). Verifier worktree
/tmp/wt_v11u452. Verified patch /tmp/r11u452.verified.patch.

## Verdict

CONFIRMED with ONE BREAK FIXED and ONE PRODUCTION REFINEMENT, both behind their own
switches. Neither fires on any corpus row, probe case or sv-tests row. The four sv-tests
conversions reproduce on the law binary and on the verified binary:

| row | base | law and verified (fresh svtests.csv row) |
|---|---|---|
| generated/uvm-examples/uvm_test_init.sv | DIFFERENT | `EQUAL,,equal` |
| generated/uvm-examples/uvm_generation_seq_poly.sv | DIFFERENT | `EQUAL,,equal` |
| generated/uvm-examples/uvm_generation_seq_persistence.sv | DIFFERENT | `EQUAL,,equal` |
| generated/uvm-examples/uvm_generation_seq_randomization.sv | DIFFERENT | `EQUAL,,equal` |

## The verifier's production changes (read through src/LawSwitch.h; R11V452_OFF gives the law's bytes, R11U452_OFF pristine's)

1. **§ thisOrigClaimedSkip452v** (`R11V452_THISORIGCLAIMED_OFF`, TypeEmit, inside
   § thisNetPerListingModule452). THE BREAK. Legal SV where pristine bound a `this`
   reference correctly and the law moved it away from golden:
   - Case VT/vt04: module m1 imports u, module m2 imports a, and a imports u. Golden
     binds u::C::show's `this` to work@m1.this. It leaves a's clone of C::show
     unbound. It anchors work@m2.this at a::D::put's 18:20.
   - Pristine bound u::C::show's `this` to work@m1.this, which is right.
   - The law replaced m2's clone hit by the ORIGINAL references, including the one
     m1's group already held. So it rebound u::C::show's `this` to work@m2.this and
     anchored m2's wire at 8:20.
   - The fix: a later definition skips originals that an earlier definition's group
     already holds, and a group left empty mints no wire.
   - Result: VT/vt02, vt03, vt04, vt05, vt08 and vt09 go to STRICT_EQUAL. On the law
     binary they were STRICT_NOTEQUAL on fullname (vt03, vt04, vt05, vt08) or
     NOT_EQUAL (vt02 163 lines, vt09 149 lines).
2. **§ tfClsArrElemNamedOutsidePkgCls452v** (`R11V452_TFCLSARRNAME_OFF`, TaskFuncEmit,
   inside § tfLocalClassArrElemClassTs452). This is a refinement, not a break, since
   pristine wrote a logic_typespec there.
   - Where it applies: a fixed-size array local of a class type, in a subroutine that
     is neither a class method nor a package subroutine. That covers module,
     interface, program, generate-block and $unit tasks and functions.
   - Golden gives the element class_typespec the written name (`class_typespec (C)`),
     on VC/vc01, vc08 and vc12 to vc17.
   - The law wrote it unnamed. Unnamed is golden's form only in a class method or a
     package subroutine (CA/ca01, VC/vc02, vc10).
   - Result: VC/vc01 and vc08 go to STRICT_EQUAL. vc12, vc13, vc15, vc16 and vc17 now
     have golden's typespec set, with other faces left. vc14 (a program) keeps one
     extra golden class_typespec at 7:5-7:13 (the program-listing face).

Each fix's own switch alone restores the law's bytes on its cases: vt04 for the
first, vc01 for the second.

## Reproduction of the implementer's numbers

- **Binaries:**
  - The law binary rebuilt in /tmp/wt_v11u452 (-j 2) is md5
    da65dcfe11796f518b63677270e8bdd3, equal to the implementer's law12. It links slang
    12.0.0+545f88b2e.
  - The pristine binary is the main tree's build/slang-uhdm (md5
    bcbbf4bebc1acb00e518ec826fbaabdf), frozen at /tmp/v11u452_bin/pristine and not
    rebuilt.
  - The verified binary (one build) is md5 9e723f9b3ca4cd924217e2e8dac35d9e
    (evidence/binaries.md5).
- **The implementer's 32 grid case dirs**, rerun with this verifier's driver
  (evidence/impl_grid_reproduced.txt):
  - Exit code, uhdm-cmp count, strict verdict and object count match on all 32, and
    so does moved or same.
  - R11U452_OFF gives pristine's bytes on 32 of 32.
  - The md5s differ from the implementer's file only because the output path is
    written into the database.
- **Law sweep** (/tmp/v11u452swl, one full five-stage sweep after three quiet
  readings; evidence/sweep_law.txt):

  | stage | result |
  |---|---|
  | probe | EQUAL 4023 + STRICT_NOTEQUAL 64, 0/0/0 |
  | surelog | default 480 + 0, testflags 474 + 0, 0/0/0 |
  | uhdm2rtlil | 803/1/67 in both modes, 0/0/0 |
  | downstream | IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0 |
  | sv-tests | EQUAL 1924, DIFFERENT 16, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions=0 conversions=4 changes=0 (the four rows above) |

  - Every csv equals the implementer's /tmp/r11u452swp csvs after path
    normalization: 0 differing rows in each of the five.
  - Against the master's control /tmp/intr11u450, only the four converted sv-tests
    rows and the two LowMem log-path texts differ.
- **Byteverify, law against the control** (evidence/byteverify_law_vs_control.txt):
  - surelog 4 of 962 movers, exactly the implementer's predicted four with its
    hashes: SeqDriver default 89255aa86b3a, SeqDriver testflags 4e6f3f81e983,
    SimpleUVM default 1b272df498a9, SimpleUVM testflags a33585478fe3;
  - uhdm2rtlil 0 of 1608 and downstream 0 of 805;
  - the self-checks flag 961, 1607 and 804.
- **Trace census on the law sweep:**
  - The corpus stages fire only § thisNetFlatStreamPlace452, on 8 databases: the four
    g219 probe cases and SeqDriver and SimpleUVM in both modes.
  - sv-tests fires § thisNetFlatStreamPlace452 on 146 rows, as the implementer
    reports.
- **Canaries:** ok=52 and ok=16; ctcan2 PASS on both (surelog ok=58 with unknown 1,
  uhdm2rtlil ok=2 with unknown 6).
- **Binary audit**, fence-filtered (drivers/audit.py reads the fence list into a file
  by a program and never prints it):
  - surelog 1523 of 1573 records name the binary under test, and the other 50 hold
    only a Surelog line;
  - uhdm2rtlil 1740 of 1740;
  - sv-tests 2346 of 2346.
  - The same holds on both sweeps.

## Verified sweep (/tmp/v11u452swv, the second and last; evidence/sweep_verified.txt)

- **Prediction**, written from the law sweep's trace before this sweep: both fixes act
  only inside a law that fires on no corpus row or probe case.
  - § thisNetPerListingModule452 fires only on 5 DIFFERENT sv-tests rows:
    uvm_vif_config_db, uvm_param_vif_config_db, uvm_ac_config_db,
    uvm_ef_vif_config_db and uvm_id_register.
  - § tfLocalClassArrElemClassTs452 fires only on the three uvm_generation_seq rows,
    in a class method, where the naming fix abstains by design.
  - So the prediction was 0 movers anywhere. Those 5 rows rerun alone through their
    cmds.txt on the verified binary read the law's bytes.
- **Result, held:**
  - Every stage reads the same counts as the law sweep, with 0/0/0 in the corpus
    stages and sv-tests at 0 regressions, 4 conversions and 0 changes.
  - Every csv is identical to the law sweep's.
  - Byteverify against the law sweep reads 0 of 962, 0 of 1608 and 0 of 805, with the
    self-checks at 961, 1607 and 804. Against the control it reads the same four
    surelog movers with the same hashes.
  - Probe: 0 of 4087 raw-byte movers against the law sweep, and 0 of 4087 by
    path-normalized dump against the control. The positive control is two different
    databases differing by 393 lines.
  - Neither fix logs a single firing anywhere in the sweep.
- **Determinism**, three concurrent draws on the verified binary
  (evidence/determinism.txt): SeqDriver testflags, SimpleUVM default, MiniAmiq default,
  Earlgrey_0_1 default and uvm_vif_config_db each read one hash in 4 of 4.
  - MiniAmiq default stays 89ef2145c577.

## Attack grid (82 fresh case dirs; drivers/mk.py, mk2.py, attack.sh, vgrid.sh)

Every case is accepted by upstream slang, and every exit code is 0 on all three
binaries. Three cases had illegal first spellings, which slang-uhdm rejected on both
binaries; they were rewritten legally in place: VW/vw03 (a generic port with .*),
vw05 (a missing modport) and VE/ve05 (an unexported enum constant).
evidence/attack_law_batch1.txt still holds the illegal runs; batch2 holds the rewrites.

| group | law | cases |
|---|---|---|
| VX | elabAssocVecIdxRange452 | 18 |
| VC | tfLocalClassArrElemClassTs452 | 17 |
| VO | clsOwnProtoAndOobDefBoth452 / pkgGroupOwnOobDef452 | 10 |
| VH | hoistPoolTransitiveImports452 | 8 |
| VT | thisNetPerListingModule452 | 10 |
| VF | thisNetFlatStreamPlace452 | 2 |
| VW | ifaceConnNetAfterForwarded452 | 7 |
| VP | clsImpParamOncePerName452 | 3 |
| VE | clsImpEnumTdShare452 | 5 |
| VK | clsImpRepTsClassKey452 | 2 |

**pristine -> verified** (evidence/grid_summary.txt, grid_verified.txt):
- 40 go NOT_EQUAL -> STRICT_EQUAL: VX vx01 to vx05, vx10, vx14, vx16 to vx18; VC vc01,
  vc02, vc08; VH vh01, vh03, vh05 to vh08; VO vo01, vo03 to vo07, vo09, vo10; VP vp02;
  VT vt01 to vt05, vt08 to vt10; VW vw01, vw02, vw04, vw05.
- 2 are STRICT_EQUAL on both binaries with bytes moving toward golden's binding:
  VE/ve04, ve05.
- 24 move bytes and stay NOT_EQUAL, closer or with the head moved later.
- 16 are byte-identical.
- None goes further.

Notes on the movers that stay NOT_EQUAL:
- VX/vx11's uhdm-cmp count grows 47 -> 56 only because the head moved to the [3]
  dimension's N-1 face. Its dump distance falls 74 -> 54.
- VO/vo02's dump distance grows 58 -> 100 while its uhdm-cmp head and count are
  unchanged. Its module listings now equal golden's ([r::write, r::S::write] in
  allModules and topModules). The dump expands the out-of-body definition at its
  first visit, which is now the module listing instead of the class.

**Switches:** R11U452_OFF gives pristine's bytes on 114 of 114 case dirs (the 82 here
plus the implementer's 32), and R11V452_OFF gives the law's bytes on 114 of 114.

**Downstream** (pristine and law): IDENTICAL on VH/vh03, vh08, VX/vx01, vx14 and
VW/vw04, with no verdict moving.

Every other attack line reads the law right where pristine was wrong, or byte-identical.
The one pristine-right -> law-wrong cell found is the break fixed above.

## Residues (all wrong on pristine too, none moved away on the verified binary)

1. **§ tfLocalClassArrElemClassTs452 shapes not taken:**
   - a parameterized element `P #(8) a[2]`, where golden writes an unnamed
     class_typespec 8:7-8:13 and ours keeps a logic_typespec (VC/vc03);
   - a scoped `p::C` element (vc04, unchanged);
   - an interface class element, where golden writes `unsupported_typespec (IC)` and
     the law a class_typespec, both wrong (vc06);
   - the program's extra golden class_typespec (vc14);
   - other faces on vc05, vc07, vc09 to vc13 and vc15 to vc17 after the element
     typespec now matches.
2. **§ elabAssocVecIdxRange452 not reaching:** an interface (VX/vx06), a generate
   block (vx07), a package variable (vx08), a function local (vx09), a parameter bound
   (vx12, the second declaration converted) and a based-literal bound (vx13).
3. **§ hoistPoolTransitiveImports452 not reaching:** an explicit `import r::S;`
   (VH/vh02) or an interface importer (vh04).
4. **VO/vo02:** golden's class S also lists its own `write` beside the imported free
   `q::write`; the older § 23 suppression still drops it.
5. **VO/vo08** (an explicit `import q::g;`), **VE/ve01 to ve03** (array, two
   importers, an enum from a third package) and **VP/vp01** (two packages each with a
   parameter P; the class keeps golden's one P but the module listing keeps both)
   move closer and stay NOT_EQUAL.
6. **VT/vt06** (an interface as the first listing definition) moves closer and stays
   NOT_EQUAL.
7. **VW/vw03** (a `.*` connection) and **vw06** (an interface array) are unchanged.
8. **VK/vk01 and vk02** move 350 and 370 -> 118 uhdm-cmp lines.
9. **The implementer's residues stand:** the three sfr_scoreboard rows at the `cs`
   pairing; bidir_get_put, bidir_item_done, pipelined_get_put, many_to_one,
   param_vif_config_db and id_register; easyUVM and the scoreboard rows; p733, p737
   and tnoc; and the carried lists.

## Sister-ground faces

None new beyond the implementer's (ParamEmit: CV/cv02, cv05, cv08, cv09 and the `cs`
clone pairing).

## Process

- One law build and one verified build, both after quiet readings. The law build ran
  only after the sister v11u453's sv-tests stage ended.
- One law sweep and one verified sweep, each after three quiet readings, never
  overlapping another sweep.
- The four corpus stages ran from the worktree. The sv-tests stage ran through the main
  tree's scripts/check_svtests.py with the worktree baseline, since the worktree's UVM
  submodule is empty.
- No pristine build and no pristine sweep: the pristine reading is the master's control
  /tmp/intr11u450.
- tests/LAWS.md was regenerated before the sweeps and again last.
- The fence list was read into a file by a program and never printed. No fenced test
  was named, opened or run. No other agent's process was touched.
- Slip, not affecting a measurement: the first spellings of three attack cases were
  illegal; they were rewritten and rerun.
