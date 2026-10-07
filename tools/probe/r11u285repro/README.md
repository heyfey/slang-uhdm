# r11u285 — module/type ground: the struct member full names of class import copies and importer copies

Base 7d3a945f (pass 283). Four laws in ModuleEmit and UhdmExporter behind `src/R285.h`: each law reads its own
`R11U285_<LAW>_OFF` switch, `R11U285_OFF` drops all four and gives pristine's bytes on 64 of 64 grid case-views,
`R11U285_TRACE=<dir>` logs every firing (one file per process, `OUT <-o path>` first). **SEVEN PROBE CONVERSIONS**,
one probe change toward golden, no regression; no corpus row changes status or strict column (MiniAmiq d/t and
SeqDriver d/t move bytes, chain away 0, toward 363 and 242 records, still CMP_EQUAL).

| target (probe, default view = the gate) | before (base) | after (law) |
|---|---|---|
| class copy of an imported struct variable: r10sd10repro g6_typedef_elem_import, v2_dynarray_struct_typedef | `fullname(2)` | **2 EQUAL** |
| the same with a member-path initializer: r10sd6repro v3_hier_path | `fullname(2)` | **EQUAL** |
| importer copy's own struct local: r10uvm198repro g198_a_homes, r10uvm202repro g202_a_kinds | `fullname(4)` | **2 EQUAL** |
| importer copy's struct with typedef'd members: r10uvm207repro g207_c_share, g207_e_head | `fullname(32)`, `fullname(16)` | **2 EQUAL** |
| r10uvm207repro g207_h_foreign (a third package's struct) | `fullname(32)` | `fullname(16)` (change, toward) |
| probe | EQUAL 3842 + STRICT_NOTEQUAL 245 | **EQUAL 3849 + STRICT_NOTEQUAL 238**, regressions 0, changes 1 |
| surelog 478 + 2 / 472 + 2, uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0 | | unchanged |

In the elaborated view (`-elabuhdm`, not gated) all seven converted cases read STRICT_EQUAL too.

## The laws

1. **§ clsImpCopyTdBindsContainerListing285** (ModuleEmit, `clsImpTdShare285` called at the end of importVarCopy5,
   the class leg of § classInheritsContainerImports23; switch `R11U285_CLSIMPTDSHARE_OFF`). A class's inherited copy
   of an imported package variable typed by a named struct or union typedef binds the CONTAINER package's own listing
   of that typedef — the object the importing package lists under vpiTypedef, whose member references read the
   importing package's chain (`q6::p6::t6::a6`). clone_tree had handed our copy a private deep copy of the source
   struct whose member references kept the stored `p6::t6::a6`; golden's database lists no such copy (g6: two member
   ref_typespecs in golden, the p6 and q6 listings; ours three). The typedef is matched in the container's listing by
   kind, name, file and span; the variable's own reference and, for an array, every element variable's reference are
   re-pointed. A container that is not a package (a class in a module, grid C/c10), or a listing without the typedef
   (a third package's struct, C/c12, C/c16), keeps the copy. Enums are not touched (C/c07).
2. **§ impCopyInitHierPathMemberName285** (ModuleEmit importCopyRefs6, the initializer re-naming of
   § importCopyInitRefIsOwnedAndUnbound6; `R11U285_IMPHPNAME_OFF`). A member path in the copied initializer
   (`int b3 = st3.f3;`) names its LAST element, when it carries a stored full name, on the copy's owner chain
   (golden `q3::c3::b3::f3`, ours `p3::b3::f3`). The root and a middle member keep what they had: the first draft
   renamed every element after the root and grid H/h02 (`st.f.g`) read chain away 1 in both views — golden gives the
   middle `f` no full name — refined before the census. Bindings are left alone. The stored name is read with
   r215StoredFullName (the generated getter would intern a computed name).
3. **§ cloneOwnAggMemberChainName285** (UhdmExporter, a design-final drain right after the r11u241 clone drains, over
   g_cloneTf241 in vector order; `R11U285_CLONEMEMBNAME_OFF`). A struct or union an IMPORTER COPY's local owns
   (parented at the local's ref_typespec, the deep clone's own object, which § cloneAggLocalOwnCopy241 leaves as it is)
   names its members' references through its parent chain in golden
   (`sluice198::Adit198::winze198::tfPkg198::quarry198::pkgSt198::lode198`); ours kept the name stored on the object
   it was cloned from (`quarry198::pkgSt198::lode198`). A stored name that differs from the chain's
   (BaseClass::ComputeFullName's walk, transcribed) is replaced by the chain's; only the shape variable ->
   ref_typespec -> struct/union -> member -> ref_typespec inside one copy is read. The same drain names the alias
   reference of a member's OWN typedef copy (`CLONEMEMBALIAS` in the trace; golden
   `...::range207::p207a_e::se207::e_min207::bt207e`, ours `bt207e`).
4. **§ cloneMembTdOwnCopy285** (UhdmExporter, inside § cloneAggMemberOwn241's member copy;
   `R11U285_CLONEMEMBTYPE_OFF`). The deep clone's member typed by a named vector typedef (`bt207e e_min207` with
   `typedef bit [63:0] bt207e`) holds its own copy of that typedef, parented at the member's reference, as the copies
   the clone already owns do (golden g207_e_head: the function-level `range207` lists bit_typespec bt207e under the
   member reference with a chain-named alias); § cloneAggMemberOwn241's member shared the source member's type. The
   type is deep-copied with clone_tree and law 3 names its alias. Struct, union, enum (pass 265's
   § cloneMembEnumAtHomeListing265 keeps those), class, array and import typespecs are not copied.
   Laws 3 and 4 act together: the movers they touch return to pristine's bytes only with both switches off.

