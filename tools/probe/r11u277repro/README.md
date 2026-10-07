# r11u277 — module/type ground: the constructor return class_var span (MINIAMIQ CONVERTS, THE SURELOG CORPUS IS FINISHED) and the strength-redeclared port net's typespec

Base 59b55191 (pass 275). Two laws in TaskFuncEmit and ModuleEmit behind `src/R277.h`: each law reads its own
`R11U277_<LAW>_OFF`, `R11U277_OFF` drops both and gives pristine's bytes on 42 of 42 grid case-views, and
`R11U277_TRACE=<dir>` logs every firing (`<dir>/<pid>.277`, first line `OUT <-o path>`).

Binaries: pristine md5 057775d8242c95d17077864f2fae643b (byte-identical to the main tree's build), law
2b1fe82b03179fa43b0caf4ea0ae677b. Both were frozen before any measurement, and every `cmds.txt` was audited by
binary path: 3273 of 3323 per sweep name that sweep's own binary, and the other 50 have no slang line.

## Verdicts

| row-mode | base | law |
|---|---|---|
| **MiniAmiq default** | STRICT_NOTEQUAL differ:col(2) (#241741 / #243118) | **CMP_EQUAL, strict equal** (uhdm-strictcmp STRICT_EQUAL 435559 objects) |
| **MiniAmiq testflags** | STRICT_NOTEQUAL differ:col(2) | **CMP_EQUAL, strict equal** (STRICT_EQUAL 435559 objects) |

The fresh rows from the law sweep: `MiniAmiq,default,CMP_EQUAL,,,equal` and `MiniAmiq,testflags,CMP_EQUAL,,,equal`.
results/ is untouched. **THE SURELOG CORPUS IS NOW STRICT-EQUAL ON EVERY ROW-MODE EXCEPT THE KNOWN FAILURES:**
default 478 CMP_EQUAL + 2 STRICT_NOTEQUAL, testflags 472 + 2. The two left in each mode are LogicTypespec and
Scr1SvTests, the known failures that are not work items. After the law, uhdm-strictcmp reads 0 records on MiniAmiq
in both modes, so nothing remains to report behind #241741 / #243118.

## The laws

### § ctorRetVarSiblingSpan277 — TaskFuncEmit, switch `R11U277_CTORRETSPAN_OFF`
Surelog places a class constructor's return `class_var` with
`CompileHelper::compileClassConstructorDeclaration` (third_party/Surelog/src/DesignCompile/CompileStmt.cpp):
`varId = Sibling(Child(first Tf_port_item))`. That is the SECOND child of `tf_port_item`. In the grammar
(`tf_port_item: attribute_instance* tf_port_direction? var_type? data_type_or_implicit identifier ...`) the
children are, in order:
- each attribute_instance;
- the direction (`const ref` is one node);
- `var`;
- data_type_or_implicit, which is always a node and is zero-width at the name when it is empty;
- the identifier.

With no attribute, direction or `var` keyword the second child is the name, which is what the base writes. Otherwise
the law takes the second child:
- `input string s` gives the data type (`string` 23-29 on MiniAmiq);
- `input a` gives a zero-width span at the name;
- `input [3:0] a` and `input signed [3:0] a` span the signing and dimensions, ending at the last dimension (slang's
  ImplicitTypeSyntax range runs on to its placeholder token, so the law stops at the last dimension instead);
- `input var int v` gives the `var` keyword;
- `(* k *) input int a` gives the direction;
- `(* k *) int a` gives the data type.

Cases: `cases/C` (c01 to c13).

### § strPortNetTsFromPortDecl277 — ModuleEmit (the module/program elaborated net listing), switch `R11U277_STRPORTTS_OFF`
Take a non-ANSI port whose body re-declaration carries a drive strength, such as `output [31:0] o;` followed by
`wire (strong1, weak0) [31:0] o = 32'd12;`. Surelog's compileNetDeclaration has no Drive_strength branch, so the body
declaration files no Signal (§ caNetDeclStrengthDropped90). The net the elaborated instance lists is the port's own
Signal, typed by the PORT declaration: golden puts the logic_typespec and range at 3:10-3:16, the port's dims. Ours
spanned the body's `wire (strong1, weak0) [31:0]`, 5:3-5:31. The law gives the net the merged-port typespec
(`sharedTypespec(..., portCtx)`), which is what the port already takes.

It fires only when all of these hold:
- `it.port` is set and the net is not a port-expression net;
- `netDeclStrength90` holds;
- `mergedPortDeclTypeSyn9` finds the port declaration's type syntax.

The interface home (n3_strnonansi_if, the interface mint) is not reached and does not move. Cases: `cases/S` (s01 to
s08; s04 is a program, which Surelog fails on, and s08 is a control with a plain re-declaration).

## Grid (`drivers/grid.sh`, `evidence/grid.txt`, `evidence/gridsum.txt`; every line carries rc=)
- 21 case dirs in both views make 42 case-views. Each was run on 5 configurations: P, L, OFF, and each switch off.
- OFF equals P bytes on 42 of 42.
- 38 case-views move: 32 enter STRICT_EQUAL and none leave.
- Every mover returns to P under exactly one switch: CTORRETSPAN 26, STRPORTTS 12.
- No exit code changes.
- uhdm-cmp line counts change on 2 case-views, both on s05_signed (102 -> 0, stage 1 -> STRICT_EQUAL in both views).
- The movers that stay not-equal are:
  - c03_kinds: after the law its only face is a `q::t` package-qualified formal type typespec (line, name), not the
    class_var.
  - c09_var: Surelog writes a nameless io_decl for a `var` formal (stage 1 on every binary).
  - c10_signed: Surelog's `input signed a` typespec reference (stage 1 on every binary).
  In all three the class_var record itself now equals golden (checked on the uhdm-dump class_var lines).
- Away census on all 40 case-views with both databases (`evidence/away_grid.txt`, order-blind away.py and
  chain-keyed awaychain.py): lost=0 and chain away=0 on 40 of 40.
- Downstream (`evidence/downstream_cases.txt`): all 21 dirs give the same verdict on both binaries: 20 IDENTICAL, and
  s04 SURELOG_FAIL.

## Byte controls (`drivers/controls.sh`, `evidence/controls.txt`, `evidence/ctlsum.txt`)
- Scope: 651 earlier repro dirs, 1302 case-views, pristine against law. The dirs come from r11u270repro,
  v11u270repro, r11u90repro, r11u92repro, r11u93repro, r11v93repro, v11u93repro, r11u247repro, r11u118repro,
  r11v11u118repro, r11u119repro, r11u275repro, v11u275repro, r11u27repro and r11u144repro.
- 12 case-views move, and all 12 enter STRICT_EQUAL. None leave, and no exit code or uhdm-cmp line count changes.
- The movers:
  - r11u270repro/cases/C/c01_input_kw in both views (the pass-270 reproduction of the MiniAmiq face);
  - r11u92repro/grid n1_strnonansi, n2_strrevorder, n7_strnonansi_in, n8_strtwoports and n10_strnonansi_gen in both
    views.

## Firing census (`drivers/tracecensus.sh`, frozen as `evidence/predict.txt` BEFORE the law sweep)
The law binary ran under `R11U277_TRACE` over the probe cases and both corpora. The filter was built from $FENCED,
and MiniAmiq was the positive control. The census predicted 9 databases:
- MiniAmiq d/t (ctor);
- probe r10v223repro/arms/v16_oobctor (ctor);
- probe r11u90repro/grid/u12_strnonansi, r11u93repro/grid n1, n2, n7, n8 and n10 (strength).

## Gate sweeps (tests/sweep.sh --jobs 3; `evidence/pristine_sweep.txt`, `evidence/law_sweep.txt`)
Both sweeps exit 1 on the law-index check alone, because the case dirs were added before scripts/law_index.py was run
last.
- **Pristine:** reproduces the baseline exactly.
  - probe 3721 + 366;
  - surelog 477 + 3 / 471 + 3;
  - uhdm2rtlil 803/1/67 both modes;
  - downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT;
  - regressions=0 everywhere.
- **Law, probe:** EQUAL 3728 + STRICT_NOTEQUAL 359, regressions=0, conversions=7, changes=0. The SEVEN PROBE
  CONVERSIONS:
  - `r10v223repro/arms/v16_oobctor` differ:col(5) -> EQUAL (§ ctorRetVarSiblingSpan277);
  - `r11u90repro/grid/u12_strnonansi`, `r11u93repro/grid/n1_strnonansi`, `n2_strrevorder`, `n7_strnonansi_in` and
    `n10_strnonansi_gen` differ:line(4) -> EQUAL, and `n8_strtwoports` differ:line(8) -> EQUAL
    (§ strPortNetTsFromPortDecl277).
- **Law, surelog:** default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2. regressions=0, conversions=2
  (**MiniAmiq default and testflags, STRICT_NOTEQUAL differ:col(2) -> CMP_EQUAL**), changes=0.
- **Law, uhdm2rtlil:** 803/1/67 both modes, regressions=0, conversions=0, changes=0.
- **Law, downstream:** 803 / 66 / 2 / 0. The csv is byte-identical to the pristine sweep's, so the verdict diff is 0.
- uhdm-cmp reads 0 lines on every touched row: MiniAmiq d/t are CMP_EQUAL, and the 7 probe cases are EQUAL.

## Byteverify and the predicted movers
byteverify (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1) ran on fence-filtered mirrors built by
`drivers/bvmirror.sh`, which now also mirrors downstream. Same-length workdirs; 8 fenced paths skipped:
- surelog 2 of 952 move, both MiniAmiq (default and testflags);
- uhdm2rtlil 0 of 1608;
- downstream 0 of 805.

Probe md5 compare: 7 of 4087 move. These are exactly the 7 predicted (`evidence/probe_movers.txt`). Every mover was
predicted by name and attributed to its law.

## Away census on the gate movers
- MiniAmiq d/t: order-blind dist 61 -> 59 with lost=0, and chain-keyed away=0 / toward=2 in both modes. The
  remaining 59 order-blind records are canonicalised identity differences; uhdm-strictcmp reads STRICT_EQUAL.
- The 7 probe movers: lost=0 and chain away=0 on each. Each one's distance goes to 0.

## Canaries and determinism
- canaries.sh: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0.
- ctcan2.sh: EXPECT_UNKNOWN=1 for surelog and EXPECT_UNKNOWN=6 for uhdm2rtlil, both PASS.
- Determinism (`drivers/det.sh`, `evidence/det.txt`): three concurrent draws of the law binary on Earlgrey_0_1,
  MiniAmiq, SeqDriver, SimpleUVM, Scoreboard, BuildUVMPkg and Rggen in both modes. Each of the 12 row-modes that has
  a database reads one hash in 3 of 3, equal to the law sweep's hash. Scoreboard and Rggen have no testflags
  database.

## Item (2): the probe residue at the base
uhdm-strictcmp --max 1 was run on all 366 STRICT_NOTEQUAL probe cases against check_probe's golden
(`drivers/probecls.py`, `evidence/probe_first_records_base.tsv`, `evidence/probe_buckets_base.txt`).
- **Largest buckets by (first field, object kind):**
  - fullname ref_typespec 92;
  - name ref_obj 25;
  - line logic_typespec 23;
  - fullname ref_obj 21;
  - name logic_typespec 15;
  - file logic_typespec 10;
  - endcol constant 9;
  - endcol class_typespec 9.
- **This pass worked:**
  - the strength-port line bucket (6 of the 23 `line logic_typespec`, all converted);
  - the out-of-body constructor case (one of the `col` cases).
- **Left on this ground, ranked:**
  - (a) About 17 cases headed by a `q2::row_t` / `pk::w_t` name record: a struct member or parameter typed by a
    packed-array typedef of a typedef (`row_t [0:1]` inside a struct). Golden's element ref points straight at the
    unlocated `q2::row_t` alias object, where ours puts an extra located `row_t` level in front. This is
    TypeEmit's typedef-alias chain, from the pass 108 / 111 / 114 / 117 grids (for example
    r11u117repro/grid/g1/t03). Not decoded further.
  - (b) 32 cases whose first record is a typespec-subtree full name, read raw. Of those:
    - r10sd10, r10sd5, r10sd6, r10uvm198, r10uvm202, r10uvm207 and r10uvm226 (14) carry the importing scope's chain
      (golden `px::outer_c::inner_c::irec_t::a`, ours `inner_c::irec_t::a`), TypeEmit buildStructTs;
    - the rest are `pkg::pkg::` doubling and `work@` prefix faces (naming is context-dependent: see the dead-end
      rule).
  - (c) class_typespec endcol, 9 cases in both directions (r10sd1 b18 / b27, r10v112 g4, r10v212: ours extends over
    the `::name`; r10uvm221 a4, r10uvm225 a6: ours too short).
  - (d) c03_kinds's `input q::t x` formal type typespec, listed at the package declaration with the name `t` where
    golden locates it at the use with the name `q::t`.
- **Sister ground, reported with counts:**
  - 17 cases headed by `<in>pk::c_t.u` against `pk`: the struct-valued function fold inside member-typespec ranges,
    ParamEmit (r11u24 / r11u26 / r11u28 / r11v26);
  - the `assign o = P` struct-parameter fold (the `name ref_obj` / `type ref_obj` buckets);
  - the home48::w48_t alias name (r10uvm36 t48a and its family);
  - the package-net listing stretch (y4_bindreach, w3_arraynet, y1_pkgnetkind, ParamEmit's package-net branch next
    to § caPkgListingNetTypeIsPerView79).

## Residues (all wrong on pristine too)
1. The q2::row_t alias-chain extra level (about 17 probe cases, TypeEmit), item (a) above.
2. The struct-member typespec raw full names through import chains (14+ cases, TypeEmit buildStructTs).
3. class_typespec end columns (9).
4. The package-qualified formal type `input q::t x` typespec listing (C/c03_kinds).
5. Surelog's own `var` formal and `input signed a` faces (c09, c10: stage 1 on every binary, not ours to fix).
6. The interface home of the strength re-declaration (n3_strnonansi_if, not reached by
   § strPortNetTsFromPortDecl277).
7. Items (3) to (7) of the brief (pass 275 / 273 / 271 and earlier residues) were not attempted in this pass.

## Process notes (slips, reported)
- **Unguarded tool variable:** two uhdm-dump calls ran in a fresh shell with UHDM_DUMP unset and no `[ -x ]` guard.
  The shell executed my own scratch database (`/tmp/r11u277_s/g/C/c02_implicit/L1.uhdm`, a case database I had
  written) and dropped 8 empty garbage-named files in `/tmp/r11u277_s/g/C`. I deleted those 8 files by
  `-maxdepth 1 -size 0 -newer`. The main tree and the worktree were clean (git status empty). After that, every
  dump went through a guarded `dumpx` helper.
- **Self-matching waiter:** a background waiter used `pgrep -f` with a pattern that matched its own shell. I stopped
  it by its own task id. No other process was signalled.
- **FENCE:** the first byteverify run on the corpus workdirs was NOT on fence-filtered mirrors. It hashed every
  slang.uhdm, including the 8 fenced row-mode databases (md5 only: no record, dump or head was read or printed, and
  none of them is a mover). byteverify was then rerun on fence-filtered mirrors (bvmirror.sh), and those are the
  numbers reported above. Apart from that run, no fenced source or database was read and nothing fenced was
  dispatched outside the gate sweeps; the census and the determinism runs used the $FENCED filter.
