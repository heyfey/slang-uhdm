# v11u480 — adversarial verification of r11u480 (module/type ground, pass 480)

VERDICT: CONFIRMED, no break found, no production change. The verified patch's src diff is
byte-identical to the implementer's /tmp/r11u480.patch (md5 464e33f926e25e6bd8f9a43f5973eb2d).
This folder adds 39 fresh case dirs (cases/VA 33, cases/VS 6), drivers and evidence.

## Binaries (frozen under /tmp/v11u480_bin)

| tag | md5 | what |
|---|---|---|
| pris | c2b2989cd5535d93b46bfce45857e5bc | the main tree's build/slang-uhdm at ffae79ca, copied (no pristine build, per the budget) |
| law | ca935476c93bd4580c8beef2e2385789 | rebuilt once from the patch on a fresh ffae79ca worktree; equal to the implementer's law3; links slang 12.0.0+545f88b2e |

## Laws checked

* § aliasParamStoredRead480 (UhdmExporter, R11U480_APSTORED_OFF): reads the parameter's stored full
  name before the storing getter, skipping a candidate with none stored.
  - The skip drops NO firing of § aliasCopyParamUnnamed478: on all 160 grid dirs (r11u480, v11u480,
    r11u478, v11u478) the 478 trace lines of that law are identical on pris and law, 104 each
    (evidence/trace_grid_pris.txt, trace_grid_law.txt). The implementer's reason (an unstored
    candidate's computed chain name always ends with the copy's name) agrees with UHDM's
    BaseClass::ComputeFullName, which walks param -> param_assign (unnamed) -> class_typespec.
  - Byte movers it alone owns: AP/ap01 to ap04, AS/as01, as02, VQ/vq09 to vq15, vq18 and the fresh
    VS/vs05; each path-normalized uhdm-dump IDENTICAL to pristine's (0 lines), same uhdm-cmp count,
    strict verdict and dump distance. VS/vs01 to vs04 and vs06 hold no candidate (no bytes move).
* The duplicated § cloneHierArrElemMember478 comment block: the two 24-line blocks in the base are
  identical line for line and the code-only diff (comment lines stripped) of UhdmExporter.cpp is
  exactly the § aliasParamStoredRead480 helper and its reader.
* § aliasFormalCopyPerClone478 is judged by the dump: recorded by the implementer; nothing to measure.
* § fixArrLocalNamedAggElemTs480 (TaskFuncEmit, R11U480_FIXARRAGG_OFF).

## Reproduction (evidence/grid_*.txt)

The implementer's 30 grid dirs reproduced field for field on pris and law (exit code, uhdm-cmp
count, strict verdict, dump distance): pristine STRICT_EQUAL 2, STRICT_NOTEQUAL 17, NOT_EQUAL 11;
law 20, 0, 10. The r11u478/v11u478 98 dirs: the same 12 apstored movers plus the element-law
movers AM/am08 and VM/vm01, vm04, vm06, vm08, vm11 to vm14, vm16, vm17 (no verdict moving except
vm11's uhdm-cmp 108 -> 17; every dump distance smaller). Over all 160 dirs (incl. this folder's
first 32): R11U480_OFF gives pris bytes on 160 of 160 and no exit code moves; the 74 movers split
exactly by switch, R11U480_FIXARRAGG_OFF alone leaving the 15 apstored movers moved and
R11U480_APSTORED_OFF alone leaving the 59 element-law movers moved. No uhdm-cmp count and no dump
distance grows on any dir.

Cross-law note (not a break): with the home element typed by the struct, § cloneHierArrElemMember478
now also binds hier_path members in import clones (AM/am08, FA/fa16, VM/vm04, vm08, vm11 to vm14,
vm16, vm17, VA/va21: e.g. `acc[0].data` -> typespec_member data), exactly where golden binds them
(FA/fa16 checked line by line against the Surelog dump). The implementer's README does not mention
that the element law reaches § cloneHierArrElemMember478.

## The sweep (one, on law; workdir /tmp/v11u480sw, 14 chars like /tmp/intr11u478)

Stages 1-4 from the worktree, sv-tests through the main tree's tests/sweep.sh (the worktree's UVM
folder is empty), R11U480_TRACE on. evidence/sweep_summary.txt.

