# HANDOFF — slang-uhdm convergence campaign

> **2026-08-17: this file is a historical log. START WITH `RESUME.md`** (canonical operator manual; `scripts/resume_survey.sh` prints the live state).

> **Phase 2 is now the target: see GOLDEN_EQUIVALENCE.md.** It supersedes the
> scope section below. Two corrections that matter when reading this file:
> the old harness covered 710 uhdm2rtlil tests (it skipped 24 multi-file dirs)
> and 695 Surelog tests (it skipped nested dirs, all 90 third_party tests, and
> 53 "multifile" dirs); real counts are **731** and **794**. The 41.6% Surelog
> figure was measured with uniform flags rather than each test's own command
> line and is **void** — use the tables in GOLDEN_EQUIVALENCE.md §3.3.

## Wave 4 "fold-family-2" (w4fold): unpacked-array param/typedef fold shapes

Targets: ArrayExprFuncArg (194), DefaultPatternModule (192), DefaultPatternInt
(581), GenerateUnnamed (813) — dump-diff lines, `default` mode. Result, 5
improvement rows and no regressions:

| test | default | testflags |
|---|---|---|
| ArrayExprFuncArg | **CMP_EQUAL** (194 -> 38) | **CMP_EQUAL** (404 -> 228) |
| FuncRetArray (not targeted) | **CMP_EQUAL** | **CMP_EQUAL** |
| DefaultPatternModule | **CMP_EQUAL** (192 -> 77) | NOTEQUAL (250 -> 145) |
| DefaultPatternInt | NOTEQUAL (581 -> 262) | NOTEQUAL (624 -> 319) |
| GenerateUnnamed | untouched (813) | untouched (813) |

Decoded mechanisms (all `default`-mode/folded-model rules):

1. **Unpacked-array function return is an `array_var`**, bare (no element reg,
   no vpiArrayType), anchored at the RETURN-TYPE token, not at the typedef —
   the array_typespec sits at the typedef, so the return var takes the
   return-type span exactly like a struct/enum return already did.
2. **The return's typespec is a CLONE of the module typedef listing**, named,
   with BARE-scoped inner refs (`T.CNT`, elem ref `T`) and a `Typedef_alias`
   ref back to the listed object. Same model as the existing logic_typespec
   `typedefRetClone`; `buildUnpackedArrayTypedefTs(ta, qname, cloneForm)` now
   builds both (extracted from `emitTypedefs`).
