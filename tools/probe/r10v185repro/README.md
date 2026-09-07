# r10v185 — the adversarial verification of r10uvm185

**VERDICT: ACCEPT WITH FIX.** The pass's headline numbers all reproduce
bit-for-bit from binaries this verifier built itself. Its law is right about the
head and right about every cell its own grid carries. On **two axes its decode
never entered — INHERITANCE and the WRITTEN-SCOPE-vs-OWNER split — it moves
legal-SV cells off golden**, one of them from a PRISTINE-RIGHT answer. Both are
fixed here by two terms inside the pass's own helper, at zero corpus cost:
the verified binary produces databases **byte-identical to the pass's patched
binary on all 956 surelog and all 1358 uhdm2rtlil databases and on all 19
committed arms its own boundary reported as moved**.

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge;
the official `uhdm-cmp` and `scripts/verify_golden.py` are. slang was **NOT**
patched, `results/*.csv` were **READ ONLY**, **no corpus row was converted**,
`GOLDEN_DEFER` stayed unset, and the four slang-fenced tests were never
dispatched. **LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

| | |
|---|---|
| BASE | `b71d5feb` |
| pristine | md5 `bc09e77cf8fd251285c06f6f0b54a5bc` — built here from a clean `b71d5feb`, **byte-identical to the master's frozen pristine** and to the md5 the pass reported |
| the pass's patched | md5 `888a51d91d62274dde0c4843f008c488` — the md5 the pass reported, REPRODUCED from a fresh apply |
| verified | md5 `88fb50c8b3f8c2a38bafbba57bd00b23` |
| the V-FIX surface | `src/EmitHelpers.h` only — two terms inside `externProtoRetVarKind185`, the function the pass added |
| the verifier's probe surface | `tools/probe/r10v185repro/` only |

---

## 1. WHAT REPRODUCED, BIT FOR BIT

Every one of these was re-measured from binaries this verifier built and froze,
with `SLANG_UHDM` exported explicitly per binary and **every `cmds.txt` audited
by PATH** (1523 surelog + 1458 uhdm2rtlil rows naming the frozen binary; the
only other paths in them are golden CACHE entries).

* **Both md5s.** The pristine came out byte-identical to the master's; the
  patched came out at the pass's own `888a51d9…`.
* **The head.** Pristine `rowheads.sh`: BuildUVMPkg **52 / 52, ONE head each**.
  Patched: **48 / 48, ONE head each**, both modes' databases byte-identical to
  each other. Every other row unchanged (SeqDriver 29, SimpleUVM 664681,
  Scoreboard/default 95, MiniAmiq 29, Earlgrey 31/364, Rggen 0).
* **The head object.** The workdir-normalised `uhdm-dump` diff of
  BuildUVMPkg/default, pristine vs patched, is **four lines, ordered and sorted
  alike**, and they are ONE object printed twice:
  `class_var` → `enum_var` on `uvm_pkg::uvm_printer::object_printed`.
* **`ct8rows` 0 differing rows** — both corpora, both modes, status AND dump
  column — against the committed baselines, against the `b71d5feb` controls,
  and against this verifier's own pristine sweep.
* **Byte movers**: surelog **2 / 956** (BuildUVMPkg ×2, the pass's own hashes
  `bbf172cd412b <- 5c6a62b63407`), uhdm2rtlil **0 / 1358**.
* **Scoreboard/default did not move in ANY of this verifier's three sweeps** —
  independent corroboration that the pass's third mover was RESUME.md §9's coin
  and not its law.
* **The census, re-derived independently** (`vcen185.py` over `ct185cen` rows,
  multiset-joined, split by the `stmt` axis): PROTOTYPE arm **KIND-DIFF 2 → 0**,
  the two being BuildUVMPkg default and testflags on the SAME cell
  (`uvm_pkg::uvm_printer::object_printed` 19055:3, golden `enum_var`, ours
  `class_var`); the DEFINITION arm's per-row AGREE counts identical on all three
  binaries.
* **The pass's own grid**, re-run here with its own driver: **TOWARD 104,
  AWAY 0, MOVED-WRONG 0, STAY-BAD 12**.
* **Canaries**: sl ok=52 changed=0, u2r ok=8 changed=0, `ctcan2` PASS ×2,
  `canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0`; SVSwitch `4842211c4030`,
  YosysVerx `6ccda350c24a`, the three byte-identical databases SAME.

Full numbers: `GATES.r10v185.txt`.

---

## 2. WHAT BROKE — the two axes the decode did not enter

The pass's law says: in the class-body PROTOTYPE listing of an `extern` method,
ask § `classTdLocalVarKindFollowsCompileOrder10` about the **MethodPrototypeSymbol**
instead of the out-of-body definition. That is right, and it is why the head
cleared. But law 10's two arms were written for sites where the return typedef
is either the compiling class's OWN or a SIBLING's named through the sibling's
own scope. The PROTOTYPE listing is the first site that also reaches
**INHERITED** typedefs, and there both arms answer wrongly.

