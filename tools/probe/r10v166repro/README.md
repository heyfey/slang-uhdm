# r10uvm166 — VERDICT: **ACCEPT AS SHIPPED**. No fix needed; `/tmp/r10uvm166.patch` stands unchanged (no `.verified.patch` produced, because nothing broke).

I rebuilt both binaries from scratch, re-ran every gate, re-ran the implementer's own grid/census/boundary, and then attacked the law with **six adversarial arms of my own** covering every collision face, target kind, home and use site the brief names. **Zero AWAY, zero WRONG, zero RESHAPE-AWAY anywhere.** One residue the implementer did not name is ranked below (R3, `vpiAutomatic` at SITE 2) — it is *not* a regression, and I proved that from the pristine databases.

---

## 1. BIT-FOR-BIT REPRODUCTION (my own worktrees `/tmp/wt_v166` + `/tmp/wt_v166pris` at `4fbf5d0`)

| claim | implementer | my independent measurement |
|---|---|---|
| pristine md5 | `3002e867e7137c2e5b2e2236d846dc2f` | **identical** |
| patched md5 | `8dc9d834176c7467f397b10f9d1f23d4` | **identical** |
| production diff | +262 / −0, additive | **+262 / −0** (12 + 164 + 21 + 65) |
| patch applies on fresh `4fbf5d0` | clean | **`git apply --check` rc=0**, no `-3` needed |
| surface | 4 production + `r10uvm166repro/` | **confirmed** (3 dirs only: `include`, `src`, `tools/probe/r10uvm166repro`) |
| fence check | 0/0/0/0 | **0/0/0/0** |
| SeqDriver ×2 + SimpleUVM ×2 head | 82 → 338 | **82 → 338, 1 head each** |
| Scoreboard/MiniAmiq/BuildUVMPkg/Earlgrey/Rggen | unchanged | **145/106/29/34/0, head logs byte-identical pristine↔patched** |
| all 8 committed `head_pris_*`/`head_pat_*.cmp` | evidence | **byte-identical to my freshly produced logs** |
| grid, 5 arms × 2 views | 57 TOWARD + 22 RESHAPE-TOWARD, 0 AWAY/WRONG | **10+10+2+35+0 = 57 TOWARD, 0+10+2+10+0 = 22 RT, 0 AWAY, 0 WRONG** |
| family census, 9 UVM DBs | 14 TOWARD, 0 AWAY/WRONG | **14 TOWARD (2 per row × 7), 0 AWAY, 0 WRONG** |
| boundary | `LISTED=4668 PROCESSED=4668 PRODUCED_DBS=4512 MOVED_ARMS=9 RC_DIFFS=0` | **exactly that string** |
| the 5 `r10vbuvm22` boundary movers | 109 TOWARD + 11 RESHAPE-TOWARD, 0 AWAY/WRONG | **29+15+26+27+12 = 109 TOWARD, 4+0+7+0+0 = 11 RT, 0 AWAY, 0 WRONG** |
| movers | 7/956 surelog, 0/1358 u2r | **7/956 (the same 7 names), 0/1358** |

**MUST-STAY CONTROLS — every one listed by the boundary and NOT in `MOVERS`:** `r10uvm155repro` (5 arms), `r10v155repro` (9), `r10uvm157repro` (5), `r10uvm164repro` (4), `r10uvm146repro` (7), `r10uvm114repro` (8), `r10uvm89repro` (2), `r10buvm14repro` (1), `r10uvm91repro` (5), and the 27 arms whose names carry `v98`. **uvm155's import fix and program carve-out are untouched — the diff deletes nothing.**

## 2. GATES — all green, both binaries, audited by binary path

* goldens **23 PASS / 0 FAIL** on pristine AND patched (`SLANG_UHDM` exported per binary); `/bin/false` → **0 PASS / 23 FAIL**.
* `ct8rows` **PASS** for: committed `golden_surelog.csv` vs patched; vs pristine; my pristine vs my patched; `gate_uhdm2rtlil.csv` vs patched; u2r tf and def pristine vs patched. **No row converted; `results/*.csv` never written.**
* surelog status histograms **byte-identical** pristine↔patched (937 CMP_EQUAL, 19 CMP_NOTEQUAL, 35+4+4 SURELOG_FAIL, 10 DEFERRED…); u2r **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in both modes on both binaries.
* **no `rc=139` anywhere** in 1523+1523+1458+1458 recorded invocations.
* `cmds.txt` audit **by binary path**: `slp` 1523 × `/tmp/v166_bin/pris.bin`, `slq` 1523 × `pat.bin`, `u2rp` 1458 × `pris.bin`, `u2rq` 1458 × `pat.bin`. **0 main-tree, 0 worktree-`build/` leakage.**
* canaries `ok=52 changed=0` / `ok=8 changed=0`; `ctcan2` PASS ×2; `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`.
* protected DBs: InterfaceModPort / BlackParrotComplex / YosysOldOr SAME in both modes; **SVSwitch `4842211c4030`**, **YosysVerx `6ccda350c24a`** held.
* main tree `git status --short` = **0 rows** at start and end; I wrote only inside my worktrees and `/tmp/v166_*`.

