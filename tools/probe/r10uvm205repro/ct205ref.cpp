// r10uvm205 — WHAT § importCloneBareTdAlias16's OWN LISTENER PREDICATE ADMITS
// AND WHAT IT REFUSES, over every `ref_typespec` in a database.
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// § 16's `CloneBodyTdRebind180` walks the design with UHDM's own
// `UhdmListener` and, at every `ref_typespec`, climbs the CALLSTACK outward
// looking for the innermost enclosing subroutine:
//
//     for (i = cs.size()-2; i >= 0; --i)
//        function/task   -> rebind if it is a wildcard-import clone; stop
//        class_defn      -> stop, refuse
//        any typespec    -> stop, refuse          <-- THE FENCE THIS PASS WIDENS
//
// This probe re-implements that climb VERBATIM and reports, for every ref
// whose bound typespec is a LAW-S scalar-typedef kind, which branch decided
// it.  With `--wide` it also reports the widened predicate (an ARRAY-shaped
// typespec — `array_typespec` / `packed_array_typespec` — is walked THROUGH
// instead of stopping the climb) so the two populations can be subtracted.
//
// The interesting sub-population is printed separately: a ref whose bound
// typespec ALREADY carries LAW S's bare name but whose `Typedef_alias` target
// is still QUALIFIED — the exact cell shape § 180 repairs
// (`gold=[t -> t]` against `ours=[t -> pkg::t]`).
//
// build: g++ -O2 -std=c++17 ct205ref.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct205ref
// usage: ct205ref <db.uhdm> [--wide] [--list] [--edge=NAME]
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static bool scalarTdKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmlogic_typespec: case uhdmbit_typespec: case uhdmint_typespec:
        case uhdminteger_typespec: case uhdmbyte_typespec:
        case uhdmshort_int_typespec: case uhdmlong_int_typespec: return true;
        default: return false;
    }
}
static bool arrayShaped(UHDM_OBJECT_TYPE t) {
    return t == uhdmarray_typespec || t == uhdmpacked_array_typespec;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static const char* shapeOf(std::string_view n) {
    if (n.empty()) return "NONAME";
    return n.find("::") == std::string_view::npos ? "BARE" : "QUAL";
}

class L16 final : public UhdmListener {
  public:
    bool wide = false, list = false;
    const char* edge = nullptr;
    std::map<std::string, long> tally;      // verdict|namesShape
    std::map<std::string, long> fixable;    // verdict for the [BARE -> QUAL] shape

    // § 16's climb, verbatim, plus the widened variant behind `wide`.
    // Returns the verdict and, when it stopped at a subroutine, its name.
    const char* verdict(const std::vector<const any*>& cs, bool wideMode,
                        std::string& tf, const any* retOwner) {
        for (int i = (int)cs.size() - 2; i >= 0; --i) {
            const UHDM_OBJECT_TYPE k = cs[i]->UhdmType();
            if (k == uhdmfunction || k == uhdmtask) {
                auto* f = (const task_func*)cs[i];
                tf = std::string(cs[i]->VpiName());
                if (i + 1 < (int)cs.size() && cs[i + 1] == retOwner)
                    return "TF-RETURNVAR";
                (void)f;
                return "TF";
            }
            if (k == uhdmclass_defn) return "BAIL-CLASS";
            if (any_cast<const typespec*>(cs[i])) {
                if (wideMode && arrayShaped(k)) continue;
                return arrayShaped(k) ? "BAIL-ARRAYTS" : "BAIL-TS";
            }
        }
        return "NO-OWNER";
    }

    void enterRef_typespec(const ref_typespec* const o) override {
        const typespec* at = o->Actual_typespec();
        if (!at || !scalarTdKind(at->UhdmType())) return;
        const auto& cs = getCallstack();
        std::string tf, tfw;
        // the return-variable exception needs the owning function's Return()
        const any* retOwner = nullptr;
        for (int i = (int)cs.size() - 2; i >= 0; --i) {
            auto k = cs[i]->UhdmType();
            if (k == uhdmfunction) {
                retOwner = (const any*)((const function*)cs[i])->Return();
                break;
            }
            if (k == uhdmtask || k == uhdmclass_defn) break;
        }
        const char* v = verdict(cs, false, tf, retOwner);
        const char* vw = wide ? verdict(cs, true, tfw, retOwner) : v;
        const ref_typespec* al = at->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        std::string aln = tg ? std::string(tg->VpiName()) : std::string();
        const char* as = tg ? shapeOf(aln) : "NOALIAS";
        char e[256];
        snprintf(e, sizeof e, "%-14s wide=%-14s ts=%s alias=%s", v, vw,
                 shapeOf(at->VpiName()), as);
        tally[e]++;
        const bool fix = !strcmp(shapeOf(at->VpiName()), "BARE") &&
                         !strcmp(as, "QUAL");
        if (fix) {
            // THE INNERMOST package OUTWARD FROM THE REF — never the
            // outermost.  `UhdmListener`'s `visited` set makes the callstack
            // whichever containment path reached the object FIRST, so on
            // SeqDriver the stack root is always `uvm_pkg` no matter whose
            // body the ref is in; only the innermost enclosing package names
            // the listing that owns it (a wildcard-import CLONE body sits
            // under the IMPORTING package, a home body under the declaring
            // one).
            std::string pkg("-");
            for (int i = (int)cs.size() - 2; i >= 0; --i)
                if (cs[i]->UhdmType() == uhdmpackage) {
                    pkg = std::string(cs[i]->VpiName());
                    break;
                }
            // WHAT HOLDS THE ARRAY.  For a ref the § 16 climb refuses at an
            // array typespec, the object one step OUTSIDE the outermost such
            // typespec is the declaration (or expression) that owns the whole
            // chain — the anchor a declaration-driven law would start from.
            std::string holder("-");
            {
                int i = (int)cs.size() - 2;
                for (; i >= 0; --i) {
                    auto k2 = cs[i]->UhdmType();
                    if (arrayShaped(k2) || k2 == uhdmref_typespec) continue;
                    break;
                }
                if (i >= 0) holder = std::string(UhdmName(cs[i]->UhdmType()));
            }
            snprintf(e, sizeof e, "%-14s wide=%-14s pkg=%-10s holder=%s", v, vw,
                     pkg.c_str(), holder.c_str());
            fixable[e]++;
            if (list)
                printf("FIXABLE %-14s wide=%-14s pkg=%-12s tf=%-40s ts=%s -> %s\n",
                       v, vw, pkg.c_str(), (tf.empty() ? tfw : tf).c_str(),
                       std::string(at->VpiName()).c_str(), aln.c_str());
        }
        if (edge && std::string(at->VpiName()).find(edge) != std::string::npos) {
            printf("EDGE %s wide=%s ts=%s -> %s  callstack tail:\n", v, vw,
                   std::string(at->VpiName()).c_str(), aln.c_str());
            for (int i = (int)cs.size() - 1, n = 0; i >= 0 && n < 8; --i, ++n)
                printf("     [-%d] %s name='%s' @%u:%u\n", n,
                       UhdmName(cs[i]->UhdmType()).data(),
                       std::string(cs[i]->VpiName()).c_str(),
                       cs[i]->VpiLineNo(), (unsigned)cs[i]->VpiColumnNo());
        }
    }
};

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct205ref <db> [--wide] [--list] [--edge=N]\n"); return 2; }
    L16 l;
    for (int i = 2; i < argc; i++) {
        if (!strcmp(argv[i], "--wide")) l.wide = true;
        else if (!strcmp(argv[i], "--list")) l.list = true;
        else if (!strncmp(argv[i], "--edge=", 7)) l.edge = argv[i] + 7;
    }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN\n"); return 3; }
    l.listenDesign(d);
    printf("\nALL SCALAR-TD REFS BY VERDICT:\n");
    for (auto& [k, v] : l.tally) printf("  %-70s %8ld\n", k.c_str(), v);
    printf("\nTHE [BARE -> QUAL] SHAPE (§ 180's repair target) BY VERDICT:\n");
    for (auto& [k, v] : l.fixable) printf("  %-70s %8ld\n", k.c_str(), v);
    return 0;
}
