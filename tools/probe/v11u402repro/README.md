# v11u402 — adversarial verification of r11u402 (pass 402, module/type ground, sv-tests campaign pair B)

Base eee9c5fd4. Implementer's patch /tmp/r11u402.patch (md5 157f9d8a10da9e05c3301cde40790801), applied clean.
VERDICT: **LANDS WITH TWO VERIFIER REFINEMENTS** (/tmp/r11u402.verified.patch). Every headline number of the
implementer reproduced bit for bit; fresh cases found one law moving strict cells AWAY from golden on legal SV
(§ gateInBitSelIndexSpan402 on output and pass-switch terminals, pristine right there) and one naming slip on a
two-level alias chain (§ unitImpTdParamTsClone402); both fixed behind their own switches, everything regated.

## Binaries (frozen chmod 555 under /tmp/v11u402_bin before any measurement; all report slang 12.0.0+545f88b2e)

- pristine 2982d1ee861fb421aceffc8c0cc4e18f (= main tree build/slang-uhdm at the base)
- law (the implementer's patch, rebuilt here) f06cef348eb2fb71d6fa5b3124dbcced (= the implementer's lawC)
- verified (law + the two refinements below) c065349d8c38aa2634dca0f3231404b0
- uhdm-strictcmp fa6e4f42f252ae0ab69d9845003e71c5 (= main tree)

## Refinements (verifier, § <name>402v through fixOn(402, ...), R11V402_OFF drops both)

### § gateExprTermByGrammar402v — `R11V402_GATETERM_OFF` (ModuleEmit buildGate, the § gateInBitSelIndexSpan402 gate)
The law's "input" is the GRAMMAR's. Surelog's NetlistElaboration compiles a `net_lvalue` terminal (every
output_terminal, both inout_terminals of a pass switch) with the whole span and only an `expression` terminal
(input, enable, control) at its index. The law keyed on `idx > 0`, which (a) index-spans the extra OUTPUTS of
buf/not and the first two terminals of tran/tranif, where pristine was right, and (b) misses terminal ci=1 in the
definition view of an UNNAMED gate (idx is shifted down by one there). Keyed on the connection position ci:
buf/not and tranif/rtranif only the last terminal, tran/rtran and pullup/pulldown none, every other gate, switch
and udp every terminal after the first. Cases cases/VG (golden vs pristine vs law vs verified, strictcmp records):
- vg09_buf_multi_out `buf b1(o1, o2[1], i[0])`: golden o2 3:15-3:20 (both views); pristine RIGHT; law 3:18-3:19
  (AWAY, the break); verified 3:15-3:20, case STRICT_NOTEQUAL col -> EQUAL.
- vg21_buf_two_out_bitsel `buf b1(o[0], o[1], i[1])`: law moved o[1] away (3:19-20 vs golden 3:17-21); verified EQUAL.
- vg04_tran_bitsel `tran t1(a[0], b[1])`: golden b 3:18-3:22 whole; law 3:20-21 AWAY; verified EQUAL.
- vg18_tranif1_all_bitsel: law moved b[0] away; verified EQUAL.
- vg16_unnamed_and_bitsel, vg19_unnamed_not_multi: the def-view a[1]/i[1] (ci=1, idx 0) now index-spanned as
  golden; vg19's def-view o2[0] whole as golden; both left at the pre-existing unnamed-gate fullname face
  (golden work@top.work@and.a, ours work@top..a, on pristine too).
R11V402_GATETERM_OFF on the verified binary gives the law's bytes on all six; no other case, corpus row, probe case
or sv-tests row is touched (firing census: 0 corpus, 0 probe, 0 sv-tests firings).