**Mover attribution, order-blind, all 7** (uhdm-dump, workdir path and `id:` normalised, both sides sorted): **98 differing lines each, and `lines_outside_law_names = 0` for every one** — every line names `uvm_utils::find`, `uvm_utils::find_all`, or `array_typespec (types_t)`. `default/Scoreboard-59431470`, the ~50/50 coin, is 98 lines out of 1,100,404 — **the coin did not flip on my run either**, so it adds nothing to attribute.

**R0 confirmed by direct count**: the new head `method_func_call: (uvm_report_fatal)` @`uvm_misc.svh:720:14` — LHS 10 `vpiArgument` mentions (5 args × 2 decompiles), RHS 14 (**7 args**). A `vpiArgument` vector-size mismatch, exactly as reported.

## 3. BREAKING THE LAW — six arms of mine, `0 AWAY / 0 WRONG / 0 RESHAPE-AWAY`

Every arm built its own Surelog golden (`-parse -nocache -nowritecache -noprecompiledcache -d coveruhdm [-elabuhdm]`), both views, both frozen binaries, every command echoed with its binary path and its rc, judged by the **official `uhdm-cmp`** and censused by `ct166cen`/`score166.py`.

| arm (`/tmp/v166_arms/`) | what it attacks | cmp lines def/elab, pris → pat | score |
|---|---|---|---|
| `v166_a_use.sv` | index select, member select through the select, `foreach` (queue + assoc), `.size()/.push_back()/.push_front()/.delete()/.exists()`, whole-array assign both ways, initialised decl, `ref`/`input` args, return-by-value, **3 declarators off one declaration**, nested `begin` / fork arm / for body / case item, out-of-body method + its nested begin, package-home decline | **82→17 / 86→17** | TOWARD **53**, RT 2, **AWAY 0, WRONG 0** |
| `v166_b_collide.sv` | **every collision face the brief names**: two methods of one class with the same statement typedef (same target *and* different target), two classes, class vs package, class vs module, class vs program, statement typedef shadowing a real typedef, **four registrations of one name in four homes**, an imported class, a program's `initial`, a UNIQUE statement typedef, forward typedefs, the typedef name also naming a variable and a function | **82→82 / 86→86** (head unchanged; only `id:` renumbering) | TOWARD **22**, RT 10, **AWAY 0, WRONG 0** |
| `v166_c_base.sv` | the base-spelling axis: concrete class handle, named enum, named packed struct, named **unpacked** struct, typedef-of-`int`, typedef-of-typedef-of-`int`, typedef-of-`string`, typedef-of-packed-vector, typedef-of-class-handle, type parameter, **scoped base `pkg::T`**, queue-of-a-queue-typedef; vs `int`/`string`/`real`/`bit[7:0]`/inline-enum/inline-struct declines. Target kinds: queue, dynamic, assoc(string/int/**type-param key**), fixed(literal/**parameter-sized**/**2-dim**). `static`, `automatic`, with-initialiser. Two specialisations of one generic class, a **derived** class naming the base's typedef, a **nested** class | **700→700** (head is an unrelated `Elem_typespec` residue in both) | TOWARD **76**, RT 9, **AWAY 0, WRONG 0**; all 6 declines **STILL** |
| `v166_d_nasty.sv` | array methods with a `with` clause (`find`, `sum`), `$size/$dimensions/$left/$right`, `$display("%p", q)`, assignment pattern, queue concatenation, **while / do-while / repeat / forever bodies**, assoc `first/next/last/prev/exists/delete/num`, bounded queue `[$:7]`, virtual class + `pure virtual` override, a class inside an **interface**, the typedef name re-used as a local variable name | **36→36** | TOWARD **49**, RT 7, **AWAY 0, WRONG 0** |
| `v166_e_auto.sv` | **`vpiAutomatic`, a cmp-READ field on `variables`** (`UHDM/build/generated/src/variables.cpp:256`) that `score166.py`'s payload does NOT carry — at both sites, in a function / a `static` function / a task / an `automatic` method, plus R1's paren-less function | **384→58 / 458→58** | TOWARD **43**, **AWAY 0, WRONG 0** |
| `v166_f_homes.sv` | a class in the **compilation unit** (`$unit`), an **interface-class** implementor, a **constructor** body, a `rand`/constraint class, a **`virtual` interface** base | **1090→1030 / 1302→1158** | TOWARD **11**, RT 1, **AWAY 0, WRONG 0** |

**Adversarial total: TOWARD 254, RESHAPE-TOWARD 29, AWAY 0, WRONG 0, RESHAPE-AWAY 0.**