Five arms, both views, package scope and module scope, in BOTH sort directions
so that no cell can agree merely because the names happened to sort the right
way (`GRIDS.r10v185.txt` carries every cell):

|  | TOWARD | AWAY | MOVED-WRONG | STAY-BAD |
|---|---|---|---|---|
| the pass's patch | 52 | **16** | **22** | 3 |
| the verified patch | **74** | **0** | **0** | 3 |

### 2.1 AWAY — `<derived>::<a typedef it inherited>` (5 distinct cells)

```
class ab_m185;                    typedef enum { MA0, MA1 } m_enum;   endclass
class cd_m185 extends ab_m185;
  extern function cd_m185::m_enum m_self_enum();     // legal SV
endclass
```

|  | golden | pristine | the pass's patch |
|---|---|---|---|
| `pm185::cd_m185::m_self_enum` | `class_var` | `class_var` | `enum_var` |
| `pm185::cd_m185::m_self_rec` | `class_var` | `class_var` | `struct_var` |
| `pm185::cd_m185::m_self_int` | `class_var` | `class_var` | `int_var` |
| `work@top185m::cmod185::m_mod_self_enum` (module scope) | `class_var` | `class_var` | `enum_var` |
| `pi185::cd_der185::i_inh_selfscoped_enum` | `class_var` | `class_var` | `enum_var` |

PRISTINE-RIGHT → PATCHED-WRONG, on legal SV, in both views.

**Why.** Surelog's `paClass_scope` arm rebuilds ONE key **from the segment as
written** and looks the leaf up in **that** container's own map — there is no
inheritance walk — so `cd_m185::m_enum` finds nothing and golden takes
`if (var == nullptr) var = s.MakeClass_var();`. Law 10's scoped arm checks that
the OWNER is reachable and sorts early, but never that the **written segment
names the owner**; for every site it governs today the two coincide, and the
prototype listing is the first site where they come apart.

### 2.2 MOVED-WRONG — a BARE inherited typedef (7 distinct cells)

```
class ab_base185;                    typedef enum { AB0, AB1 } ab_enum; endclass
class cd_der185 extends ab_base185;
  extern function ab_enum i_inh_bare_enum();         // the inherited lookup
endclass
```

golden `ref_var` on every one; pristine `class_var`; the pass's patch the
RESOLVED kind (`enum_var` / `struct_var` / `int_var`):
`i_inh_bare_enum`, `i_inh_bare_rec`, `i_inh_bare_alias`, `i_inh_bare_int`,
`der_q185::l_virtual` (a virtual OVERRIDE), `ck_der185::k_inhspec_bare`
(inheriting from a SPECIALIZATION), `cmod185::m_mod_bare_inh` (module scope).

**Why.** `component->getDataType(typeName)` is a lookup in the class
component's OWN datatype map and does not walk the base chain, so an inherited
typedef is not found and the switch falls through to `CompileType.cpp:421`'s
bare `MakeRef_var` — the same object the pass's own term 4 names, for the same
reason. Law 10's bare arm answers this cell by its SIBLING-ORDER term instead;
its own comment records inheritance as the one way a bare name reaches a
non-`self` owner and states that the corpus never separates the two readings.
Once the PROTOTYPE listing is decided by that law, they separate.

The **negative control is in the same arm**: `md_der185::i_late_bare_enum`, the
identical shape with a base that sorts AFTER the derived class, was already
answered `ref_var` by the order term and golden agrees — so the term below
changes what must change and nothing else.

---

## 3. THE FIX — two terms, inside the pass's own function

`src/EmitHelpers.h`, `externProtoRetVarKind185`, after the pass's own
class-owned-typedef gate and its DECLINE rows:

* § `externProtoBareRetReachesOwnTypedefOnly185v` — in the BARE arm, if the
  typedef's owner is not the prototype's own class, the answer is `ref_var`.
* § `externProtoScopedRetMustNameTheOwner185v` — in the SCOPED arm, if the ONE
  written segment (an `IdentifierName`, or a `ClassName` for a specialization)
  does not spell the owner's name, the answer is `class_var`.

Both are stated in the source with the golden cells that convict them and the
controls that must not move. The controls do not move: `m_owner_enum` /
`m_owner_rec` / `i_inh_scoped_enum` / `i_inh_scoped_rec` write the OWNER's own
name for the very same typedefs and stay TOWARD, and `k_spec_early`
(`ak_gen185#(8)::gk_enum`, whose written segment is a `ClassName` node) keeps
resolving.