### § impTsAliasRefOwnName402v — `R11V402_IMPTSOWNNAME_OFF` (UhdmExporter impTsChain402)
The copied alias reference is named `<reference>.<the COPY's own bare name>`, not the alias target's: golden for
`typedef bit [1:0] b_t; typedef b_t c_t; parameter c_t R` ($unit import) is R -> c_t -> `R.c_t` -> b_t ->
`R.c_t.b_t` (and `c_t`, `c_t.b_t` under the folded Rhs constant's empty-named reference); the law wrote `R.b_t`.
The two coincide for a typedef of a plain vector (UVM_PACK.uvm_field_flag_t), so no UVM row and no corpus row
moves (census: 0 firings in the corpora, the probe and sv-tests; the 134 sv-tests rows firing
§ unitImpTdParamTsClone402 are byte-equal law vs verified). Case VI2/vj03_unit_import_chain (moves toward golden,
stays NOT_EQUAL: our package b_t carries no Typedef_alias, so golden's third level `R.c_t.b_t -> b_t` is absent,
pristine too).

## Reproduction of the implementer's numbers (law binary, my sweeps /tmp/v11u402_wdL, pristine /tmp/v11u402_wdP)

- implementer grid: my driver (drivers/grid.sh, same columns, OFF column also checking the exit code) over the 78
  r11u402repro cases: 78 lines identical to evidence/grid402.txt (evidence/grid_impl_reproduced.txt).
- probe: law 4018 EQUAL + 69 STRICT_NOTEQUAL, regressions 0, conversions 1 (r10uvm149repro/g149/homes
  STRICT_NOTEQUAL differ:endline(1) -> EQUAL), changes 0; pristine 4017 + 70, 0/0/0. Byte movers law vs pristine:
  1 of 4087 (g149/homes), the trace naming § anonUnpackedStructSlotEnd402 (census_probe; the other 11 probe firings
  are § classCovergroupPropSilent402 exit-code-only on r10svs7/r10svs8/r10v121/r10v133 cases, bytes equal).
- surelog: default 480 + 0, testflags 474 + 0 CMP_EQUAL; regressions 0, conversions 0, changes 2:
  `Tnoc,default,CMP_NOTEQUAL,decompile:,,` and `Tnoc,testflags,CMP_NOTEQUAL,decompile:,,` (base SLANG_REJECT rc=-11),
  § uninstIfaceTdThroughPortSkip402. Byte movers 0 of the 960 common databases, the two Tnoc databases new.
- uhdm2rtlil: 803/1/67 both modes, 0/0/0; byteverify 0 of 1608 (SELFCHECK 1607 of 1608, the known twin).
- downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT; verdict column equal to
  results/downstream_uhdm2rtlil.csv on 871 of 871, law, pristine and verified.
- sv-tests (main-tree scripts/check_svtests.py, byte-identical to the worktree's; the worktree copy resolves the
  UVM tree under its empty submodule): pristine reproduces the baseline exactly (EQUAL 1153, STRICT_NOTEQUAL 23,
  DIFFERENT 705, BOTH_REJECT 309, SURELOG_ONLY 133, SLANG_ONLY 13, SLANG_CRASH 1, SURELOG_CRASH 8, TIMEOUT 1;
  0/0/0); law: EQUAL 1187, STRICT_NOTEQUAL 22, DIFFERENT 687, BOTH_REJECT 308, SURELOG_ONLY 119, SLANG_ONLY 14,
  SLANG_CRASH 0, SURELOG_CRASH 8, TIMEOUT 1, regressions 0, conversions 40, changes 1 (tnoc SLANG_CRASH ->
  SURELOG_ONLY): the same 41 rows as the implementer's table, by path (evidence/svtests_verified_stage.txt).
  Same-status detail changes law vs pristine: 5 (12.6.1 case/casex/casez_pattern, 12.6.2 if_pattern, 12.6.3
  conditional_pattern: SURELOG_ONLY, message `typedef target: UnpackedUnionType` -> the sister's `statement kind:
  PatternCase` / `complex if condition` / `complex conditional`).
- canaries surelog ok=52, uhdm2rtlil ok=16; ctcan2 PASS, PASS. Binary audit: every cmds.txt of each sweep names
  its own binary 3273 times and the others 0; each sv-tests stage's 2346 cmds.txt its own binary only.
- exit-code-only corpus movers CarryTrans d/t, Gates d/t (§ elabMosPullPrims402), SVSwitch d/t
  (§ classCovergroupPropSilent402); bytes equal, CMP_EQUAL before and after (census_surelog_verified.txt).

## sv-tests movers law vs pristine (normalised dumps; the raw bytes embed the workdir in builtin.sv's path)

176 rows move (evidence/svtests_dump_movers_law_vs_pristine.txt): the 41 status movers above plus 156
DIFFERENT -> DIFFERENT (146 UVM + 10), 8 SURELOG_ONLY -> SURELOG_ONLY (the 5 pattern rows and 3 more partial
databases), 4 SLANG_ONLY and 2 BOTH_REJECT. Order-blind dump census (drivers/away.py, golden vs pristine vs law)
on the 20 non-UVM movers: every one nets toward golden (e.g. p790 96/0, p753_2 96/0, class_member_test_18 16/0,
utd-sv primitives 272 toward / 28 away from shared generic lines, p193_2 28/4 the `C::f::p` vs `C::f.p` body
naming, p628 19/1 the implicit net `pd` line). UVM heads (uhdm-cmp first object, 156 UVM-tagged movers,
evidence/uvm_heads_*.txt): pristine 134 at `uvm_pkg::uvm_packer::get_packed_bytes`; law 132 at
`class_var uvm_pkg::uvm_init::idx` (StmtEmit foreach loop variable, sister) and 2 at `string_var
uvm_pkg::error_str`, the 12 uvm_pkg and 5 test-package listing heads unchanged. Census over sv-tests with the
verified binary: § oobMacroDefAtExpansion402 fires on 156 rows, § unitImpTdParamTsClone402 on 134.

## Gates of the verified binary (/tmp/v11u402_wdF, sv-tests /tmp/v11u402_svF)

- law index current; probe 4018 + 69, 0/1/0 (g149/homes); surelog 480 + 0 / 474 + 0, 0/0/2 (Tnoc d/t as above);
  uhdm2rtlil 803/1/67 both modes 0/0/0; downstream 803/66/2/0, verdicts equal to the committed csv on 871 of 871.
- sv-tests: identical csv to the law stage (status, detail, strict on 2346 of 2346): regressions 0,
  conversions 40, changes 1.
- byteverify verified vs law: surelog 0 of 962, uhdm2rtlil 0 of 1608, probe 0 of 4087 (PREDICTED: the firing
  census of both refinements read 0 on every corpus command line, every probe case and every sv-tests row before
  this sweep). Verified vs pristine: surelog 0 of 960 + 2 new Tnoc, uhdm2rtlil 0 of 1608, probe 1 of 4087.
- canaries ok=52 / ok=16, ctcan2 PASS / PASS, binary audit own 3273 other 0.
- determinism: three concurrent draws each of Earlgrey_0_1 default and testflags, MiniAmiq default and SeqDriver
  testflags: one hash per row-mode, equal to the sweep's database; chapter-16/16.12--property-interface-prec-uvm
  three concurrent draws one normalised dump hash, equal to the sv-tests stage's.
- corpus UVM and large rows stay CMP_EQUAL strict equal (MiniAmiq d/t, SeqDriver d/t, Earlgrey_0_1 d/t, Rggen d,
  BlackBePipeInt d/t, BuildUVMPkg d/t, SimpleUVM d/t, Scoreboard d, TypeParam d/t, LogicTypespec d/t, Scr1SvTests d/t;
  databases byte-identical to pristine, so their object counts are the base's).

## Fresh attack: 102 case dirs (cases/, every first line names its law), grids evidence/grid_fresh_*.txt

Verified binary vs pristine (grid_fresh_verified.txt): 75 move, 3 exit-code only, 24 same; 56 enter EQUAL; none
of the 13 pristine-EQUAL cases leaves EQUAL; R11U402_OFF = pristine (bytes and exit code) on 102 of 102 and on the
implementer's 78 of 78; every mover restored by one switch or the listed set (VM/vm02 needs UNITOOB + OOBMACRO
together: with UNITOOB on, the macro order is invisible). V switches (vswitch_restore.txt, 180 cases):
R11V402_OFF = law on 180 of 180; the 7 refinement movers restored by their own switch. Downstream on the 77
class-free cases (downstream_fresh_*.txt): pristine -> verified, none worse; 16 better (VA/va01, va02, va03, va05
EQUIVALENT -> IDENTICAL: the top span; VU/vu01, vu04 (DIVERGENT), vu05, vu07, vu09; VV/vv02, vv03 STATUS_DIFF ->
IDENTICAL, vv05, vv06; VY/vy02, vy04; VT/vt02 SLANG_REJECT -> IDENTICAL); VY/vy10 STATUS_DIFF on both binaries
(bytes equal; one early pristine draw read EQUIVALENT and three reruns STATUS_DIFF on both). Groups:
- VN (§ netKindTypeAll402) vn01-vn10: non-ANSI ports, ANSI `tri0 logic`, charge strengths, uwire with an initializer,
  child twice, unpacked arrays EQUAL; wand/wor/tri control same.
- VC (§ moduleNamedClocking402) vc01-vc07: child twice, skews, two blocks, `or` event, inout EQUAL; vc05 (block used
  in an initial) toward; program control same.
- VA (§ topModSpanSkipsAttrs402) va01-va05 EQUAL but va04 (an interface top with an attribute, same on both).
- VG (§ elabMosPullPrims402, § gateInBitSelIndexSpan402, § gateExprTermByGrammar402v) vg01-vg21: strengths, delays,
  cmos, arrays, rtranif1, notif0 with a variable index, child twice EQUAL; the six refinement cases above;
  vg07 (parameter index) and vg17 (udp) move toward and keep other faces.
- VE/VK (§ classEventArrElem402, § classCovergroupPropSilent402): event[3] and static event arrays EQUAL; dynamic
  and queue event arrays stay `class array property element` (exit 4, same); covergroup with event, coverpoint
  bins, in a package class: exit 4 -> 0, already EQUAL.
- VU (unions) vu01-vu10: EQUAL but vu09 (union array variable, toward) and vu10 (union typedef as a function
  argument: golden locates the typespec at the reference 4:18-4:21, ours at the typedef; pristine rejected).
- VY (§ assocTdIndexShapes402, § arrTdAliasElemClone402): vy03, vy06 EQUAL; vy02, vy07 toward; vy04 ($unit
  `typedef nib_t w_t[*]`) accepted but leaves two orphan aliased array_typespec copies (pristine rejected);
  vy05 (module `typedef byte b_t[int]` aliased), vy08 (module queue of a typedef), vy10 ($unit dynamic array of a
  typedef) still exit 4, same.
- VO (§ unitOobDefsNotInClass402, § unitOobFuncOnDesign402) vo01-vo08: mixed in-body, interleaved classes, extends,
  used ping EQUAL; vo01 (parameterized class) STRICT_NOTEQUAL fullname (the `pc::f.W` body naming); vo02 (static
  function called from a module: golden names the design copy `work@top.c::g`, parented at the call) and vo06
  (constructor with arguments) toward; package control same.
- VM (§ oobMacroDefAtExpansion402): vm02 EQUAL, vm03 toward (class order now golden's; the package listing order
  is the sister's pkgTfListingLess), vm01 already EQUAL.
- VV (§ vifVarNotElaborated402, § virtIfaceTd402): modport, child twice, $unit parameterized typedef EQUAL;
  vv02 (vif assigned and dereferenced) toward; vv01 (vif ARRAY, elab array_net kept) same; vv05 (module-body vif typedef) still
  exit 4 `typedef target: VirtualInterfaceType`, its partial database moved toward by § vifVarNotElaborated402.
- VS (§ anonUnpackedStructSlotEnd402): child, one line, two vars, multi-declarator member, used EQUAL; generate
  block same; `var struct` control same.
- VT (§ uninstIfaceTdThroughPortSkip402): vt02 pristine exit 139 -> exit 0; instantiated and plain-port controls same.
- VI2 (§ unitImpTdParamTsClone402, § impTsAliasRefOwnName402v): vj01 EQUAL; vj02, vj03 toward; enum control same.

## Residues (ranked; all wrong on pristine too, none moved away by the verified binary)

1. The UVM rows: 132 at the sister's foreach loop variable (StmtEmit), 17 at the sister's package variable
   listing (ParamEmit collectOobCtorLocalsIn / flushHoist9), 2 at uvm_pkg::error_str (same listing).
2. $unit out-of-body bodies: `c::f.x` naming and the call-site-bound design copy `work@top.c::g` (VO/vo01, vo02,
   UO/uo05, uo07; sv-tests p154_1, p190, p193_2).
3. Net kinds the law does not reach: interface nets (VN/vn01), generate-scope nets (vn05), `tri0 integer` and
   `supply1 logic` (vn09: golden 10 where ours writes 36).
4. Implicit-net lines (p628, 6.10, p597), as the implementer decoded.
5. Associative / array typedef shapes: vy04 orphan copies, vy05, vy08, vy10 (exit 4), typedef_test_13, AA/aa07,
   aa08, ae_enum.
6. Union typedef located at a subroutine-argument reference (VU/vu10); union array variable (vu09).
7. Virtual interface arrays in the elaborated view (VV/vv01), module-body vif typedef (vv05), dynamic/queue event
   arrays as class properties (VE/ve02).
8. Interface attributes and the interface top span (VA/va04).
9. Unnamed-gate fullname `work@top..a` (VG/vg16, vg19), switch arrays (GP/gp11), udp terminal faces (vg17).
10. The implementer's residues 6-10 (tnoc's uninstantiated interface, 5.6.4 `line, basejump continuous assign,
    US/us08, IT/it01).

## Sister-ground faces (reported, not written)

As the implementer listed them (StmtEmit foreach loop variable; ParamEmit collectOobCtorLocalsIn / flushHoist9 and
pkgTfListingLess; StmtEmit PatternCase / complex if / complex conditional; ExprEmit `expression kind: Invalid` in
tnoc, `user function call` p728, the gate concat terminal's ref actual GP/gt02), plus the $unit out-of-body body
naming `cls::f.x` (VO/vo01) decided in the expression emitter's name path.

## Process (no effect on any measurement)

- The first pristine corpus sweep ran from the verified worktree after the refinement edit, so its law-index check
  read STALE (rc 1); every stage's numbers are the base's and the verified sweep reads `law index current`.
- One case written first (`-> e[1];` on a class event array) is rejected by Surelog's parser (no golden); removed.
- One downstream background batch was killed with its parent shell half way and rerun whole.
- Nothing written to the main tree, results/, tests/ (but tests/LAWS.md) or third_party/; no process of another
  agent touched; every tree-wide list (probe dirs, corpus cmds.txt) built and fence-filtered before any file was
  opened; the two census rows of a test whose name holds a fenced name as a substring are left out of the evidence.