* probe EQUAL 4026 + STRICT_NOTEQUAL 61, regressions 0, CONVERSION r10uvm129repro/g129_d_bases
  STRICT_NOTEQUAL differ:type(1) -> EQUAL, fresh row `r10uvm129repro/g129_d_bases,EQUAL,,equal`;
  the csv differs from the control in that row only.
* surelog default 480 + testflags 474, 0/0/0; uhdm2rtlil 803/1/67 both modes, 0/0/0; downstream
  803/66/2/0, none unexcused; sv-tests EQUAL 1937, DIFFERENT 3, BOTH_REJECT 303, SURELOG_ONLY 75,
  SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1, 0/0/0. Every csv equal to the control's row for row
  (after workdir-path normalization) except the probe conversion. Both sweep.sh calls exit 1 on the
  law-index check alone (this folder not yet indexed in the worktree; the main tree's index stale).
* byteverify (SELFCHECK=1) against /tmp/intr11u478: 0 movers in surelog, uhdm2rtlil and downstream
  (3375 databases); the 24 kept sv-tests databases all differ in bytes, by the workdir name only
  (path-normalized dumps identical on the four checked: p58, 8.26.5 implemented_class_handle,
  uvm_overriding, p733), rsd also by the law's one firing (SURELOG_CRASH, no golden).
  evidence/byteverify.txt.
* trace (evidence/sweep_trace.txt): g129_d_bases 16 x fixArrLocalNamedAggElemTs480, rsd 1 x,
  uvm_param_vif_config_db 332 x aliasParamStoredRead480: the implementer's prediction exactly.
* canaries ok=52 and ok=16, ctcan2 PASS (ok=58, ok=2).
* binary audit (fence-filtered): surelog 1523 of 1573 records name the law binary, the other 50
  hold only Surelog lines; uhdm2rtlil 1740 of 1740; sv-tests 2346 of 2346.

## Attack grid (cases/VA 33 + cases/VS 6; every case accepted by upstream slang, every exit code 0 on both binaries; driver drivers/runcase.sh)

§ fixArrLocalNamedAggElemTs480 (VA): pristine STRICT_EQUAL 1, STRICT_NOTEQUAL 23, NOT_EQUAL 9;
law STRICT_EQUAL 20, STRICT_NOTEQUAL 5, NOT_EQUAL 8 (no dump distance or uhdm-cmp count growing).

| case | shape | pris | law |
|---|---|---|---|
| va01 | parameter-width struct, two overridden instances | NOT_EQUAL 50 dd 56 | same, dd 51 |
| va02 | explicit import p::op_t | SNE type | STRICT_EQUAL 144 |
| va03 | module nested two levels, static task | SNE type | STRICT_EQUAL 122 |
| va04 | package int enum, direct call | SNE type | STRICT_EQUAL 182 |
| va05 | interface function, two interface instances | SNE type dd 43 | SNE type dd 38 |
| va06 | packed struct via always_comb | SNE type | STRICT_EQUAL 235 |
| va07 | packed union with initializer | SNE type dd 25 | SNE type dd 20 |
| va08 | parameterized class typedef, two specializations | SNE type | STRICT_EQUAL 95 |
| va09 | package function imported by two modules | SNE type | STRICT_EQUAL 275 |
| va10 | foreach over the local | SNE type | STRICT_EQUAL 216 |
| va11 | typedef imported into the declaring package | SNE type | STRICT_EQUAL 252 |
| va12 | class in a package importing the typedef | SNE type | STRICT_EQUAL 115 |
| va13 | nested struct element | SNE type | STRICT_EQUAL 154 |
| va14 | enum, ascending range, case | SNE type dd 25 | SNE type dd 20 |
| va15 | module array variable and local of one typedef | SNE type dd 55 | SNE type dd 50 |
| va16 | declaring module under a generate loop | SNE type dd 43 | SNE type dd 38 |
| va17 | static local, static function | SNE type | STRICT_EQUAL 124 |
| va18 | struct with an enum member, package task | SNE type | STRICT_EQUAL 260 |
| va19 | one typedef, two functions | SNE type | STRICT_EQUAL 231 |
| va20 | out-of-body method of a module class | SNE type | STRICT_EQUAL 119 |
| va21 | package function reached by a class of an importing package (clone abstains) | NOT_EQUAL 94 dd 608 | same, dd 586 |
| va22 | module typedef of a package typedef | NOT_EQUAL 17 dd 50 | same, dd 49 |
| va23 | enum in a ported submodule | SNE type | STRICT_EQUAL 266 |
| va24 | program task | NOT_EQUAL 405 dd 77 | same, dd 76 |
| va25 | interface task exported through a modport (Surelog exits 4, golden written) | NOT_EQUAL 389 dd 33 | same, dd 28 |
| va26 | local declared in a begin block (StmtEmit's branch, the law does not fire) | STRICT_EQUAL 124 | same bytes |
| va27 | typedef of the base class used in a derived method | NOT_EQUAL 52 dd 21 | same, dd 16 |
| va28 | package function never called nor imported | SNE type | STRICT_EQUAL 119 |
| va29 | $unit typedef, declaring module twice | NOT_EQUAL 92 | STRICT_EQUAL 187 |
| va30 | the declaring module an uninstantiated second top | SNE type | STRICT_EQUAL 132 |
| va31 | module typedef shadowing a wildcard-imported one | NOT_EQUAL 934 dd 58 | same, dd 57 |
| va32 | typedef of a specialized parameterized base | NOT_EQUAL 52 dd 21 | same bytes |
| va33 | scalar and array locals of one typedef | SNE type | STRICT_EQUAL 148 |

The five law dirs left STRICT_NOTEQUAL type (va05, va07, va14, va15, va16) stop at an older face
pristine has too: the elaborated continuous assignment's function call folded to a constant where
golden keeps the func_call or hier_path u.f (strict #187 to #296 `func_call f` against
`constant UINT:...`); va01 at the same face plus the '0 argument kept as '0 size -1.

§ aliasParamStoredRead480 (VS): vs05 (two classes holding the alias) moves bytes with an identical
dump, STRICT_EQUAL 353 on both; vs01 to vs04 and vs06 byte-identical.

Downstream (scripts/downstream_uhdm2rtlil.py `one`): va06 DIVERGENT -> IDENTICAL, va23 EQUIVALENT ->
IDENTICAL, FA/fa18 DIVERGENT -> IDENTICAL (the implementer's), fa03 IDENTICAL on both; va01 and va16
EQUIVALENT on both; va05, va07, va14, va15 DIVERGENT on both (the folded-call constant face above).
No case leaves IDENTICAL.

## Away census (evidence/away_census.txt; drivers/census.sh)

The complement of the implementer's 1888 dirs: 2408 fence-filtered case dirs under tools/probe/*/cases
whose dut.sv holds struct, union or enum and a function or task, not in the implementer's list, plus
the positive controls FA/fa01 and fa04 (both flagged). No exit code moves. Two dirs differ in bytes,
r11u242 F/f06 and f08, and both are coins: three draws per binary give one hash shared by pris and
law, and runcase.sh reads pris and law byte-identical with the same verdict and dump distance.

## Residues (the implementer's list stands; ranked)

1. The import-clone half of the fixed-array element (golden's private struct copy under the clone's
   ref_typespec): VM/vm01, vm04, vm08, vm11 to vm13, vm16, vm17, AM/am08, FA/fa16, VA/va21.
2. The clone array_var parented at the begin where golden parents it at the function.
3. Element shapes the law does not reach: a typedef of a specialized parameterized base class (va32), alias-of-typedef
   elements (fa10, fa26, va22), program and generate-block functions (fa20, fa21, va24).
4. The elaborated continuous-assignment call fold (va05, va07, va14, va15, va16, va01): the sister's
   or ModuleEmit's elaborated view, not decoded here.
5. Pass 478's carried list (VF/vf06, vf02, vp06, iu14/vi15, vi16, vi01, AP/ap01 to ap05).

## Sister-ground faces (reported, not written)

* The implementer's unmeasured StmtEmit block-item twin is measured here and is NOT a face: a fixed
  array of a named struct declared in a begin block of a function (VA/va26) is already STRICT_EQUAL
  on pristine, so nothing is left to report there.
* StmtEmit's § 175 design-final begin copies after the provider binding (pass 478's report).

## Process

No pristine build or sweep (pris = the main tree's build, the control = /tmp/intr11u478); one law
build, started after the sister r11u487's sv-tests stage had ended (the sister's verifier build was
running at the same time); one five-stage sweep, started by a launcher that waited for a quiet
machine. Slip, affecting no reported number: the first grid batch ran pris and law concurrently on
one golden cache and raced on four golden builds; the cache was deleted and both reruns made
sequentially. The fence list was read into a file by a program and never printed; every tree-wide
list was filtered on it before a file was opened; this folder scans clean.
