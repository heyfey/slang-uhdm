// r10uvm164 — THE OWNER-FINDER, MIRROR FORM.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge; this tool links the
// SAME generated `Compare` and only reports.  LHS is ALWAYS golden (Surelog),
// RHS is ALWAYS ours.
//
// r10uvm161's `ct161own.cpp` finds the owner of a head whose LHS is present
// (`RHS: <null>`): BaseClass.h's SINGULAR SafeCompare (`:191-193`) names the
// VALUE, and the tool scans GOLDEN's edges for the one that lands on it.  THIS
// head is the OTHER half of that same overload — `LHS: <null>` with a full RHS,
// the MIRROR — so the object the judge stopped on lives in OUR database and the
// scan has to run the other way round: enumerate every edge of every object in
// OURS that lands on the head, then print the SAME edge of golden's
// counterpart, matched by face (kind + name + span) and ancestor-face path.
// `GetByVpiType` is the generated, kind-agnostic edge accessor, so no field is
// named by hand and no edge can be missed by omission.
//
// STEP 2 additionally lists, for a named FUNCTION, EVERY reference in its body
// on both sides with the cast wrapper above it — the question this pass exists
// to answer.
//
// build: g++ -O2 -std=c++17 ct164own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct164own
// usage: ct164own <golden.uhdm> <ours.uhdm> [<function name substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <string>
#include <algorithm>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static std::string parentPath(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
        s += ":";
        s += std::to_string(p->VpiLineNo());
    }
    return s;
}
static bool sameFace(const BaseClass* a, const BaseClass* b) {
    return a->UhdmType() == b->UhdmType() &&
           std::string(a->VpiName()) == std::string(b->VpiName()) &&
           a->VpiLineNo() == b->VpiLineNo() &&
           a->VpiColumnNo() == b->VpiColumnNo() &&
           a->VpiEndLineNo() == b->VpiEndLineNo() &&
           a->VpiEndColumnNo() == b->VpiEndColumnNo();
}
// The cast wrapper chain above a reference, innermost first (see ct164cen.cpp
// for the decode: `vpiCastOp` 67 and the `$signed`/`$unsigned` sys_func_call
// the SAME `paCast` arm mints).
static std::string castChain(const BaseClass* o) {
    std::string c;
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 64;
         p = p->VpiParent(), ++guard) {
        if (const operation* op = any_cast<const operation*>(p)) {
            if (op->VpiOpType() == vpiCastOp) { c += c.empty() ? "" : ">"; c += "castop"; }
            continue;
        }
        if (p->UhdmType() == uhdmsys_func_call) {
            const std::string n(p->VpiName());
            if (n == "$signed" || n == "$unsigned") { c += c.empty() ? "" : ">"; c += "signcast"; }
            continue;
        }
        if (p->UhdmType() == uhdmref_obj || p->UhdmType() == uhdmbit_select ||
            p->UhdmType() == uhdmpart_select || p->UhdmType() == uhdmhier_path ||
            p->UhdmType() == uhdmfunc_call || p->UhdmType() == uhdmmethod_func_call)
            continue;
        break;
    }
    return c.empty() ? "-" : c;
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    if (const chandle_var* r = any_cast<const chandle_var*>(o)) return r->Actual_group();
    return nullptr;
}
static bool isRef(const BaseClass* o) {
    return any_cast<const ref_obj*>(o) || any_cast<const ref_var*>(o) ||
           any_cast<const chandle_var*>(o);
}
// Does `o` sit inside the function whose name contains `want`?
static const BaseClass* enclosingFn(const BaseClass* o, const char* want) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
            const std::string n(p->VpiName());
            if (n.find(want) != std::string::npos) return p;
            return nullptr;
        }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct164own <golden> <ours> [fn]\n"); return 2; }
    const char* fnWant = argc > 3 ? argv[3] : nullptr;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS(golden) = %s\n", ident(c.m_failedLhs).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(c.m_failedRhs).c_str());
    const BaseClass* HR = c.m_failedRhs;

    // ---- STEP 1 — THE MIRROR SCAN --------------------------------------
    if (HR) {
        printf("HEAD RHS parent chain:\n");
        for (const BaseClass* p = HR->VpiParent(); p; p = p->VpiParent())
            printf("    < %s\n", ident(p).c_str());
        printf("MIRROR REFERENCE SCAN — every edge of OURS that lands on the head, and golden's:\n");
        for (auto& kv : so.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            for (int t = 1; t <= 2100; ++t) {
                auto tup = X->GetByVpiType(t);
                const BaseClass* one = std::get<0>(tup);
                const std::vector<const BaseClass*>* vec = std::get<2>(tup);
                int idx = -1;
                if (one == HR) idx = -2;
                if (vec)
                    for (size_t i = 0; i < vec->size(); ++i)
                        if (vec->at(i) == HR) idx = (int)i;
                if (idx == -1) continue;
                printf("  ours   %s\n      edge vpiType=%d %s   cast=%s\n",
                       ident(X).c_str(), t,
                       idx == -2 ? "(singular)"
                                 : ("(vector index " + std::to_string(idx) + ")").c_str(),
                       castChain(X).c_str());
                int nm = 0;
                for (auto& kv2 : sg.AllObjects()) {
                    const BaseClass* Y = kv2.first;
                    if (!Y || !sameFace(X, Y) || parentPath(X) != parentPath(Y)) continue;
                    ++nm;
                    auto tu2 = Y->GetByVpiType(t);
                    const BaseClass* o2 = std::get<0>(tu2);
                    const std::vector<const BaseClass*>* v2 = std::get<2>(tu2);
                    if (idx == -2)
                        printf("      golden %s -> singular %s\n", ident(Y).c_str(),
                               ident(o2).c_str());
                    else
                        printf("      golden %s -> vector %s size %zu, [%d] = %s\n",
                               ident(Y).c_str(), v2 ? "present" : "NULL",
                               v2 ? v2->size() : 0, idx,
                               (v2 && (size_t)idx < v2->size()) ? ident(v2->at(idx)).c_str()
                                                                : "-");
                }
                if (!nm) printf("      golden NO COUNTERPART for the referrer\n");
            }
        }
    }

    // ---- STEP 2 — EVERY REFERENCE IN THE NAMED FUNCTION, BOTH SIDES -----
    if (fnWant) {
        printf("REFERENCES IN FUNCTION MATCHING \"%s\" — golden then ours:\n", fnWant);
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || !isRef(o)) continue;
                const BaseClass* fn = enclosingFn(o, fnWant);
                if (!fn) continue;
                char b[1200];
                const std::string val =
                    actualOf(o) ? ("BOUND -> " + ident(actualOf(o))) : std::string("BARE");
                snprintf(b, sizeof b, "    %4u:%-3u %-14s cast=%-16s %s",
                         o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                         std::string(o->VpiName()).c_str(), castChain(o).c_str(),
                         val.c_str());
                rows.push_back(b);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s : rows) printf("%s\n", s.c_str());
            if (rows.empty()) printf("    (no references found)\n");
        }
    }
    return 0;
}