## Grid (tools/probe/r11u285repro/cases, 32 case dirs in both views: 64 case-views, every line with its exit code)

C (16, law 1: associative, plain, dynamic and queue, fixed-array, union, packed, enum control, nested class, explicit
import, class-in-module control, two classes, third-package struct, initializer, included header, CRLF,
package-qualified source type), H (5, law 2: one-level, two-level, select and operation, array-element root, two
importers), M (11, laws 3 and 4: package-function and out-of-body method copies, block locals, unions, bit / logic /
int / signed typedef members, enum control, nested struct, two importers, struct formal and return).
`drivers/grid.sh` runs every case-view on pristine (P), the law (L), the law with `R11U285_OFF` and the law with each
switch off (evidence/grid.txt); `drivers/gridsum285.py` (evidence/grid_summary.txt):

- `R11U285_OFF` gives pristine's bytes on **64 of 64**.
- **50 moving, 24 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.** Attribution (evidence/grid_pairs.txt from
  drivers/gridpairs.sh): CLSIMPTDSHARE 20, IMPHPNAME 4, CLONEMEMBNAME 6 alone; 6 need CLSIMPTDSHARE + IMPHPNAME (H/h01,
  h04, h05 both views), 14 need CLONEMEMBNAME + CLONEMEMBTYPE (M/m04, m05, m06, m08, m09, m10, m11 both views).