Three findings worth recording from these arms:

1. **The class-home gate is right, not merely narrow.** A class living inside a **module** (`work@cb166_mod::InMod166`), inside a **program** (`work@cb166_prog::InProg166`), inside an **interface** (`dn166_if::InIf166`), and in **`$unit`** (`work@Unit166`) all fire and all score TOWARD. Golden degrades for the class in every container — the container is irrelevant, the typedef's own home is everything, which is what the code asks.
2. **SITE 1's `vpiAutomatic` handling is exactly golden's, 7 cells out of 7** (`v166_e_auto`, nested `begin` in a function / `static` function / task / `automatic` method): golden `ref_var` auto=1 on the written-`automatic` declarations and auto=0 on the plain ones; patched matches every cell. Pristine put the flag on the element `class_var` and 0 on the `array_var` — the patch moves it onto the object golden carries it on.
3. **The `Owner::td` decline is load-bearing and correct** — `cb166_imp::impFn166`'s `cb166_pkg::real166_t r166;` declines, `pkgUse166`'s package-homed `pkgq166_t` declines, and the pristine answer is preserved verbatim for both.

## 4. RANKED RESIDUES (measured, none blocking)

* **R0** — the new head: `uvm_report_fatal`'s argument vector carries the callee's remaining defaulted formals (7 args) where golden carries only the 5 written. Confirmed by count; four row-modes.
* **R1** — paren-less function body (`blockItems9` declines SITE 2). `v166_e_auto` `noParen166::pv166`: golden `ref_var` auto=1, ours still the flat `class_var` auto=1. Unchanged by the patch, as claimed.
* **R2** — a statement-scope typedef that is itself an array, named bare: golden `ref_var` + `unsupported_typespec`. Intersection of this law and § `blockLocalTdDeclIsRefVarUnsupported155`. Unchanged.
* **R3 — NEW, found by me, NOT a regression.** At **SITE 2** the minted `ref_var` never receives `VpiAutomatic`, and `variables::Compare` READS that field. `v166_e_auto` `Auto166::tf166::fAuto166` (`automatic aq166_t fAuto166;` as a TF-item): **golden `ref_var` auto=1, patched `ref_var` auto=0**. I checked the pristine database before attributing it: pristine's `array_var` carries auto=0 **and its element `class_var` carries auto=0 too**, so no object was ever right — the cell was failing on `VpiType` before and now fails one field later on `VpiAutomatic`. **Off-corpus**: `uvm_utils::find`/`find_all`'s `types_t types;` writes no `automatic` keyword and is a SITE 1 block item, which is why the corpus head cleared completely. The fix, when this family is next opened, is to give SITE 2 the same `writtenAutomaticKw80` question SITE 1 already asks — but SITE 2's three existing array factories do not ask it either, so it is that site's law to change, not this one's.
* **R4 — NEW, minor.** `v166_f_homes` `work@Unit166::new::cq166` (a `$unit`-homed class **constructor** body local) scores `ONLY-O-MOVED`: Surelog lists no such cell at all, so cmp cannot judge it; our side went `array_var` → `ref_var`. Consistent with the law, unjudgeable, and 0 cells on either corpus.
* Unchanged and correctly declined, verified against golden rather than assumed: keyword base, inline enum/struct base, `virtual` interface base, module/interface/program **typedef home** (our typespec there is a `bit_typespec` — fix the typespec first), package home's DEF/ELAB split, package typedef of an array of class handles, dims on the declarator, class property, formal, `$unit` typedef home.
* **Documentation nit (no action required):** the pass README §3 says "`src/TaskFuncEmit.cpp` **+66/−0**" and "**+263 / −0**"; `git diff --numstat 4fbf5d0` measures **+65** and **+262**. The report's own headline figure (+262) is the correct one.

## 5. EVIDENCE

Worktrees `/tmp/wt_v166` (patched) and `/tmp/wt_v166pris` (pristine, still clean at `4fbf5d0`); frozen binaries `/tmp/v166_bin/{pris,pat}.bin` (`chmod 555`); sweep workdirs `/tmp/v166_wd/{slp,slq,u2rp,u2rq}` with their CSVs; head logs `/tmp/v166_wd/heads_{pris,pat}/`; mover attributions `/tmp/v166_wd/attrib/*/d.txt`; family census `/tmp/v166_wd/cen/`; grid reruns `/tmp/v166_wd/grid_g166_*`; the 4668-arm boundary `/tmp/v166_wd/bnd/{LISTED,MOVERS}` + `/tmp/v166_wd/bnd.log`; the `r10vbuvm22` re-measurement `/tmp/v166_wd/vb22/`; my six arms and their drivers `/tmp/v166_arms/{v166_[a-f]_*.sv,armjudge.sh,attrib.sh}` with per-arm databases and cmp logs under `/tmp/v166_wd/arms/`; arm tally `/tmp/v166_wd/ARMS.txt`.