3. **An unpacked-array typedef's SIZE dim keeps a NAME reference symbolic** —
   `[CNT]` becomes `0 : (ref_obj CNT) - 1`, ref fullname `<qname>.CNT` — and in
   the compile-time LISTING object the synthetic `1` is UNPARENTED (the
   elaborator's clone parents it). A LITERAL size still folds.
   **Exception, and the DefaultPatternInt distinguisher: a size naming an
   IMPORTED (package) param FOLDS** — value at the param's width with a ts ref
   to a fresh int_typespec instanced at the param's HOME package.
4. **A built-in element type gets an Elem_typespec** (`typedef int unsigned
   T[CNT]` -> int_typespec at the target-type span); previously only typedef'd
   elements produced one.
5. **`elabParamDim` also governs the SYMBOLIC dim**: only an ELAB param dim
   parents its synthetic `1`; the def view and port/net dims leave it
   unparented (MemoryInGenblock is the negative calibration point, and it
   demoted match->differ on the first, sym.kind-based attempt). A MATERIALIZED
   IMPORT counts as elab (clone_tree copy).
6. **A folding param-sized dim carries the sized param's shape**: decompile =
   the VALUE (not the name), size = that param's width, ts ref named after the
   HOLDER param -> a fresh int_typespec at the sized param's type syntax with
   `vpiInstance` = its home package. `dimFoldOwner` carries the holder name
   into `buildUnpackedRanges`; `homePkgInstOf()` resolves the instance.
   Surelog mints a FRESH typespec per fold (proved by the weak tail: several
   `int_typespec 2:12-2:24` objects, each parented at its own ref) — sharing
   the param's ts is wrong.
7. **`int unsigned` spans split by context**: a data/param declaration's
   int_typespec spans BOTH keywords, a function FORMAL's spans only the base
   keyword. (The formal rule already existed for dimensioned types; the
   signing case was missing.)
8. **A function formal's unpacked dim is symbolic too**, scoped at the formal
   (`work@top.F.SRC.CNT`).
9. **`'{default: X}` on an unpacked-array param EXPANDS to an `array_expr`**
   with one folded element constant per element (element-type width, at the
   default value's span) — but ONLY outside the declaring scope's DEFINITION
   view, which keeps the raw op75 + tagged_pattern. An IMPORT's copies parent
   their constants at the array_expr; the elaborator's own object leaves them
   unparented and, for a MODULE-local param, tags the array_expr with the
   param's array_typespec.
10. **An elab system task in a TAKEN generate block** becomes a gen_scope
    `Elab_task` (`vpiSysTaskCall`) spanning the whole statement, semicolon
    included, with ONLY the message string literal as an argument.
11. **A TYPED integral localparam whose init is a const CALL** folds at the
    PARAM's width, BIN-encoded, with the param's own typespec ref — unlike the
    untyped case, which sizes at the function return type and stays UINT.

Still open:
- **DefaultPatternInt** (581 -> 262): cmp advanced four layers (pkg-def dim
  ref -> package instance -> module typedef dim -> function-body ref). Next
  blocker is decoded: a function-body reference to an IMPORTED package param
  (`i < CNT` in ASSIGN_VADDR) folds to a constant that must carry a ts ref
  (fullname = the function's fullname) -> the pkg int_typespec; we emit the
  constant untypespec'd.
- **GenerateUnnamed** (813, untouched): TWO separate families, neither in this
  cluster. (a) the unelaborated gen_if_else tree drops a level when an
  if-generate's then-branch is a BARE nested if (`if (p==1) if (q==0) ...`);
  Surelog wraps it in an anonymous `begin`, we hoist the inner if. (b) the
  elaborated view hoists taken case/if-generate scopes to the MODULE level
  (`work@test1.u1`, `.genblk1`, `.n5` side by side) where we nest them
  (`genblk1.u1`).

Gate: goldens 23/23; u2r testflags 674 CMP_EQUAL / 5 CMP_NOTEQUAL, ZERO movers;
Surelog both modes 227 default / 218 testflags CMP_EQUAL with exactly the 5
improvement rows above. **Golden-cache poisoning warning (wave-wide, not this
patch):** the concurrent-agent load made Surelog itself OOM on the giant
designs, and `verify_golden.py` CACHES a SURELOG_FAIL status — so
Earlgrey_nexysvideo, YosysOpenSparc and YosysSmallBoom showed up as
`-> SURELOG_FAIL` movers. Re-running them with `GOLDEN_CACHE=0` restores their
baselines exactly (SLANG_REJECT / SLANG_REJECT / CMP_NOTEQUAL). The cache is
shared across worktrees, so a memory-starved run poisons every later sweep;
consider not caching SURELOG_FAIL, only success.

## ⚠️ SCOPE OF THE ZERO-DIFF CLAIM — verified, but corpus-specific (2026-07-24 ~21:40)

Re-verified INDEPENDENTLY with the standard `uhdm-cmp` (UHDM 1.86,
~/git-repos/UHDM/build/bin/uhdm-cmp) run directly on each .uhdm pair, not via converge.sh:
  scripts/verify_stdcmp_uhdm2rtlil.sh -> results/verify_uhdm2rtlil_stdcmp.csv
  uhdm2rtlil (710 tests): 661 CMP_EQUAL, 0 CMP_NOTEQUAL, 44 SLANG_REJECT, 5 SURELOG_FAIL.
  (NOTE: run_corpus.sh/converge.sh ALREADY used the standard uhdm-cmp for PASS_CMP; the scratchpad
   `cmptool` was only a diagnostic that printed failLhs. So 488/173/0 was always a standard-tool verdict.)

BUT the uhdm2rtlil corpus is the corpus we OPTIMIZED AGAINST. Held-out check on Surelog's own suite
(scripts/verify_stdcmp_surelog.sh -> results/verify_surelog_suite_stdcmp.csv), both tools run in
Surelog's DEFAULT pre-elab mode (the mode this exporter targets):
  Surelog tests (695): 176 CMP_EQUAL / 247 CMP_NOTEQUAL / 213 SLANG_REJECT / 53 SKIP_MULTIFILE / 6 SURELOG_FAIL
  => of the 423 where both tools produced UHDM, only 176 (41.6%) compare equal.
So "0 DIFF" means zero on uhdm2rtlil, NOT general Surelog equivalence. Generalization gap is real.

Caveats in BOTH directions (do not over- or under-read the 41.6%):
 - 623 of 695 Surelog tests pass `-elabuhdm` in their .sl (post-elab UHDM). We do not implement that
   (task F). Comparing our pre-elab output to their post-elab output would be meaningless, so the runner
   deliberately uses default mode for both sides instead of the tests' own .sl args.
 - The runner therefore also DROPS per-test .sl flags: 33 of the 213 rejects need +incdir/-sv/-y/-v/UVM/
   -fileunit that it does not pass — those are harness artifacts, not exporter gaps.
 - The other ~180 rejects are slang (the FRONTEND) legitimately refusing code Surelog accepts leniently:
   unknown module, undeclared identifier, duplicate definition, missing UVM library. Many Surelog tests
   are deliberately partial fragments. These are frontend-tolerance issues, not exporter bugs.
 - GOOD NEWS: the mismatches are mostly SMALL/near-converged — sampled 40, and Attributes2=9 lines,
   CondOpPattern=10, BitsHierPath=11, BlackParrotSkipParam=16, AlwaysNoElab=17, ClogCast=18,
   ComplexExprSize=22 ... i.e. the same rule families this campaign has been decoding. A wave aimed at
   the Surelog suite's <=50-line mismatches should convert many.

## ZERO DIFF on uhdm2rtlil (2026-07-24 ~21:20): 488 PASS / 173 CMP_ONLY / 0 DIFF

Every corpus test is now at least SEMANTICALLY IDENTICAL to Surelog (uhdm-cmp DESIGN r=0); 488 are
byte-identical. Goldens 23/23. Remaining work is byte-level only (173 CMP_ONLY).

### Wave 63 — the final five (all converted, one combined gate, zero regressions)
- func_tern_hint DIFF->PASS. Surelog's const-function evaluator (UHDM ExprEval.cpp) models NO LRM widths:
  every intermediate is a 64-bit word, vpiConditionOp reduces to INT:<selected branch>, vpiRShiftOp and
  vpiArithRShiftOp are BOTH a 64-bit logical shift, and evalFunc masks the value to the return
  logic_typespec width on each return. New SrlgFold (ParamEmit) replays that model over a narrow
  statement/expression subset and returns nullopt -> slang's LRM value for anything unmodelled.
  REFUTED en route: "ternary takes the selected branch's signedness" (my own guess), value-based gates,
  and LRM-signedness gates — a plain (-1 + inp) >> 2 diverges too.
- cs_registers DIFF->CMP_ONLY. Materialized imported-param typespecs pointed vpiInstance at the DEF
  package (AllPackages[0], 64-bit unelaborated constants) where Surelog points at the ELAB one
  (TopPackages[0], 32-bit). UHDM's Compare follows typespec->Instance, so the def view dragged in the
  wrong constants — a DUMP-INVISIBLE aliasing blocker, found with an instrumented per-container
  comparator. Plus: an elab imported-param copy re-emits the resolved Value, so a based-decimal default
  loses its base (2'd1 -> INT:1).
- multiplier DIFF->CMP_ONLY. A gen-conn bit_select index that is constant after genvar substitution
  folds to ONE UINT at the index expression's FIRST token. And an elab var-dim bound folds only when the
  literal-init param lives in the SAME InstanceBody — slang value-dedups an instance body under a second
  parent, so currentScope is then the ENCLOSING module and a bound resolves to the parent's same-named
  param at its narrower width. (First predicate attempt regressed macc; refined.)
- arraycells DIFF->CMP_ONLY (8133 -> 6 byte lines). A MODULE instance array emits per-index elements
  under vpiModule PLUS a module_array wrapper in the ELAB view — the mirror of the interface array, whose
  module_array is def-view-only — with its range and module_typespec left BARE. Also: a slang
  instance-array element has an EMPTY name (the index lives in the elaborated path only), and Surelog's
  elaborator builds the element-select index itself (folded, spanning the connection token, no
  vpiConstType, unparented).
- func_upto DIFF->CMP_ONLY. Surelog keeps the func_call for EXACTLY the 512 of 2144 instances whose body
  loop runs at least once: evalStmt reduces an ASSIGNMENT's Rhs with pexpr set, and in that context a
  bit/part select of a function-scope object does not resolve; operators that read operands through the
  SHARED invalidValue flag (&&, ||, &, |, ^, ~, !, ==, *, -, <<, ?:, select indices) then abort the whole
  fold, while vpiAddOp/concat use LOCAL flags and still fold. subroutinePoisonsEvalFunc reproduces the
  per-instance fold/no-fold exactly (512/1632 on both sides). REFUTED: lifetime, body localparam,
  $-system-call, recursion — none apply here.

## (superseded) Drive 8b (2026-07-24 ~09:30 -> ~18:10, Opus lane): 487 PASS / 169 CMP_ONLY / 5 DIFF

Started at 420/203/38. Goldens 23/23 throughout; every landing gated on a full corpus run plus a
verbatim movers diff, and every regression was refined (or reverted with the distinguisher recorded)
rather than forced through.

### IN FLIGHT
Wave 54 fully landed (ps54, if54, gen54 — gen54 gave gen_struct_access + gen_test5 +
iface_ff_genvar_partsel DIFF->PASS). Wave 55 is running four agents over ALL 19 remaining DIFF tests:
  /tmp/sp55.patch  — BitSelect trio + TypedefStructParamWithRangeInSubmodule
  /tmp/if55.patch  — iface_cfg_param_def_pass, iface_array_elem_cfg_param, iface_param_2level
  /tmp/mac55.patch — int_types, multiplier, cs_registers, func_upto
  /tmp/sm55.patch  — const_arg_loop, func_tern_hint, rsp_gen_minimal, arrays03, prefix, rotate
Apply each with `git apply --3way`, rebuild, spot-check, full-corpus gate, commit if clean.
ac56 owns the last two DIFFs (arraycells, const_func). Wave 57 additionally runs two agents on the
biggest CMP_ONLY byte piles:
  /tmp/hp57.patch — hier_path (3345 lines) + the ref-fullname family. Profile: ~500 lines are Surelog
    naming a part_select <instance-prefix>.<own name> again (doubled) so every ref under it inherits
    the doubled prefix via ComputeFullName, while we emit the single form — context-dependent, since
    our dump already has the doubled form in 520 other places; ~248 lines are operands Surelog parents
    at their operation. A marker sweep over the 8 MakePart_select sites is inconclusive because later
    code overwrites vpiDefName there.
  /tmp/pp57.patch — the pattern-parameter pile (NestedStructArrayParameter… 1620, StructArrayParameter…
    999, plus assignment-pattern/struct_pattern_loop/ParameterUnpacked* relatives).
LANDING ORDER when several arrive together: land the largest/most independent first, then `git apply
--3way` the rest; expect conflicts in TypeEmit makeTypespec and the ModuleEmit cont-assign chain.
Apply with `git apply --3way`, rebuild, spot-check, then full-corpus gate before committing.
NOTE on if54: it was written against the pre-ps54 HEAD and CONFLICTS in TypeEmit.cpp makeTypespec
(~line 128) with the elaborated-pkg-typedef rule ps54 landed. Resolve by KEEPING OURS — ps54 fixed the
NSAP root cause (a nested inner-struct leaf missing its package vpiInstance), so if54's span-stretch
workaround is unnecessary. A mid-flight snapshot of if54 measured interface_array 258->174 but
iface_cfg_mem 611->647, so re-measure the finished patch before gating.

### Ready-to-act decode: arrays03 (r=1)
An OBJECT-COUNT split on the $unit typedef `typedef reg8_t [0:3] reg2dim1_t`. Surelog emits ONE
design-parented reg2dim1_t plus 14 per-use reg8_t ELEMENT clones; we emit 3 reg2dim1_t (the $unit
typedef loop in UhdmExporter.cpp ~734 stamps it once per TOP in a multi-top design) and only 11
reg8_t. A WIDE marker sweep (220 VpiName sites) pinned both producers: UhdmExporter.cpp ~734 (the $unit alias
design listing, one object) and ModuleEmit.cpp ~6643 (a NAMED per-port clone for a file-level vector
typedef, gated by `fileLevelVec`). Surelog has BOTH of those too — its per-port clone sits at the PORT
type span (42:12-42:22) where ours binds the shared typedef object (5:9-5:21). So this is not a
"drop the duplicates" fix: the real gap is the ELEMENT clones (Surelog 14 reg8_t vs our 11) plus which
object each port typespec ref binds. Treat the reg8_t element-clone-per-use rule as the lever: Surelog has 12 `ref_typespec: (reg8_t)`
Typedef_alias refs to our 10, i.e. exactly two use sites that never reach the ModuleEmit ~6643 helper
mint no clone. Find those two uses (compare the reg8_t-bearing objects' parents between the dumps).
Found with a name-suffix instrumentation sweep over the 10 `->VpiName(<alias>.name)` clone sites —
stamping a unique marker at each candidate site and grepping the dump is the fastest way to identify
which of several look-alike sites actually emits an object.

### Remaining DIFF (5)
arraycells (r=1, missing elab module_array object with 32 vpiModule children + module_typespec),
cs_registers (r=-601, pkg-param ts aliasing + always-block bit_select LHS),
func_tern_hint (r=1, ONLY Surelog's evaluator arithmetic-shifting a signed operand `-1>>2` — replicating
needs a whole SL constant evaluator; PARKED),
func_upto (r=12, const-function fold, 28820 lines),
multiplier (r=-32, elab genvar-fold/positional lowConn tail).
CONVERTED since the 7-DIFF state: const_func + rsp_gen_minimal (df62 — string-param folds sized at LHS
width in gen CAs; blocking-written whole logic_net repoints to its first bit_select; blocking-written
pkg-struct port becomes struct_var). prefix, rotate, arrays03 (wave 58). int_types (mac55).

### REFUTED this stretch (do not retry blindly)
- Parenting the synthetic op11 `INT:1` everywhere: 9 PASS demotions (it is view- and owner-dependent).
- Parenting def-view net typespecs at their net: partsel_simple / vector_index / simple_hierarchy all
  get worse, whichever net object is used.
- Parenting an if-condition at the if_stmt when the enclosing scope is a case_item: struct_access and
  unique_case regress.
- Suppressing the formal-ts ref on ALL nested call arguments: const_fold_func PASS->DIFF (a
  module-context gate rescues NestedCallsOfTheSameFunction but not const_fold_func).

## (superseded) Drive 8b interim: 462 PASS / 175 CMP_ONLY / 24 DIFF

Continuation of drive 8 after a network drop. Goldens 23/23 throughout; every landing
gated on the full corpus + a verbatim movers diff. Waves 50-53 (Opus worktree agents,
3-4 at a time) plus a continuous serial lane.

### DIFF -> CMP_ONLY / PASS this stretch
unbased_unsized_param, DivisionOfSize, TypedefVariableDimensions,
ucsbece154b_victim_cache (PASS), asym_ram_sdp_read_wider + write_wider (PASS),
read_remux (PASS), func_typename_ret, ParameterFromPkgOnParameterPortList,
iface_struct_field_param_width, iface_wholestruct_param, iface_array_modport_drive,
NestedStructArrayParameterInitializedByPatternPassedAsPort, ImportedDoubleCastedParameter.

### CMP_ONLY -> PASS this stretch (byte-level rules)
nested_struct, struct_typedef_packed_array, struct_array_indexed_write,
struct_little_endian_bit_array, struct_part_select_write, multidim_hier_path8,
MemberSelectOf2DStructPackedArray, ImportedParameter, ParameterDoubleUnderscoreInSvFrontend,
BitsCallOnParametetrizedTypeFromPackage, InterfaceParameter, InterfaceParameterSetValue,
iface_param_set_value, StructParameter, StructLocalParam, AnonymousUnion,
AssignToUnionAndReadField, AssignToUnpackedUnionFieldAndReadOtherField.

### Models landed (each gated separately)
- Unbased-unsized override pa constants bind the param's OWN elab typespec; a '1 copy
  read by a cont-assign takes its own clone. An unbased CA RHS into a SELECTED target
  reuses the def constant instead of re-folding.
- A module-view copy of an imported package param's initializer keeps pkg vpiInstance on
  its size-cast typespecs and parents them at their ref_typespec.
- A def-build member alias clone of a module typedef carries the typedef's vpiInstance;
  cross-package struct members keep their HOME package instance; alias-less elem refs are
  bare (no leading separator).
- A var declared from a PACKAGE unpacked-array typedef is a MINIMAL array_var sharing the
  package array_typespec.
- Struct-member SELECT hier paths: the select span stops at the bracket; a PROCEDURAL write
  names the select (vpiDefName) and anchors the base ref at the member token, a cont-assign
  lvalue anchors at the index and keeps the dotted text, a read keeps the hier text.
- Materialized imports: param typespec parents at its ref_typespec,each reference mints its own
  clone, and a cont-assign fold constant parents at the package param_assign.
- Anonymous unions: the ELAB clone spans the `union` keyword and scopes member refs through
  the signal; the DEF object keeps the header span (packed) / stops at the first member
  (unpacked).
- A dotted-LHS cont_assign keeps the SHARED def object only when its RHS is a plain signal
  reference (literals, operations, params and enum values all re-emit fresh).
- Agent-landed: pkg-param based-DECIMAL folds keep DEC; untyped-param concat folds keep the
  concat width; the const-function fold gate is "body declares a localparam", not lifetime;
  overridden struct params copy the referenced param's Rhs tree; gen-scope CA index refs stay
  unbound and loop-body params fold; an instance's own body typespecs drain before its
  descendants'; >64b imported struct params strip tagged wrappers in the elab view.

### Later in the stretch (waves 52-53 agents + serial)
- Operand constants carry vpiParent IFF their owning object was DEEP-CLONED at elaboration
  (Surelog's compileConst never parents; clone_tree/DeepClone re-parents every child) — decoded from
  Surelog's sources and verified across 441 dumps.
- Ref fullnames are computed by UHDM's ComputeFullName walking vpiParent (skipping a bit_select or
  hier_path directly above a ref_obj), so the fix is usually to LEAVE the fullname unset; spans anchor
  on raw source tokens.
- A package typedef exists as TWO objects (def listing + elaborated); signal uses bind the elaborated
  one, struct-typedef PARAM uses keep the def one (NSAP vs PartSelectInFor).
- Surelog reports source positions in the FULLY MACRO-EXPANDED text: recursive expanded-length model,
  nested-call deltas, multi-line bodies, multi-token argument merging (int_types -800, multiplier -280).
- cont_assign sharing: a dotted/select LHS keeps the shared def object only when the RHS is a plain
  signal reference; literals, operations, params and enum values all re-emit fresh in the elab view.
- Anonymous struct/union typespec views; whole-assigned signals get bare member refs and no owner parent.
- Package struct-member bounds keep the written syntax in the def view and fold to a signed int at the
  identifier token in the elab view.

### Wave 62 landings (each gated vs a fresh HEAD baseline)
- df62: const_func + rsp_gen_minimal DIFF->CMP_ONLY (2 conversions). See remaining-DIFF note above.
- pat62: pattern-param byte reductions, no class change (no pendingPatternOrphans op for raw
  unpacked-array cont_assign patterns; unary-op real-literal operands stay unparented). Confirmed the
  per-ref struct/array typespec clone weak tail (~100 exact clones in pool order) is INTRACTABLE:
  high PASS->CMP_ONLY risk, zero cmp benefit — do not attempt.
- if62: hier-path param-init ref-span byte reductions, no class change (ClogOf 59->37, OutputSize
  76->59). Family A (iface member-typespec tail ordering, 4 tests) needs an all-or-nothing 3-part arena
  reorder (io60 also deferred it) — negative EV under the hard gate, left.

### Waves 60-61 landings (each gated, zero regressions)
- io60: interface-array-port byte-polish, no class change (elab interface_array range stays bare;
  modport-port array_typespec parents at the port). Agent declined the deeper interface typespec-order
  change as too risky on an already-passing cluster — left for later.
- ms61: 3 member-select CA tests CMP_ONLY->PASS. A member-select (hier_path) LHS cont_assign keeps a
  BARE loc-only RHS constant in the elab view — the "select-LHS literal re-compile" rule had
  over-applied the parented/sized form to the hier_path-LHS case.
- en61: enum-param clone byte reductions, no class change. An overridden enum param whose value
  ORIGINATES (through param hops / member selects) in a different package instances its clone at the
  VALUE-ORIGIN package, not the enum's home (new enumParamValueOriginPkg). Confirmed xt59's deferred
  diagnosis via a marker sweep. Still-deferred: the E1/E2/L1 def/elab enum doubling (cross-wire
  machinery) and the caFold9 bare base-ref fullname.
- ro61: REVERTED. Its lowConn-span byte-reduction (wandwor 22->2, net-to-net-aliasing -> port-decl
  span) regressed setundef PASS->CMP_ONLY — the agent gated against a stale baseline and missed it.
  setundef is `foo #(2'b0x) foo(o);` connecting top's net `o` to foo's OUTPUT net `o` (SAME name,
  passthrough), a net-to-net case where Surelog KEEPS the conn-site span. So the rule needs a further
  gate (output-direction? different-object? passthrough exclusion). Patch parked at /tmp/ro61.patch;
  re-derive the exclusion before relanding.

### Waves 55-59 landings (each gated, zero regressions)
- pp57: 5 CMP_ONLY->PASS (LocalParamSelect/NestedForLoops/ParameterUnpackedArray/
  ParameterUnpackedLogicArray/PatternParameterInSubmodule). An unpacked-array-param ELEMENT SELECT
  claims the pattern's leaf constant (leaf span + CA parent; its Lhs binds DEF nets so an `output int`
  target reaches the def logic_net). The elab array_typespec is a WRITE-PHASE clone with its own ranges.
- mac55: int_types DIFF->CMP_ONLY (8984->3040), cs_registers 1195->1013. NOT vpiSigned/typespec-count as
  briefed — it is the elaborated gen-scope-local model: unnamed begin blocks count as genblkN at MODULE
  scope, gen locals emit their true var/ts CLASS (int/shortint/longint/byte/bit) with per-view
  signedness, and an INT-encoded fold (negative/multiplicative) SHARES the param's typespec.
  (mac55 branched from an earlier HEAD; its UhdmExporter.h struct-field and ExprEmit unary-suppression
  hunks conflicted with waves 57/58 — resolved by UNION, keeping both sets of flags.)
- if55: 3 iface DIFF->CMP_ONLY. A CA reading an interface param through the module's OWN iface/modport
  port is exempt from the elab general fold (the cast keeps its hier_path). REFUTED "the def view always
  keeps the tagged form": the distinguisher is interface-ARRAY instantiation, where Surelog re-reduces the
  DEFINITION's struct param default to a flat op75 with a BARE (unparented, unnamed) ts ref.
- sm55: const_arg_loop DIFF->CMP_ONLY. A DEF-view param used as a direct actual of a cont-assign function
  call has its own ref_typespec rebound to that call's formal ts (LAST call in source order wins);
  procedural calls never rebind. A nested call to a PASS-THROUGH function (return value IS a formal)
  carries no formal-ts stamp — that is the const_fold_func distinguisher I missed earlier.
- sp55: all 4 struct-param tests DIFF->CMP_ONLY. A package struct param whose member carries a
  PARAMETER-DEPENDENT packed dim never flattens its pattern in EITHER package view
  (structHasSymbolicMemberDim) — the old "width > 64 keeps the tagged tree" gate was only a proxy.
- ac56: no conversions but const_func 507->175 and arraycells element defs fixed. compileGenStmt always
  makes ONE gen_region but fills it from only the FIRST generate item (later items contribute nothing;
  the begin is EMPTY when the first item is a genvar decl or loop-generate — gen_test6's golden encodes
  this). A process written directly in an explicit generate region is appended to the DEFINITION once per
  INSTANCE. ExprEval::evalFunc stamps formal typespecs onto actual args BEFORE discovering it cannot
  evaluate, so a call kept symbolic still carries them.
- hp57: 4 CMP_ONLY->PASS, hier_path 3347->1323. A part_select REPEATS its base name so its own fullname
  doubles, and refs inside its range expressions scope through it — ComputeFullName skips only
  bit_select/indexed_part_select/hier_path, NOT part_select. A range endpoint that IS a literal stays
  unparented; a constant nested in an endpoint operation keeps its operation parent. Surelog's lexer
  folds whitespace TRAILING a based literal (1'b0/4'd2) into one column, shifting later columns left.
- hier_path's remaining 1323 lines are BALANCED (661 SL-only vs 664 ours-only), dominated by 146 bare
  anonymous int_typespec objects on each side: pure tail ORDERING, not missing objects.

### METHOD (reusable)
The corpus CSV records each test's DUMP_DIFF line count. Sweeping every CMP_ONLY test into a
scratch dir and clustering the NORMALISED diffs (numbers -> N, names -> X) exposes shared
byte-level rules fast: 4-line diffs cluster into 2-5 test families, and clustering by FIRST
divergence found families of 20 (ref_obj spans), 12 (bit_select spans), 18 (operation-operand
parenting), 43 (def cont_assign sharing). Count changed lines with `grep -c '^[-+]' dump.diff`
minus 2 — NOT wc -l, which counts context lines.

## Drive 8 (2026-07-24 03:00 -> ~19:00): 420 PASS / 203 CMP_ONLY / 38 DIFF @ ~17:20 (near-final)

16-hour drive: 68 -> 38 DIFF (30 removed), 418 -> 420 PASS. Goldens 23/23 throughout;
zero regressions kept (every gate = full corpus + movers diff). Waves 23-49 (one to
three Opus worktree agents each) + a continuous Fable serial lane.

### Converted this drive (DIFF -> CMP_ONLY unless ->PASS noted)
hierdefparam, iface_array_{struct_whole,port,struct}, EnumInPackage, MIAIP
(ModuleInstantiationAndIndirectParams), assignment-pattern, MultirangesStartNotFromZero,
genvar_iface_struct, hier_path, ExpressionInIndex, iface_nested_param_field,
simple_package, nested_struct, static_cast_simple, struct_param_dim(->PASS),
simple_instance_array(->PASS), iface_scalar_localparam, iface_struct_field_partsel,
genscope_cells, macc, generate_test, VarPassedTo2Submodules,
ParameterOfParametrizedTypeInSubmodule, iface_unpacked_struct_array,
interface_array_fanout, iface_arr_struct_{whole_field,field_partsel},
ParameterOfSizeOfParametrizedPortInSubmodule, ImportedDoubleCastedParameter(earlier
r-fix; still DIFF at pkg dup layer)... plus big cmp-advances left in DIFF: gen_test5
(r=-502->-1), unbased_unsized_param (r=-9->1), ucsbece154b (dl 241->38), BSOPPS
(r=9->-32 deeper), rotate (dl 4764->444).

### The current 38 DIFFs — see results/triage_drive8.txt (fresh r-sweep @ b1513f9)
Clusters: keep-symbolic op-vs-constant r=32 family (BitSelect*GenFor x2,
iface_param_2level/wholestruct, TypedefStructParamWithRange — override-substituted
iface ranges + gen-for pkg-param select folds); missing ref_typespec r=1 family
(func_typename_ret, PartSelectInFor, ParameterFromPkgOnParameterPortList,
iface_array_elem_cfg_param, iface_struct_field_param_width r=-1); near-r singles
w/ banked decodes in memory drive8-progress (rotate = gen-local proc-driven REG
netting NetType:48; gen_test5 = unnamed-genblk bind, no clean distinguisher found;
prefix = assert hier-leaf bind asymmetry; func_tern_hint = Surelog const-func EVAL
quirk — likely permanent park); structural bigs (arraycells module arrays,
iface_ff_genvar_partsel gen_region wrapper, const_func gen-case elab, int_types
macro-span clones, cs_registers span normalization, func_upto symbolic call keep,
multiplier extra net).

### Method notes for drive 9
Agent-ops learnings in memory note drive8-progress (unique helpers, no git stash,
main-tree gates only, small schemas + early StructuredOutput, always check
/tmp/<label>.patch after agent deaths). Serial lane pattern that worked: probe ->
decode distinguisher from BOTH dumps -> narrow gate -> corpus arbitration; every
refuted broad rule became a narrower landed rule the same hour.

## (superseded) Drive 8 mid-drive checkpoint @ ~08:00: 418/190/52

Waves 23-36 + serial lane. Landed: iface-ARRAY family (def+elab layers, 4 tests),
genvar_iface_struct, hier_path (biggest test), Multiranges, MIAIP, EnumInPackage,
const_func string layers, assignment-pattern, simple_package, nested_struct,
ExpressionInIndex, iface_nested_param_field, arrays03/struct_param_dim partials,
selName/display policies, wave-24 array classification, gen-lp mulDiv INT rule.
REFUTED: bsopps27 (pkg struct-pattern keep too broad — see memory drive8-progress).
Agent-ops hardening: unique helper scripts, small schemas + early StructuredOutput
(waves 21/25 died at the structured-output cap with good orphan patches — always
check /tmp/<label>.patch), main-tree gates only (agents' worktree baselines lie).
Running waves at this checkpoint: ifp33 (iface modport-port pa), vp34 (enum-alias +
port-var-flip + gen_struct_access coupled), gsc35 (gen-instance ts clones + r=32
family), tdc36 (typedef clone/share policy). See memory note drive8-progress for
the full ledger and open decodes.



> **READ [PLAYBOOK.md](PLAYBOOK.md) FIRST.** It governs HOW to work: the goal
> is 0 DIFF / 0 CMP_ONLY, autonomous blocks never pause at milestones or ask
> to continue, risk is a gate to run (not a reason to stop), and every
> regression is the experiment that reveals the missing distinguisher
> (revert-and-REFINE, never revert-and-abandon). This file records WHERE we
> are; the playbook records HOW to keep moving.

## Drive 7 (2026-07-23 12:00 -> 2026-07-24 ~03:00): 418 PASS / 175 CMP_ONLY / 68 DIFF (FINAL)

16-hour Fable-serial + Opus-agent-wave drive (waves 12-21, 2 worktree agents each,
calibration-hardened briefs). 98 -> 68 DIFF (30 removed), 405 -> 418 PASS. Goldens 23/23
throughout; zero regressions kept (every gate = full corpus + movers diff vs
results/baseline_auto.csv).

### Converted this drive (DIFF -> CMP_ONLY/PASS)
net_types, param_array_wildcard, ParameterPackedArray, sva_range(->PASS),
StructArrayParameterInitializedByPatternPassedAsPort, fail_detect_width(->PASS),
LocalParamInNestedForLoops, gen_test4, UnionCustomTypeMultirange, realexpr,
iface_param_port_width, iface_cfg_mem, ModuleUsingStuctInput, ImportTypeOfPort(->PASS),
OutputSizeWith...StructMember, ClogOfParam...StructMember, subbytes(->PASS),
genscope_async_ff_signal(->PASS), MemoryInGenblock(->PASSS), StringWithBackslash(->PASS),
BitsCallOnExpression(->PASS), struct_3d_packed_array(->PASS), struct_init_partial_write(->PASS),
multidim_hier_path7(->PASS), asgn_binop(->PASS), Casezx(->PASS earlier in drive), and more.

### The current 68 DIFFs — clustered from results/triage_drive7_final.txt (fresh r-sweep @ 002cc35)
1. **iface-ARRAY family (5, r=-2359)**: iface_array_{modport_drive,port,struct,struct_whole} +
   genvar_iface_struct — array_typespec(SL) vs interface_typespec(ours): interface ARRAY
   ports need an array_typespec wrapper model. Single shared mechanism, biggest cluster.
2. **module_inst rhsNULL family (~10, r=1)**: arraycells + simple_instance_array (PRIMITIVE
   gate arrays — SymbolKind::PrimitiveInstance emission, P1 in batch-2 roadmap),
   MIAIP (child vpiTypedef listing — wave-21 in flight), interface_array_fanout,
   gen_struct_access, hier_path + ucsbece154b_victim_cache (select-member hier_path model:
   csr_pmp_cfg_i[r].mode / dll_d[i].valid need hier_path + doubled elem struct_net),
   VarPassedTo2Submodules (net-vs-var port modeling, decoded in memory),
   TypedefVariableDimensions (array_var + pkg array_typespec ref), ParameterOfParametrizedTypeInSubmodule.
3. **t2304 ref_typespec rhsNULL family (6, r=1)**: iface_scalar_localparam,
   iface_struct_field_partsel (naming layer done, ONE ts ref missing),
   iface_nested_param_field, iface_array_elem_cfg_param, ParameterFromPkgOnParameterPortList,
   PartSelectInFor, func_typename_ret ($unit ret clone chain + orphan-serialization blocker
   — see memory).
4. **keep-symbolic stragglers (r=32/601)**: BitSelect*InGenFor* (gen-for variant of the
   member-init family), iface_param_2level (2-level SYS_DAT un-fold, deferred as high-risk),
   iface_wholestruct_param (module-localparam nested-pattern keep), simple_package (wave-14
   partials landed; 3 sub-models decoded in memory), TypedefStructParamWithRangeInSubmodule,
   MultirangesStartNotFromZero (packed-array-of-struct dims — wave-21 in flight).
5. **Surelog-quirk / eval families**: func_upto r=12 (const-eval BAILS on variable-width
   partial part-selects — keeps func_call for 512 instances), int_types + multiplier +
   asym_ram pair (macro nested-arg width edge cases; asym at dl=63), cs_registers
   (32'(P) cast keeps the param's SOURCE literal encoding DEC:1/2'd1), hierdefparam
   (defparam), EnumInPackage (naming, parked), unbased_unsized_param (CA-claimed shared
   constants), static_cast_simple, rotate + genscope_cells + generate_test + gen_test5
   (gen HighConn/hier naming family), ExpressionInIndex + IndexedPartSelectInFor
   (hier-path naming), prefix, const_func, const_arg_loop (func ts kinds), macc
   (def bound const size-32 — emitter untraced), struct_param_dim (child elab CA def-share),
   read_remux (gen CA select-bound localparam folds, decoded), rsp_gen_minimal (pkg
   literal-op member bounds fold in ONE view + use-site ts span), assignment-pattern,
   func_tern_hint (Surelog eval quirk), DivisionOfSize + nested_struct +
   NestedStructArray... + arrays03 + ImportedDoubleCastedParameter + EnumInPackage
   (pkg identity/orphan family).

### In flight at close
Wave-21 (wf_94c309bb-c7f, /tmp/final21.patch): MIAIP child typedef + Multiranges dims +
BSOPPS TopPackages importer-first order. If not merged, verify the patch fresh (calibrate,
gate) before applying.

### Where the decodes live
memory/diff-fix-roadmap.md carries the per-test decodes and refuted experiments for this
whole drive (bottom half). Key reusable models discovered: member-init symbolic family,
select-repoint ruleset, per-view netType policies, pkgTopMap cross-view linkage,
macro arg-substitution columns, nested packed pattern vpiSize stamps, modport port-view
param_assign keep, iface-member range keep-symbolic + elab fold-at-default.

## Session 21 (2026-07-23, drive 6 continuation): 405 PASS / 158 CMP_ONLY / 98 DIFF (FINAL)

DIFFs broke double digits (99). Serial lane + waves 5-6 (2 Opus worktree agents each).
Converted this session: simple_hierarchy + wandwor (clone-body ref binding: slang clones
InstanceBodySymbol per elaborated instance, so 2nd+ instances of a shared def missed the
symbol-keyed defInfo->nets — fallback matches name+decl-loc, RHS via `reemitting`, LHS via
`elabContAssignLhs`); union_simple (per-member vector-typedef alias clones in
buildStructTs/buildUnionTs + packed-union field => struct_var); size_cast (cast clones at
every scope + byte'() => byte_typespec incl. pendingCastTs drain); param_no_default +
ImportFunction + ParameterPassedTo{SubmoduleOfSubmodule,3TimesNested,InGenscopeOfSubmodule}
(wave-5); TypedefPackedDimensions (pkg packed-array typedef: shared named ts for net+var
views, no spurious wire net-type, alias-twin nameless Elem ref); struct_pattern_loop
(2-state bit model: bit_var scalars, array_var w/ shared-range bit_var element, BIT-element
def-port array_typespec wrapper, sizeless based pattern leaves);
iface_{samename_port,internal_assign,unpacked_signal,array_internal_assign} +
ParameterFromPkgInNestedModule (wave-6: iface elab var model + P=X pkg-param clone fold).

Key merge lessons: an agent's blanket "parent bare fold constants at ca" demoted ~26
byte-PASS tests — gate landed as isMultiParamDef && NamedValue-RHS; wholesale def-CA sharing
into iface elab views demoted InterfaceAssign — constant-RHS CAs keep the fresh per-view
re-emit; the untyped multiparam param fold ts is int_typespec at the FULL param-decl span and
must be checked BEFORE the bare-vec branch (implicit type is a packed logic[31:0]).

Parked with decode notes (memory diff-fix-roadmap): iface_gen_delay (iface gen-scope
Variables missing: logic_var tmp per gen_scope instance + bit_select naming),
iface_cfg_param_def_pass (def iface struct-param pattern needs tagged_pattern operands:
Pattern constant size 64 + string_typespec(member) ts ref; elab re-emits at override site),
ImportedDoubleCastedParameter / BitSelectOfParameterPassedToSubmodule /
ParameterFromPkgOnParameterPortList (pkg-level residues, wave-6 pk agent findings),
nameless pkg twin decode (aggArray branch in ParamEmit ~2404 = the alias-actual twin builder).

## Session 20 (2026-07-23, drive 6, levers 1+2+3): 405 PASS / 134 CMP_ONLY / 122 DIFF (in progress)

12-hour autonomous parallel drive (workflow opt-in). Serial lane + 4 waves of 2 Opus worktree
agents. Converted so far: SumOfParameters, 2DParameterOfInstance, size_cast_param,
named_genblk_cascade, TypedefedRangedFunctionReturn (byte PASS),
ImportedFunctionCallAsInstantiatedModulePortValueInsideGenFor (byte PASS), TypeParameter family
x4 (tp agent + clone finishers), StructParameterInitializedWithPatternAndReferenced,
iface_struct_field_bitselect (modport ALPHABETICAL ordering — iface agent),
multidim_hier_path9 (byte PASS) + multidim_hier_path8 + indexed_partsel_array (hp agent patch).

Major decodes: imported-param materialization (instance-override scan, overridden-default
re-bind, vector-typedef two-level alias clone chain, def Lhs param clone, source-form overrides,
pkg-typedef cast keep); gen-case symbolic def emission + else-if re-pass (nested genblk1 wrap,
first-item spans); concat/call conn scoping through instance+formal; const-call CA dual
emission (def func_call + elab BIN fold); type_parameter model (def default from port-list
syntax, per-tp typedef/enum clones); modports sort alphabetically (Surelog name-keyed map);
materializeDefNetTs = the typedef-net ts builder; pkg struct-pattern folds (BIN concat setters).

Agent-ops lessons: verify agent patches in the MAIN tree (claims can be placeholder junk);
a dead-on-StructuredOutput agent may still leave a complete patch at patchPath; converge.sh
sends exporter stderr to $WORK/slang.log.

Parked (documented in memory diff-fix-roadmap.md): LocalParamInNestedForLoops (module-level
extra param_assign model decoded, late-renamer unidentified), net_types dual net listing,
TypedefVariableDimensions (array_var + shared pkg array ts model), ParameterFromPkg pair,
simple_package pkg-fn return-range binding, wandwor multi-driver CA binding, ImportFunction
pkg-fn copy clone forensics, multi-distinct-parameterization cluster (wave-4 agent on it).

## Session 19 (2026-07-22, drive 5): 402 PASS / 120 CMP_ONLY / 139 DIFF

~30 gated commits (fbadcb2..bdd3e21+). Converted: typedef_package, package_task_func (+2 bonus),
MemoryInGenblock, typedef_packed_enum_array (byte PASS), jeras_gpr (byte PASS, 400-milestone),
GenIfInside (byte PASS), iface_struct_field, iface_sig_in_child_port, iface_modport_out,
add_sub_bind_if (byte PASS — clocking blocks landed!).

Major features: r=601 family (pkg def-refs symbolic + enum-origin HEX folds), pkg fn/param elab
semantics (tfShells, view-local chaining, computed folds), pkg-imports-pkg clones (enum+struct),
vector/enum typedef array forms, emitSyntaxExpr ternary+inside ops, location-sorted param lists,
iface group-10 (dup bare ports, port-view decl-span LowConns, doubled port-backed modport nets),
NAMED clocking blocks (cross-view event binding), iface unpacked array_nets, non-ANSI/mixed-conn
ref_module omission rules.

All decodes and next targets in memory diff-fix-roadmap.md (the process-context hier-select rule
blocks mem_read_reg/iface_field_partsel/iface_unpacked_signal; arena-content pairing blocks the
ParameterPassedTo trio + multidim pair).

## Session 18 (fable[1m], 16h autonomous drive 4, 2026-07-22, in progress)

**Running: PASS 398 / CMP_ONLY 114 / DIFF 149** (drive start 397/109/155).
Converted: carryadd, defvalue, dff_different_styles, gen_test7,
gen_test8(->PASS), genscope_async_ff_signal; byte-upgrades held. ~20 commits
(37096df..97247f3), goldens 23/23, zero regressions (every demotion bisected
back to green same-session). Highlights:

1. **Port-default semantics decoded** (defvalue): def ref_module omits
   `.name`-shorthand HighConns and default-conn ports entirely; def port
   default refs double prefix.PORT.name; elab OUTPUT-port initializers
   synthesize a loc-less initial (bare Lhs ref + use-site clone of THIS
   instance's param const — walk m->Param_assigns() by name, pointer maps
   cross specializations); elab INPUT-port defaults synthesize a
   net-decl-assign CA (folded const + fresh Lhs net w/ folded-range ts);
   unconnected-with-default elab port HighConn = folded UINT64 const.
2. **Gen-scope binding refined further**: own-scope CA LHS refs resolve by
   NAME against the module scope; DRIVEN REG-keyword locals (CA or process
   writes) -> logic_net 48 (logic-keyword stays var); net-kind locals stay
   unbound in processes; blkWrites feeds hasBindableRef; symbolic hier base
   indices ([i-1]) -> bit_selects with SPACED re-lex in BOTH def emitters.
3. **Attr sharing**: ONE attribute object per (* *) spec across
   multi-declarator groups (keyed on AttributeSpecSyntax — symbols differ
   per net), parent = last net; module-level attrs on module_inst (span
   starts at the `module` keyword). def ref_module omitted when a
   positional conn is an OPERATION.
4. **Pkg struct ts span-stretch**: the TOP-view pkg struct typedef ts
   stretches endln to the LAST signal-use declarator that extends past the
   name (init or unpacked dims); def view keeps the typedef span.
5. **Func-ret pkg semantics**: pkg-typedef returns share the pkg ts
   (package parent kept), clones qualify names (P::S), ret vars span the
   trimmed return-type syntax; signed-scalar formal calls re-encode
   converted values (def INT:-1; elab folds to UINT32 at arg span with a
   formal-ts ref).
Parked with decodes in memory: arrays03 (per-use clone census),
gen_struct_access (packed-array-of-filelevel-struct port var form),
func_local_array (func-local begin-parenting minefield), iface struct-param
cluster (elab layers), func_typename_ret (last t2304), genscope_cells
(gen-local ts range folds).

## Session 15-17 (fable[1m], autonomous drives 1-3, 2026-07-21..22) — struct + def-view gen + macro layout

**Running: PASS 397 / CMP_ONLY 109 / DIFF 155** (drives started at 391/63/207;
drive 3 alone: 393/103/165 -> 397/109/155). ~70 gated commits across the three
drives (through 0ff946e), goldens 23/23 throughout, zero net regressions.
Full ranked roadmap + per-test decodes live in the agent memory
(`~/.claude/projects/-home-heyfey-git-repos-slang-uhdm/memory/diff-fix-roadmap.md`)
— two 45+64-agent triage fan-outs clustered ALL DIFF tests by shared fix; the
re-runnable workflow script is referenced there.

Drive-3 headline features (all in NOTES-worthy detail in memory):

1. **Surelog macro-location model FULLY decoded** (947777d, eff740a, 1f658dc).
   Positions = the EXPANDED-LINE layout: single-line macro bodies place
   tokens VIRTUALLY at the invocation site (usage line, usage col + body
   offset — `macroInvLineCol`); file tokens AFTER an expansion on the same
   line shift right by bodyLen-usageLen (`buildLineShifts`/`fileLineCol`,
   enumerating all macro buffers via SourceManager); multi-line bodies keep
   DEFINITION-site spans (`getFullyOriginalLoc`); vpiFile maps to the
   definition file. Cracked struct_access(+PASS), array_assign,
   macro_arg_spaces->PASS, genscope_cells' macro layers. OPEN: arg-
   substitution column shifts inside multi-line bodies (asgn_binop r=1).
2. **Def-view gen-block content is now fully re-emitted** (86ddf3c..c8819e1).
   emitBranch recurses NESTED if-generates (chained named_begin fullnames,
   doneIfs dedup, construct-span on nested gen_if_else, loc-less top-level
   unless in an explicit generate region); emits PROCESSES via emitProcess
   with branch prefix + FULLY unbound refs (defGenProcessEmit — not even
   enum_const mints); unpacked-array decls stmt-ify as Rhs-less assignments
   with array_var (BARE symbolic dim refs, Elem_typespec link); stmts are
   stable-sorted into source order. Elab side: gen_scope array_var/array_net
   /ranged-logic locals, per-instance anon-struct ts clones, implicit nets
   dropped unless feeding a child instance conn (their CAs share the def
   object bare). Converted generate_scope_implicit_net(PASS),
   gpr_genscope_repro, genblk_order(PASS), EnumConcat, matching_end_labels,
   for_decl_shadow, gen_test9->PASS.
3. **Elab gen-scope binding rules decoded** (803dcaa): if/named-gen processes
   bind stmt-block locals + gen-block locals (plain refs); hier-path leaves
   bind only OUTSIDE procedural for bodies; loop-gen scopes bind nothing.
   `for (integer x=..)` -> integer_var. Unnamed gen block containing nested
   constructs takes its Surelog identity from the FIRST nested construct
   (genblk<idx+1> name + its span). Gen-scope reg local driven by a block
   cont_assign -> logic_net NetType 48.
4. **IF-gen elab CA select-bound param folds** (d077f71, bf1867c, 8f51c68):
   LHS bounds fold param refs to typed constants (base-scoped ts ref ->
   fresh SIGNED int_typespec at the param decl span); RHS bounds clone a
   use-site constant PARENTED at the param's own param_assign with an
   instance-scoped ts ref; literal-RHS re-elab parents direct literal
   bounds at the part_select. Loop-gen scopes keep symbolic bounds
   (gen_test1/3/6, MemoryPort, forgen02 were the distinguisher demotions).
5. **Struct family cracked** (bf1657b, eff740a, a06529a, cf3cee3):
   prefixedStructNet gate = NON-ANSI module header; 4-state struct with
   atom/enum/2-state top-level field -> struct_var; unsized based literal
   keeps vpiSize -1 on dotted CA LHS; anon packed-struct elab gets a
   per-instance ts clone + name+location attr fallback (distinct instance
   bodies break pointer maps — `findAttrs`).
6. Assorted: hier_path non-leaf refs must CACHE name-only fullnames (else
   the dump lazily recomputes scoped names — phantom-prefix diffs, also
   fixed the [idx]-dropping lazy walk for part_select under gen arrays);
   dotted sys-call args emit as hier_paths; gen-scope child conns scope at
   the GEN path (bit_selects double via inst name); gen-scope $bits CA
   carries a result-ts ref; alias-of-packed-array-of-alias nets omit
   vpiNetType (arrays03 layer).

Parked with decodes in memory: genvar_loop_decl_2 (int-ts identity graph —
use probe tool), named_genblk_cascade (per-depth elab gen_scope nesting for
else-if chains), genscope_cells (231 dump lines left: gen-local ts range
folds), asgn_binop (multi-line-macro arg shifts), assignment-pattern (pkg
struct ts: package parent + span stretched to the initialized use decl),
arrays03 (alias-clone at TypeEmit ~1583, extend to PackedArrayType-of-alias
targets), pinmux/2DParameterOfInstance clone graph, iface t2194 embed
cluster, int_types (needs full def-view stmt coverage under heavy macros).

## Session 14 (opus 4.8[1m], autonomous, 2026-07-21) — imports + negative folds

**Running: PASS 391 / CMP_ONLY 63 / DIFF 207** (start 391/58/212). Five
DIFF->CMP_ONLY conversions + one cmp-advance, all gated clean (PASS 391 held
throughout, no demotions, goldens 23/23):

1. **Imported package param materializes as a module param** (ImportedParameter,
   ParameterDoubleUnderscoreInSvFrontend DIFF->CMP_ONLY). An `import pkg::P;`
   param referenced in the body materializes as a module `parameter` with
   `vpiImported`. It is a RESOLVED copy: def param_assign RHS sized at the TYPE
   width (int->32, not the package def's 64-bit bare decimal); int_typespec
   instanced at the source package; the written-in-cont-assign fold locates at
   the REFERENCE site (elab) and carries a ref_typespec->the imported param's
   def typespec (def). `importedParamDefTs` maps pkg-param symbol -> def ts.
   Gated to actual imports (wildcardPkgs/explicitSyms) + cont_assign parents so
   qualified `pkg::P` folds are untouched. OneImport still DIFF (explicit-import
   import_typespec multiplicity — distinct cluster).
2. **Header-imported typedef port emits BOTH alias clones** (ImportTypeOfPort
   DIFF->CMP_ONLY). A header-imported pkg typedef used unqualified as a port
   type makes TWO typedef-alias logic_typespec clones: elab (unqualified name)
   AND def (qualified name, self-alias, pkg instance, copied range). Ours had
   only the elab clone; added the def sibling. Residual 6-line vpiParent:package
   ordering cosmetic (cmp accepts).
3. **Param cast width in a GEN-BLOCK function** (CastInFunctionInGenBlock
   cmp-advance 50->43, still DIFF). `(P)'(x)` reuses the param's int_typespec +
   hangs a doubled-name (P.P) vpiExpr ref_obj ONLY for a function directly in
   the module; a function inside an elaborated generate block builds a fresh
   integer_typespec (params fold). Gated on currentSubSym having no
   GenerateBlock ancestor. (Distinguisher via demotion: plain in-function gate
   regressed CastInFunctionToParameterWidth.) OPEN: the remaining elab operand
   fold (Depth->500, PtrWidth->3 inside the gen-block function body).
4. **Negative-signed param init folds to INT** (int_types_blk1 DIFF->CMP_ONLY).
   tryFoldConst refused negative-signed values w/o typedConv, so `localparam
   integer y = -1` kept the unary op in elab; SL folds to INT:-1/32. Pass init0
   as typedConv for ALL typed params; fold negative directly (INT) when the
   TARGET type is signed integral, else re-fold through the conversion to the
   unsigned type width; encode still-negative as INT (never UINT:-n -> 0).
   TARGET type governs, not the init self-type (`~(15)` self-typed int but a
   logic[17:0] param wants UINT:262128 — via ParameterInitializationWithNegation
   demotion).
5. **Cont-assign param concat stays an operation** (param_int_types
   DIFF->CMP_ONLY). SL reduces a literal-only concat to a packed constant but
   leaves `{a,b,c}` of params as an op with ref_objs. Skip the cont-assign
   general fold when the concat contains any Parameter NamedValue (literal-only
   still folds — StreamOp demotion set the line).

**Method note (holds):** every regression above was the informative experiment
— diff the demoted DUT vs the helped DUT, the difference IS the gate.

**Session 14 continued (2nd block) — structural cracks + more imports:**
6. **Non-top def port range stays symbolic** (ParameterOfSizeOfParametrizedPort
   + ReplicationPassedToInstance: BOTH def views -> r=0). Cracked the
   def/elab shared-typespec blocker: a defPortDim flag around
   emitModuleDefPorts's emitPorts unfolds module-param dim bounds ONLY for
   NON-TOP defs (a top def's ports get the write-phase swap; a non-top def's
   port ts is not shared with the elab child port ts — safe). Both tests keep
   elab layers ($bits(a) param at 4:25; replication param-subst scoping).
7. **Vector-typedef param DEF ts shares the typedef logic_typespec**
   (ParameterOfParametrizedType def -> matches, 166->100). deferAggTs now
   includes PackedArrayType-integral TypeAlias; elab keeps the aliased clone
   (makeParamTs). OPEN: elab needs a 2ND aliased my_type_t clone for the
   int'(Y) cast ref (SL has 2 elab aliases, ours 1; that clone parents to a
   ref_typespec (work@top.Y)).
8. **Wildcard-imported typedef's range param materializes** (BitsCall
   DIFF->CMP_ONLY; fail_detect_width advanced). collectImportedParams now
   scans each wildcard pkg's typedef range SYNTAX for identifiers resolving to
   imported params. fail_detect_width OPEN: imported UNTYPED param int_typespec
   loc (SL 19:3-19:34 full decl, ours 19:13 name — side-effect of the
   typedParam fallback taking the implicit-type span) + design-level package
   ordering (LHS null / RHS package, shared with package_task_func).
9. **Cross-package pkg-param ref in a package init keeps its ref_obj**
   (ModuleUsingStuctInput 98->74). paramInitPkg + ref pkg != current pkg
   (first ::-segment of prefix) -> doubled-scope ref_obj (pkg::otherpkg::P).
10. **Hier_path range-select name drops source whitespace** (mem_read_reg
    112->88). selName() helper strips spaces/tabs from the rawText used for
    hier_path range names (sub.req.wdt[ 7: 0] -> [7:0]).
11. **Module param in an elaborated gen-block function folds** (CastInFunc-
    tionInGenBlock 43->37). ExprEmit NamedValue + emitSyntaxExpr IdentifierName,
    gated on currentSubSym having a GenerateBlock ancestor. OPEN: the LOCAL-VAR
    range bound [PtrWidth-1:0] emits in a DEFERRED typespec pass (currentSubSym
    null) so it stays a ref — thread the gen-fn ctx into pendingNetTs; plus the
    folded constants need a vpiTypespec.
12. **Imported UNTYPED param typespec locates at the decl span** (fail_detect_-
    width 116->53). makeParamTs: typedParam+ImplicitType (imported fallback)
    uses the ParameterDeclaration span, not the empty implicit-type span.
    fail_detect_width still DIFF (small t2254 int-vs-logic_typespec + design
    package-ref layer).

**Note on the non-top def-range fix (#6):** it makes the SHARED submodule port
typespec symbolic, so ParameterOfSizeOfParametrizedPort's ELAB port range is
handled correctly (elab leftRanges match SL); the def range is the symbolic one. Gate
clean, no CMP_ONLY->DIFF). The elab needs a FRESH folded port ts per instance
(not the shared def one). Also elab is missing a logic_net(submodule.a).

**More block-2 wins (2026-07-21):**
13. **Imported unqualified enum value keeps its ref_obj** (OneImport
    DIFF->CMP_ONLY). Gate the package-enum-const fold on ScopedName syntax;
    unqualified (imported) enum refs fall through to the general ref path
    (binds enumConstMap, names work@mod.V). EnumConcat advanced 124->92.
14. **Packed-array param assignment-pattern: op typespec + LSB-first reorder**
    (ParameterPackedArraySurelogSubstitution + param_packed_array_subst pair
    DIFF->CMP_ONLY). ParamEmit: a packed-array param's ASSIGNMENT-PATTERN op
    (opType 75, not concat — PkgParamAsFunctionArg demotion pinned that) gets a
    ref_typespec even w/ known operands. ExprEmit SimpleAssignmentPattern: elab
    param patterns (inParamInit && !paramInitDef) of an integral non-scalar
    type with >1 operand REVERSE operands + vpiReordered:1 + vpiSize:1.
15. **selName** (mem_read_reg), **imported-untyped decl-span loc**
    (fail_detect_width 116->53), **gen-block fn param fold** (CastInFunction-
    InGenBlock 43->37).

**Open (hana_test, 1-of-19-module-views from conversion!):** ONLY f6_test's
elab `assign out = p` differs — p (untyped param, =10) folds to a size-32
constant (value 10) but SL TRUNCATES to the 1-bit LHS `out` -> UINT:0 size 1,
located at the param default (84:15) with a ref_typespec->int_typespec. It is
NOT the 4020 typedParamRhs path (untyped p sets no typedParamRhs). Tried:
(a) LHS-width trunc in the 4020 path (no-op, wrong path); (b) excluding the
RHS from the shareWithDef def-cont-assign share (48->34 but the fresh fold
STILL gives 10, not 0, + weak-tail int_typespec reorder) — both reverted.
Next: FIND the untyped-param cont-assign fold that emits the located+typespec
constant (grep for a fold at paramDefaultSyn w/o typedParamRhs) and truncate
its value to ae.left() width. All 18 other module-views already match.

**Open (2D-array member hier_path — SelectOnMemberSelectedFrom2DArray +
IndexedPartSelectOfArrayElement):** `a[0][0].x[2]` (member access whose base
is a 2-D packed-struct-array element select) — ours emits a flat
`ref_obj (a[0][0])` where SL emits NESTED bit_selects (a[0] then a[0][0]).
The ExprEmit ElementSelect member-base path (~1941) only fires when the
base's esBottom is a NamedValue (single-dim `a[0].x[2]`); a 2-D base makes
esBottom an ElementSelect, so it falls through. Fix: extend that path to walk
a base ElementSelect chain and emit one bit_select per dim before the member
elems (mirror emitMixedHierPath's baseSelMode).

**Open (interface modport direction):** iface_modport_conn's instance-side
interface port (ModuleEmit ~1783) hardcodes vpiInout(3); SL wants 1 for that
`tcb_if.sub s` port. iface_modport_out already MATCHES (3,1,1,2), so the rule
is NOT "modport->N" — the 1783 path is the specific wrong one. Derive the
direction there (def-side dev port `s` is also 3-vs-1). Cluster: 5 iface_*
tests.

**Open cluster-roots decoded this session (resume here):**
- **DEF-view port range with an overridable module param folds when it should
  stay symbolic** (cluster: ParameterOfSizeOfParametrizedPortInSubmodule 4:18,
  ReplicationPassedToInstance 5:11). `output logic [X-1:0] a` where X is a
  module parameter (default OR no-default): the DEF (unelaborated) view keeps
  `X-1` as an OPERATION (X unresolved / overridable); ours folds it to a
  constant using the default. The range-bound fold path in TypeEmit chooses
  makeBoundConst (folded) vs emitSyntaxExpr (unfolded) — the enum base ts
  already keeps non-literal bounds unfolded (TypeEmit ~994-1004); the plain
  logic_typespec port-range path needs the same DEF-view gate. Both tests have
  further layers ($bits(a) param, param-substitution scoping) after this root.
  - BLOCKER (tried + reverted): a `defPortDim` flag around emitModuleDefPorts's
    emitPorts + a module-param detector in emitBound made BOTH def views
    cmp-MATCH (r=0!) — but def & elab ports SHARE one typespec object (TsCache,
    ModuleEmit ~781), so unfolding the def bound ALSO unfolds the ELAB port
    range (SL folds it there), breaking 2 goldens (23->21). Fix needs SEPARATE
    def vs elab port typespecs for module-param-dim ports (don't share the
    TsCache entry) BEFORE gating the def bound symbolic. "Stays symbolic" gate =
    the bound refs a non-local module `parameter` (localparam bounds fold).
- **ParameterOfParametrizedType DEF-view share** (elab clone landed, 166->103).
  DEF-view param typed by a local vector typedef wants the SHARED typedef
  logic_typespec (NO alias); ELAB wants the aliased clone (done, in
  makeParamTs). Routing the def param through deferAggTs->drainDefParamTs
  (direct-share) interfered with the elab clone (shared object re-point) — the
  def needs its own share without disturbing typedefTs[ta]. Next: give the def
  param a fresh NON-aliased clone (or a copy) instead of sharing typedefTs[ta]
  directly.

## Session 13 (fable, autonomous, 2026-07-20) — systematic-root + gen_for

**FINAL: PASS 391 / CMP_ONLY 58 / DIFF 212** (session start: 388/48/225;
pivot baseline DIFF 237 -> 25 real bugs fixed total; 3 straight DIFF->PASS:
ParameterInGenScopeInitializedWithLongConstant, MemoryPort,
local_nested_struct_field; late adds: StructOfArrayOfStructs + PackedArray
DIFF->CMP_ONLY via the pkg-struct-with-ARRAY-of-struct-member -> struct_var
rule; hasStructFieldMember counts array-of-struct members; module Typespecs
interleave own+imported typedefs name-sorted. EnumInPackage open: elab-view
import-listing order in a different container.)

**Late-session additions (after the gen_for checkpoint):**
- Elab gen CA genvar-ref fold -> iteration value (MemoryPort DIFF->PASS).
- PACKAGE TYPEDEF RULES (4x 5Level DIFF->CMP_ONLY + local_nested PASS):
  (1) emitPackage creates typedefs in SOURCE order but LISTS name-sorted;
  (2) module WILDCARD imports list every pkg typedef (name-sorted, shared),
  re-parenting + re-scoping FLAT ones interface-style
  (work@<mod>.<pkg>::<T>[.m], last-writer) while NESTED-container structs
  keep pkg parent; (3) elab params typed by a PKG typedef share the pkg TOP
  ts (no clone); (4) a wildcard-imported pkg's NESTED-container struct
  typedef's TOP view scopes members pkg::T.m (single prefix, dot) and is
  UNPARENTED — gated on wildcardImportedPkgs (qualified-only use keeps the
  doubled pkg::pkg::T::m form — BitsCallOnStructMember); (5) nested pattern
  ops (reemitting): no first-operand VpiSize + bare ts ref to the member
  typedef.
- hasStructFieldMember also counts packed-ARRAY-of-struct members (no wire
  type on such nets).
- OPEN: StructOfArrayOfStructs (53) — SL models the array-of-struct-container
  pkg signal as a struct_VAR (ours logic_net); direct-struct containers stay
  untyped logic_net (local_nested passes). Another micro-distinction to chase.

**STRUCT-PARAM SYSTEMATIC ROOT CRACKED (5 tests DIFF->CMP_ONLY):**
StructParameter, StructLocalParam, paramod_struct_param,
PatternAssignmentOfStructParam (+earlier AssignToUnpackedUnionField...).
The SL model (StructParameter cmp dump, 3 objects): (A) DEF param ref ->
SHARED named typedef ts, via NEW deferred drain `pendingDefParamTs` ->
`drainDefParamTs()` (UhdmExporter.cpp calls it after the def-content loop,
when typedefTs is populated; aggregate-typedef params only, def path in
emitParameters defers). (B) ELAB op-75 ts ref -> OWN module-scoped clone
(created FIRST). (C) ELAB param ref -> fresh clone, vpiInstance=module,
members scoped work@top.P.<ty>.<m> (makeParamTs memberScope via
syntaxRefPrefix; clone member-leaf ts parents at the member REF via
structCloneMemberRefParent). Fold rules: module struct params NEVER fold
(cast keeps cast-op, patterns keep ops; elab pattern = FLAT op-75 w/
source-encoded literal operands via emitExpr); pkg struct params keep only
PATTERN ops; whole-struct-param refs stay refs (module: share def CA;
pkg: pkg::-named ref bound to pkg def parameter); struct-param member
reads (N = Info.x) keep hier_path in BOTH views; elab CA o = P.a folds to
the member's pattern-setter constant (fresh CA).

**gen_for FULL MODEL (ParameterInGenScopeInitializedWithLongConstant
DIFF -> straight PASS):** inline-genvar for-generates only (separate
`genvar i;` keeps gen_region — gen_test6 golden). KEY DISCOVERY: uhdm-cmp
Compare distinguishes fields the DUMP prints identically — SL fills the
PLURAL VpiForInitStmts but the SINGULAR VpiForIncStmt (diagnosed with a
field-bisect tool $SP/cmptool linking libuhdm — REUSE THIS for future
DUMP_MATCH+CMP_FAIL puzzles). Full recipe in commit 305890e. Remaining
gen tests: MemoryPort (82), SumOfParametersInNestedForLoops (134) — nested
loops / next layers.

**Struct-param override layer still open:** instance-override param_assign
RHS should keep hier_path (Info.x) at the override site w/ NumScrmblBlocks'
int ts (Clog/OutputSize...InitializedByStructMember, ~115/183) — override
machinery (emitParameters override RHS path).

## ⭐⭐ SYSTEMATIC ROOT (blocks ~20+ DIFF tests) — param-ts-before-typedef timing

A parameter typed by a NAMED typedef (struct/union/enum/vector) needs its
typespec to be the SHARED named typedef typespec (Surelog points param ->
ref_typespec -> the ONE typedefTs object). But `emitParameters` runs BEFORE
`emitTypedefs` populates `typedefTs` (both for modules — UhdmExporter def loop
runs all params, THEN emitModuleDef/emitTypedefs; and packages — emitPackage
does params at L1003 then typedefs at L1007), by design ("def-view param
typespecs precede elaboration typespecs", arena order). So makeParamTs builds a
FRESH typespec (wrong kind: int_typespec for a vector/struct/union typedef; or
fresh-unnamed for a parametrized vector), never the shared one. Symptoms across
the DIFF set: logic_typespec->int_typespec (typedef_package,
ParameterOfParametrizedType[InSubmodule]), struct_typespec (StructParameter/
StructLocalParam + ~14 pass-through tests), enum_typespec ordering
(ParameterInitializedIn*5LevelHierarchy x4). The ELAB view CAN share (deferred
via pendingParamTs -> patchParamTypespecs, which runs after typedefs) but the
DEF view (AllModules, which uhdm-cmp compares FIRST) cannot without either
(a) reordering emitTypedefs before the def-param emit, or (b) a deferred
def-param-ts drain that binds to typedefTs after emitTypedefs.
CONFIRMED SL ARENA ORDER favors (a): in StructParameter's cmp dump the typedef
struct_typespec is id:1 and the parameter is id:5 — Surelog creates TYPEDEFS
BEFORE PARAMS. So our current params-first order is itself wrong vs Surelog;
reordering (emitTypedefs before the def-param loop) ALIGNS with SL rather than
risking it (PASS tests without typedefs are unaffected; tests with typedefs
should improve). The def-param emit lives in a SEPARATE loop
(UhdmExporter.cpp def-params loop, BEFORE the emitModuleDef/emitTypedefs loop) —
the refactor is to run typedefs first, then make makeParamTs return the shared
typedefTs entry for a named-typedef param (struct/union/enum/vector). This is
the single highest-leverage fix left (~20+ DIFF tests) and also unblocks the
struct-param op-75 pattern work. STILL gate the FULL corpus for PASS->CMP_ONLY
demotions (weak-tail shuffle), but expect it to be net-positive.

## ⭐ KEY INSIGHT (Session 12 end) — PRIORITIZE DIFF (cmp-failing) OVER CMP_ONLY

uhdm-cmp is the SEMANTIC comparator. Classes: **PASS** (dump byte-identical +
cmp-equivalent), **CMP_ONLY** (cmp PASSES, only dump TEXT differs — Surelog
quirks: weak-tail ordering, span columns, cosmetic parents; semantically
CORRECT, downstream-safe), **DIFF** (cmp FAILS — a REAL semantic bug).
Current: PASS 388 / CMP_ONLY 47 / DIFF 226. The small-dump-diff ladder is
mostly CMP_ONLY quirks; the REAL bugs are the DIFF tests (cmp-failing).
**User priority: reduce DIFFs (and uhdm-cmp diffs) over CMP_ONLY.** Dump-line
increases on a still-DIFF test are FINE if cmp advances; the ONLY hard rule is
never demote PASS or CMP_ONLY. uhdm-cmp reports the FIRST diverging object
(LHS=Surelog, RHS=ours) — fixing a DIFF test is iterative: fix first mismatch,
re-run, repeat until cmp passes. Workflow: `WORK=$W converge.sh dut.sv` then
read `$W/cmp.log` (LHS/RHS) — NOT the dump diff.

**Session-12-end cmp-focus wins (12 real bugs DIFF->CMP_ONLY; DIFF 237->225):**
- Anonymous packed struct signal -> struct_typespec not bit_typespec
  (makeTypespec had no non-typedef struct branch): 9 tests — AnonStructs,
  IndexedPartSelectOfMember, PartSelectOfMember, multidim_hier_path7,
  struct_3d_packed_array, struct_array_indexed_write, struct_init_partial_write,
  struct_little_endian_bit_array, struct_part_select_write.
- Anonymous packed union SIGNAL -> struct_net not union_var (net-vs-var):
  AnonymousUnion, AssignToUnionAndReadField.
- Anonymous UNPACKED union -> union_typespec + struct_net (extended makeTypespec
  union branch to UnpackedUnionType + isStruct): AssignToUnpackedUnionField...
- Packed-array-of-ENUM typedef -> packed_array_typespec + enum_typespec element
  (emitTypedefs packed-array branch, enum leaf): typedef_packed_enum_array
  (cmp-ADVANCED past the typespec, still DIFF at a later module_inst diff).
- Unpacked-array-of-anonymous-struct: element gets struct_typespec (makeTypespec
  struct branch now unwraps FixedSizeUnpackedArray dims): ucsbece154b_victim_cache
  574->315 (cmp-advanced, now blocked by the named-vector-typedef ref = the
  SYSTEMATIC ROOT above).
- Struct/union-typed PARAM -> struct/union_typespec not int_typespec
  (makeParamTs): advances ~16 param tests past the typespec (still DIFF pending
  the pattern RHS below).
The pattern: makeTypespec/makeParamTs/emitTypedefs/buildStructTs default
aggregate & array-of-typedef types to scalar typespecs. Anonymous
(non-typedef) aggregates were the clean early-return fixes. STILL-OPEN
same-class (riskier, in core/param paths): packed-array-of-VECTOR-typedef
struct member (struct_typedef_packed_array, makeTypespec pa-branch needs
named-typedef leaf); named-vector-typedef PARAM (ParameterOfParametrizedType,
timing — makeTypespec returns fresh unnamed for the parametrized typedef);
function return var types (TypedefedRangedFunctionReturn packed_array_var,
func_tern_hint signed-vector->int_var); unpacked-array typespec
(struct_pattern_loop array_typespec).

**Systematic DIFF patterns still open (from cmp.log survey of smallest DIFFs):**
- STRUCT-PARAM CLUSTER (~16 tests, HIGH leverage) — DEEPLY investigated, has
  THREE stacked blockers (fix in cmp.log order):
  (1) UPSTREAM BLOCKER (fix FIRST): the def-view module_inst cmp-fails with
      RHS=<null> BEFORE the pattern even matters — the struct_typespec built in
      makeParamTs (my struct-param-typespec commit) isn't fully wired into the
      module structure. Found one missing piece: its vpiInstance was 1 vs SL's
      2 (fix: set its->Instance((instance*)up->VpiParent()) in
      patchParamTypespecs for struct/union its — verified 2==2, no regress, but
      does NOT clear the module_inst-null, so there's ANOTHER missing
      module_inst reference in the def view). Diagnose by comparing every
      vpiInstance/vpiParent->module_inst between SL and ours dumps.
  (2) Param RHS is a def/elab ASYMMETRY: Surelog's DEF-view op-75 uses a
      tagged_pattern (emitExpr's form, KEEP IT), the ELAB-view op-75 uses FLAT
      per-member constants. So skip the fold for struct params + emit the flat
      op-75 only when topView (elab); the def view keeps emitExpr. The op's
      typespec ref binds to the SHARED param struct_typespec via rhsRt (set
      rhsRt=the op's ref_typespec; patchParamTypespecs binds it — the op-parent
      path skips the uintFold special case). Clean structure: emit op-75 setting
      rhs, then guard `if(!rhs) rhs=emitExpr(...)` (no if/else restructure).
      This got StructParameter 65->48 but stays blocked by (1).
  (3) The elab flat constant should keep the based-literal decompile (1'b1),
      not decimal (my op-75 emitted UINT decimal "1" vs SL "1'b1").
- makeReturnVar packed_array_var: a multi-dim packed-array function return
  (word[1:0]) should be packed_array_var (TypedefedRangedFunctionReturn), but
  "element isPackedArray -> packed_array_var" REGRESSED BitSelectPartSelectIn
  Function (PASS->DIFF). Rule is subtler — needs the exact multi-dim vs
  vector-of-typedef distinction.
- operation-vs-constant FOLD mismatch (int_types_blk1: ours op / SL constant;
  ReplicationPassedToInstance + ParameterOfSizeOf...: ours constant / SL op) —
  per-context fold rules, not one fix.
- missing ref_typespec (ImportTypeOfPort, param_packed_array_subst pair);
  extra `package` (package_task_func, fail_detect_width — recursion/$unit?);
  hier_path multi-dim (SelectOnMember/IndexedPartSelectOfArrayElement).


## Session 12 (autonomous 8h block, 2026-07-20)

**Remaining top-ladder triage (all characterized, all HARD):**
- Anonymous packed union (union packed {..} u;): PARTIAL done — makeTypespec
  now builds an unnamed union_typespec (AnonymousUnion 109->47,
  AssignToUnionAndReadField 119->49, union_simple 592->540). REMAINING: the
  ELAB view models an anonymous union signal as a struct_net (golden), ours
  emits union_var; the DEF view already matches (logic_net). Attempted fix
  (REVERTED): route an anonymous union to the NET path (isStruct=true ->
  struct_net) + makeVar returns null for it. It helped AnonymousUnion 47->34
  and AssignToUnionAndReadField 49->22 but REGRESSED union_simple +18 — its
  `s1` (typedef'd 4-state struct) started emitting a struct_net it shouldn't,
  and golden nets its anonymous union `u` (line 82, struct-member) but the
  rule is NOT simply "anonymous -> net" (depends on member composition/context,
  unresolved). Also the anonymous union_typespec span is the `union packed`
  HEADER (2:4-2:16), not the whole body (named unions use the whole body). The
  union_typespec partial IS committed and clean.
- InterfaceParameter / iface_param_set_value / InterfaceParameterSetValue
  (10 x3): SHARED root — Surelog creates the module cont-assign CAST typespec
  (int'(u_sim_sram_if.start_addr)) BEFORE the interface instance's param W
  typespec; ours reverses because emitInstance emits children (interface
  instances, ~L1633) BEFORE emitContAssigns (~L1854). A cont-assign-before-
  children reorder would fix it but shuffles every module's weak tail (broad
  regression risk). A targeted cast-ts pre-create is hard (buried in a CA RHS).
- iface_modport (39): multi-issue — interface-port HighConn ref_obj fullname
  doubles the last hop (work@top.m0.bus.bus vs .bus) AND a bus.out hier_path.
- ReplicationPassedToInstance (91): a submodule-param ref inside a replication
  count scopes through the instance path (work@top.u_dut.wmask_i.Width) in
  golden; ours flattens to work@top.Width.
- MemberSelectOf2DStructPackedArray (8, from 50): last issue is a bare '1
  member-select-LHS RHS — golden keeps it UNBASED (size -1, BIN:1), ours folds
  to the member width (UINT:1023). Not via tryFoldConst (suppressUnbasedFold on
  dottedLhs was inert) — slang likely pre-evaluates it; needs the raw-'1 path.
- subbytes (4): Surelog ARTIFACT — a whole-var ref's vpiActual points at a
  part_select of a prior blocked assignment (data_reg_128[31:24]=...), not the
  net. sva_range (76): SVA property_spec/operation structure.
- Still-open earlier notes below (StringWithBackslash escape-col quirk,
  mixed_sign_ops column quirk, OnePackage/case_expr weak-tail ordering,
  union_param_repro first-use typespec loc).

**PASS 377 -> 388 (+11) this block. Converged:**
- DotMultirange (388): completed via a 3-part multi-dim packed-struct-array
  fix — (1) packed multi-dim member-select LHS parents its index when the RHS
  re-elaborates (elabLhsReelab); (2) a multi-dim packed-array NET typespec
  truncates to the first-dim span (gated !structMemberTsCtx so union/struct
  members keep full span); (3) a struct used as a packed-ARRAY element stays
  unparented at the design (structUsedByModuleSignal returns false on any
  packed-array use). Plus two SHARED base-multi-dim-select fixes below.

**Big shared diff-reductions this block (multi-dim member-select cluster):**
- Base multi-dim select RVALUE hier_path spans the whole path (gate base-name
  span on inLhs): 11 tests, e.g. ExpressionInIndex 260->224,
  TypedefVariableDimensions 209->185, hier_path -60.
- Base multi-dim select RVALUE trailing member resolves to its own fullname
  (work@top.min_v, gate on !inLhs && lastMember): 11 tests, e.g.
  TypedefVariableDimensions 185->169, TypedefPackedDimensions 234->218.
  Combined the cluster dropped ~200+ diff lines. MemberSelectOf2DStructPacked
  Array 50->12 (remaining: RVALUE base-select index parenting is golden-
  parented but our base-select rule suppresses !inLhs — entangled with the
  tuned unpacked/ref-RHS cases; and the '1 def/elab constant sharing).

**Earlier this block. Converged:**
- func_port_implied_dir (378): port-init HighConn/var-vpiExpr via ASTContext
  tryEval (call->INT, literal->UINT) at emitTopPorts (elab top-port owner).
- Interface port typespecs precede elab var typespecs (382, +4): an interface
  instance's PORT typespec was created AFTER its variable typespecs, reversing
  Surelog's [port-ts, var-ts] weak-tail order. Fix: pre-create port typespecs
  (portTsPre map) before the variable loop in emitInterfaceInstance. Cleared
  InterfaceAssign, InterfaceWithPort, iface_pkg_enum_item,
  ImportedPackageEnumItemInInterface; reduced 10 more iface tests.
- Procedural assign_stmt span ends at RHS not ';' (383): EnumFirstInInitial;
  bonus TaskReturn 32->12. (StmtEmit ProceduralAssign: SourceRange(start,
  ae.right().end).)
- Case-inside members carry no vpiParent on constants (384): CaseInside.
  StmtEmit case-inside path uses suppressConstParent; ValueRange respects an
  incoming suppression (only force-parents its bounds when NOT suppressed).
- Interface processes parent at the DEF view (386, +2): InterfaceAlways +
  InterfaceInitial. The folded always/initial + begin were named/parented at
  the elab instance (work@top.u_sw); Surelog uses the DEF interface_inst
  (work@<iface>) with def-prefixed block names, ref actuals still elab vars.
  Fix: emitInterfaceInstance emits processes with procParent=ifaceDefMap[&def]
  + procPrefix="work@"+def.name.
- assign_stmt RHS constant parents at the assign_stmt (387): TaskReturn.
  Surelog parents it in EVERY context; ours only where an outer
  forceConstParent leaked (module procedural), not package-task bodies. Force.
- Var-init param-ref folds to a constant + var-init call args drop formal-ts:
  int_types_blk1 110->62, package_task_func 96->93 (diff-reduction, no PASS).
  ModuleEmit signal loop: NamedValue-of-Parameter init -> folded constant
  (makeParamTs ts ref); Call init sets portInitCtx to drop arg formal-ts.
- Comma-list continuous assign spans the whole list (diff-reduction): each
  cont_assign of 'assign a=0,b=1;' spans the full assignment list
  (ContinuousAssignSyntax.assignments.sourceRange when size>1). mem2reg_test5
  40->20, wandwor 280->216.

**Skipped as low-ROI / Surelog quirks (documented, not bugs in ours):**
- StringWithBackslash (8): golden end col = start + raw.size() + 2*(backslash
  count); Surelog's buggy escape-column math, past the actual line end.
- mixed_sign_ops (22): golden places `u1` one column early on `4'd2  ** u1`
  (double-space) — a Surelog column-counting quirk; every child span shifts -1.
- InterfaceParameter/iface_param_set_value/InterfaceParameterSetValue (10 x3):
  the module cont-assign cast typespec (int'(...)) must be created BEFORE the
  elab interface-instance param typespec; needs cont-assign-vs-child reorder.
- OnePackage (12): package param typespec created before the enum typedef ts
  (emitParameters runs before typedefs in emitPackage); golden reverses.
  Swapping risks param-typed-by-typedef cases.
- union_param_repro (16): union_typespec located at first-USE (function arg
  `u_t op`, 7:31) not its definition (5:9); plus struct_typespec parent->design.

**Weak-tail ORDERING cluster (fragile; ordering by UhdmId/creation order —
each needs a targeted pre-create/defer, like the interface port-ts win):**
- BindModuleWithInputPorts (4), CellNamedLikeModule (6): a bare logic_typespec
  emitted at the wrong weak-tail position (two modules' typespec creation
  interleave differently than Surelog).
- partsel_simple (6): net-decl-assign (offset = idx<<2) has TWO logic_typespec
  copies; golden parents the EARLIER (elab) one to the logic_net + leaves the
  later unparented, ours does the reverse. Entangled with the lhsSyms/fresh-
  Lhs-net mechanism (clearing the module net ts parent + pendingNetDeclTs).
- case_expr_non_const (22): 8 folded case-comparison int_typespec (empty loc)
  in a different weak-tail order (same count).
- InterfaceAsPort (29): int_typespec 5:38 (dut's `a` port) ordered early; plus
  a folded interface-member cont_assign appears 5x in golden vs 4x in ours
  (def+elab view duplication of `assign u_sim_sram_if.start_addr = ...`).

**Use-dependent predicates / multi-issue (risky or entangled):**
- DotMultirange (46): 3 roots — (a) packed_array_typespec span should truncate
  to the FIRST dim (13:17 not 13:22); (b) struct_typespec parent->design
  (structUsedByModuleSignal predicate too broad here); (c) multi-dim LHS
  member-select index constants (group_status[0][0].a) ARE parented in golden,
  but ExprEmit:372 suppresses for sels.size()>1 (tuned for unpacked a[0][0].x).
  Packed-vs-unpacked may be the real distinguisher.
- Clog2OfSum (10): submodule param `a` elab constant's actual binds to the DEF
  logic_net (work@submodule.a) in golden, elab int_var in ours; + const parent.
- AssignBitsCallToSubmoduleParameter (40): bit_select fullname must scope
  through the submodule port (work@top.u_reg...we_i.key_init_we), ours flattens.
- SelectFromUnpackedInFunction (38): tagged_pattern + string_typespec(default)
  lose their location in ours.

**Diff-reduction partials (earlier in block):**
- ParameterInitializedByPartSelectOfParametersAssignedToVar 60->24 (DIFF->
  CMP_ONLY): emitGenScopes folds a plain param-ref RHS carrying a part-select
  fold constant, with a fresh bit/logic_typespec scoped to the gen scope
  (makeTypespec + syntaxRefPrefix). REMAINING: the DEF param_assign fold ts
  is bit_typespec vs logic_typespec is GEN-REFERENCE-gated (base test wants
  logic, this variant bit — same source, distinguisher is gen-block use);
  sharing the param's bit_typespec directly REGRESSES the base.
- param_packed_array_subst / ParameterPackedArraySurelogSubstitution 105->70:
  nested-pattern params keep their operation in the elab view (no fold), def
  operands unparented. REMAINING: Surelog REORDERS packed-array pattern
  operands to bit-index order + vpiReordered:1 + outer-op typespec ref.
- func_port_implied_dir 111->64: port initializers -> vpiHighConn (call stays
  a name-anchored func_call w/ no arg ts via portInitCtx; literal stays an
  unparented constant); elab port folded HighConn + port-backed var vpiExpr
  (call-fold INT, literal UINT). REMAINING: gold's MULTI-declarator ports
  (output integer w=16, x=4, ...) don't reach the it.port init link.
- ImportTypeOfPort 37: DEFERRED. The pkg-typedef ts parent is use-dependent
  (allPackages def wants package parent, topPackages top wants none; the
  cont-assign-LHS clearing loop nulls it). Restoring the pkg parent REGRESSES
  TypedefEnum + TypedefInModulePort. A precise use-based predicate is needed.
- struct-param pair (StructLocalParam/StructParameter 101): a struct/enum
  param should share the typedef ts. BLOCKED: the DEF param typespec is built
  BEFORE emitTypedefs populates typedefTs (typedefTsSize=0 at the first
  makeParamTs call), so the shared ts isn't found; also the deferred drain
  re-parents the shared object to the param ref. Needs phase coordination +
  a re-parent guard (its->VpiName().empty()), plus a pattern-op RHS.

## Session 11 (autonomous 8h block, 2026-07-20) — FINAL

**PASS 360->377 (+17), DIFF 274->239.** Converged in the second half (on top
of the first-half list below): struct_pat_fill + module typedef listings are
NAME-SORTED (Surelog's registry is a name-keyed map; def AND elab listings,
creation order unchanged), typedef_simple (module typedef-of-typedef alias
clones at the TARGET's span w/ Typedef_alias; typedef'd logic vars carry NO
vpiSigned; var-init vpiExpr forms: -1 -> minus op w/ unparented width-sized
constant, y = x -> ref_obj scoped work@top.y.x bound to the var),
EnumWidth + UnionInsideStruct (member-ref prefixing driven by
WHOLE-cont-assignment only — hasNestedTypedef was a coincidence of its
motivating tests; unions follow the same rule; union vars -> union_var;
def-ts drop skips structs w/ a union member), TypedefAliasInPackage +
TypedefEnum (pkg enum-alias clones: created at DEF time/listed TOP-only,
VARIABLE use -> wide span to the use declarator + doubled pkg::pkg:: refs +
pkg parent, PORT-only use -> target-decl span + single scoping + no parent;
port-backed vars don't count as uses; alias-LHS enum-const assigns fold
FRESH in TOP at LHS width/RHS span), mem2reg_test4 (unpacked-array
select-LHS cont-assigns re-emit fresh in elab w/ shared def Rhs constant;
LHS-index func_calls anchor at the callee name, args carry no formal-ts;
array_net signed leaves), EnumArray + EnumArrayListedElements
(emitPackedStructArrayVar accepts ENUM leaves; suppressConstParent honored
by pattern enum-const operands; netTypeFor descends packed dims to the leaf
alias).

**Partials (diff reductions, zero corpus delta):** ImportTypeOfPort 69->37
(imported-unqualified pkg-typedef ports are NETS w/ shared ts; top port
gets an alias clone; REMAINING: cross-view pkg-ts parent placement + a
second QUALIFIED tail clone), hana 81->48 (param-arith folds: unary-plus
keeps op, minus/subtract fold signed INT untruncated at LHS width; process
unary literal operands unparented; bare literals truncate at LHS width;
REMAINING: untyped-param fold w/ int_typespec + multi-top param-ts drain
ordering), CastInFunctionInGenBlock 94->50 (emitSyntaxExpr CastExpression
case; emitGenScopes call fold with EvalFlags::IsScript retry — const-fn-in-
generate fails strict rules; REMAINING: in-function (PtrWidth)'(Depth)
operand/size fold shapes).

**NEXT LADDER**: ImportTypeOfPort 37, hana 48, CastInFunctionInGenBlock 50,
ParameterInit...AssignedToVar 60 (gen-scope param fold — partially helped by
the new gen fold), iface_modport_conn 68 / iface_modport_out 72 (arena),
sva_range 76, ReplicationPassedToInstance 91 (high-conn replication folds to
BIN all-ones at bound width + no-default child param RHS fold),
package_task_func 96, struct_part_select_write 97, StructLocalParam 101.

### First-half detail (PASS 360->368) Converged: BitSelectPartSelectInFunction (4 parts:
NamedType block-local predicate — typedef-typed non-init function locals are
body-block members, builtin-typed stay at function w/ vpiAutomatic; '1 args
in def cont-assign stay bare / elab fold to formal width repeated-digit BIN
via new contAssignView member; vector-typedef block-local binds a fresh
NAMED alias clone), OneStruct (module-prefixed struct nets drop def
typespec — !bareRefs set from emitTypedefs, carve-outs: initializer /
child-port-conn use; array_net struct_net element w/ doubled fullname,
loc=name..first-dim-end), const_fold_func (module-function constant args get
formal-ts + width for VECTOR formals only; REF args ts at any depth;
impure-function calls (subWritesNonLocal) never fold — def ca shared into
elab), AssignArraySelPlus + typedef_unpacked_input (THE unpacked-array-port
arena puzzle: the def-side array_typespec is created at emitTopPorts'
ts-swap re-bind point (write phase); size-dims end before ']', ranged dims
after; non-port clone computed bounds fold BARE), UnpackedArray (nested
pattern: def leaves unparented, elab sizes only outermost first operand, no
orphan), MultipleNets (pkg-enum-typedef ports are enum_vars; time ports stay
logic_nets), TypedefedRangedFunctionArgument (packed-array-of-typedef formal
ts: Elem_typespec -> named alias clone + array-dim ranges; typedef-return
calls WITH args fold; def concat args carry no formal-ts, patterns do).
Partial: ImportTypeOfPort 69->37 (imported-unqualified pkg-typedef ports
are NETS binding shared ts; top port gets alias clone; REMAINING: cross-view
pkg-ts parent placement + a second QUALIFIED tail clone at the write-phase
arena position — same defer problem as the listing-order/insert experiment
that briefly made it worse, reverted).
Also: continuation ANSI net-port declarators (out2/out3 get bare
VariablePortHeaders) inherit the preceding explicit net keyword.

## Session 10: memory/array + typedef ladder (2026-07-19)

**PASS 344->360, DIFF 274->256.** Five features, +16 PASS (one fix cleared a
12-test cluster):

- **Unpacked array of a NET-type leaf → array_net (12 tests)**: a `reg`
  memory (`reg [W-1:0] mem [0:D-1]`), an ANSI net port, or a 4-state packed
  struct array elaborates as an `array_net` (vpiNet = logic_net element, no
  array_typespec/rand/visibility) not an array_var. `unpackedArrayLeafIsNet`
  mirrors makeVar's scalar carve-out (non-port `logic` variable stays var;
  reg/port/4-state-struct is net); new `emitArrayNet` builds it
  (buildUnpackedRanges + logic_net element + netTypeFor). Cleared
  simple_memory, priority_memory, sp_read_first/or_write/write_first,
  mem2reg_test1/3/6, aes_kexp128, arrays01, mul_unsigned, repwhile.
  mem2reg_test2: the array_net + its element both carry the signal's
  (* mem2reg *) attribute (shared from attrMap).
- **ReturnEnumArray**: a function local/return of type `sp2v_e [1:0]` (packed
  enum array) is a packed_array_var (range + enum_var element mirroring the
  packed_array_typespec) not logic_var; `makeEnumArrayVar` helper. The
  function-var-loop copy of a body-block local is re-parented to the body
  begin block after the body is emitted.
- **blockrom**: computed body localparams `W = (X-1)`: isOverriddenParam no
  longer misfires on a parenthesized default (inner-expr syntax differs but
  its tokens lie within the default's range — containment check); the folded
  RHS constant spans the parens; analyzeParamEnc marks a subtract-init param
  int-encoded so a bare `[W:0]` bound folds signed INT.
- **TypedefStructArray**: a `struct packed {..} [31:0] T` typedef → NAMED
  packed_array_typespec whose Elem_typespec is a fresh struct_typespec
  (members re-parent to the array ts; struct ts at the `struct` keyword); a
  var of that type is a struct_var (element struct anonymous, so
  emitPackedStructArrayVar doesn't fire).

**DEFERRED — AssignArraySelPlus / typedef_unpacked_input (unpacked-array
PORT typespec)**: golden's ALLMODULES (def) port typespec is an
array_typespec wrapping the element logic_typespec; ELAB keeps the bare
logic_typespec. Attempts to wrap in emitPorts(topView=false) landed the
array_typespec in the TOPMODULES view, and the def-view port's `internal`
symbol does not carry a FixedSizeUnpackedArrayType (the unpacked dim is
modelled elsewhere for the def net) — so the condition never fired. Needs
the def-net's unpacked-dim source + a DEFERRED array_typespec placed late in
the weak tail (after the process constants). Genuine arena/view puzzle.

**DEFERRED — OneStruct (unpacked struct arrays)**: two parts, one solved
one blocked. (1) SOLVED in a throwaway branch: emitArrayNet's element for a
struct leaf must be a struct_net (doubled fullname work@m.sig.sig →
shared struct_typespec), located name..FIRST-unpacked-dim-end (Surelog stops
at dim 0 even for [10][20]) — a clean extension of this session's array_net.
(2) BLOCKED: golden's DEF-view nets for OneStruct's memArray/memMulti/mem
carry NO typespec, but gating ALL struct-leaf def nets off the pendingNetTs
typespec regressed 12 tests + a golden (most struct def nets DO keep it).
The distinguisher is member-access-ONLY structs (mem.wr/.addr/.data, never
whole-assigned) drop the def typespec — needs a precise "member-access-only"
predicate before the array_net struct-element extension can land.

**NEGATIVE RESULT — block-local var re-parenting is NOT general**:
BitSelectPartSelectInFunction's `result` (non-init function local) is
parented at the body begin (name-loc, no vpiAutomatic) like ReturnEnumArray's
`out`. But generalizing that (all non-init module-scope function locals →
name-loc + no-automatic + re-parent to begin) REGRESSED 7 tests
(func_block, function_arith, function_loop, function_mixed, many_functions,
scope_task, scopes) whose locals golden keeps at parent=function with
type-span loc + vpiAutomatic. Both families have begin-block bodies, so the
distinguisher is NOT "has a body block" — it is finer (still uncharacterised;
func_block's `idx` is used only inside a `for ... begin:blk`, iota's `result`
in bare body statements). Needs the precise predicate before
BitSelectPartSelectInFunction's block-local part (one of its FOUR parts:
block-local + '1-arg-sizing-to-formal + '1-typespec + box_t 2D-packed-logic
typedef with typedefAlias+2 ranges) can land.

**NEGATIVE RESULT — TypedefAliasInPackage**: an enum-typedef ALIAS
(`typedef lc_tx_e lc_tx_t` in a package) — golden emits it ONLY in the elab
(topPackages) view as an enum_typespec WITH vpiTypedefAlias (ref→lc_tx_e) +
vpiBaseTypespec + a wide loc (2:4..11:50, spanning into the module's use);
the def (allPackages) view OMITS it. Ours does the opposite (fresh copy in
both, no alias). The wide canonical-enum loc + def-omission + alias-wiring
are all specific quirks; not a quick fix.

**NEXT LADDER (fresh difsize)**: AssignArraySelPlus (35, deferred),
typedef_unpacked_input (49, same family), OneStruct (57, deferred above),
iface_modport_conn (68, arena), ImportTypeOfPort (69),
TypedefAliasInPackage (70), iface_modport_out (72),
BitSelectPartSelectInFunction (73), sva_range (76),
ParameterInitializedByPartSelectOfParametersAssignedToVar (80, gen-scope),
hana_test_parse2synthtrans (81), TypedefedRangedFunctionArgument (82).

## Session 9: session-8 ladder (in progress, 2026-07-19)

**PASS 335->344, DIFF 283->274.** NINE items converged (byte-identical
PASS): StringLocalParamInitByConcatenation, StructPackedOutput,
ParameterOfSizeOfPort, AssignmentToConcatenation,
ParameterInitializedByPartSelectOfParameters, PatternInFunction,
wildcard_eq, asgn_expr (+ asgn_expr2 bonus).

- **PatternInFunction**: function-body block lists the element int_var as
  a sibling before the array_var; a folded call returning a[K] of a
  pattern-inited local locates its constant at the source element token
  (traces the return element-select through the local's pattern).
- **wildcard_eq**: digit-separator underscores (4'b001x, 16'bxxxx_xxxx)
  removed from decompile+value; a CONCAT with x/z bits folds (tryFoldConst)
  to a full-width BINARY constant preserving 0/1/x/z (w'b<bits> decompile).
- **asgn_expr / asgn_expr2**: an assignment used as an OPERAND or another
  assignment's RHS (x = (y=...)+1) emits operation(vpiAssignmentOp=82) with
  [lhs,rhs] operands + paren-inclusive span; a statement assignment stays
  an assignment object. The embedded op's LHS ref parents at the ENCLOSING
  assignment (enclosingAssign member), not its own op; a direct leaf-const
  RHS unparents while nested-op operands parent normally.

Probed **ParameterInitializedByPartSelectOfParametersAssignedToVar** (80):
the same part-select param (`bit [DepthW:0] FullDepth = WidthRatio[..]`)
but READ inside a GENERATE scope (`assign max_value = FullDepth`). Needs
the gen-scope cont-assign path (emitGenScopes — a SEPARATE simpler emitter)
to gain the typedParamRhs / moduleParamFoldConst fold+share machinery and
the int'(x) cast emission that emitContAssigns already has; plus the fold
constant's ts here is the param's bit_typespec (4:15-4:29), not the fresh
logic_typespec. Substantial (duplicate the fold logic into emitGenScopes).

**NEXT LADDER (fresh difsize)**: iface_modport_conn (68), AssignArraySelPlus
(69), ImportTypeOfPort (69), TypedefAliasInPackage (70), iface_modport_out
(72), BitSelectPartSelectInFunction (73), asgn_expr (74), wildcard_eq (74),
sva_range (76), TypedefStructArray (78),
ParameterInitializedByPartSelectOfParametersAssignedToVar (80),
ReturnEnumArray (81), TypedefedRangedFunctionArgument (82).

Two more PROBED (not yet done):
- **ImportTypeOfPort** (`import pkg::lc_tx_t; output lc_tx_t o; assign o=5`):
  the port `o` (package vector-typedef, continuously assigned) should be a
  logic_NET (with the vpiTypedef logic_typespec + an import_typespec entry,
  vpiNetType:36), but slang classifies it a Variable so we emit a
  logic_var. Also the imported typedef's logic_typespec gets a spurious
  vpiParent module_inst (drop it). Same net-vs-var-for-a-net-port family as
  AssignArraySelPlus + StructPackedOutput — the pkg-typedef output port is
  a net.
- **TypedefAliasInPackage** (`typedef lc_tx_e lc_tx_t;` — alias of an enum
  typedef): golden emits lc_tx_t as an enum_typespec in the TYPEDEF-ALIAS
  form (vpiTypedefAlias -> ref -> lc_tx_e's enum, plus vpiBaseTypespec,
  spanning a merged 2:4..11:50 loc); we emit a plain enum copy at the alias
  decl (6:4-6:28) with no alias link. buildEnumTs needs an alias branch for
  a typedef whose target is ANOTHER named enum typedef (vs an inline enum):
  reuse the base enum's ts via a Typedef_alias ref rather than rebuilding.
  Downstream the enum_var lc_en_i span shrinks to the name (11:25-11:32) and
  its vpiExpr constant unparents.

**AssignArraySelPlus** (attempted, REVERTED — deep arena puzzle):
`output logic [3:0] data [15:0]` assigned in an initial block. slang makes
`data` a Variable (procedurally assigned) so we emit an array_var; Surelog
keeps the output-port NET an **array_net** (vpiArrayNet: logic_net element
via Nets(), no vpiTypespec on the array_net; no var-only
randType/visibility/arrayType flags) — gate on `it.port && netTypeFor()`.
A written emitArrayNet + instance Array_nets() worked for the signal. The
BLOCKER: the PORT's typespec must be a full array_typespec (vpiArrayType,
[15:0] range via buildUnpackedRanges, Elem_typespec -> the shared element
logic_typespec, loc 1:20-1:43) that Surelog creates LATE in the
write-phase weak tail — creating it inline in emitPorts/emitTopPorts
shifts the arena and mislabels the def net's shared logic_typespec. Needs
a DEFERRED array_typespec (pending list drained in the write phase, shared
by both def + top port refs) rather than inline creation. makeArrayTypespec
helper + emitArrayNet were written and are recoverable from git reflog
(reverted commit-less).

- **ParameterInitializedByPartSelectOfParameters** (DONE): def
  part_select param-scoping + the elab BIN fold shared into the reading
  cont-assign (moduleParamFoldConst, own bare-bound tail logic_typespec)
  + a bare param-ref bound in a PARAMETER's typespec ([DepthW:0]) staying
  a scoped ref_obj (owner-is-Parameter discriminator vs issue326's
  var/net typespec which folds).
- **PatternInFunction** (PARTIAL, commit a2dc4dd): function-local
  unpacked-array (int a [2]) now emits an array_var (vpiReg element
  int_var + ranged array_typespec, Elem_typespec shared with the reg) via
  emitArrayVar's parent widened to BaseClass*. REMAINING 6 lines: (a) one
  Surelog function COPY lists the element int_var as an EXTRA sibling
  before the array_var in its body `begin` block (the block var listing
  emits both element + wrapper for an unpacked-array local — the
  design-level func copy lists array_var only, so it's copy-specific);
  (b) the o=get_a1() call-fold constant needs loc 5:24-5:25 (the folded
  a[1] source token).

Original session-9 five converged items:

- **StringLocalParamInitByConcatenation**: a string localparam whose init
  is a CONCAT folds to a STRING constant in the elab (def keeps the op,
  literal operands unparented); a cont-assign READING the param (o = X)
  shares that fold constant, re-parented at the cont-assign
  (moduleStringParamConst; the typedParamRhs gate + integer-fold guard now
  handle string params).
- **StructPackedOutput**: a packed-array-of-package-struct PORT stays a NET
  (new emitPackedStructArrayNet: packed_array_net wire + struct_net
  element with a DOUBLED fullname, element carries no net type). The
  package-struct leaf's packed_array_typespec is UNLOCATED; isPkgStructType
  descends packed dims (def net -> wire). An UNCONNECTED child port
  (dut d();) emits no ref_module port. A single-dim LVALUE base-select in
  the ELAB cont-assign LHS parents its index (elabContAssignLhs; def +
  multi-dim stay unparented).
- **ParameterOfSizeOfPort**: $bits(SIGNAL) folds to a constant when the
  signal width is FIXED (int o -> 32), stays a sys_func_call when
  param-dependent or a TYPE; currentScope is set in the def param
  pre-pass so the fold reaches both views (typeWidthUsesParam +
  foldQuery). A single cast whose operand is a PARAM whose init references
  no unknown-valued param folds loc-less (int'(X), X='1 -> 4294967295;
  int'(C), C=A/B with A,B='x, stays an operation).
- **AssignmentToConcatenation**: a packed-struct signal WITH an
  initializer becomes an elab struct_VAR (init -> vpiExpr, operands
  unparented, declarator-name span), not a struct_net. A CONTINUOUS-assign
  LVALUE concat ({a,b}=...) locates at its FIRST operand (procedural <=
  keeps the whole braces — concat_lhs_signext taught the gate). The
  packed_array_typespec dim-span scan falls back to the typespec range
  when the symbol has no getTypeSyntax() (struct members).

**REMAINING session-8 ladder** (fresh difsize order):
ParameterInitializedByPartSelectOfParameters (67), PatternInFunction (67),
iface_modport_conn (68), AssignArraySelPlus (69), ImportTypeOfPort (69),
TypedefAliasInPackage (70), iface_modport_out (72),
BitSelectPartSelectInFunction (73).

**ParameterInitializedByPartSelectOfParameters** (`localparam bit
[DepthW:0] FullDepth = WidthRatio[DepthW:0]`): def part_select scoping
DONE (commit 19855da — regression-free). TWO parts remain, both verified
against golden:
  1. The ELAB param RHS folds to a BIN constant (WidthRatio[5:0]=20 ->
     BIN:010100, size 6, decompile 6'b010100, constType 3) and is SHARED
     with the o=FullDepth cont-assign (parent = the cont_assign, the
     param_assign back-references it — exactly the StringLocalParam
     moduleStringParamConst pattern but a bit-vector part-select value).
     Ours currently folds UINT:20 at the param_assign. Add a
     part-select/bit-vector BIN fold in the typedParam RHS path + a
     moduleParamConst-style share.
  2. The `[DepthW:0]` bit_typespec bound keeps a REF to DepthW
     (ref_obj work@top.FullDepth.DepthW), NOT a folded constant. This is a
     BARE-direct-param-ref bound (unlike `[ADDR_WIDTH-1:0]` expression
     bounds which fold via boundOwnerFullName) — the discriminator is a
     direct NamedValue(param) bound. emitBound in makeTypespec needs a
     "bare param-ref bound stays a scoped ref" branch (fullname
     work@top.<param>.<boundparam>). Both views.

Remaining after that: PatternInFunction (67), iface_modport_conn (68),
AssignArraySelPlus (69), ImportTypeOfPort (69), TypedefAliasInPackage
(70), iface_modport_out (72), BitSelectPartSelectInFunction (73).

## Session 8: ENTIRE session-7 ladder converged (2026-07-19, 10 commits)

**FINAL: PASS 325->335, DIFF 296->283, CMP_ONLY 40->43 (cmp-passing
365->378).** Every item on the session-7 ladder is a full byte-identical
PASS (plus AssignmentPattern as a bonus):

- **OneClass**: module-local classes attach under the def module's
  vpiClassDefn (emitClassDefn refactor; bare name + work@mod::name
  fullname). Class-handle def nets carry a ref_typespec->class_typespec
  UNLESS procedurally assigned (bar = new() strips it — OneThis).
- **StructPackedArray** (+DotMultirange/int_port_signed/
  MemberSelectOf2DStructPackedArray -> CMP_ONLY): packed dims after a
  NAMED type live in NEITHER syntax node — a bracket scan (scanDimSpans)
  over the declaration source recovers their spans; the packed_array_var
  spans declarator..init and carries the pattern-init op as vpiExpr on
  BOTH the array var and its element struct_var; struct-leaf named-type
  nets get no vpiNetType.
- **MixedPatterns + AssignmentPattern**: a struct typedef whose variable
  is cont-assigned WHOLE gets BARE member refs and no module parent
  (member-only / \$bits-only keep the work@mod prefix). STRUCT-typed
  structured patterns re-emit EXPANDED in the elab (op75, per-field UINT
  constants at the source value tokens); vector-typed still fold to
  8'd255. Def tagged-pattern literal values unparent; the write-phase
  orphan re-parents only SIMPLE-pattern operands.
- **iface_param_width_per_inst**: interface overrides encode UINT at
  value width (uniquified). PORT VIEWS double their default-valued
  params (no param_assigns) and fold var bounds at the DEFAULT param
  values (createDefault body cached in ifaceDefaultInst — Surelog reads
  AllModules widths); the HOME view keeps instance values. The tail dup
  carries its own default param clones + shares the home's param_assigns.
- **CastClog2...FromCommandLine**: nested casts lose the inner
  conversion's syntax (it holds only the PARENTHESIZED node) — the outer
  recovers the inner CastExpression via castSynOverride and emits the
  operand FIRST (inner integer_typespec with the bound \$clog2 vpiExpr
  precedes the outer's ts). The elab folds a NESTED cast that evals
  fully to loc-less UINT-by-magnitude at result width; SINGLE casts keep
  the operation (CastLogic/FunctionReturnEnum taught the gate).
- **iface_passthrough**: iface PORTS + port views emit BEFORE children
  (iface arena order is outer-first; regular ports stay children-first);
  a passthrough child's HighConn binds the ENCLOSING module's port view
  (conn raw text resolved in the instantiating scope ->
  ifacePortViewMap); passthrough conns get no connection-site net and
  the stub binds the module's OWN port net; the passthrough child's
  iface-member CA keeps the SHARED def CA; def iface-port ts drain runs
  deepest-first.
- **BindModuleWithInputPortsInGenScope**: a bind directive INSIDE a
  generate scope never materializes (direct binds still do, even under
  implicit tops); the dropped def's port phase runs in the write phase
  (droppedBindDefs — an unscoped fill crashed every interface def).
- **ParameterOfSizeOfParametrizedPort**: \$bits(SIGNAL) typespec bounds
  stay unfolded in BOTH views (\$bits(type) folds — BitsCallOnVar); the
  arg ref scopes through the declaring param (work@top.Y.o) and binds
  the def net via pendingBitsBoundRefs (drained at the END of
  exportDesign — the def param pre-pass runs before any nets exist).
  Plus: vpiLocalParam follows the WRITTEN keyword for module-body params.
- **StringAssignConcatenation**: the compiler string conversion around a
  string literal in {NAME,"efgh"} is dropped (bare unparented constant);
  the elab folds the string concat to one loc-less STRING @8bits/char.
- **nested_cast_repro**: \$unit-function typedef quirks — the return
  clone gate matches the registered alias by name+canonical; typedef
  returns skip the return-var artifact (refs unbound); VECTOR-typedef
  casts in \$unit bodies clone the ts (Typedef_alias); direct formal refs
  under such casts stay unbound; a \$unit struct typedef used only by a
  function FORMAL parents at the design, anchored at that formal's type.

**NEXT LADDER (fresh difsize)**: StringLocalParamInitByConcatenation
(44), StructPackedOutput (55), ParameterOfSizeOfPort (58),
AssignmentToConcatenation (66), ParameterInitializedByPartSelectOfParameters
(67), PatternInFunction (67), iface_modport_conn (68), AssignArraySelPlus
(69), ImportTypeOfPort (69), TypedefAliasInPackage (70), iface_modport_out
(72), BitSelectPartSelectInFunction (73).

## Session 7b: session-7 ladder triage (2026-07-19, 6 commits)

**PASS 324->325, DIFF 297->296.** Converged **StringAssignConcatenation**
(a string literal in `{NAME,"efgh"}` is a NON-implicit compiler string
conversion — Surelog drops the cast, emits the bare unparented string
constant; the elab CA folds the whole string concat to one loc-less
STRING constant at 8 bits/char). Also landed a validated-clean
correctness fix: **vpiLocalParam now follows the WRITTEN keyword for
module-body params too** (a body `parameter` is local per LRM with an
ANSI header but a real parameter to Surelog) — partial progress on
ParameterOfSizeOfParametrizedPort.

**The rest of the session-7 ladder is SUBSTANTIAL FEATURES, not quick
pickoffs** (80-130 line diffs each). Fully triaged; per-item mechanism +
the exact discriminator found:

- **ParameterOfSizeOfParametrizedPort** (localparam done; remainder:
  `logic [$bits(o)-1:0] Y`): the `$bits(o)-1` typespec bound stays
  UNFOLDED (sys_func_call + `o` ref, fullname `work@top.Y.o`, actual ->
  the port net) in BOTH views. KEY DISCRIMINATOR (verified against the
  PASSING BitsCallOnVar): `$bits` of a *type* (`$bits(dmi_t)`) FOLDS to a
  constant; `$bits` of a *signal/port whose width is param-dependent*
  (`$bits(o)`, o is `[X-1:0]`) stays UNFOLDED. emitSyntaxExpr already
  emits the sys_func_call (TypeEmit ~1294) but its arg ref needs the
  param-scoped fullname + a deferred actual-binding to the net.
- **MixedPatterns** (module struct typedef + pattern): (1) elab CA folds
  `'{third:0, default:'1}` to a packed constant `4'd13` (size 4); (2)
  module typedef struct_typespec drops vpiParent (keeps vpiInstance
  only); (3) member ref fullnames are BARE `struct_t.first` not
  `work@top.struct_t.first`. DISCRIMINATOR (checked struct_array=bare vs
  BitsCallOnVar=prefixed, both module/unit leaf structs): a struct that
  is INSTANTIATED as a variable (`struct_t c;` — a struct_var/net of the
  type exists) uses BARE refs; a struct used ONLY in `$bits(T)` (no
  variable of the type) uses module-PREFIXED refs. The current
  `hasNestedTypedef` gate in emitTypedefs (TypeEmit ~1012) is the wrong
  axis — needs the "has-a-variable-of-this-type" test. RISKY (shared
  gate; re-gate carefully against BitsCallOnVar/StructMemberAsModuleInput).
- **OneClass** (module-local classes; diff 119->93 after the int_var
  commit): (1) DONE — class `int`/predefined fields now route through
  makeVar (int_var+signed). (2) REMAINING, module-LOCAL classes
  (`class c` inside a module) are not emitted at all — the class_defn loop
  (UhdmExporter.cpp ~336) only walks `comp.getCompilationUnits()`
  (file-level). Refactor that block into a helper and also call it for
  module-body ClassType members (attach under the module's vpiClassDefn,
  name `work@top::c`, populate classDefnMap). (3) class-typed nets
  (`u one; c two;`) need their class_typespec — NOTE makeTypespec ALREADY
  builds a ClassType->class_typespec (TypeEmit ~25, links Class_defn via
  classDefnMap), so once (2) populates classDefnMap the fix is to STOP
  skipping the typespec for class-handle nets (the `classHandle` guard at
  ModuleEmit ~104 that sets no typespec) and instead emit the
  ref_typespec+class_typespec located at the type-name span. RISK: find
  what test the "class-handle nets carry NO typespec" rule was added for
  before removing the guard (may need gating on whether classDefnMap has
  the class).
- **iface_param_width_per_inst** (parametrized interface port): the CORE
  feature the test documents — a submodule's interface field width must
  use the ELABORATED per-instance param (`#(.W(22))` -> data is [21:0],
  we use the default W=3 -> [2:0]). Also: the interface override param
  encodes UINT@valuewidth (we emit INT:-1), and the per-instance iface
  emits `vpiParamAssign`(overriden) not a bare `vpiParameter`; the home
  elab view drops the param block entirely.
- **StructPackedArray** (`filter_ctl_t [1:0] a = '{...}`): packed_array_var
  with an assignment-pattern vpiExpr (op 75), an outer packed range, and
  an element struct_var; plus a spurious vpiNetType:36 on the port to
  drop. We currently truncate the var span and omit the vpiExpr/range.
- **nested_cast_repro / CastClog2...FromCommandLine**: nested casts
  (`int'($clog2(X)'(X))`) lose the inner conversion's syntax so the inner
  cast ts falls to the loc-less logic_typespec fallback; golden wants the
  inner ts as integer_typespec@the-inner-span with vpiExpr = the bound
  sys_func_call. Needs syntax pass-down from the outer CastExpression, and
  the elab must RE-EMIT the whole nested cast (we mis-fold to a UINT wrap
  — find the folder first).
- **iface_passthrough / BindModuleWithInputPortsInGenScope**: interface
  passthrough / bind-in-genscope machinery (see session-7 notes below and
  the iface_passthrough paragraph). Order-sensitive; budget a session
  each.

**Recommended next-session order** (tractability-first): OneClass part-1
int_var (trivial, may help other class tests) -> StructPackedArray ->
MixedPatterns (fold + re-gate) -> iface_param_width_per_inst -> the cast
cluster -> the interface/bind pair.

## Session 7: whole session-6 ladder converged (2026-07-19, 9 commits)

**FINAL: PASS 314->324, cmp-passing 351->364, DIFF 310->297, CMP_ONLY
37->40.** Every named lead in the session-6 ladder is now a full PASS
(plus bonus wins named_cover_assert; readmemh_param / InterfaceAsPort /
StructInPackage -> CMP_ONLY). New full PASSes and their mechanisms:

- **ParameterInitializationWithNegation** (`localparam logic[17:0] X =
  ~(15)`): tryFoldConst gained a `typedConv` fallback param — when the
  bare eval is NEGATIVE-SIGNED (and only then; the unknown-value refusal
  is untouched so X-operand ops stay unfolded), it re-evaluates through
  the implicit conversion to the param type (unsigned at type width).
  The UINT fold then takes the existing bare-vec-ts drain path (loc-less
  clone). DEF-view param-init UNARY operand constants are unparented
  (`paramInitDef` flag; binary operands stay parented — probe showed
  `15+1` keeps parents, `~15`/`~(15)` don't).
- **clk2fflogic_effects** + **named_cover_assert**: a LABELED immediate
  assertion (`eff3: assert(x);`, syntax != SequentialBlockStatement) gets
  NO named_begin wrapper — the label becomes the assertion object's own
  VpiName (refs still scope through the label via joinRef). Module
  net-decl-assign unbased inits: '0 keeps BIN:0/'0 but sizes at the net
  width; '1 UINT-folds at width; 'x/'z stay size -1.
- **StringAssignment**: `parameter string N = "s"` — STRING:<v> value on
  both views' parameter objects; LOCATED string_typespec at the `string`
  keyword (def parents at the parameter, elab at the prt ref via the
  pendingParamTs drain); the elab Rhs NEVER folds and decompiles WITHOUT
  quotes (def keeps quotes).
- **CastWidthFromPackage** (`pkg::W'(a)`): def mints a BARE (nameless,
  loc-less) int_typespec carrying UINT:<value>; the ELAB CA folds the
  cast through the operand VARIABLE's INITIAL value (Surelog reduce
  quirk) to a loc-less unparented constant at the cast width — gated to
  ScopedName widths ONLY (5'(a), (P+1)'(a), my_struct'(a) keep the
  operation; three regressions taught that).
- **InterfaceAsPortAssignValueInSubmodule**: plain (no-modport) iface
  ports parse as VariablePortHeader — makeIfacePortTs falls back to the
  dataType syntax: ts NAMED by the interface TYPE at the type token, and
  is created LATE (pendingIfacePortTs, drained at emitTopPorts). Def
  lowconn binds the def interface_inst; the child elab lowconn re-points
  at the port view (parent CLEARED) and the view lists TWICE under
  vpiInterface. An iface-member LHS CA in a CHILD elab re-emits FRESH:
  hier_path (name==fullname, no work@ prefix) with name-only elements ALL
  anchored at the LAST member token, Rhs = BARE loc-only constant. The
  col-0 tail-dup's arena slot precedes the iface vars' typespecs
  (dup shell created early, filled at the end).
- **BitsCallOnSubArray**: pkg struct typedefs — Surelog CROSS-WIRES the
  two views' member typespecs: first-created (FOLDED bounds) belongs to
  the TOP struct, second-created (UNFOLDED ops with
  pkg::pkg::T::member::PARAM refs bound to the def param constants) to
  the DEF struct; member actuals swap after the top build (dump order
  AND cmp graph both matter — dump alone matched with the wrong wiring).
  Pkg-typedef struct nets get vpiNetType wire only with FLAT members
  (nested-struct members stay untyped — BitsCallOnStructMember).
- **MultipleCells**: if-generates WITHOUT else emit gen_if located at the
  `if` keyword (with-else keeps loc-less gen_if_else); emitSyntaxExpr
  learned prefix-UNARY ops (mapSyntaxUnaryOp: ! ~ - +). GENERATE-
  containing children are uniquified by Surelog: their override
  param_assign constants encode UINT at the VALUE width even for untyped
  params, and their gen-scope CA RHS refs stay UNBOUND (LHS keeps its
  actual).
- **PkgParamAsFunctionArg**: func-call ARGS referencing pkg params stay
  REFS — named `pkg::P` (fullname==name), anchored at the `pkg::`
  qualifier span, actual -> the package's DEF parameter object, NO
  formal-ts ref. Package CONCAT param inits keep the operation in BOTH
  views with unparented literal operands (never fold). Elab call folds
  with a 1-BIT result encode BIN:<b> / decompile w'b<b> (15/32-bit
  results keep decimal INT/UINT — VarInFor + CastInFunctionToParameterWidth
  taught the width gate).
- **port_int_types**: def CAs unparent DIRECT-literal unary operands
  (assign a = -1; nested ~A[3] keeps index parents — constmsk/lcov
  taught the isLiteralExpr gate); the ELAB view folds a negative-literal
  RHS to a loc-less INT:<neg> at the LHS type width REGARDLESS of
  signedness (byte unsigned d=-4 -> INT:-4@16, not a UINT wrap).

**NEXT LADDER (fresh difsize)**: iface_passthrough (48),
CastClog2ToMinimalSizeOfParamValueFromCommandLine (58),
ParameterOfSizeOfParametrizedPort (60), BindModuleWithInputPortsInGenScope
(62), MixedPatterns (62), nested_cast_repro (62), OneClass (62),
iface_param_width_per_inst (64), StringAssignConcatenation (64),
StructPackedArray (66).

Findings on the two probed-but-deferred:
- **iface_passthrough**: iface port FORWARDED port-to-port (mid passes its
  own port to leaf). Golden adds an implicit wire net (work@mid.bus at the
  CONNECTION token) in mid's def view; leaf's def lowconn actual binds
  work@mid.bus (ours wrongly binds top's elab var); the elab u_leaf
  highconn actual resolves THROUGH the passthrough to the ORIGINAL
  interface's col-0 tail dup (work@top.bus); the fresh-CA rule does NOT
  apply (passthrough shares the def CA — discriminate via
  ip.getConnection() kind Instance vs InterfacePort); weak-tail shows the
  DEEPER port view's vars created before the shallower one and the def
  port ts drain interleaved per-child. Order-sensitive; budget a session.
- **CastClog2...FromCommandLine** (`int'($clog2(X)'(X))`): the INNER
  conversion loses its syntax (nested casts) so the def inner-cast ts
  falls to the loc-less logic_typespec fallback — golden wants
  integer_typespec at the $clog2(X) span carrying vpiExpr = the bound
  sys_func_call (needs a syntax-recovery pass-down from the outer
  CastExpression). The ELAB view must RE-EMIT the whole nested cast
  (outer ts -> shared int_typespec, inner ts -> loc-less logic_typespec,
  ref X unbound) — we currently mis-fold it to UINT:4294967295 from an
  unidentified branch (value is the signed-cast wrap; find the folder
  first).

## Session 6: ladder continued — PASS overtakes DIFF (2026-07-19, ~6 commits)

**FINAL: PASS 309->314, cmp-passing 346->351, DIFF 315->310.** PASS now
EXCEEDS DIFF for the first time. New full PASSes:

- **StreamOpImplicitSliceSize**: emitSyntaxExpr grew ElementSelect/
  IdentifierSelectName (t[0] -> bit_select, prefix-scoped, parented index)
  and StreamingConcatenationExpression (stream op at the INNER braces span
  wrapping a concat with the WHOLE streaming span — the usual span swap) —
  def-view gen if/else CAs from syntax now fill Lhs/Rhs; `parameter bit` ->
  bit_typespec (makeParamTs 2-state scalar); implicit-type multi-dim def
  net ts truncates at the first dim (ImplicitTypeSyntax dims); ELAB
  gen-scope STREAMING operand refs stay UNBOUND (suppressRefActual around
  the gen CA RHS — note the RHS often hides behind a non-implicit
  Conversion, strip one level).
- **unbased_unsized_shift**: OPERATIONS over unbased-unsized literals
  ('0 << 8) never fold in the elab — the CA re-emits the operation. Casts
  (3'('0)) and DIRECT literals still fold (three regressions taught the
  exact gate: BinaryOp/UnaryOp/ConditionalOp/Concatenation only).
- **FileLevelParameter**: $unit parameters emit as DESIGN-level
  Parameters/Param_assigns (name-only, value on the param, RHS constant
  with a BARE ts ref) — emitted BEFORE module defs so module refs bind the
  design parameter (unitParamMap); the int_typespec materializes at the
  VERY END (pendingUnitParamTs, after pendingSysFuncTs).
- **issue326_packed_mem**: PARAM-sized unpacked dims ([DEPTH]) fold the
  size constant at the param's width WITH a ts ref (loc-less signed int
  clone, fullname = the VAR — boundOwnerFullName member set around the
  elab sharedTypespec call) and the array_var VpiSize counts such dims as
  1; TYPED-param bare packed bounds ([ADDR_WIDTH:0]) take the same
  fold+ts shape (UNTYPED params keep the bare 64-bit fold —
  multiple_blocking taught that gate); SUBTRACT param inits (W - 19) fold
  INT/ct7.
- **Replication** ('{8{1}} in a CA): def-view pattern operands stay
  UNPARENTED at 64 bits (plainCtx = !reemitting && !suppress && !force);
  the elab RE-EMITS the operation (ReplicatedAssignmentPattern added to
  containsOperation + excluded from tryFoldConst) with PARENTED operands,
  count still 64; the count-to-32 resize applies only in INIT contexts
  (suppressConstParent on entry).

NEXT LADDER (fresh difsize): ParameterInitializationWithNegation (35),
clk2fflogic_effects (45), StringAssignment (45), CastWidthFromPackage (48),
InterfaceAsPortAssignValueInSubmodule (49), BitsCallOnSubArray (50),
MultipleCells (50), PkgParamAsFunctionArg (55), port_int_types (56).

## Session 5: UNSUPPORTED -> ZERO + ladder (2026-07-19, ~5 commits)

**FINAL: PASS 304->309, cmp-passing 341->346, DIFF 317->315,
UNSUPPORTED 3->0.** Every achievable corpus test now emits UHDM, and all
three former UNSUP went to FULL byte-identical PASS:

- **sva_value_change_sim PASS** (was UNSUP, 1288-line diff — all downstream
  of two missing pieces): ClockingEvent expression args
  ($fell(a, @(posedge clk))) emit via emitEventExpr (edge operation), and
  PROCEDURAL `assert property` (ConcurrentAssertion statement) emits an
  assert_stmt statement with property_spec (StmtEmit case mirroring
  emitAssertion). Sampled-value funcs ($fell/$rose/$stable/$past): share the
  elab CA (containsOperation exempt), carry the LHS ts (pendingSysFuncTs
  names + a NET fallback in the drain beyond ports), and take a NAME-ONLY
  span when a clocking-event arg is present.
- **sva_counter PASS**: named property decls (property_decl on the module:
  bare-ts prop_formal_decls; body from AssertionInstanceExpression::
  makeDefault with ::-scoped refs — FORMAL refs bind Invalid (untyped) and
  resolve via propDeclScope to IMPLICIT MODULE WIRES, Surelog leaks formals
  as module nets); property_inst for the instantiation (args ALSO held by a
  weakly-tail artifact func_call that carries parent+args; the
  property_inst itself is PARENTLESS); sequence repeats ([*n] -> op 60,
  count from the SYNTAX BitSelect — literal counts unparented, the seq
  operand keeps the PROPERTY_SPEC as parent); spaced based literals
  (8'd 3 -> 8'd3) re-lex compactly: setLocCompact/basedLiteralSpaceCount
  shrink ALL containing spans (constants, ops, property_specs, asserts).
- **OneThis PASS** (classes): class_defn in design->AllClasses (VpiName
  work@foo, file set); properties as ::-fullname bit/logic vars
  (Automatic+Visibility, ts ref DEFERRED to the write phase —
  pendingClassPropTs); methods via emitTaskFuncs classScope (:: seps via
  "work@foo::" prefix + joinRef's contains-:: rule; VpiMethod, NO
  Automatic/Instance; implicit built-ins (randomize...) skipped via
  !getSyntax; `this` local skipped; formals stay UNBOUND); class emission
  BETWEEN def modules and tops (arena order). Module side: handles are bare
  def logic_nets (no ts) / elab class_vars with per-decl fresh
  class_typespec (name foo, Class_defn link); bar = new() -> loc-less
  method_func_call "new" + the Lhs ref re-parented through a weakly-tail
  artifact hier_path (name==fullname frozen, ref UNBOUND); bar.set(4) ->
  method_func_call at the method token with unbound Prefix ref;
  this.member -> hier_path spanning the `this` token, member ref loc-less
  with block-scoped fullname; named blocks now carry vpiEndLabel; 2-state
  vectors get bit_typespec (makeTypespec).
- **PutC PASS**: STATEMENT-context built-in method calls (b.putc(2,"x");)
  flatten to method_func_call + unbound Prefix (the hier_path shape is
  expression-context only; gate on stmtCtx).
- **StreamOp PASS**: >> maps vpiStreamLROp (slang sliceSize==0 = LR) and
  BOTH directions emit the slice const — parsed from RAW TEXT (streaming
  exprs often arrive with null syntax), located, def-unparented but
  elab-parented (reemitting); folded CONCAT RHS encodes full-width
  BIN:<bits> with NO decompile (tryFoldConst).

NEXT: StreamOpImplicitSliceSize (68), unbased_unsized_shift (52),
FileLevelParameter (43), issue326_packed_mem (43), Replication (44),
clk2fflogic_effects (45), StringAssignment (45), CastWidthFromPackage (48).
Re-run scripts/difsize.sh for the fresh ladder.

## Session 4: DIFF-frontier pickoff continued (2026-07-19, ~8 commits)

**FINAL: PASS 298->304, CMP_ONLY 37 (cmp-passing 341), DIFF 323->317,
UNSUP 3.** Same per-test method and gates as session 3.

New PASS: IndexedPartSelectInUniqueCase (elab struct-var pattern inits fold
per-member: op 75 + bare ts ref + per-setter UINT constants at the setter
sites — unsigned magnitude via SVInt::setSigned(false); hier-path indexed
selects in the 1640-branch carry the DOTTED fullname and stop BEFORE ']'),
ParameterWithUnderscoreValueDividedPassedFromCommandLine (the x/z bare
ts-ref on param RHS constants is DEF-only; elab TYPED-param op inits fold
UNKNOWN param-ref operands to their BIN:X constants copied from the param
objects + the op gains a ts ref patched to the param ts),
UnsizedConstantParameter (non-overridden '1-UINT vector-param folds bind
LOC-LESS bare ts clones — makeBareVecParamTs — at the elab param_assign
(unparented bounds, no clone parent) and the CA clone drain (parented
bounds + clone parent); overridden or BIN-valued folds keep the LOCATED
ts: gate = UINT-value && !isOverriddenParam && isPackedArray), setundef
(NO-DEFAULT overridden params: isOverriddenParam is FALSE without a
default — gate on !hasDefault && getInitializer(); def AND elab
param_assign Rhs empty at emission, the ELAB one backpatched to SHARE the
CA's raw-encoded loc-less fold constant (noDefOvPa/noDefOvTsRef pendings);
vpiOverriden set; CA re-emits with def-net-bound Lhs), GetC (built-in
METHOD calls (no leading $) do NOT force a fresh elab CA in
containsOperation; method literal args parent at the method_func_call;
string-literal var inits keep 8*len size — the bare-decimal resize was
clobbering them to width 0). case_expr_non_const DIFF->CMP_ONLY (negative
'sb net-decl RHS re-encodes INT:<v>/ct7 in elab; fresh net-decl Lhs nets
keep vpiSigned; residual = int_typespec creation-order interleave).

Near-leads left measured: PutC (50, method-call statement contexts),
StreamOp (41), FileLevelParameter (43), issue326_packed_mem (43),
Replication (44), clk2fflogic_effects (45), StringAssignment (45),
CastWidthFromPackage (48), param_no_default (261 — the setundef no-default
machinery is the entry point, multi-view encoding still to map).

## Session 3: DIFF-frontier pickoff (2026-07-19, ~17 commits)

**FINAL: PASS 280->298, CMP_ONLY 33->37 (cmp-passing 313->335), DIFF
345->323, UNSUP 3 (unchanged: OneThis/sva_counter/sva_value_change_sim).**
Zero net regressions; every commit gated by goldens 23/23 + full corpus +
the PASS->CMP_ONLY demotion join (run_corpus MISSES that class — always run
`join -t, -j1 <(sort baseline) <(sort new) -o 1.1,1.2,2.2 | awk -F, '$2!=$3'`).

18 tests converged to full PASS, in order: ImportParametrizedType (module
explicit-import typedefs listed+re-parented; pkg def-view bound refs bind the
param's init constant), PatternAsFunctionArgument (constCallFold follows
literal-pattern args through element selects; pattern func-args carry the
formal element-ts ref — added uhdmoperation to the arg-ts kinds),
unbased_unsized ('0 def-sized at whole-net LHS + elab SHARES the def
constant — '1 folds fresh UINT, 'x/'z share; elab port HighConn literals
parent at the port), StructMemberAsModuleInput (dotted port conns scope the
LAST hier elem through prefix.child.port in BOTH views; elab hier_path
carries the struct-ts ref + base struct_net as Root_value→vpiExpr),
CastInFunctionToParameterWidth (PARENthesized param width (P)'(x) reuses the
param's int_typespec + loc-less doubled-fullname Cast_to_expr ref_obj,
mirrored into the elab ts at patchParamTypespecs), TypedefInModulePort (pkg
vector-typedef ports: no def NetType, elab logic_var, clone keeps pkg
Instance — module-LOCAL clones carry NONE), FunctionExportDPI (exported
FUNCTION locates at the export directive — exported TASK keeps its def span
(TaskExportDPI!); DPI-import prototypes synthesize the Return var; DPIImport
returnTypeSyntax), CastToSum submodule pair (override-gated port ranges:
rangeRefsOverriddenParam -> def port ts DEFERRED into pendingNetTs, unfolds
with name-only refs at the write phase — the narrow trigger the old -19
blanket missed), StreamOperatorBitReverseFunction (BARE param width P'(x)
mints a per-site NAMED int_typespec with UINT:<value> at a zero-width span
on the param name token), ParameterColonReference (pkg-param bit-selects:
pkg::A-named select parented at the pkg parameter in def; elab folds to BIN
at init-start..+1), array_default_init ('{default:'0} array init emits via
the existing structured-pattern path; array_typespec created AFTER the init
for arena order), AssignmentPatternArrayPort (def pattern-conn ts-ref scopes
through the conn path; elab HighConn folds to <w>'d<digits> constType 0),
TypedefOnFileLevel (2-STATE structs — int members — elaborate as struct_vars
(4-state stay struct_nets: DotRange/UnsizedConst!); var-backed dotted-LHS
CAs re-emit fresh in elab with the def Rhs shared — NET-backed bases keep
the shared def CA), TypedefedFunctionArgument + TypedefedFunctionReturn
(typedef'd formals/returns get a fresh NAMED logic_typespec clone with
Typedef_alias -> shared typedef; formal clone at the USE token, return clone
at the TYPEDEF site with the return var at the type token; typedef-return
calls NEVER fold in elab — the CA stays shared), AssignTypedefedFunctionCall
(user-call var inits keep the func_call as elab vpiExpr),
SizeOfUnsignedParameter (localparam $bits folds LOC-LESS in elab re-emits
only — def keeps the call+LHS-ts; parameter $bits still kept; signed-implicit
param ts at the signing keyword, param-parented). Plus OnePackage
DIFF->CMP_ONLY (module-context pkg enum-const refs fold to the enum's OWN
encoding — INTERFACE contexts keep the ref, gated by walking VpiParent to
the owning instance type; typed pkg-param folds size at the type width,
untyped stay 64) and side-flips: TypedefWithParameter, SelectFromUnpacked,
AssignBitsCallToSubmoduleParameter -> CMP_ONLY.

DIRECTION TRAP: in `diff -u surelog.dump slang.dump`, `-` = GOLDEN, `+` =
OURS. Misread three times this session; verify before coding.

NEXT LEADS (diff-size ladder, measured): IndexedPartSelectInUniqueCase (31),
ParameterWithUnderscoreValueDividedPassedFromCommandLine (35), GetC (36),
setundef (36), UnsizedConstantParameter (37), case_expr_non_const (38),
StreamOp (41), FileLevelParameter (43), issue326_packed_mem (43),
Replication (44). The difsize script is scratchpad/difsize.sh (re-measure
after batches — fixes shift the ladder).

## Overnight autonomous session 2 (2026-07-19, ~22 commits)

**FINAL: PASS 273->280, cmp-passing 299->313, UNSUPPORTED 62->3.**
(+EnumConcatenatedConst full PASS: computed enum-const inits encode BIN at
base width; def decompile = de-spaced source, top decompile UNSET; module fold
= <w>'b<bits>, ONE constant shared across both module views.)

NEXT LEADS for the DIFF frontier (345): FunctionExportDPI (25 lines: exported
fn loc = the export stmt line + DPI-import fn needs Return var + AccessType 4);
ImportParametrizedType (10); PatternAsFunctionArgument (15, needs func-param
elem ts + INT callFold); StructMemberAsModuleInput (19); TypedefInModulePort
(21); CastToSum cluster (need param-override-gated range unfold, NOT blanket —
blanket cost -19). Many newly-emitting ex-UNSUP tests have big diffs (500-7000
lines) needing struct/array elaboration depth. The only
remaining UNSUP: OneThis (NewClass — class support), sva_counter
(AssertionInstance), sva_value_change_sim (ClockingEvent). Everything else
EMITS; convergence work continues in DIFF (296).

Late additions beyond the list below: Final procedures; member access +
range/element selects over ANY compound base (interface arrays, struct-port
chains, 2D arrays) via relaxed dotted-builder gating; unpacked-array typedefs
(named array_typespec) + bare array_typespec struct members; package sub-call
shells; Invalid-child unwrap; casts to NAMED typedefs (my_struct'(a)) use the
shared typedef ts — the "Invalid" cluster was OUR size-cast misroute, NOT
slang (CastStruct/PackageCast cmp-pass); inside op + case-inside; built-in
method calls; $readmemh (NOTE: UHDM group setters SILENTLY reject vectors
with invalid members — a poisoned vector simply doesn't set).

**PASS 273->279, cmp-passing 299->310, UNSUPPORTED 62->16.** Zero demotions
throughout (PASS-only + cmp-only checks each commit). Features landed:
- Package-scoped enums (pkg::pkg:: base fullname, view-dependent decompile,
  both-view module fold, base ts Instance) — 3 tests cmp-pass.
- Interfaces list imported pkg typedefs (SHARED top-view object re-parented,
  base/member refs re-scoped work@<iface>.<pkg>::<ts>[.member]); elab home
  view lists them too (not port views); elab folds pkg enum-const RHS loc-less.
- Interface struct members: def net netType wire; elab home struct_net (Nets);
  port views carry a fresh struct_net on the modport io_decl (doubled fullname
  prefix.<modport>.<m>.<m>); pkg-typedef struct PORT nets are wires.
- MemberAccess/selects over dotted interface paths: shared buildDottedHierPath
  (name-only fullname trick: fullname==name is OMITTED by the dump and blocks
  the lazy scoped recompute); Range/Element selects over dotted/array-element
  bases -> hier_path with final (indexed_)part_/bit_select; a[0] components
  become bit_selects. Fall-through gating on NamedValue bottoms.
- Modport-qualified conns (.mon(s.mon)): hier HighConn, formal-anchored
  LowConn, NO tail dup / conn-site net (both gated on a bare whole-iface conn).
- Packed unions (buildUnionTs), file-level vector typedefs, NamedType+dims.
- fork/join (+join types), disable (+implicit label wire), procedural assign,
  streaming ops (stream-op wraps concat with SWAPPED spans; sliced adds the
  slice const), $readmemh (EmptyArgument skip + output-arg Assignment unwrap —
  NOTE: UHDM group setters SILENTLY REJECT invalid vectors), built-in method
  calls (e.first() -> hier + method_func_call), inside op + case-inside,
  package sub-call shells.

Remaining UNSUP (16): Invalid-no-child (CastStruct/size_cast/PackageCast/
ucsbece154b — slang leaves them unbound), member-access-base 3 (iface array
struct whole/gen_delay/unpacked), member-select 2, range-select-in-for 2,
Final procedure, sva x2 (AssertionInstance/ClockingEvent), NewClass, getc/putc
remainder. Each needs specific feature work.

## (prior sessions below)

## Autonomous convergence session (2026-07-19, uhdm-cmp=golden policy)

FINAL: PASS 270->273, cmp-passing 289->294, ~15 commits, ZERO regressions
(goldens 23/23 + full corpus + manual demotion check on every commit). Flips:
simple_fsm, alu_sub, OneCast -> PASS; BitsCallOnExpression, Clog2,
SizeOfGeneratedWireArray -> CMP_ONLY. Method that worked: branch + patch +
full corpus + demotion check; commit clean wins, revert regressions.

Frontier is now uniformly FEATURE-LEVEL (verified by categorizing all ~296
DIFF cmp-failures by first-object): imported typedefs in modules, function-
scoped casts, package enums referencing pkg params (fullname doubling
pkg::pkg::), anon structs/unions (struct/union typespecs + members), real
arithmetic, interface struct-member access (22 UNSUP), multidim packed arrays
(7 UNSUP), assignment-as-expression (asgn_expr), packed unions. Each is hours
of feature work with regression risk — NOT rushed autonomously. Correct
partials already landed that ADVANCE many (no-default params, real typespec/
value, enum-int base, typed/ranged param ts, string_typespec).

Highest next leads (documented per-test above/below): (1) typespec-on-
expression — extend the sys_func_call-RHS typespec mechanism (add names /
investigate operation-RHS); (2) enum-with-pkg-param value + fullname doubling
(3 tests: ReferencedPackageParameterInEnum, iface_pkg_enum_item,
ImportedPackageEnumItemInInterface); (3) CastToSum range-unfold needs a NARROW
trigger (param overridden), not the blanket def-port unfold (which cost -19).

(later wins): 
- **Typespec-on-expression cluster** (HIGH YIELD): a kept sys_func_call RHS of
  a cont-assign carries a ref_typespec sharing the LHS net's typespec. The
  mechanism already existed for $signed/$unsigned (pendingSysFuncTs, ModuleEmit
  ~2198); extended to $bits and $clog2 -> SizeOfGeneratedWireArray + Clog2 both
  DIFF->CMP_ONLY. To extend: add the sys-func name to that condition. (Not yet
  done: operation-RHS carrying LHS typespec — likely more members.)
- OneCast PASS: (1) signedSizeCast only reinterprets as signed when the result
  is actually NEGATIVE (high bit set) — 32'(ONE) stays UINT; (2) a size-cast
  param value takes the CAST width, not the untyped-64 default. ExprEmit+ParamEmit.
- REVERTED (corpus caught, -19 PASS): setting tfContext to unfold param ranges
  in ALL module def ports — most module def typespecs fold/share-with-elab
  (unlike interfaces). CastToSum needs a NARROW trigger (param overridden at
  instantiation), not a blanket unfold.

(earlier this session)
PASS 270->272, cmp-passing 289->291, all merged to main, zero regressions
(every change corpus-checked with manual demotion check; regressive experiments
reverted). Method: find over-restrictive gates / structural diffs, test on a
branch with full corpus, commit only clean wins.
- BitsCallOnExpression CMP_ONLY: $bits does NOT fold when arg is an expression
  ($bits(~x)) or a PARAMETER ($bits(P), override-dependent); type/var/member
  args still fold. ExprEmit.
- simple_fsm + alu_sub PASS: value/typespec plain LOCAL untyped params
  (localparam IDLE=2'b00) — dropped the isLocal exclusion. ParamEmit.
- Correct partials (no test flip, safe): no-default (override-only) params
  empty in def view; real param real_typespec + REAL value; typed/ranged param
  typespec kept with x/z value; untyped string-literal -> string_typespec.

REVERTED experiments (regressed, corpus caught them): removing x/z-const ts-ref
(needed by ParameterWithUnderscoreValue+Divided); rhs-unknown ts gate (needed
by UnsizedConstantsParameterParsing); $bits value-arg broadening ($bits(var)
DOES fold); port-default High_conn (getInitializer also returns instance-port
connections; def-only prefix gate didn't isolate cleanly).

**Confirmed close DIFF tests (each blocked on a specific, non-trivial piece):**
- SizeOfUnsignedParameter (36): $bits(P) now kept, but the sys_func_call needs
  vpiTypespec -> the assign TARGET's int_typespec (typespec-on-expression).
- OneCast (18): localparam DUMMY=32'(ONE) — mine INT:1/size64+signed ts vs
  golden UINT:1/size32 (signedSizeCast over-fires for positive size casts +
  untyped-param size-64 override wrong for cast values).
- setundef (36): no-default RANGED param overridden with x/z — needs
  vpiOverriden + override-constant structure for no-default overrides.
- **Typespec-on-expression cluster** (Clog2, PatternAsFunctionArgument,
  SizeOfUnsignedParameter): a folded/kept RHS expr (operation / $clog2 /
  $bits / pattern) carries the assign TARGET's typespec. If a general "RHS of a
  typed cont_assign carries the LHS net's typespec" rule can be added safely,
  it may flip several — but it's regression-prone (RHS typespec paths).
- defvalue (199): port default values -> port High_conn (PortSymbol::
  getInitializer, def-decl only). param_no_default (263): no-default override
  encoding across elab views. Both niche/multi-view.

## Oracle/mechanism findings + frontier reality (2026-07-19, verified)

- **Surelog version**: local build `v1.86-114-gcbdbea458c` (Jul 17 2026), 6
  commits behind upstream master; UHDM submodule also behind. Goldens are from
  THIS local build (the campaign oracle) — match it, don't chase upstream.
- **uhdm-cmp ignores ALL locations**: BaseClass/constant Compare compare NO
  line/column fields. So every location-only diff is cmp-tolerated (CMP_ONLY).
  Verified: StringWithBackslash cmp exit 0.
- **StringWithBackslash "loc bug"** = a SURELOG preprocessor bug (a backtick
  triggers macro scanning; backslash-near-whitespace before it over-counts the
  end column; e.g. golden endln 3:47 vs correct 3:39). Stored wrong in the
  .uhdm (uhdm-dump is faithful — proven: replace backtick with X -> 3:39).
  Not a clean formula (preprocessor state machine). Repro files:
  slang-uhdm/locbug/{dut.sv,golden.uhdm,golden.uhdm-dump.log} (buggy dump line 53).
- **Weakly-tail ordering**: UhdmId is assigned by uhdm-dump at RESTORE
  (`Serializer_restore.cpp:56 ++m_objId`), in serialization order = per-type
  factory-vector order = my Make*() creation order within each type. So it's
  PERF-FREE to influence (uhdm-dump computes the id, not us). BUT not a clean
  local reorder: e.g. BindModuleWithInputPorts needs the DUPLICATE net
  logic_typespec created AFTER the param int_typespecs (a deferred-phase
  match), not inline — fragile per-construct. Deferred (dump-cosmetic only).
- **DIFF vs CMP_ONLY is the real semantic line**: DIFF => uhdm-cmp FAILS
  (exit != 0, genuine mismatch); CMP_ONLY => cmp PASSES (cosmetic only).
  Verified on 4 DIFF (exit 255) + CellNamedLikeModule (exit 0).
- **Frontier reality**: cmp-first-mismatch shallowness does NOT predict fix
  size. The "shallow-cmp" DIFF tests have LARGE dump diffs / structural gaps:
  const_func 2085, defvalue 211, param_no_default 356, OneCast 154. The clean
  single-gap DIFF wins are exhausted; remaining DIFF needs per-test FEATURE
  work: no-default params (override-only params must be EMPTY in the def view —
  no value/typespec/param_assign Rhs), generate-with-const-func-cond, casts,
  assignment-pattern typespecs, hier-path struct-member scoping.
- Landed r113: untyped string-literal param -> string_typespec (const_func
  partial; correct, no regressions). Policy going forward: **uhdm-cmp is the
  golden; dump byte-match is best-effort.**

## Small-DIFF pickoff r106-r112 (2026-07-19)

PASS 263->270, CMP_ONLY 17->18, all merged to main, zero regressions (goldens
23/23 + full corpus + manual PASS->CMP_ONLY demotion check each commit).
- r112 unpacked_array_shift_ff PASS: the UnbasedUnsizedIntegerLiteral parent
  rule ignored suppressConstParent (IntegerLiteral honors it), so a
  '{default: '0} pattern default got wrongly parented to the operation. Added
  the !suppressConstParent guard. ExprEmit.

**CMP_ONLY closest-to-PASS scan (dump-diff lines):** most are weakly-tail
ORDERING (same int_typespec/logic_typespec objects, different tail position by
UhdmId — cmp tolerates, byte-match needs matching Surelog's creation/id order,
broad+hard) or Surelog location bugs:
- StringWithBackslash (8): Surelog's string end column (3:47) is PAST the actual
  line end (`;` at col 39) — an escape-counting bug, not sensibly matchable.
- partsel_simple (6): a shared logic_typespec's VpiParent differs (logic_net vs
  ref_typespec) AND tail position — parent + ordering.
- CellNamedLikeModule / InterfaceAssign / InterfaceWithPort / iface_param_* /
  InterfaceParameter*: int_typespec/logic_typespec tail ordering.
Matching the weakly-tail id order across these would flip several CMP_ONLY->PASS
at once but needs the serializer creation-order to match Surelog — a larger
structural effort (see the weakly-tail mechanism in the modport section).

### r106-r111 detail
- r110 (no test flip): a 1-bit 'x based literal formats UPPERCASE (1'bx->1'bX /
  BIN:X) but 1-bit z and all multi-bit x/z stay lowercase (Surelog quirk,
  confirmed exhaustively). ExprEmit IntegerLiteral. Cuts unbased_unsized 26->18.
- r111 sign_part_assign + case_expr_const PASS: a SIGNED based literal ('sb/'sd)
  carries vpiTypespec -> ref_typespec -> int_typespec(signed) (tail). Also moved
  mixed_sign_ops DIFF->CMP_ONLY. ExprEmit IntegerLiteral. THIS IS THE SHARED
  "signed int_typespec on a constant" CLUSTER — but the OTHER cluster members
  (PatternAsFunctionArgument, Clog2, mixed_sign_ops) each have a 2nd issue.

**Remaining near-DIFF (all now multi-issue; single-fix wins exhausted):**
- mixed_sign_ops: CMP_ONLY. Remaining = location off-by-one ONLY on the
  double-space `4'd2  ** u1` line (whitespace-sensitive span; low value).
- PatternAsFunctionArgument (15): (a) assignment-pattern operation needs the
  func-param element int_typespec ref; (b) folded call result 1 should be INT
  (callFold path/signedness), no loc. mine: UINT + loc via tryFoldConst.
- CastToSum.. / CastInFunctionToParameterWidth: cast folds an operation golden
  keeps (P+.. as operation), + int_typespec-vs-integer_typespec type/loc.
- BitsCallOnExpression: mine FOLDS $bits(expr) (pre-existing emitExpr fold at
  ExprEmit ~883) but golden keeps the sys_func_call here — a "when NOT to fold
  $bits" context distinction (opposite of r107's typedef fold).
- Clog2.. (17): needs the target int_typespec ref on $clog2 + a port LowConn
  int_var-vs-logic_net binding (2-3 issues).
- unbased_unsized (18): elab cont-assign unbased '0 RHS sizing (64 vs -1),
  def/elab constant sharing, + HighConn constant port parent (3 issues).
- StructMemberAsModuleInput (19): hier-path fullname scoping + struct_typespec
  + struct_net vpiExpr (3 issues).
Highest remaining leverage: finish the signed/typespec-on-expression work
(PatternAsFunctionArgument (b) signedness, Clog2/PatternAsFunctionArgument (a)
target-typespec) — a real cluster, but each test needs both halves to flip.

### Earlier this day: r106-r109
- r106 UnsizedConstantsParameterParsing PASS: elab-view unbased-unsized 'x/'z
  param default decompiles 'bX/'bZ (def view keeps bare 'X). ParamEmit.cpp.
- r107 BitsCallOnType PASS: fold $bits/$size/$clog2 type-query bounds to a
  constant ONLY inside a named typedef typespec (typedefTsContext flag); a
  variable's inline type keeps the sys_func_call. TypeEmit emitSyntaxExpr.
- r108 func_output_arg PASS: whole-ref -> select-object Actual binding. Rule
  (derived across corpus, base-type gated): bit-select write re-points only if
  base is io_decl; indexed-part-select write only if base is logic_net; simple
  part-select never; local logic_var never. Per-body track+backpatch
  (beginSelTrack/endSelTrack around process + function bodies).
- r109 multiple_blocking PASS: signed power (2**n) -> INT const; a param
  int-encoded from one propagates so net range bounds ([DINW:0]) emit INT.
  isIntEncoded Power case + emitBound binds bound syntax to check isIntEncoded.

**Near-DIFF triage (remaining, each now multi-issue / bespoke Surelog quirk):**
- sign_part_assign (10): signed based-literal (1'sb1) needs a signed
  int_typespec ref + weakly-tail int_typespec. Separate feature.
- unbased_unsized (26): ABANDONED — Surelog inconsistently uppercases 1'bx->
  1'bX but keeps 1'bz, 3'bxxx, 3'bzzz lowercase (x-only, 1-bit-only). Not a
  sane rule; global uppercase regresses (34 lines).
- Clog2OfSum.. / PatternAsFunctionArgument / BitsCallOnExpression / CastToSum..
  / CastInFunctionToParameterWidth: "missing int_typespec/ref_typespec on an
  expression (operation / $clog2 / cast)" cluster — Surelog attaches the
  assignment target's typespec to certain folded expressions. Clog2 ALSO has
  a port-LowConn int_var-vs-logic_net binding diff (3 issues).
- StructMemberAsModuleInput (19): hier_path inner-ref fullname should scope
  through the port-connection path (work@top.d.o.ping_p, not work@top.ping_p),
  plus a missing struct_typespec ref + struct_net vpiExpr. 3 issues.
- ImportParametrizedTypeAndDeclareParamWithTheSameName (10): package/module
  param structural mismatch.
Debugging aids still in scratchpad (finder/f2..f15, build cmd in the modport
section below).

## Modport tail-dup convergence (2026-07-18, branch `iface-modport-tail`)

iface_modport DIFF->CMP_ONLY (cmp now passes; 26-line dump diff is pure
weakly-tail typespec ORDERING, tolerated). CMP_ONLY 17->18, no regressions.
Decoded the full Surelog interface_inst reference topology:

- Two interface_inst STYLES per interface:
  - **Declaration-style (home)** e.g. `work@top.bus` @decl-line:col (25:5):
    HAS Instance/DefFile/DefLineNo; modport io_decl has NO vpiExpr; modport
    Interface_inst self-refs; loc shows endln.
  - **Reference-style** e.g. m0 port view `work@top.m0.bus` @instantiation
    line, col 0 (27:0) AND the home's col-0 **tail duplicate** `work@top.bus`
    (25:0): OMIT Instance/DefFile/DefLineNo; modport io_decl HAS vpiExpr;
    modport Interface_inst self-refs; NO endln. The tail dup SHARES the home
    view's variable objects (shown shallow in the dump) and is referenced only
    weakly (from the receiving module port's HighConn ref_obj) -> lands in the
    weaklyReferenced tail.
- A receiving module port's **Low_conn** ref_obj.Actual must point at the PORT
  VIEW's own modport (io_decl exprs + Interface_inst back-ptr), NOT the shared
  def modport. Repointed in the portIfaces loop after the port view is built.
- HighConn ref_obj.Actual -> the col-0 tail dup (ifaceTailDup map), not the
  home view. LowConn ref_obj loc = connection site, not port decl.

**Semantically redundant (future `--no-surelog-tail-dups` switch, default
OFF):** the col-0 tail duplicate (`makeIfaceRefDup` + the HighConn redirect to
it) carries zero semantic info beyond the home view — it exists only to match
Surelog's folded-UHDM dumper byte-for-byte. The modport `vpiExpr` on io_decls
and the modport `Interface_inst` self-ref are likewise dump-fidelity only
(the direction + name already fully specify the modport port). A switch can
skip makeIfaceRefDup, the ifaceTailDup HighConn redirect, and the io_decl
Expr / modport Interface_inst wiring without changing semantics.

Debugging aids (scratchpad): finder/f2..f15 — small UHDM-linked programs that
load two .uhdm files, run per-subobject `Compare`, and localize the first
mismatched scalar/vector (uhdm-cmp only reports the leaf pair, not the path).
Build: `g++ -std=c++17 -I$UHDM/include -I$UHDM/build/generated f.cpp
$UHDM/build/lib/libuhdm.a <capnp .a's> /usr/lib64/libz.so.1`. f8/f11/f12
bisect a module's/design's collections; f13-f15 dump nets+ref_modules.

**BLOCKED — iface_modport_out/conn/passthrough (still DIFF/CMP_FAIL).** Root
cause is the parent DEF view's connection-site NET + child-module ref_module,
which Surelog emits by an OPAQUE rule that does NOT reduce to any of: "parent
drives interface", net-present<=>refmod-present, or interface arity. Measured
golden top-def state (net = interface-named wire in parent; refmod = child
MODULE ref_module):
  - iface_modport:      net YES, module-refmod YES  (top drives bus.in)
  - iface_modport_out:  net NO,  module-refmod NO   (top reads bus.out only)
  - iface_modport_conn: net NO,  module-refmod YES  (top reads s.cnt only)
  - passthrough:        net YES, module-refmod YES  (top neither reads nor
                        writes bus — only forwards it to u_mid)
No single predicate fits all four; passthrough breaks "drives", conn breaks
net<=>refmod. Mine currently emits BOTH net+refmod unconditionally (correct
for modport/passthrough, wrong for out/conn). Do NOT gate these without a
rule validated across ALL interface tests — a wrong gate regresses the ones
that pass. Next: instrument what REFERENCES the connection-site net/refmod in
each golden (holders) to reverse the actual trigger, or defer as low-value.

## Session r166-r173 + interface feature (2026-07-18, this session)

PASS 256->263, DIFF 299->306, CMP_ONLY 8->17, UNSUP 98->75. All clean
(no regressions). Interface feature: simple+ported interface_inst (1 PASS +
8 CMP_ONLY), then the MODPORT feature EMISSION (23 tests UNSUP->DIFF) +
partial convergence (elab InterfacePort HighConn->interface_inst; a bare
logic_net per interface port). Modport DIFF->CMP_ONLY is now a large per-test
phase - fixes are small and TEST-SPECIFIC (e.g. suppressing the child def
ref_module helped iface_modport_out -35 but hurt iface_modport/passthrough,
so NOT a universal rule). See the MODPORT FEATURE + INTERFACE FEATURE
sections for status + remaining work. (r173)
Unbased-unsized param values handle 'x/'z (fixed a latent r172 BIN:1 bug);
elab RHS is value-dependent ('1 -> UINT all-ones). Next interface lever:
template emitPorts/emitContAssigns/emitProcess on the instance type to
support ported interfaces (InterfaceAssign/Initial/Always/WithPort).

MODPORT FEATURE — EMISSION DONE + PARTIAL CONVERGENCE (23 UNSUP->DIFF; UNSUP
98->75). All pieces emit (modports, interface_typespec, InterfacePort,
ArbitrarySymbol). Common-cause convergence done (each roughly halved the
modport diffs, no regressions): (a) a bare logic_net per interface port;
(b) elab InterfacePort HighConn->interface_inst (ifaceInstMap) + LowConn->
modport + vpiDirection; (c) elab interface_inst emits its own modports;
(d) makeIfacePortTs: interface_typespec is a modport ts (vpiIsModPort) parented
by the base interface ts, from the InterfacePortHeader; (e) a dotless
ArbitrarySymbol is a plain ref_obj (only sub.sig -> hier_path). RESULT:
(f) BREAKTHROUGH - the INSTANCE-SCOPED interface_inst view: a module instance
with an interface port exposes its OWN interface_inst (work@top.m0.bus) under
vpiInterface, reusing emitInterfaceInstance with the instance-scoped path
(emitInstance !isTop block, gated conn.first->kind==Instance). Aggregate modport
DIFF -597. RESULT: iface_modport_out 167->83, iface_modport ->82,
iface_passthrough ->99, OneNetModport ->192. NONE at CMP_ONLY yet.
REMAINING is REFERENCE-ORDER-DEPENDENT (weakly-tail): golden duplicates the
interface_inst (abbreviated, loc col 0) in the weaklyReferenced tail, and holds
a connection-site logic_net (work@top.iface, referenced by the child ref_module).
MEASURED ~7 incremental attempts (connection-site net gated on scalar Instance,
modport Interface_inst + io_decl Expr, child ref_module suppression) - ALL
net-worse on the modport aggregate EVEN WHEN golden-correct, because adding one
referenced object shifts the weakly-tail arena order (iface_modport_out 83->91
with the golden-correct connection net). NEXT needs the full weakly-tail
reference/duplication model (how UHDM collects weaklyReferenced objects and
their dump order), not incremental object additions. None is close to CMP_ONLY
(smallest 82).

CMP-BLOCKER DIAGNOSIS (verified by walking uhdm-cmp on iface_modport, a
ref_module-KEEP test): the KEEP tests reach a SINGLE cmp mismatch with these
FOUR correct structural additions (all reverted - they worsen the DUMP metric
and convert nothing while the weakly-tail wall stands, but they ARE golden-
correct and get cmp to one weak-reference; RE-APPLY them together with a
weakly-tail fix):
  1. Connection-site logic_net: in emitModuleDef, for each child InterfacePort
     whose getConnection().first is a scalar Instance, emit a logic_net named
     after the interface (work@top.bus) at the connection expr, with
     n->VpiNetType(vpiWire); store in ifaceConnNet[iface] AND info.nets[iface].
  2. ref_module port bind: in emitModuleDefPorts, for an InterfacePort
     connection whose ref_obj came from emitExpr, set VpiFullName
     work@top.child.port and Actual_group=ifaceConnNet[iface] (the NamedValue
     branch already binds via info.nets once (1) stores it there).
  3. Elab modport io_decl Expr: io->Expr(netMap[mpp.internalSymbol]).
  4. Elab modport Interface_inst: umod->Interface_inst(iface).
THE WALL: golden ALSO emits the interface_inst AGAIN in the weaklyReferenced
tail (loc col 0, abbreviated) with a full modport whose io_decls carry vpiExpr;
this makes golden reference bus.in 8x vs mine 7x, and uhdm-cmp fails on the
missing weak reference (NOT just ordering). Cracking this needs matching UHDM's
Serializer weaklyReferenced collection (which owned-but-also-weakly-referenced
objects it re-lists, and in what order).
WEAKLY-TAIL MECHANISM FULLY DECODED (UHDM/templates/vpi_visitor.cpp): the
dumper collects into m_weaklyReferenced1 any object visited SHALLOWLY (weak
ref) that is NEVER fully visited in the main tree; at the end it full-dumps
them sorted by UhdmId. visit_modport() visits its Interface_inst SHALLOWLY
(vpi_visitor line ~2426, shallowVisit=true). GOLDEN EXPLOITS THIS: it creates
DUPLICATE interface_inst objects at COLUMN 0 (e.g. work@top.bus at line:25:0,
distinct from the owned one at 25:5) - one per weak reference point (the
modport's vpiInterface, connection sites). iface_modport golden has 9 such
col-0 interface_inst dups; each carries its own logic_vars + a modport whose
io_decls have vpiExpr->logic_var and whose vpiInterface points back to the
col-0 dup (self-referential). These col-0 dups are ONLY weakly referenced, so
they land in the tail, and their extra io_decl vpiExpr->logic_var references
are what make golden reference bus.in 8x vs mine 7x -> uhdm-cmp fails.
TO MATCH (the actual remaining task): create a col-0 "reference" interface_inst
duplicate for each modport's Interface_inst (and interface-connection point),
with the same vars + a self-referential modport, owned by NOTHING (only pointed
at weakly). This is pure Surelog dump-artifact replication (no semantic value)
but is what byte-identical requires. It is DEEP (object duplication + a
self-referential fixed point) and was NOT attempted; the 4 structural adds
above are the prerequisite. Est: converts the ~6 ref_module-KEEP modport
tests to CMP_ONLY; the OMIT tests additionally need the child-ref_module rule.
--- older note --- The KEEP tests (iface_modport,
iface_passthrough, iface_sig_in_child_port, ...) would convert to CMP_ONLY once
1-4 + the tail duplicate land. The OMIT tests (iface_modport_out,
OneNetModport, iface_modport_conn - golden emits ZERO child-module ref_modules)
ALSO need the child ref_module suppressed, and the rule is unclear (KEEP tests
have a top-level `assign iface.sig = ...` driving the interface; OMIT tests do
not - PLAUSIBLE rule: keep the child ref_module only if the parent itself
drives/refs the interface via a cont_assign, else omit - UNVERIFIED).
All-or-nothing per test: ANY noteUnsupported -> exit 4 -> UNSUP, so a modport
test needs ALL pieces below before it moves from UNSUP even to DIFF. Golden
structure verified on iface_sig_in_child_port (dut->mid(myif.s sub)->child).
PIECES:
 (1) MODPORTS - DONE (committed): interface_inst gets a vpiModport per
     ModportSymbol (VpiName + one io_decl per ModportPortSymbol: VpiName +
     VpiDirection from mpp.direction). isSimpleInterfaceBody now allows
     Modport. Matches golden exactly.
 (2) interface_typespec - s.MakeInterface_typespec(), VpiName = modport name,
     loc at the port's modport-name span. Referenced by the InterfacePort's
     vpiTypedef ref_typespec.
 (3) InterfacePort - a module port of kind SymbolKind::InterfacePort
     (InterfacePortSymbol: .interfaceDef=DefinitionSymbol*, .modport=name,
     .getConnection()->pair<Symbol* ifaceInstance, ModportSymbol*>). GOLDEN:
     port(sub) with vpiLowConn ref_obj (work@mid.sub.sub) -> Actual = the
     MODPORT object (s); vpiTypedef ref_typespec -> interface_typespec(s). Do
     NOT bail at ModuleEmit.cpp:45 for InterfacePort; emit it in emitPorts
     (def), emitModuleDefPorts, and emitInstance's port loop (elab). Need a
     map (interface DefinitionSymbol*, modport name)->UHDM::modport* populated
     in the modport emission (piece 1).
 (4) Elab interface connection - the interface instance passed to the module
     port (HighConn -> the interface_inst / its signals).
 (5) ArbitrarySymbol - emitExpr default case bails on ExpressionKind::
     ArbitrarySymbol (interface-port member access s.sig / sub.clk). Emit as a
     ref_obj/hier_path resolving through the modport to the interface signal.
     Some tests also need "element select base" (s.d[1]) and "member access
     base" (struct fields on interface signals).
Recommended: implement 2->5 in one focused block on a branch; verify each
against the iface_sig_in_child_port golden; the test only leaves UNSUP once
all bail-outs are gone, then converge the ~500-line diff.

--- ported interfaces (DONE) ---
PORTED-INTERFACE STEP (DONE — 4 tests converted to CMP_ONLY) — the ported
interfaces (InterfaceWithPort/Assign/Initial/Always) now converge to CMP_ONLY
(only weakly-tail typespec ordering remains). Key folded-model quirks handled:
(1) def-view interface ports carry no typespec; def net recorded in info.nets
so def port LowConns bind. (2) elab port loop handles positional connections
(loc at the conn expr) + parents the HighConn constant. (3) a single-instance
interface's def cont-assign refs re-point to the instance's ELAB vars (rebind
after elab). (4) the elab cont-assign SHARES the def's RHS object with a fresh
unbound elab-prefixed LHS. (5) processes are emitted ONCE in the elab view
(binding elab vars) and the SAME object is shared into both interface_inst
views (Surelog folds one process into both). Remaining ported-interface tests
with child instances/generate still fall through to the module path.
--- earlier (infrastructure) notes ---
INFRASTRUCTURE BUILT, per-test convergence remaining —
Step A: emitPorts/emitContAssigns/emitProcess/emitGenScopes now take instance*
and dispatch their setter on m->UhdmType() (instSetPorts/ContAssigns/Process/
GenScopeArrays in EmitHelpers.h). Step C: isSimpleInterfaceBody broadened to
allow ports/cont-assigns/processes (still excludes child instances/generate/
modports); emitInterfaceDef reuses those helpers (def view), emitInterfaceInstance
adds elab cont-assigns/processes + a port loop (LowConn own var, HighConn parent
signal, needs parentNets/parentRefs). Interface def ports carry NO typespec.
RESULT: no regressions; big reductions (InterfaceAssign 91->16, InterfaceWithPort
43->12, InterfaceInitial 63->37, InterfaceAlways 63->45) but still CMP_FAIL.
REMAINING per-test blockers to reach CMP_ONLY/PASS:
- InterfaceAssign: the def-view cont_assign LHS ref_obj should bind vpiActual to
  the ELAB int_var (a def->elab forward reference; Surelog quirk).
- InterfaceWithPort: the parent def-view ref_module port (emitModuleDefPorts loop,
  ~line 355) doesn't bind its ref to the interface child's def net (null vs
  logic_net) and has a wrong loc for positional/input connections.
- weakly-tail int_typespec ordering (the usual CMP_ONLY residue).
Next after that: the 48 UNSUP modport tests (InterfacePort/ArbitrarySymbol) build
on this same interface_inst infrastructure.

--- original analysis (still accurate) ---
The next interface lever after simple interfaces. Golden verified on InterfaceAssign (`interface
sw_test_status_if(output int x); assign x=10; endinterface` + `... u_sw(.x(o))`):
the interface_inst carries a vpiPort (x, dir out, LowConn->its net/var), a
vpiContAssign, and the parent references it via ref_module (def, whose vpiPort
carries the .x(o) HighConn) and vpiInterface (elab, whose vpiPort has BOTH
HighConn->parent's o and LowConn->interface's x var, cross-referenced).
MECHANISM decided: NOT C++ templates - instead change emitContAssigns/
emitProcess/emitPorts/emitGenScopes signatures from module_inst* to instance*
and dispatch the final setter on m->UhdmType() (uhdmmodule_inst vs
uhdminterface_inst; enum + VectorOf* types confirmed present). Nets(instance)/
Variables/Param_assigns/Typespecs(scope) need no dispatch. THE BLOCKER: the
elab port HighConn (linking the interface port to the PARENT's signal) is
emitted INLINE in emitInstance's instance-view port loop (~line 786+), not in
the reusable emitPorts (which only does LowConn). So converting ported
interfaces needs EITHER making emitInstance interface-aware (create
interface_inst, DefInfo::mod -> instance*, route + if/dispatch the ~7
module_inst-only calls) OR duplicating the port-connection logic into
emitInterfaceInstance. Every ported-interface test (InterfaceAssign/Initial/
Always/WithPort) has this port-connection need - no incremental win without it.
This is a large careful refactor of the core emission (produces 263 PASS);
do it as a dedicated focused effort, testing the module path green at each step.

Eight code commits (r166-r173), all clean (no regressions):
- (r166) Assignment-pattern param defaults ('{0,1}): elab-view folded RHS
  decompiles as based-decimal (2'd1) w/ no typespec & no constType; def-view
  pattern-op elements keep vpiSize:64 UNparented. Converts 4 Negation/Pattern
  param tests.
- (r167) Parameter vpiSigned only when the declaration has an explicit
  `parameter`/`localparam` keyword (bare ANSI #(int x) omits it). CellNamed
  DIFF->CMP_ONLY.
- (r168) Unbased-unsized VAR initializers ('0/'1/'x/'z) each encode distinctly
  ('0->BIN:0 sized, '1->UINT all-ones sized, 'x/'z->BIN:X/Z size -1). Converts
  UnsizedConstantsParsing.
- (r169) Unified outermost assignment-pattern element sizing on
  suppressConstParent (var-init resizes to element type; func-arg/param-default
  keep 64 unparented). Subsumes r166 inParamInit case.
- (r170) Folded range-bound: only SUBTRACT (N-1) is INT; other ops (P+1) are
  UINT (counter WIDTH-1->INT:7, CastToSum P+1->UINT:2).
- (r171) Module vector/scalar typedef ranges UNFOLD param/$bits-dependent
  bounds (tfContext). BitsCallOnType 25->15, +3 others reduced.
- (r172) Unbased-unsized typed-param defaults ('0/'1): parameter VpiValue
  BIN:<bit>; elab RHS BIN + <width>'b<bit> decompile; def-view RHS carries
  the param typespec ref. Converts UnsizedConstantParameterInInstance.

Attempted-and-reverted this session:
- Sized-literal x/z uppercasing (1'bx -> 1'bX): Surelog's casing is
  INCONSISTENT (1'bx->X but 1'bz->z, 3'bxxx->xxx lowercase) - no clean rule,
  reverted (unbased_unsized got worse 26->34).

INTERFACE FEATURE — PARTIALLY IMPLEMENTED (branch interface-feature, then
merged). DONE: "simple" interfaces (only variables/nets/parameters, no
ports/processes/cont-assigns/child-instances/generate/modports - gated by
isSimpleInterfaceBody) are emitted as interface_inst in design->AllInterfaces,
referenced from a parent module via ref_module (Actual->interface_inst, def
view) and Interfaces() (vpiInterface, elab view). emitInterfaceDef/
emitInterfaceInstance in ModuleEmit.cpp; routing in exportDesign +
emitInstance child loop + emitModuleDefPorts ref. Def-net typespecs deferred
through pendingNetTs (arena order + init-span); def-net param-ranges unfold
via tfContext during materialization; elab var inits apply the unbased-unsized
width fill. CONVERTED: InterfaceVariable (PASS); InterfaceParameter,
InterfaceParameterSetValue, iface_param_set_value, iface_local_in_sub
(CMP_ONLY - residual is weakly-tail typespec ordering).

REMAINING interface work (complex interfaces still fall through to the
module_inst path, staying DIFF): processes (InterfaceInitial/Always),
cont_assigns (InterfaceAssign), ports (InterfaceWithPort), child instances.
These need emitContAssigns/emitProcess/emitPorts (currently typed
module_inst*) to serve interface_inst too - either TEMPLATE them on the
instance type (Cont_assigns/Process/Ports are parallel identical methods on
both classes, so `m->X()` resolves per-type; use explicit instantiation) OR
duplicate the vector-building subset for interface_inst. The 45 UNSUP
interface tests were unaffected (their UNSUP cause is elsewhere - triage
separately).

--- original plan (golden structure, still accurate) ---
Golden structure verified from Surelog on InterfaceVariable (the
minimal case: `interface sim_sram_if; int start_addr=...; endinterface` +
`sim_sram_if u(); ... u.start_addr`):

  design
   |uhdmallInterfaces -> interface_inst work@sim_sram_if (DEF view; parent=
   |   design; content like a module def: start_addr is a LOGIC_NET here)
   |uhdmallModules    -> module_inst work@top (DEF): net o, port o, cont_assign,
   |   and |vpiRefModule -> ref_module work@sim_sram_if (u) whose Actual_group
   |   -> the interface_inst DEF.  ** def-view child ref is STILL a ref_module,
   |   just Actual points at interface_inst -> def path barely changes **
   |uhdmtopModules    -> module_inst work@top (ELAB): int_var o, port o,
       |vpiInterface -> interface_inst work@sim_sram_if (work@top.u) — the
       ELABORATED iface (int_var start_addr + init constant + vpiInstance->top,
       vpiDefName/vpiDefFile/vpiDefLineNo).  Attached via module_inst::Interfaces().

Touch points (agent-verified file:line):
  - Detect: inst.isInterface() / getDefinition().definitionKind ==
    DefinitionKind::Interface (slang InstanceSymbols.h:112, SemanticFacts.h:45).
  - UhdmExporter.cpp:201-210 shell pre-create: interface defs ->
    s.MakeInterface_inst() into a NEW d->AllInterfaces() vec (design.h:83; there
    is NO TopInterfaces, only AllInterfaces).
  - ModuleEmit.cpp:472 elab object create: MakeInterface_inst for iface insts;
    VpiTop/VpiTopModule only for modules.
  - ModuleEmit.cpp:490-491,506-507: interface_inst has Instance() but NOT
    Module_inst() -> drop the Module_inst back-pointer for ifaces.
  - ModuleEmit.cpp:760-780 elab child loop: route interface children into a
    separate vec -> m->Interfaces(vec) (module_inst.h:152) instead of Modules().
  - ModuleEmit.cpp:329-392 def-view ref_module: unchanged; Actual_group takes
    BaseClass* so it points at interface_inst fine.
  - Interface content reuse: Nets(instance base), Variables/Parameters/
    Param_assigns/Typespecs(scope base), Cont_assigns/Process/Ports/
    Gen_scope_arrays(parallel identical sigs on interface_inst) -> a function
    templated on InstT resolves for both; OR duplicate the ~7 module_inst-only
    call sites.
  Coupling to widen: DefInfo::mod (module_inst* -> instance*), TopPending::m,
  ~18 module_inst* signatures, ~12 .mod refs, 7 module_inst-only call sites.
  Recommended: change DefInfo::mod to instance*, cast to module_inst* at the 7
  module_inst-only sites (guarded by !isInterface); widen emitModuleDef/
  emitInstance return + emitPorts/emitContAssigns/emitGenScopes params to a
  template or instance*/scope*. Build+goldens+corpus after each step; revertible.

FINDINGS / dead-ends this session:
- GENERIC-DEF PORT-RANGE UNFOLD (CastToSum*, ParameterOfSizeOfPort,
  ParameterPackedArray - ~5 tests): a NON-top module's AllModules def unfolds
  param-dim PORT bounds (P+1->operation) while a TOP def folds (counter
  WIDTH-1->7). Verified rule. BUT setting tfContext during non-top emitPorts
  swaps the arena order of the shared def-vs-elab port typespec (they're the
  SAME object). Needs SEPARATE def/elab port typespec objects first - deeper
  refactor. Reverted. No passing test has instantiated-param-width-port
  submodules, so the change is safe once typespecs are unshared.
- $bits(TYPE) in a TYPEDEF range wants fold->const 32 (BitsCallOnType), but in
  a plain range wants sys_func_call (BitsCallOnVar, r160). Context-dependent;
  needs sub-expression eval. Left at 15 lines.
- net-vs-var for typedef'd output ports (TypedefInModulePort: output pkg::word
  -> logic_VAR not logic_net) and struct-member port-conn hier-path scoping
  (StructMemberAsModuleInput) remain conditional/risky.
- isIntEncoded INT-vs-UINT for folded consts is genuinely context-dependent
  (multiple_blocking 2**SELW->INT elab; PatternAsFunctionArgument func result
  ->UINT). No universal rule found.

---
# HANDOFF — slang-uhdm convergence campaign (98-DIFF state)

For a fresh session picking up this project. Read this, then NOTES.md
(quirk catalog — the accumulated ground truth), then PLAN.md Part II
(campaign strategy). Everything below is verified as of 2026-07-18.

## Mission (unchanged)

1. Converge the 710-test uhdm2rtlil corpus: slang-uhdm output byte-identical
   to Surelog's (`uhdm-dump` diff empty + `uhdm-cmp` exit 0) for all 661
   achievable tests (710 − 44 SLANG_REJECT − 5 SURELOG_FAIL).
   Remaining phases: B2, C2, C3, D, E, F (details in PLAN.md Part II §2).
2. Then the Surelog repo suite (~703 dirs, PLAN.md Part II §3).
3. Then sv-tests (~2346 files, PLAN.md Part II §4).

## Current scoreboard (r163 baseline, committed as results/baseline.csv)

PASS 256 · CMP_ONLY 8 · DIFF 299 · UNSUPPORTED 98 (r163). SESSION r138-r163
(this session): +18 PASS (238->256), UNSUP 109->98. LATE-STAGE STRATEGY: DIFF
classified 214 structural(a: wrong/missing objects) vs 78 attribute(b); prioritize
(a). No clean multi-test DIFF levers remain (packed_array_var/struct_var/vector-
typedef all proved per-test); reliable value = per-test pickoffs + a few real
features. (r158) SIGNED SIZE-CAST fold N'(signed_ref)->signed const + deferred
signed logic_typespec (pendingSignedCastTs), gated to signed non-literal operands
so 3'(31)/int'(x) don't regress - CastClog2 PASS. (r159) STRUCT-PREFIX WALL CRACKED
(leaf-vs-nested): module-level LEAF packed struct typedef -> prefixed member refs
(work@mod.T.m) + module parent; struct containing a nested struct/enum -> BARE;
file-level -> bare. (r160) $bits(TYPE) in an unfolded range bound -> sys_func_call
w/ ref_obj arg (emitSyntaxExpr SystemName branch) - BitsCallOnVar PASS. (r161)
typed packed-logic-VECTOR param (parameter logic [31:0] X) -> logic_typespec via
makeTypespec, gated to IntegerTypeSyntax (typedef'd stays int_typespec) - broad
(a) reduction across package-param tests. (r162/r163) PACKAGE TYPEDEFS: emitPackage
now emits vector (logic_typespec pkg::T) + struct/enum typedefs with pkg::pkg::T::m
DOUBLED member refs (buildStructTs memberSep param) + field-typespec vpiInstance=
package, populating typedefTs - BitsCallOnStructMember PASS, 8 pkg tests UNSUP->DIFF.
REMAINING pkg-typedef refinements (per-test): range-bound X-1 UNFOLD w/ ::-doubled
refs (needs emitSyntaxExpr :: separator + tfContext), typedef'd-signal logic_var-vs-
net, vpiNetType. GENERATE cluster (r153-r156):
(r153) emit gen-scope LOCAL NETS (wire tmp;) as logic_nets on the gen_scope, kept
out of netMap so refs stay weak - simple_generate PASS; (r154) gen_blk[N] index in
a HierarchicalValue path is a bit_select (name ref + bare UINT index), not one
ref_obj; (r155) bare-reference range bounds ([i:i]) fold to UINT not INT (only
operation bounds N-1 use INT-at-left-operand); (r156) gen-scope net-decl-assigns
(wire z = '1;) as gen_scope cont_assigns with a fresh Lhs net + deferred typespec,
unbased-unsized RHS folded to net width via tryEval, net-decl net loses its list
typespec parent, and genvar int_typespecs drain LAST (pendingGenvarTs) -
AssignGeneratedWireInAlways/CaseWithGeneratedWire PASS. Larger genblk tests
(blockrom/forgen02/genblk_order/MemoryInGenblock/BitSelectOf*InGenFor) still need
gen-scope VARS/memories, submodule instances in gen-for, nested generate.
(r152) function part-select
bound refs scope their fullname by the base name inside a task/function body
(currentSubSym gate; Surelog's doubled inp[A:B]->func.inp.A form) + task/function
params follow the source keyword for vpiLocalParam (like packages) - func_block
PASS. The PARAM cluster was the
richest vein: (r147) untyped ranged param int_typespec locates at its range span;
(r148) ranged untyped param carries its packed range (located, range-parented UINT
bounds) + parents to the parameter [isRangedUntypedParam helper] -> 3 counters PASS;
(r150) ranged untyped LOCALPARAMs are valued+typed like non-locals -> 2 more PASS;
(r151) untyped params carry a typespec ONLY for LITERAL inits (computed $clog2(W)/
2**S get none) - broad diff reduction. Also (r146) $signed/$unsigned sys_func_call
result typespec shares the LHS PORT typespec; (r149) inline anon enum bare base
ref_typespec (gated implicitBaseRef).
REMAINING DIFF are consistently: weakly-ref-actual (a ref's vpiActual resolves to a
later indexed_part_select/bit_select by fullname collision - func_output_arg,
sign_part_assign, multiple_blocking, CellNamedLikeModule); context-dependent
unbased-unsized encoding ('0/'1/'x/'z as typed-param/int-var values need a constant
typespec + BIN encoding - UnsizedConstants*, ParameterWithUnderscore); cast folds
(CastClog2/CastToSum multi-view signedness); big features (interface_inst refactor
per NOTES, top-view packed_array_var elaboration for DotMultirange). Clog2OfSum (17)
needs $clog2 result typespec [r146 shape] + fold-const unparented + top-view LHS
binds def net.
--- older session summary (r138-r149) below ---
PASS 247 · CMP_ONLY 8 · DIFF 300 · UNSUPPORTED 106 (r149). SESSION r138-r149
(this session): +9 PASS (238->247), UNSUP 109->106. Additional landings after r145:
(r146) $signed/$unsigned sys_func_call result typespec shares the LHS PORT's
typespec actual (search di->mod->Ports() by name after the write phase; port nets
don't carry n->Typespec(), so it lives on the port) - OneSysFunc PASS. (r147)
untyped ranged param int_typespec locates at its range span. (r148) untyped
ranged param (parameter [N:0] X) int_typespec carries its packed range with
located, range-parented UINT bounds AND parents to the parameter (isRangedUntyped
Param helper) - counter_ifelse_chain/counter_xpath/pico_count_cycle PASS. (r149)
inline anonymous enum (enum {..} v) carries a bare base ref_typespec (fullname
patched to the var by the var-emit path); gated on implicitBaseRef so typedef
anon-base enums (enum_values) stay unaffected - simple_enum PASS.
NEXT tractable leads: Clog2OfSum (17, needs $clog2 result typespec [same shape as
r146] + fold-constant unparented + top-view LHS binds def net); the ranged-param
typespec pattern may convert more param tests (UnsizedConstantsParameterParsing).
--- older session summary (r138-r145) below ---
PASS 242 · CMP_ONLY 8 · DIFF 305 · UNSUPPORTED 106 (r144). SESSION r138-r144
(this session): +4 PASS (238->242), UNSUP 109->106, plus several diff reductions.
Landed: (r139) 2D-array member access in hier_paths (base multi-dim element
select group_status[0][0].a - one bit_select per dim, simple dotted fullnames,
prior-selector loc chain, only-first-dim vpiName, unparented index consts,
full-dotted trailing member; DotMultirange/int_port_signed/
MemberSelectOf2DStructPackedArray UNSUP->DIFF, blocked on top-view
packed_array_var ELABORATION). (r140) unpacked-array net element typespec keeps
its packed ranges (descend past unpacked dims to the packed leaf before the
isPackedArray guard - mem_sub_plain, simple_memory_noreset). (r141) unpacked-array
range bounds fold non-literal to INT at left-operand span (MemorySlice). (r142)
size-style unpacked dim [N] emits right bound as unfolded N-1 operation opType 11
(ArraySize). (r143) anonymous-enum value refs bind their enum_const deferred
(simple_enum 35->15). (r144) constants parent to their immediate_assert
(simple_enum 15->11). (r145) $signed/$unsigned don't force a fresh top-view
cont_assign - shared like non-operation RHS (OneSysFunc 32->9; remaining:
sys_func_call result vpiTypespec = LHS net type, needs a SHARED deferred
actual - naive makeTypespec mints a tail duplicate, the top-def port-net
actual share is unresolved; Clog2OfSum needs the same).
INTRACTABLE THIS SESSION (documented in NOTES): weakly-tail net-typespec
parenting (27-regression), anon-enum base-typespec ref (enum_values regression -
typedef vs inline is subtle), interface_inst refactor (needs templating ~15 fns;
InterfaceVariable is a PURE interface_inst-vs-module_inst type diff, only ~3
port-less tests). Cast folds (CastClog2/CastToSum/CastInFunction) are each
distinct multi-view signedness/unfold quirks. Small-DIFF weakly-ref-actual
tests (func_output_arg, sign_part_assign, CellNamedLikeModule) resolve a ref's
vpiActual to a later bit_select/part_select by fullname collision - Surelog-
internal, hard to replicate.
PRIOR (r137): PASS 238 · CMP_ONLY 7 · DIFF 301 · UNSUPPORTED 115. r136-r137: replicated assignment patterns '{N{...}} (MultiAssignmentPatternOfConcat) and constant-driven integer-var cont_assign RHS fold (CppMacroNameAsVariableName; gated to predefined-integer vars via an lvalue write-scan - logic typedef vars stay shared). SESSION r109-r137: 204->238 PASS (+34), UNSUP 125->115, DIFF 326->301, CMP_ONLY 6->7. NB: run_corpus's regression check MISSES PASS->CMP_ONLY - after broad changes, manually diff PASS rows (join baseline r137, awk '$2==PASS && $4!=PASS'). r135: r133-r135: gen-scope process refs to outer signals left unbound (async_reset_partsel), block-local var typespecs keep UNFOLDED range bounds (local_var_in_always), block-local signed var signedness on typespec not var + based-literal attr values BIN/HEX (sincos). SESSION r109-r135: 204->236 PASS (+32), UNSUP 125->116, DIFF 326->302. NEXT tractable: OneSysFunc/Clog2OfSum need a $unsigned/$clog2 result vpiTypespec (= the cont_assign LHS type) + the top-view cont_assign SHARED (containsOperation forces re-emit for sys calls; $signed/$unsigned shouldn't). simple_enum: anonymous-enum value refs need vpiActual->enum_const but enumConstMap is populated in the write phase AFTER processes (ordering). Then the weakly-tail CMP_ONLY cluster, package typedefs, interfaces. r132: r131-r132: typed logic scalar params -> logic_typespec (NegationOfParameterInInstance), and DPI export/import attributes (DPI-exported sub -> function w/ AccessType 3 + DPICStr 2; import 'context' -> vpiDPIContext; TaskExportDPI). SESSION r109-r132: 204->233 PASS (+29), UNSUP 125->116, DIFF 326->305. r130: r130: system-call direct literal args parent to the call in every context (MultiplePrints). SESSION r109-r130: 204->231 PASS (+27), UNSUP 125->116, DIFF 326->307. Remaining: 7 CMP_ONLY + small-DIFF weakly-tail tests (partsel_simple, simple_struct, array-copy, UnsizedConst struct-member cont_assign, BindModuleWithInputPorts, sva_basic02, StringWithBackslash string-loc quirk) - net-typespec arena position/parent + dual-view ordering. Then package typedefs + packed_array_typespec (NOTES), then interfaces (45). r129: r129: the typed-param re-emit binds its LHS ref to the def-view net (like other literal/fold re-emits), fixing the weakly-tail LHS-actual for ParameterUnsignedInt (converged). SESSION r109-r129: 204->230 PASS (+26), UNSUP 125->116. NEXT: the 8 CMP_ONLY tests (partsel_simple, simple_struct, array-copy, BindModuleWithInputPorts, MultiplePrints, StringWithBackslash, sva_basic02, UnsizedConst) are DUMP_MATCH-or-near, blocked on the WEAKLY-TAIL arena-order + net-typespec-parent quirk (a net's def-view logic_typespec appears at a different arena position with a different parent - logic_net vs ref_typespec - than Surelog; materializeDefNetTs doesn't set ts VpiParent). Then package typedefs + packed_array_typespec (NOTES), then interfaces (45). r128: r128: typed non-overridden param cont_assign RHS folds to a constant + param-typespec ref (ParameterUnsignedInt 30->4, now blocked only by the weakly-tail LHS-actual quirk: ref resolves to int_var not the def logic_net). The 9 CMP_ONLY tests are now the highest-value cluster - all DUMP_MATCH, blocked on the recurring WEAKLY-TAIL arena-order / ref-actual resolution (same fullname, dump follows the pointer to the wrong dual-view object). Cracking the def-vs-top ref-actual resolution would convert several at once. r127: r126-r127: enum function returns (enum_var + unfolded enum base-typespec range bounds) and STRING TYPE support (string_var/string_typespec; StringWithBackslash 35->8, two string tests DIFF->CMP_ONLY). Converged FunctionReturnEnum. r125: r123-r125: port-with-logic-body-redecl -> logic_var, left-assoc event-or lists, and REAL SUPPORT (real/shortreal vars+typespecs, REAL constants, block-local var-init as a blocking assignment, module real-var no-typespec init-as-expr). Converged AluOps, fsm_using_always, RealValue, Shortreal, conditional_if_else, cdc_static_basic, UnitForLoop, hier_undriven_port + more. r122: r118-r122: multi-attribute groups with values (last (* *) group; STRING/REAL/INT for direct literals), implicit-return-type bare return var, reg-variable net-declaration assignments, implicit nets (bare wire, no typespec) + unsized-based-literal size context (-1 vs 0 by parent), and left-associative event-or lists. r109-r117: constant-sizing cluster (net/instance-view attributes; boolean-fold BIN; assignment-pattern element sizing with an outermost-vs-nested rule; net-decl bare-decimal RHS to net width; raw string constants), const-fold for-loops that return on the first iteration (terminal-flag propagation in constCallFold) + arg-less fold UINT encoding, function-body unbased-unsized RHS sizing, and emitMixedHierPath (b.a[0].x mixed member/element-select hier_paths; lvalue vs rvalue bit_select forms differ). NEXT ENABLER: PACKAGE STRUCT/ENUM TYPEDEFS - emitPackage (src/ParamEmit.cpp) emits only params+task_funcs; it must also emit vpiTypedef struct_typespec/enum_typespec AND populate typedefTs. Golden shape (PackedArray): struct_typespec VpiName=pkg::struct_a, VpiParent=package, VpiInstance=package, vpiPacked:1, member ref fullname DOUBLED as pkg::pkg::struct_a::x. Unblocks ~8 packed-array-of-struct DIFF tests (PackedArray, StructPackedOutput, hier_path, StructOfArrayOfStructs, ...) plus the packed-array-of-typedef cluster (EnumArray needs packed_array_typespec with Elem_typespec ref to the shared package enum) and BitsCallOnVar; watch the weakly-tail typespec ordering. THEN interfaces (45: AllInterfaces design relation, interface_inst def+inst views, InterfacePort, ArbitrarySymbol member access). r107-r108: struct-typed function returns (struct_var + canonical-matched typedef; conditional file-struct design parent), nested member-access selects (bar.l[2][1] -> hier_path var_select), and module end labels. Converged func_struct_repro, DotRange, struct_array. NEXT: PACKED-ARRAY-OF-TYPEDEF (EnumArray/DotMultirange/gen_struct_access) needs (1) package typedefs added to typedefTs - emitPackage does NOT call emitTypedefs today, so package enums/structs are built inline not shared - and (2) a packed_array_typespec {Ranges + Elem_typespec ref to the shared typedef} in makeTypespec (code sketched then reverted as dead until package typedefs land). Then interfaces (46+46). r105-r106: file-level packed struct design-parent (struct_array) and file-level typedef source-order build with name-sorted list (simple_struct 202->86). NEXT: struct member access on packed-array-of-struct + struct-typed function returns (struct_var) unblock the struct DIFF cluster; then interfaces (46+46). A recurring blocker on several CMP_ONLY tests (simple_struct/array-copy/partsel_simple/BindModule) is the weakly-tail TYPESPEC ORDER - same object set, different arena position; a general fix to typespec creation order would convert several at once. r103-r104: compound assignments (+=/<<= -> op-typed assignment) and FILE-LEVEL packed/unpacked struct typedefs (buildStructTs on the design). NEXT tractable: struct-typed function returns (struct_var, func_struct_repro), struct member access on packed-array-of-struct (DotMultirange/DotRange/gen_struct_access), then interfaces (46+46, biggest untouched). Also: \x-sizing in blocking-assign is context-dependent (function sizes, always block does not - unresolved, reverted). r99-r102 landed the full property-expression emitter (implications/until/throughout/sequence-concat/not), default clocking blocks, and NET-DECLARATION ASSIGNMENTS (wire x = expr -> cont_assign; literal/op RHS -> fresh Lhs net + deferred typespec; general x->X uppercase for unbased-unsized). Converged sva_not, sva_throughout, sva_value_change_*, signed_partsel_ext. r96-r98 landed the property-expression emitter (emitAssertionExpr: implication/until/throughout/sequence-concat/not ops), default clocking blocks, assume/cover/restrict, and typed localparams (integer/byte/... _typespec). Converged sva_basic00/01/03, sva_value_change_rose, sva_throughout, sva_not. r95 landed concurrent assertions (folded assert_stmt: label, clocking-only property_spec for assert-with-clocking; via instance Assertions()/vpiAssertion, shared across instances like processes). NEXT for assertions: a recursive property-expression emitter (emitAssertionExpr) + assume/cover kinds - the exact rule + operator/opType tables are in NOTES.md "Concurrent assertion property-expr rule". Also landed r93-r94: assignment-pattern fold to based constant + numeric-index integer_typespec tags (PatternDefault/PatternIndexes converge). Session 5 third
stretch (r82-r92) landed: var_select flattening (nested element selects,
range/part-select of element-select bases), array_var/array_typespec for
unpacked-array signals (element types, pattern inits, io_decl ranges),
range-select of member-access -> hier_path, multi-dim packed def-net span,
predefined integer types (shortint/longint/byte/time), while/do-while/
forever loops, and assignment-pattern default/index setters.
NEXT solo-blocker clusters (run the m91.txt-style triage to refresh):
- ConcurrentAssertion: 7 done; remaining need: net-decl-assign (NOTES r98, sva_value_change_changed - CAREFUL ts-extension condition), ##[*]/until precedence (sva_range - slang vs Surelog assoc), AssertionInstance/named property (sva_counter), package func (package_task_func), bind+assert (sva_basic02 CMP_ONLY).
- member access base (9) - mostly interface/struct (overlaps E4).
- assignment pattern setter kind: DONE for tags; remaining tests need the
  top-view pattern FOLD to a based constant + def value parenting under the
  orphan re-parent machinery (PatternDefault, PatternIndexes).
- PackedStructType typedef (7) + PackedUnionType (3): package/anon structs.
- LValueReference (5), Streaming (4), ProceduralAssign (2), parallel block.
- E4 INTERFACES (46 InterfacePort + 46 ArbitrarySymbol) - biggest overall,
  still untouched; needs interface instances, modports, virtual interfaces.
- Unpacked-array PORTS want array_net (not array_var) - AssignArraySelPlus.
Deferred: func_local_array (function-local unpacked array in begin blocks),
ImportFunction (package import deep-clone), macro-expansion locs (asym_ram_*),
BindModuleWithInputPorts (4-line ts arena position), F --elabuhdm, suites.

## Old scoreboard reference (r81)

PASS 169 · CMP_ONLY 1 · DIFF 291 · UNSUPPORTED 200 (r81). Session 5 second
half (r79-r81) landed: B2 parameter overrides (isOverriddenParam detection,
DEFAULT-derived values both views, vpiOverriden, folded override constants,
child CA override re-emits, unknown 'x defaults, untyped INT/-1 folds),
type casts (target-type ts, deferred re-emit variants, top-keeps/child-folds
rule), and the DEF CONTENT PRE-PASS architecture change (all defs' content
compiles name-sorted before any instance; only emitModuleDefPorts is
encounter-ordered — see NOTES r81 entry).
NEXT immediate targets:
1. Select-base cluster (~34 solo): unpacked-array element selects with
   non-NamedValue bases (nested pa[0][1]) — ExprEmit.cpp:772/797. Probe
   golden with a MINIMAL unpacked array select first (array_assign is big;
   try 2DUnpackedArray or func_local_array).
2. E4 interfaces (46 tests, InterfacePort+ArbitrarySymbol).
3. PackedStructType typedefs 17, ConcurrentAssertion 13, integer type kind.
4. BindModuleWithInputPorts CMP_ONLY: 4-line tail order — the bound
   instance's port pts (4:21) must come RIGHT AFTER its def's net-ts
   materialize, before rv_dm write ts; ours emits it later.
5. Known-hard/deferred: ImportFunction (package import deep-clone with
   half-reprefixed names), macro-expansion locations (asym_ram_*),
   rsp_gen_minimal (1549 lines), simple_package (package struct typedefs).

## Old scoreboard reference (r78)

PASS 163 · CMP_ONLY 1 · DIFF 297 · UNSUPPORTED 200 · CRASH 0
· SLANG_REJECT 44 · SURELOG_FAIL 5
Session 5 (r72-r78) landed: function-scope localparams + block-param
implicit nets, package task_funcs (:: fullnames, dual-view copies, ts
vpiInstance), function body begin wrappers + initialized locals, const-call
folds (literal chains, package-param-backed with ts clones, evaluable
calls), call arg formal-ts refs, module imports (import_typespec + hidden
Item constant + shared pkg fns in module Task_funcs), positional port
connections, gen-scope functions + def-view gen_if_else from syntax,
$unit (design-level) functions, type casts. The one CMP_ONLY:
BindModuleWithInputPorts (4-line ts arena position).
NEXT: B2 parameterized instances (param overrides: def view keeps DEFAULT
values incl. BIN:X for 'x, instance views carry override-site constants,
vpiOverriden:1 on overridden param_assigns, DEC:7_200 underscore-preserving
decompiles - see ParameterWithUnderscoreValue diff); then select bases
(~34 solo), interfaces (46), PackedStructType 17, ConcurrentAssertion 11.
Remaining known-hard: import deep-clones (ImportFunction), macro-expansion
locations (asym_ram_*), rsp_gen_minimal.

## Environment (this machine)

- This repo: ~/git-repos/slang-uhdm  (history: extracted from the
  slang fork's uhdm-export branch, which remains frozen as an archive)
- Build: `~/.local/bin/cmake -B build -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_PREFIX_PATH=$HOME/.local && ~/.local/bin/cmake --build build -j 4`
  (system cmake is too old; slang + UHDM installed in ~/.local prefix)
- Binary: build/slang-uhdm
- Reference producer: ~/git-repos/Surelog/build/bin/surelog  (v1.86-114)
  invoke: surelog -parse -nobuiltin -nocache <files> → slpp_all/surelog.uhdm
- Oracles: ~/git-repos/UHDM/build/bin/{uhdm-dump,uhdm-cmp,uhdm-hier,uhdm-lint}
  (UHDM 5523dfc — NEVER update these checkouts mid-campaign)
- Corpus: ~/git-repos/uhdm2rtlil/test/*/dut.sv (710 tests)
- Slang sources for API reference: ~/git-repos/slang (branch uhdm-export)
- DO NOT USE: any binary under ~/git-repos/sv-tests/third_party or
  ~/git-repos/UHDM-1.84 (v1.84, schema-incompatible)

## The dev loop (verified, fast)

1. `./scripts/triage.sh results/latest.csv` → pick the top blocker.
2. Write a minimal probe dut.sv exercising it; run
   `./scripts/converge.sh probe.sv` and read the golden via
   `uhdm-dump <workdir>/slpp_all/surelog.uhdm` to learn Surelog's shape.
3. Implement in src/; rebuild (`cmake --build build -j 4`, ~30s);
   re-run converge.sh until DUMP_MATCH + PASS_CMP.
4. `./tests/check_goldens.sh` (must stay 5/5), then
   `./scripts/run_corpus.sh ~/git-repos/uhdm2rtlil/test results/rN.csv
   results/baseline.csv` (~50s, parallel; FAILS on regressions).
5. Commit per converged feature; append every new quirk to NOTES.md;
   promote 1-2 representative tests to tests/golden/ per feature;
   update results/baseline.csv when a round improves.

Methodology hard rules (learned the expensive way):
- DUMP_MATCH alone is NOT success — uhdm-cmp checks fields the dump never
  prints (Module_inst, typespec Instance). Require both.
- When cmp fails but dump matches, bisect with a C++ probe against the
  installed UHDM lib (pattern in NOTES.md "Session 1"; probe compiles with
  g++ -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj).
- Weakly-tail dump order = object CREATION order per type. Fix content
  first, ordering second.
- Match Surelog bug-for-bug; document every replicated quirk in NOTES.md.

## DONE (session 3): Task 0 split, tail ordering, C2, D1, E2, D2, C3

The file layout now: src/{UhdmExporter,ModuleEmit,ParamEmit,StmtEmit,
TaskFuncEmit,ExprEmit,TypeEmit}.cpp + src/EmitHelpers.h. The arena-order
model (write-phase drains, def/top port ts swap, fullname freeze quirk)
is fully documented in NOTES.md sessions 3 — READ IT before touching
typespec ordering.

## Next phases (r32 triage: scripts/triage.sh results/baseline.csv)

1. Top remaining blockers (r65 triage): HierarchicalValue 57 (E1),
   InterfacePort 46 (E4), ArbitrarySymbol 46, member access base 37
   (remaining select-on-complex cases: lvalues, range selects on members),
   StructuredAssignmentPattern 35 + Simple 25 (D3), element select base 32
   (2D/array selects — D4 arrays), user function call 33 (package funcs),
   expression kind Invalid 33 (investigate: likely error-recovery exprs),
   range select base 24, PackedStructType typedef 17 (package contexts).
   DONE since r32: vector typedefs, bind, qualifiers, var inits, block/
   function locals, statement lists, member-base bit selects, cast-size
   exprs, $bits folds, select base-scoping, case query-call parents.
2. B2 parameterized instances: STUDY AdditionAsParameterInInstance golden
   first (folded specialized-def shape still unknown).
3. F: --elabuhdm mode (run UHDM ElaboratorListener + UhdmAdjuster
   in-process like Surelog's -elabuhdm; needed for Stage 2 and
   sv-pathfinder).

## Stages 2-3 (after corpus is mostly green)

- Surelog suite: tests/<Name>/<Name>.sl holds raw surelog args; write
  scripts/run_surelog_suite.sh mapping them to slang-uhdm args. Many use
  -elabuhdm → needs F first. Tiering + goals in PLAN.md Part II §3.
- sv-tests: metadata-driven runner (:tags:/:should_fail:), agreement matrix.
  PLAN.md Part II §4.

## Flow closure (deferred by user, do LAST)

Build uhdm2rtlil, run its test_uhdm_workflow.sh with slang-produced .uhdm;
rebuild sv-pathfinder's native addon against UHDM v1.86 (binding.gyp
UHDM_HOME change + node-gyp rebuild).
