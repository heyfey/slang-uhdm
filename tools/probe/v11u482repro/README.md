# v11u482 — adversarial verification of r11u482

Base 6344380c (pass 480). Implementer's patch /tmp/r11u482.patch (six laws in src/TaskFuncEmit.cpp and
src/UhdmExporter.cpp). Verdict: **one break found and fixed** by one refinement,
§ copyInstMemberOwnRoot482v (UhdmExporter, `fixOn(482, "R11V482_MEMBROOT_OFF")`). Every headline
number of the implementer was reproduced. No sv-tests row moves, and every corpus gate reads 0
regressions on both the law binary and the verified binary.

## Binaries (frozen under /tmp/v11u482_bin before any measurement)

| tag | md5 | what |
|---|---|---|
| pristine | ca935476c93bd4580c8beef2e2385789 | a frozen copy of the base build, as the brief requires (the main tree has moved on to pass 487) |
| law | 9b2ac7c75b8d9e830b60ed561c389994 | rebuilt from /tmp/r11u482.patch on a fresh 6344380c worktree; equal to the implementer's law3 |
| verified | d078631cb04f4d365c50ab813eca1731 | law plus § copyInstMemberOwnRoot482v; links slang 12.0.0+545f88b2e |

No-header audit of the added lines: no src/R*.h, no getenv, no include. The six law switches are
read through `lawOn(482, ...)` and the fix switch through `fixOn(482, ...)`. Every law and the fix
have a `lawTrace` call.

## Reproduction of the implementer's numbers

* **Grid** (r11u482 cases/CI, 25 dirs; evidence/grid_r11u482_*.txt). Every verdict, uhdm-cmp
  count, dump distance (dd) and object-census distance (oc) is reproduced field for field.
  - pristine: STRICT_EQUAL 1, NOT_EQUAL 24.
  - law: STRICT_EQUAL 19, NOT_EQUAL 6.
  - The verified binary is byte-identical to the law binary on all 25.
* **Switches** (evidence/switch_off_check.txt; the 25 CI dirs plus 56 attack dirs).
  - `R11U482_OFF` gives pristine's bytes on 81 of 81, on both the law and the verified binary.
  - `R11V482_OFF` gives the law's bytes on 81 of 81.
  - With each switch alone (evidence/switch_table.txt), the CI dirs move exactly as the
    implementer's table says.
* **Law sweep** (one full five-stage `tests/sweep.sh --jobs 3`, workdir /tmp/v11u482swp, the same
  length as the control /tmp/intr11u480, with R11U482_TRACE on; evidence/sweep_summary.txt). This
  is the first sweep of law3 itself, since the implementer swept law2.
  - probe: 4026 + 61; 0/0/0.
  - surelog: 480 + 474; 0/0/0.
  - uhdm2rtlil: 803/1/67 in both modes; 0/0/0.
  - downstream: 803/66/2/0, with 0 not excused.
  - sv-tests: EQUAL 1937, DIFFERENT 3, BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19,
    SURELOG_CRASH 8, TIMEOUT 1; 0/0/0.
  - Every csv equals the control's row for row after workdir normalisation.
* **byteverify, law against the control** (SELFCHECK=1): surelog 4 of 962 (MiniAmiq d/t and
  SeqDriver d/t), uhdm2rtlil 0 of 1608, downstream 0 of 805. The selfchecks flagged 961, 1607 and
  804. The four hashes equal the implementer's.
* **Canaries:** ok=52 and ok=16; ctcan2 PASS on both (ok=58 and ok=2).
* **Binary audit**, fence-filtered:
  - surelog: 1523 of 1573 records name the binary under test; the other 50 hold only a Surelog
    line.
  - uhdm2rtlil: 1740 of 1740.
  - sv-tests: 2346 of 2346.
* **Trace:** 69 processes.
  - The 43 probe cases are exactly the implementer's predicted list (comm reads 0 differences).
  - MiniAmiq d/t and SeqDriver d/t.
  - 21 uvm-examples rows (all EQUAL) and rsd (SURELOG_CRASH).
  - Only COPYINST, COPYINST_member and TFVARPARENT fire: 8645, 1964 and 55560 lines.