**The fix's footprint is zero outside those shapes**, measured three ways:
surelog **0 / 956** and uhdm2rtlil **0 / 1358** movers verified-vs-patched; all
**19** committed arms the boundary reported as moved **byte-identical** under
the two binaries; and the boundary's moved-arm set unchanged, name for name.
Every gate is green on the verified binary (`GATES.r10v185.txt`), the head
stays cleared at **48 / 48, ONE head**, and the pass's own grid still scores
**TOWARD 104 / AWAY 0 / MOVED-WRONG 0 / STAY-BAD 12**.

---

## 4. AXES ENTERED AND WHAT EACH ONE SAID

| axis | arm | result |
|---|---|---|
| INHERITANCE, bare and scoped, both sort directions | `v185_i_inherit.sv` | **broke the law twice** (§2.1, §2.2); fixed |
| written scope vs OWNER, package + module, 3 kinds | `v185_m_selfscope.sv` | **broke the law** (§2.1); fixed |
| intra-class DECLARATION ORDER (typedef after the prototype) | `v185_j_order.sv` | **axis closed by the language** — slang rejects it (rc=3, symmetric), so it carries no cell on either side |
| PARAMETERISATION: a specialization-scoped return (`cls#(8)::T`, a `ClassName` segment), an `extern` prototype inside a generic class, inheritance from a specialization | `v185_k_parm.sv` | one MOVED-WRONG (§2.2); the two specialization-scoped cells were already TOWARD and stay TOWARD |
| method QUALIFIERS (static / virtual / protected / local / a virtual override) | `v185_l_quals.sv` | qualifiers change nothing; the override's inherited bare return was MOVED-WRONG (§2.2) |
| NAME CASE (`Ax185` sorting before `ax185`) and a typedef LEAF-NAME COLLISION between two classes | `v185_l_quals.sv` | both answered correctly by the patch and by the fix |
| DEF vs ELAB | every arm, both views | every finding above reproduces in both |
| the whole committed probe tree | 5027 arms, both views | `BOUNDARY.r10v185.txt` |

---

## 5. RESIDUES, ranked

* **R-V1 — the IN-BODY twin of §2.2.** `v185_i_inherit.sv`
  `i_body_bare_enum`: an ORDINARY (non-`extern`) method returning a BARE
  INHERITED typedef is golden `ref_var` and ours `enum_var`, on BOTH binaries.
  That is § `classTdLocalVarKindFollowsCompileOrder10`'s in-body arm making the
  same sibling-order mistake at a site this pass does not govern. It is the
  first-ranked residue because the fix above already decodes the rule
  (`getDataType` does not walk the base chain) and the same term would answer
  it — but the in-body arm is law 10's, its population is unmeasured, and
  moving it is a change to a law five sites depend on. Three cells here; the
  corpus population is not measured by this pass and should be censused before
  the term is moved.
* **R-V2 — the pass's R1 stands, re-read.** Golden anchors the prototype
  listing's return variable at the PROTOTYPE's return-type span where we keep
  the definition's (`36:21` vs `40:12`, `19055:27` vs `20364:10`). No generated
  `Compare` reads a line or a column, so the judge cannot see it; every cell in
  this verifier's grid carries the same span split and none of it is scored.
  Correctly measured and correctly deferred.
* **R-V3 — the pass's R2/R3 confirmed unmoved.** `g22.sv` `po_q_int` (golden
  `array_var`, ours `class_var`) and `po_pq_cls` stay STAY-BAD under the
  verified binary, exactly as the pass reported; the DECLINE row is doing what
  it says.
* **R-V4 — one-sided keys.** `v185_m_selfscope.sv`'s module-scope class yields
  golden keys spelled `work@top185m.cmod185::…` against our
  `work@top185m::cmod185::…` (a `.` vs `::` between the module and the class),
  identical on all three binaries — a pre-existing naming residue of the
  module-scoped-class listing, not this law's.
* **R-V5 — the pass's own R4 is unchanged**: its term 4 reuses § 177's shadow
  gate without re-measuring it, and this verifier did not re-measure it either.

---

## 6. HOW TO RE-RUN

```bash
g++ -O2 -std=c++17 ../r10uvm185repro/ct185cen.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/<yours>/ct185cen
PRIS=<pristine> PATCHED=<binary under test> CEN=/tmp/<yours>/ct185cen \
  STAGE=/tmp/<yours>/stage ./vgrid185.sh          # the five arms, both views
python3 vcen185.py <golden.tsv> <ours.tsv> <label>  # the stmt-split census
```

`vgrid185.sh` reuses `../r10uvm185repro/score185.py` and `ct185cen.cpp`
unchanged, so the verifier's arms and the pass's arms are scored by the same
instrument on the same field. Every path is an argument or an environment
variable; nothing is hard-coded.
