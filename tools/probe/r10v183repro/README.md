# r10v183 — ADVERSARIAL VERIFICATION of r10uvm183 (§ `cloneForeachArrayRefUnresolved183`)

**VERDICT: ACCEPT** — no fix was needed and the production surface is
unchanged from the implementer's patch. Every headline number was rebuilt from
scratch in this verifier's own worktrees and reproduced **bit-for-bit**.

**MEASUREMENT-ONLY.** The official `uhdm-cmp` and `scripts/verify_golden.py`
are the only authorities. slang was NOT patched; `results/*.csv` were READ
ONLY; nothing was promoted and NO CORPUS ROW CONVERTED; `GOLDEN_DEFER` stayed
unset; the four slang-fenced tests were never dispatched (`FENCED_SKIPPED=0`
is the wide gate's own assertion that no arm file is named after one).
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `6fee5084`, two FRESH worktrees (patched + pristine), both configured and built independently |
| pristine binary | md5 `86973e02d6a070958700f9a63ffe3ffe`, 22 423 200 bytes — **byte-identical to the master's frozen pristine at this commit** |
| patched binary | md5 `646ee5730fe19d8d40576d9a2267aef0`, 22 419 056 bytes — **byte-identical to the implementer's**, from an independent `cmake`+`make -j 2` |
| both | frozen `chmod 555` at immutable paths BEFORE any sweep; `SLANG_UHDM` exported explicitly per binary; **every `cmds.txt` audited by binary PATH** |

---

## 1. What reproduced, bit for bit

| claim | verifier's own measurement |
|---|---|
| patch applies clean on a fresh `6fee5084`, rebuilds to the same binary | yes — md5 above, 0 build errors, 0 conflict markers, `git status` clean |
| goldens | **23 PASS / 0 FAIL** patched, **23 / 0** pristine, **0 / 23** with `SLANG_UHDM=/bin/false` |
| uhdm2rtlil | **679 / 50 / 2** in both modes under BOTH binaries; `ct8rows` **0 differing rows** vs the committed `results/gate_uhdm2rtlil.csv` and vs this verifier's own pristine sweep, both modes, status AND dump column |
| surelog | default **471 / 283 / 25 / 10 / 5**, testflags **466 / 284 / 23 / 9 / 5 / 3 / 2 / 1 / 1**; `ct8rows` **0 differing rows over 1588** vs the committed baseline, vs the verifier's pristine sweep, and pristine-vs-committed; **NO ROW CONVERTED** |
| bytes | **4 / 956** surelog, **0 / 1358** u2r, `PATH_SETS_IDENTICAL`, `SELFCHECK` 955/956 and 1357/1358 |
| a-priori prediction | re-run on the verifier's OWN pristine sweep: `comparable rows=956`, OURS-SIDE 4, GOLDEN-SIDE 4, `AGREE=True`, the same four names (MiniAmiq ×2, SeqDriver ×2) |
| heads | MiniAmiq **26 → 13** both modes; the two modes' logs byte-identical, md5 `32a37b37f74e276f6ee5b0ca5370cc40` → `6a7b1478c978ab38d884bcbf783e7155` — **identical to the committed `head_{pris,pat}_MiniAmiq.*.cmp` artifacts**. SeqDriver 13/13, SimpleUVM 664681 ×2, Scoreboard/default 95, BuildUVMPkg 52/52, Earlgrey 31/364, Rggen/default CMP_EQUAL — unchanged |
| corpus census | **DEGRADE-TOWARD 1044, untouched 5853, MUST-STAY-AWAY 0, MOVED-WRONG 0, TOWARD-OTHER 0**; golden-vs-golden calibration **untouched 6897, degrade-cells 0** (rebuilt by feeding the golden census as both sides) |
| the 522 | all four clone row-modes: golden **522** `unsupported_typespec @uvm_pkg`, pristine **520 @importer + 1 string_typespec + 1 array_typespec**, patched **522 @uvm_pkg** |
| attribution (order-blind) | each mover's sorted dump diff holds only this law's lines: 522 `\_package: uvm_pkg` in / 520 importer out, 2 `\|vpiInstance:` in, the two placeholders (`arg`, `actions`) in, `string_typespec` + `array_typespec` out. **Scoreboard/default did not move.** |
| the six implementer arms | re-run against fresh real Surelog goldens: A **5/0/0** KIND both views and **6 TOWARD +1 partial** INST; B **8 / 16** KIND, **8 / 15** INST; C **4 / 8** both columns; E **1 / 2** KIND, **2 / 4** INST; F **1 / 2** KIND, **1 TOWARD + 3 partial** INST; D (no import) **BYTE-IDENTICAL both views**. AWAY 0, MOVED-WRONG 0, copy-count unchanged everywhere |
| the WIDE boundary | `LISTED=4996 FENCED_SKIPPED=0 PROCESSED=4996 PROCESSED-ASSERT-OK`, **MOVED=58 arm-views** = the implementer's 48 + this verifier's own 10 (4996 = 4990 + the six arms below). The moved-arm SET is the same 24 arms |
| boundary re-scoring | all 24 rebuilt against their OWN real Surelog goldens in both views: **TOWARD 406, TOWARD-PARTIAL 14, AWAY 0, MOVED-WRONG 0, MOVED-SIDEWAYS 0, copy-count unchanged** — the implementer's totals to the unit |
| the R-addrbound pair | `r10buvm22repro/g22.sv` and `r10uvm154repro/l154_noenum.sv`: `22609657→22605561` and `22608801→22604705`, **exactly −4096** each against a **4144-byte binary shrink**; `grep -c foreach` = 0 in both |
| the must-stay floor | **1150 arm-views** of `r10uvm170repro` (all five `g170_*` arms, both views), `r10uvm8{2..9}`/`9{0,1}`, `r10buvm{3..15}`, `r10sd{8..12}` compared as RAW `.uhdm` BYTES: **0 differing**. uvm170's arms and both its fences stand |
| canaries / audit | `canaries.sh` **ok=52 changed=0** and **ok=8 changed=0**; `ctcan2.sh` PASS ×2; `canaudit.sh` **29 audited, 0 UNCOVERED, 0 FENCE-BREACH**; SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort / BlackParrotComplex / YosysOldOr SAME in both modes |
| collateral | patch surface = `src/StmtEmit.cpp` + `RESUME.md` §3b (the landing's own row, which rides with the code) + `tools/probe/r10uvm183repro/` only; the six copied gate scripts are byte-identical to their sources; no `results/*.csv`, no `scripts/`, no fenced name in any driver |

---

## 2. BREAKING THE LAW — six new arms, every mint face × 1..3 instances

`../r10uvm183repro/grid183.sh` (the implementer's driver, reused verbatim — this
directory carries the arms only, no copied instruments) builds one REAL
Surelog golden and both frozen binaries' databases in both views per arm, with
every rc recorded; `score183.py` scores KIND / INST / COPY-COUNT.

| arm | face | KIND (def / elab) | INST (def / elab) |
|---|---|---|---|
| `v183_b_chain.sv` | **1..3 INSTANCES**: home + TWO independent wildcard importers + a clone OF A CLONE (transitive re-export) | TOWARD **9 / 12**, AWAY 0 | TOWARD **9 / 11**, AWAY 0 |
| `v183_d_homes.sv` | where the iterated object LIVES inside one clone: formal, `ref` formal, subroutine local, STATIC local, statement-block local, package variable, and the function's own **RETURN VARIABLE** | TOWARD **7 / 14**, AWAY 0 | TOWARD **7 / 12**, AWAY 0 |
| `v183_e_expl.sv` | the paths the DEGRADE half does not take: an **EXPLICIT named-import copy** and the `::`-scoped mint (which is NOT gated on `foreachUnres9`) | TOWARD **2 / 4**, AWAY 0 | TOWARD **5 / 7** + 1 partial, AWAY 0 |
| `v183_c_param.sv` | THE FENCE both ways: package `parameter` / `localparam` / typedef'd-array parameter vs a package VARIABLE, **plus a SUBROUTINE-LOCAL localparam** | TOWARD **1 / 2**, AWAY 0 | TOWARD **1 / 2** + 4 partial, AWAY 0 |
| `v183_f_stay.sv` | MUST-STAY: the home package's two listings, a module that imports the HOME, class methods in-body and out-of-body, an interface, a no-import package | **BYTE-IDENTICAL under both binaries in both views** | idem |
| `v183_a_shadow.sv` | **NAME-SHADOWING** — an iterated array whose NAME is also a type/class name visible in the home package | MOVED-SIDEWAYS **3 / 6**, AWAY 0 | 1 AWAY + 1 MOVED-WRONG (elab), 1 MOVED-WRONG (def) — **finding F1** |

**"A resolved formal golden also resolves — prove it stays resolved."**
`v183_f_stay.sv`, home package `st183_home::h_fml(input int arg[0:2])`, ELAB
view, cell for cell:

```
golden   package:st183_home#1   ARRTS=int_typespec()@13:38-13:41  INST=package:st183_home#1   (x2)
         package:st183_home#91  ARRTS=unsupported_typespec(arg)   INST=package:st183_home#91  (x2)
pristine  identical shape          patched  identical shape         (the two databases are BYTE-IDENTICAL)
```

The home listing's resolution is untouched, and the DEF twin's placeholder is
the one `pkgDefViewBody9` already owned.

---

## 3. FINDINGS (ranked) — none is judge-visible, none blocks the landing

### F1 — THE FENCE IS INCOMPLETE: a NAME that also names a TYPE

Surelog's `compileDatastructureTypespec` asks
`component->getDataType(typeName)` **first**
(`~/git-repos/Surelog/src/DesignCompile/CompileType.cpp:724`), then the
design's class definitions (`:727-745`), and only THEN the
`getParamAssignVec()` scan the pass fenced on (`:750-762`) and the
`unsupported_typespec` tail. So the parameter is not the only escape: **an
iterated array whose NAME is also a type or class name visible in the home
package resolves in golden in EVERY listing, clone included**, and the law
degrades it.

Measured on `v183_a_shadow.sv` (all three faces are legal SV; slang accepts
them, rc=0), ELAB view, in the clone `sh183_clone`:

| face | golden | pristine | patched |
|---|---|---|---|
| `nm_arr nm_arr;` (a variable of a typedef'd ARRAY type, named like the type) | `array_typespec(nm_arr)@11:11-11:26` ×4 | 2 `unsupported_typespec(nm_arr)` + 2 `array_typespec()@21:12` | 4 `unsupported_typespec(nm_arr)` |
| `int plain_t[0:2];` (name of a scalar typedef) | `int_typespec(plain_t)@12:11` ×4 | 2 + 2 | 4 `unsupported_typespec(plain_t)` |
| `int kls183[0:2];` (name of a class) | `class_typespec()@39:14` ×4, `INST=<null>` | 2 + 2, `INST` half `sh183_clone` half null | 4 `unsupported_typespec(kls183)`, `INST=package:sh183_home` |

**Why it is not a regression the judge can see.** At every one of those cells
the pristine binary's own answer already differs from golden — by KIND
(`array_typespec` where golden has `int_typespec` / `class_typespec`) or by
NAME+SPAN (`array_typespec()@21:12` where golden has
`array_typespec(nm_arr)@11:11`, the R3 nameless/mis-spanned family) — so the
edge was NOT-EQUAL under both binaries and no cell went from equal to unequal.
The scorer prints the KIND column as MOVED-SIDEWAYS (never AWAY) for exactly
that reason. The arm's official `uhdm-cmp` result is the proof: **the same
head object (`package: sh183_home`) and the same line count (2624 def / 3646
elab, ONE head) under BOTH binaries**, and the def-view logs are byte-identical.
The single INST `AWAY` cell (`<null>` → `package:sh183_home`) is the knock-on
of minting a placeholder where golden has a `class_typespec`; its KIND was
already wrong.

**Corpus population: zero**, and proven so rather than assumed — the four
clone row-modes reach **522/522 exact** agreement with golden, which they could
not do if any corpus cell of this shape existed, and the other 952 surelog
databases are byte-identical under the two binaries.

**Not fixed here, deliberately.** The fix needs the HOME package's scope to
mirror Surelog's name-first lookup, and `pkgImportCloneHomePkg` is null on the
class-method clone path (`ParamEmit.cpp:23264`), so it is not the one-line
change `arrIsParam183` was; widening a landed law over a construct with zero
corpus population is the same call the implementer made for R1 and R7. Anyone
taking it should reuse `v183_a_shadow.sv` as the arm and re-run the byte gate.

### F2 — THE FENCE OVER-REACHES: a SUBROUTINE-LOCAL localparam

`arrIsParam183` tests `arrSym->kind == SymbolKind::Parameter`, and slang gives
a `localparam` declared INSIDE a function that same kind. Surelog's escape
scans `component->getParamAssignVec()` — the **package's** parameters — so a
function-local localparam never reaches it. Golden proves it
(`v183_c_param.sv`, `pr183_home::flocal`'s `localparam int FL[0:2]`, ELAB
view):

```
golden   package:pr183_clone#2    ARRTS=unsupported_typespec(FL)@44:14-44:16  INST=package:pr183_home#1   (x2)
         package:pr183_clone#946  ARRTS=unsupported_typespec(FL)              INST=package:pr183_home#1   (x2)
patched  package:pr183_clone#569  ARRTS=array_typespec()@0:0-0:0              INST=<null>                 (x2)
```

golden degrades it in **every** listing; the fence exempts it, so the ELAB
clone copy keeps our `array_typespec`. This costs a cell, it can never cause
one: pristine holds the identical value (the scorer calls it `still-off`, not
`AWAY`). Narrowing the fence to
`arrSym->getParentScope()->asSymbol().kind == SymbolKind::Package` would be a
strict gain with, again, zero corpus population. The PACKAGE-parameter half of
the fence is confirmed necessary and correct: golden's `fp` over
`parameter int P_FIX[0:3]` is `array_typespec()@8:13-8:27` in **all** listings
including both clone copies.

### F3 — arithmetic nit in the implementer's README §8

"18 are the clone-foreach neighbourhood" enumerates and measures **17**
(uvm181's four, v181's six, uvm180 `g180_b_depth`, uvm37 `t51a`/`t51b`,
uvm21 `t32d`, buvm19 `grid19`, vbuvm19 `vg19c`, v178 `f_shadow`). 17 + the 2
R-addrbound arms + the pass's own 5 = the 24 the same section reports, which
is right; only the sub-count is off by one.

---

## 4. REPRODUCING

```sh
git worktree add /tmp/wt_v183 6fee5084 && git worktree add /tmp/wt_v183pris 6fee5084
(cd /tmp/wt_v183 && git apply -3 /tmp/r10uvm183.patch)
for w in /tmp/wt_v183 /tmp/wt_v183pris; do
  cmake -S $w -B $w/build -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
     -DUHDM_DIR=$HOME/.local/lib64/cmake/UHDM -Dslang_DIR=$HOME/.local/lib64/cmake/slang
  cmake --build $w/build -j 2
done
cp /tmp/wt_v183/build/slang-uhdm /tmp/v183_pat.bin;  chmod 555 /tmp/v183_pat.bin
cp /tmp/wt_v183pris/build/slang-uhdm /tmp/v183_pris.bin; chmod 555 /tmp/v183_pris.bin

g++ -O2 -std=c++17 ../r10uvm183repro/ct183cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/ct183cen

# the six verifier arms, driven by the pass's own instruments (no copies here)
CT183CEN=/tmp/ct183cen bash ../r10uvm183repro/grid183.sh v183_a_shadow.sv \
    /tmp/v183_pris.bin /tmp/v183_pat.bin /tmp/wd_a
python3 ../r10uvm183repro/score183.py /tmp/wd_a --all
python3 ../r10uvm183repro/stilloff183.py /tmp/wd_a

# the wide boundary over a COPY of tools/probe, then re-score every moved arm
PRI=/tmp/v183_pris.bin PAT=/tmp/v183_pat.bin ROOT=<copy of tools/probe> BWD=/tmp/bnd \
    bash ../r10uvm183repro/bound183.sh
```