* **Away census** (evidence/away_bytecensus.txt, drivers/bytecensus.sh). 3548 fence-filtered case
  dirs: the implementer's 3346 plus 202 more whose dut.sv holds `package`, `import` and a
  function or task.
  - No exit code moves on any of the three binaries.
  - 688 dirs move bytes pristine -> law: the implementer's 672 plus 16 outside its list, among
    them r10uvm227 a10_ctxs, a12_p2_own_body, a2_iface_inst and a4_pkg_holder, r10uvm36 t48b,
    r11u247 decode/d01, r11u449 IP/ip01 to ip04, r11u453 HS/hs02 and r11v21 v5.
  - law -> verified: 0 dirs move.
  - All 688 were judged against fresh Surelog goldens (evidence/away_movers_judged.txt):
    - 68 move up: 61 NOT_EQUAL -> STRICT_EQUAL, 6 NOT_EQUAL -> STRICT_NOTEQUAL and 1
      STRICT_NOTEQUAL -> STRICT_EQUAL.
    - None moves down, and no uhdm-cmp count or object-census distance grows.
    - The 6 whose dump distance grows (r11u244 N/n05, v11u244 E/e10, v11u248 B/b06, v11u446
      VQ/vq06, v11u478 VM/vm03 and vm10) all have a smaller object-census distance.
    - v11u478 VM/vm11 grows in instance-census distance (157 -> 185). See finding 2.

## The break: a member type that is itself a package typedef copy (fixed)

**§ copyInstMemberOwnRoot482v** (UhdmExporter, the member loop of § cloneOwnCopyInstHomeTop482;
`R11V482_MEMBROOT_OFF`).

The law's member loop gives every member type of a copy root the root's package top view. When the
member type is itself a copy of a package typedef, that overrides the instance the first loop had
just given it from its own name. Example: inside a copy of u's `op_t`, a member `s::in_t i;` or
`s::e_t e;`.

Golden's deep clone keeps the source's instance, so these copies read **s(top)**. Pristine had no
such copy objects (they were shared, and wrong differently). On the law binary they are the
law's own objects carrying a value the law wrote wrong, **u(top)**, which leaves the copies further
from golden than the law's own first loop had put them:
* VM/vm05: uhdm-cmp head `package s` against `package u` on the member copy; instance census 69 on
  pristine, 40 on the law and 28 on the verified binary.
* VC/vc06: 24, 16 and 12.

The fix skips a member type that is itself a root, keeping the instance it got from its own name.
* vm05's head moves later, to the shared s::in_t listing instance u(all) that pristine already
  has; uhdm-cmp stays 476 lines (94 on pristine, whose head was earlier) and dd goes 621 -> 609.
* vc06 dd 162 -> 158.
* It fires in no sweep process: the verified sweep's trace is identical to the law sweep's, and
  the away census shows 0 movers law -> verified.

## Attack grid (cases/VF, VA, VC, VP, VI, VM, VD; 59 dirs; evidence/attack_*.txt)

Every case is accepted by upstream slang (VF/vf06 was edited after drivers/gen.py wrote it, to
`function automatic` and a full initializer). Every exit code is 0 on all three binaries. Surelog
exits 4 on VA/va08 (a class in a package) and still writes the database.

| binary | STRICT_EQUAL | STRICT_NOTEQUAL | NOT_EQUAL |
|---|---|---|---|
| pristine | 9 | 2 | 48 |
| law | 32 | 2 | 25 |
| verified | 32 | 2 | 25 |

Movers: 53 of 59 pristine -> verified, and 2 law -> verified (vc06 and vm05).

Downstream (`ds.one`, both lanes) on VD/vd01, vd02, vd03, VF/vf01, VI/vi01, VM/vm01, VC/vc06 and
VM/vm05:
* vd01 and vd02 go EQUIVALENT -> IDENTICAL. These are cloned functions in a continuous assignment
  and an always_comb, with nohier/il differing on pristine.
* vd03 (11 gates) and the rest read IDENTICAL on both binaries.