- uhdm-cmp line counts changing: 2, M/m06_inttd both views 60 -> 64 at stage 1 on both binaries (the head prints the
  member typedef copy's chain name; chain away 0, toward 16).
- Away census (drivers/awaycv.sh; evidence/grid_away.txt): lost 0 on all 50; chain away 0 on 49. H/h05_twoimp_el
  (stage 1 on both binaries, flat away 0) reads chain away 1 under law 1: golden walks 15 member-reference records,
  pristine 20 and the law 15; pristine's extra second-listing record of package r's `st` happened to carry golden's
  first-listing name, while the first-listing record reads `p::p::s_t::f` on both binaries where golden has
  `r::p::s_t::f` — a multiset coincidence, not a record the law moved away (documented, not refined).
  Positive control (binaries swapped): away 2 to 28 (evidence/away_poscontrol.txt).
- Movers staying at stage 1 or STRICT_NOTEQUAL (all wrong on pristine too): C/c14_hdr (`file`, the header's file on the
  package listing), H/h02, h03, h05, M/m01, m03, m05, m06, m07, m08, m09, m11 (stage 1: other faces of the importer
  copy), M/m10 (`fullname`, the formal / return copy).
- Downstream on the 32 dirs (drivers/dscases.py; evidence/downstream_cases_{P,L}.txt): 31 IDENTICAL and 1 EQUIVALENT
  on both binaries, none moving.

## Gates (law binary 5b6de75145584562bbf6a9286aa343c4; pristine c4f0de1e125459aeca302e7c20760c55 = the main tree's)

- tests/sweep.sh --jobs 3 (all four stages; evidence/sweep_P.log, sweep_L.log): probe **regressions=0
  conversions=7 changes=1** (EQUAL 3849 + STRICT_NOTEQUAL 238); the change r10uvm207repro/g207_h_foreign
  `fullname(32) -> fullname(16)`, same first field, half the objects; surelog regressions=0 conversions=0 changes=0
  (default CMP_EQUAL 478 + STRICT_NOTEQUAL 2, testflags 472 + 2); uhdm2rtlil 0 / 0 / 0 (803/1/67 both modes);
  downstream IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, not excused 0, the csv byte-identical to pristine's and to
  results/downstream_uhdm2rtlil.csv. The surelog csv differs from pristine's only in the LowMemLib / LowMemPkg
  testflags detail text (the workdir path); uhdm2rtlil csvs identical. Both sweeps exited 1 on the law-index check
  alone (stale at the base); this patch regenerates it.
- Predictor (drivers/tracecensus.sh, the law binary under R11U285_TRACE over the probe cases and both corpora in both
  modes with the fence filter, frozen before the law sweep; evidence/predict.txt, 13 lines): 9 probe databases
  (the 8 targets and r10uvm180repro/g180_a_kinds, EQUAL on both binaries) and MiniAmiq d/t, SeqDriver d/t.
- Byteverify (tools/probe/r11v75repro/byteverify.sh, fence-filtered hard-link mirrors from drivers/bvmirror.sh, 8
  fenced row-mode databases left out; evidence/byteverify_corpus.txt): **4 of 3365 corpus databases move, exactly the
  predicted MiniAmiq d/t and SeqDriver d/t**; surelog, uhdm2rtlil and downstream otherwise 0. SELFCHECK reads 3363 of
  3365 (the reference file downstream/1DUnpackedArray has a byte-identical twin, uhdm2rtlil/testflags/1DUnpackedArray,
  so n-2 is the expected count). Probe: **9 of 4087 move, exactly the predicted 9** (evidence/byteverify_probe.txt).
- Corpus away census on the four movers (drivers/awaycorp.sh order-blind, awaychain.py chain-keyed): MiniAmiq d/t
  lost 0, chain away 0, toward 363; SeqDriver d/t lost 0, chain away 0, toward 242; every row-mode CMP_EQUAL before and
  after. Probe movers: lost 0 and chain away 0 on all 9, toward 2 to 56 (evidence/probe_away.txt).
- uhdm-cmp on every converted case and every touched row: 0 lines.
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both csvs.
- Binary-path audit (fence-filtered cmds.txt lists): 3265 of 3315 name each sweep's own binary, the other 50 carry no
  slang line, on both sweeps.
- Determinism (drivers/det.sh, three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM,
  Scoreboard, BuildUVMPkg and Rggen with the law binary; evidence/determinism.txt): one hash per row-mode, each equal to
  the law sweep's (Scoreboard and Rggen testflags write no database, as at the base).
- Byte controls (drivers/controls.sh over every case of the 23 repro dirs in evidence/controls_dirs.txt: passes 241,
  253, 259, 265 with their verifiers, r11u214dec, 261, and pass 118's, 119's, 120's, 124's, 125's, 131's and 283's grids;
  path lists fence-filtered first): 1416 dirs, **2832 case-views, 140 moving, 4 entering STRICT_EQUAL
  (r11u259repro M/m02_pkg_only, r11u265repro B/b01_vd01 both views, v11u259repro VM/vm12_two_pkgs_only), 0 leaving, 0
  exit-code changes, 0 uhdm-cmp line-count changes**; away census lost 0 and chain away 0 on all 140
  (evidence/controls_away.txt). Four case-views exit 139 on BOTH binaries (v11u283repro VB/vb06 both views).

## Residues (ranked; all wrong on pristine too)

1. g207_h_foreign: an importer copy's local typed by a THIRD package's struct (`p207c_x::sx207 lx207` in p207a_x's
   function): § cloneAggTsAtHomeListing241 abstains on a typedef of another package, so the struct is the shared one
   (members named `bt207x`, a `name` record on the elaborated member typedef); and the member path `lx207.x_min207`
   binds a member whose typedef alias reads `bt207x` where golden's reads `p207c_x::p207c_x::sx207::x_min207::bt207x`.
2. Law 1's open shapes: a class in a module (C/c10), a struct the source package imports from a third package
   (C/c12, c16), a union and a packed struct (C/c05, c06: stage 1 on both binaries on another face), the header
   file (C/c14 `file`).
3. Laws 3 and 4's open shapes: package-function importer copies (M/m01, m03, m05, m06, m08, m09, m11 stage 1 on both
   binaries before the member names are reached), the struct formal and return copy (M/m10 `fullname`).