| group | law | shapes (each case's first line names its law) | pristine -> verified |
|---|---|---|---|
| VF | § cloneFixArrAggElemShared482 | three importers (vf01), alias of the struct (vf02), home alias of a third-package struct (vf03), typedef in the function (vf04), N-sized (vf05), initializer (vf06), nested begin (vf07), module variable of the struct (vf08), importer's package variable (vf09), packed struct with an enum member (vf10), task with two importers (vf11), struct plus union arrays (vf12), chain b -> a -> u (vf13), direct and cloned use (vf14), explicit import u::f (vf15), static local (vf16) | to STRICT_EQUAL: vf01, vf06, vf08, vf10 to vf14, vf16; vf07 STRICT_EQUAL on both; vf02, vf03 see finding 2; vf05 94 -> 465 and vf09 94 -> 1410 lines with the head later (finding 3); vf04, vf15 closer |
| VA | § cloneArrElemAggOwnCopy482 | queue with packed members (va01), queue of a union (va02), dynamic in a task (va03), anonymous struct member (va04, abstains), three importers (va05), dynamic formal (va06), string member (va07), class method (va08) | va01, va03, va05, va07 to STRICT_EQUAL; va02, va08 STRICT_EQUAL on both and closer; va04 closer; va06 unchanged bytes |
| VC | § cloneOwnCopyInstHomeTop482 | enum member (vc01), formal (vc02), return type (vc03), union with three importers (vc04), struct member (vc05), member enum of package s (vc06, the break), module port (vc07), enum local (vc08), two packages with an op_t each (vc09) | none to equal: their heads are older faces (vc03 return type, vc02 depth); every moved dir closer by dd, oc and instance census; vc02, vc03 unchanged |
| VP | § cloneTfVarParentAtTf482 | named block (vp01), for loop (vp02), initializers with two importers (vp03), fork (vp04), class method (vp05), nested begin (vp06) | all keep their verdict; dd and oc smaller where they move; vp03 unchanged |
| VI | § cloneHierIdxChainActual482 | three importers (vi01), variable indexes (vi02), `acc[$][2]` (vi03), with the member chain (vi04), part-select after the member (vi05), no clone (vi06), `s.arr[0][1]` (vi07), `acc[0].arr[1][0]` (vi08) | vi01, vi02, vi04 to STRICT_EQUAL; vi03, vi05, vi07, vi08 closer; vi06 unchanged |
| VM | § cloneHierMemberChain482 | three levels (vm01), union member (vm02), packed member (vm03), alias member (vm04), third-package member (vm05, the break), queue (vm06), scalar (vm07), module function (vm08), `.e.name()` (vm09) | vm01, vm02, vm03, vm06, vm09 to STRICT_EQUAL; vm04, vm07 closer; vm08 unchanged |
| VD | downstream shapes | as above | vd01, vd02 NOT_EQUAL -> STRICT_EQUAL; vd03 STRICT_EQUAL on both |

## Findings that are not breaks

1. **The implementer swept law2, not its final law3.** Its README says the narrowing fired nowhere
   in that sweep. This verifier's law sweep on law3 closes the gap, every stage reading 0/0/0.
2. **Alias typedefs** (v11u478 VM/vm11, VF/vf02, vf03). Law 1 also fires when the element is an
   alias declared in the home package, including an alias of another package's struct (vf03). Its
   package check reads the alias's scope, not the canonical struct's.
   - The copies carry our name u::op2_t where golden names them by the bare alias op2_t (the older
     alias face).
   - Their member types get the home top view where golden writes the struct's own package's top
     view (vf03: s).
   - The instance census therefore grows (79 -> 89 on vf02 and vf03, 157 -> 185 on vm11), while
     uhdm-cmp counts, strict verdicts, dd and oc stay or shrink.
   - The fix belongs with the alias face: name an alias copy by the bare alias, and give a copy's
     members the canonical struct's package.
3. **Later heads reached** (vf05, vf09, vm05). The count grows because the head moves later, onto
   faces pristine already has:
   - vf05: the N-1 range's constant int_typespec instance u where golden has none.
   - vf09: golden lists the importer package variable `pv` as a logic_net under top.
   - vm05: the shared s::in_t's listing instance.
4. **Law 1 is gated by pass 480's switch.** `R11U480_FIXARRAGG_OFF` also turns off
   § cloneFixArrAggElemShared482, and pass 480's `lawTrace(480, "fixArrLocalNamedAggElemTs480")`
   line now also fires in import clones. The implementer's README names the gate but not the trace
   change.

## Residues (ranked; all wrong on pristine too; none moved away on the verified binary)

1. **Alias copies** (finding 2: VM/vm11, VF/vf02, vf03). This is the next face for this ground.
2. **The implementer's residues**, confirmed:
   - CI/ci03, the enum element;
   - CI/ci16 and VM/vm12, the third-package typedef;
   - CI/ci10, the associative clone;
   - member types shared inside copies;
   - VM/vm08 and vm18 at the array-member instance face, plus vm14.
3. **The enum base inside a copied enum member** (VF/vf10, STRICT_EQUAL). Golden's 10 logic base
   copies read u(top); ours read u(all). Second-level member types are not covered.
4. **Older faces reached by the grid:**
   - an N-sized range's constant typespec instance (vf05);
   - importer package variables listed as nets under the importing module (vf09; ModuleEmit);
   - struct formal and return copies (VC/vc02 depth, vc03 27 lines);
   - two dimensions under a queue (VI/vi03);
   - a part-select after a member (vi05);
   - an array member inside a struct (vi07, vi08);
   - VA/va04 and VA/va06.
5. **The carried lists of the brief and of r11u482.**

## Sister-ground faces (reported, not written)

* The implementer's three, unchanged: ExprEmit's call-argument constant typespec (CI/ci11, ci23),
  ExprEmit's fold of `f(1)` (CI/ci22, and VC/vc08 here), and StmtEmit's
  § importCloneBodyLocalCopies175 begin copies made after the shared instance is rewritten.

## Gates on the verified binary (one full five-stage sweep, workdir /tmp/v11u482sw2, trace on)

* Every stage reads 0 regressions, 0 conversions and 0 changes, with the same counts as the law
  sweep.
* Every csv equals the control's row for row.
* byteverify, verified against law: 0 of 962, 0 of 1608 and 0 of 805.
* byteverify, verified against the control: the same 4 surelog movers, 0 and 0.
* Probe: the 43 trace-firing cases have path-normalised dumps identical to the law sweep's.
* Canaries ok=52 and ok=16; ctcan2 PASS on both.
* Binary audit: 1523 of 1573, 1740 of 1740, 2346 of 2346.
* The trace is identical to the law sweep's: the refinement fired in no sweep process.
* Determinism: three concurrent draws plus the sweep read one hash, 4 of 4 each.
  - MiniAmiq default: 15a2c8dae023174eba8e9f8c92f3ff1a.
  - SeqDriver testflags: d9a59668e594cd070a3fa33fb31aa1d0.

  These are the implementer's hashes. The master must re-record MiniAmiq d/t and SeqDriver d/t
  at landing, as the implementer said.

## Process

* Measured within the budget: no pristine build or sweep (a frozen copy of the base binary and the
  master's control), one law build and one law sweep, one verified build and one verified sweep.
* The verified sweep ran because the refinement changes production code.
* Slip, affecting timing only: the verified binary's first grid batch overlapped the start of the
  sister verifier v11u489's sweep. No sweep of this pass overlapped another sweep; each launch
  waited on quietwait.py.
* The fence list was read into a file by a program and never printed. Every tree-wide list was
  filtered on it before any file was opened, and the repro folder scans clean.
* No other agent's process was touched.

## Drivers

* drivers/runcase.sh <bin> <tag> <casedir>...: exit codes, uhdm-cmp lines, strict verdict, dd, oc,
  instance-census distance (ic, r11u482's tsinst) and md5. Explicit dirs; goldens are cached under
  /tmp/v11u482_runs/<full path>.
* drivers/grid.sh, bytecensus.sh (per-binary exit code and md5), ds.py (downstream `ds.one`),
  cmpdiff.sh (uhdm-cmp's two blocks diffed with ids stripped), gen.py (the attack generator) and
  env.sh.