4. Everything else in the brief's item (1) list: the base classification (evidence/residue_first_records_base.tsv,
   245 first records with their walk path; fullname 97, type 30, line 29, endcol 22, file 15, depth 15, col 13,
   name 9, endline 8, value 4, count 2, decompile 1) — the struct-member full names under type parameters and
   parameters (r11u112 k14_unpacked, r11u24 n11, r11u47 g10 / g12, r11v21 v15, r11v47 v12, r11v74 v2_kindns,
   r11u107 a08 / a18 / t13, v11u93b107 p02), the elaborated cont_assign call fold (r10rgg6 r2_ca_outer and
   top_none_n4_yes_typed_ca, r10vrgg6 w_two_ctx_order), the interface declaration order (r11v93 v15), and the items
   (2) to (7) not attempted.

Sister-ground faces met (reported, not written): the package typedef listings' alias reference names
(r10vearl100repro v6_more100, r11u108repro f5a20_ovr_pkgarr, r11u111repro a10_q_chain, v11u108repro b13_pkg_arr:
`package > logic_typespec / struct_typespec > ref_typespec` full names, the package-parameter and typedef stretch of
ParamEmit), r10v112repro g19_builtin (a type parameter's file, ParamEmit).

## Process

- Fence: every corpus path list was filtered by $FENCED (read fail-closed from tools/probe/r11u107repro/canaudit.sh)
  before any file was opened (bvmirror, the census filter, the binary-path audit); the decode helpers added here
  (drivers/objinfo.cpp, drivers/recpath.py, drivers/probecls285.py) refuse to run without four fenced names and refuse
  a fenced path; no fenced source or database was read or dispatched outside the gate sweeps.
- No process of another agent was listed or signalled. SLIP: one completion check of the controls run used
  `pgrep -f` with this pass's name, which can match the checking shell itself; its answer was discarded and the
  completion read from the output's line count (1416 dirs x 4 lines); nothing was signalled.
- Every tool variable was checked with `[ -x ]` (drivers/env.sh); nothing was written outside the worktree and the
  pass's own scratch.
- Drivers: copied from tools/probe/r11u283repro/drivers (grid.sh with the R11U285 switches and LAWBIN, gridsum285.py),
  plus gridpairs.sh, probecls285.py, recpath.py and objinfo.cpp.
