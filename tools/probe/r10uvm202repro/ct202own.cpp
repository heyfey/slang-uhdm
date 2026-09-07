// r10uvm202 — THE OWNER-FINDER + JUDGE DECODER for the wildcard-import clone's
// PACKAGE-SCOPE SPECIALISATION-TYPEDEF LOCAL head: golden
// `unsupported_typespec(uvm_reg_field_cb_iter)@1128:10` vs our resolved
// `class_typespec(uvm_pkg::uvm_reg_field_cb_iter)@334:9`.
//
// MEASUREMENT ONLY.  The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge; this tool links the SAME generated `Compare` and only
// reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Derived from r10uvm198repro/ct198own.cpp (owner chain / referrer index /
// mint census / ablation), with the two modes THIS head needs:
//
//   --cls        every `class_typespec` in each database: name, span,
//                vpiClassDefn, vpiTypedefAlias target, vpiInstance and its
//                referrer count.  This answers the SPECIALISATION SHARING
//                question directly — one object per typedef, or ONE object
//                shared by a whole `#(...)` family and renamed.
//   --locals     every VARIABLE DECLARATION of a subroutine whose name carries
//                `::` (an out-of-body class method) that is listed under a
//                PACKAGE — i.e. every clone-body local — with the typespec KIND
//                its declaration binds, keyed and TALLIED BY KIND on both
//                sides.  This is question (1)'s census.
//   --refs --mint --maskall as in ct198own.
//
// build: g++ -O2 -std=c++17 ct202own.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct202own
// usage: ct202own <golden.uhdm> <ours.uhdm> [--refs] [--mint] [--maskall]
//                 [--cls] [--locals] [--pairs=<name>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field { const char* name; int sel; FKind kind; };
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
// UhdmName() returns a string_view over UHDM's table and is NOT guaranteed
// NUL-terminated — the explicit std::string is required (r10earl60).
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static std::string chainStr(const BaseClass* o) {
    std::string r;
    int g = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && g < 24;
         p = p->VpiParent(), ++g) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst &&
            t != uhdmfunction && t != uhdmtask && t != uhdmbegin &&
            t != uhdmnamed_begin)
            continue;
        r += " < ";
        r += std::string(UhdmName(t));
        r += "(";
        r += std::string(p->VpiName());
        r += ")";
    }
    return r;
}
static void chain(const char* tag, const BaseClass* o) {
    printf("  %s owner chain:%s\n", tag, chainStr(o).c_str());
}
static const BaseClass* rel1(const BaseClass* o, const Field& f) {
    if (!f.sel) return nullptr;
    return std::get<0>(o->GetByVpiType(f.sel));
}
static void relv(const BaseClass* o, const Field& f,
                 std::vector<const BaseClass*>& out) {
    if (!f.sel) return;
    if (auto* v = std::get<2>(o->GetByVpiType(f.sel)))
        for (auto* e : *v)
            if (e) out.push_back((const BaseClass*)e);
}
static size_t referrers(const char* tag, Serializer& s, const BaseClass* head,
                        bool print) {
    if (print) printf("  %s referrers of %s:\n", tag, ident(head).c_str());
    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X) continue;
        auto it = kFields.find(std::string(UhdmName(X->UhdmType())));
        if (it == kFields.end()) continue;
        for (const Field& f : it->second) {
            bool hit = false, isvec = false;
            size_t idx = 0;
            if (f.kind == F_REL1) {
                if (rel1(X, f) == head) hit = true;
            } else if (f.kind == F_RELV) {
                std::vector<const BaseClass*> v;
                relv(X, f, v);
                for (size_t i = 0; i < v.size(); i++)
                    if (v[i] == head) { hit = true; isvec = true; idx = i; break; }
            }
            if (!hit) continue;
            ++n;
            if (!print) continue;
            char w[32];
            snprintf(w, sizeof w, "vec[%zu]", idx);
            printf("      REF .%-20s %-9s %s%s\n", f.name, isvec ? w : "rel1",
                   ident(X).c_str(), chainStr(X).c_str());
        }
    }
    if (print) printf("      REFERRERS=%zu\n", n);
    return n;
}
static const BaseClass* tsInstance(const BaseClass* o) {
    auto it = kFields.find(std::string(UhdmName(o->UhdmType())));
    if (it == kFields.end()) return nullptr;
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, "Instance"))
            return rel1(o, f);
    return nullptr;
}
static void mintCensus(const char* tag, Serializer& s, const BaseClass* like) {
    printf("  %s MINT CENSUS for %s named '%s':\n", tag,
           std::string(UhdmName(like->UhdmType())).c_str(),
           std::string(like->VpiName()).c_str());
    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X->UhdmType() != like->UhdmType()) continue;
        if (X->VpiName() != like->VpiName()) continue;
        ++n;
        printf("      OBJ %s inst=%s refs=%zu%s\n", ident(X).c_str(),
               ident(tsInstance(X)).c_str(), referrers("", s, X, false),
               chainStr(X).c_str());
    }
    printf("      OBJECTS=%zu\n", n);
}
// ------------------------------------------------------------------ --cls
// Every class_typespec: is the specialisation family SHARED (one object
// renamed, span borrowed from another typedef) or MINTED per typedef?
static void clsReport(const char* tag, Serializer& s) {
    printf("  %s class_typespec population (name | span | classDefn | alias | inst | refs)\n",
           tag);
    std::vector<const class_typespec*> v;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (X && X->UhdmType() == uhdmclass_typespec)
            v.push_back((const class_typespec*)X);
    }
    std::sort(v.begin(), v.end(), [](const class_typespec* a,
                                    const class_typespec* b) {
        if (a->VpiName() != b->VpiName()) return a->VpiName() < b->VpiName();
        return a->UhdmId() < b->UhdmId();
    });
    std::map<std::string, size_t> spanuse;
    for (auto* c : v)
        spanuse[base(c->VpiFile()) + ":" +
                std::to_string(c->VpiLineNo()) + ":" +
                std::to_string(c->VpiColumnNo())]++;
    for (auto* c : v) {
        std::string cd = "-";
        if (const class_defn* d = c->Class_defn()) cd = std::string(d->VpiName());
        std::string al = "-";
        if (c->Typedef_alias()) {
            const typespec* a = c->Typedef_alias()->Actual_typespec();
            al = a ? std::string(a->VpiName()) : std::string("<null>");
        }
        const std::string sp = base(c->VpiFile()) + ":" +
                               std::to_string(c->VpiLineNo()) + ":" +
                               std::to_string(c->VpiColumnNo());
        printf("    CLS %-46s %-34s defn=%-32s alias=%-32s inst=%-24s refs=%zu spanshare=%zu\n",
               std::string(c->VpiName()).c_str(), sp.c_str(), cd.c_str(),
               al.c_str(),
               c->Instance() ? std::string(c->Instance()->VpiName()).c_str() : "-",
               referrers("", s, c, false), spanuse[sp]);
    }
    printf("    CLASS_TYPESPEC-TOTAL=%zu\n", v.size());
}
// --------------------------------------------------------------- --locals
// Every clone-body local: a variable listed by a subroutine whose name carries
// `::`, under a PACKAGE.  Tallied BY THE TYPESPEC KIND the declaration binds.
static const BaseClass* pkgAbove(const BaseClass* o) {
    for (const BaseClass* p = o; p; p = p->VpiParent())
        if (p->UhdmType() == uhdmpackage) return p;
    return nullptr;
}
static void localsReport(const char* tag, Serializer& s, bool verbose) {
    printf("  %s clone-body locals (subroutine name carries `::`, listed under a package)\n",
           tag);
    std::map<std::string, size_t> tally;
    size_t n = 0;
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X) continue;
        const VectorOfvariables* vars = nullptr;
        switch (X->UhdmType()) {
            case uhdmtask: vars = ((const task*)X)->Variables(); break;
            case uhdmfunction: vars = ((const function*)X)->Variables(); break;
            case uhdmbegin: vars = ((const begin*)X)->Variables(); break;
            case uhdmnamed_begin: vars = ((const named_begin*)X)->Variables(); break;
            case uhdmfork_stmt: vars = ((const fork_stmt*)X)->Variables(); break;
            case uhdmnamed_fork: vars = ((const named_fork*)X)->Variables(); break;
            default: continue;
        }
        if (!vars) continue;
        // the enclosing subroutine, and the package above it
        const BaseClass* sub = nullptr;
        for (const BaseClass* p = X; p; p = p->VpiParent())
            if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
                sub = p;
                break;
            }
        if (!sub) continue;
        const std::string sn(sub->VpiName());
        if (sn.find("::") == std::string::npos) continue;
        const BaseClass* pk = pkgAbove(sub);
        if (!pk) continue;
        for (const variables* v : *vars) {
            if (!v) continue;
            const ref_typespec* rt = v->Typespec();
            const typespec* a = rt ? rt->Actual_typespec() : nullptr;
            std::string k = a ? std::string(UhdmName(a->UhdmType()))
                              : std::string("<null>");
            tally[k]++;
            ++n;
            if (!verbose) continue;
            char b[900];
            snprintf(b, sizeof b,
                     "    LOC pkg=%-16s sub=%-52s var=%-24s ts=%-24s name=%-40s inst=%-18s span=%u:%u",
                     std::string(pk->VpiName()).c_str(), sn.c_str(),
                     std::string(v->VpiName()).c_str(), k.c_str(),
                     a ? std::string(a->VpiName()).c_str() : "-",
                     (a && tsInstance(a))
                         ? std::string(tsInstance(a)->VpiName()).c_str() : "-",
                     a ? a->VpiLineNo() : 0,
                     a ? (unsigned)a->VpiColumnNo() : 0);
            rows.push_back(b);
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    for (auto& [k, c] : tally) printf("    KIND %-28s %zu\n", k.c_str(), c);
    printf("    CLONE-BODY-LOCALS=%zu\n", n);
}
// every ref_typespec whose Actual_typespec is named <nm>
static void pairs(const char* tag, Serializer& s, const char* nm) {
    printf("  %s BINDINGS to a typespec named '%s':\n", tag, nm);
    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X->UhdmType() != uhdmref_typespec) continue;
        const ref_typespec* rt = (const ref_typespec*)X;
        const typespec* a = rt->Actual_typespec();
        if (!a || a->VpiName() != std::string_view(nm)) continue;
        ++n;
        printf("      TS %-28s @%u:%u inst=%-30s owner=%s%s\n",
               std::string(UhdmName(a->UhdmType())).c_str(), a->VpiLineNo(),
               (unsigned)a->VpiColumnNo(), ident(tsInstance(a)).c_str(),
               ident(X->VpiParent()).c_str(), chainStr(X->VpiParent()).c_str());
    }
    printf("      BINDINGS=%zu\n", n);
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct202own <golden> <ours> [--refs] [--mint] [--maskall]"
                " [--cls] [--locals] [--localsv] [--pairs=<name>]\n");
        return 2;
    }
    bool maskall = false, refs = false, mint = false, cls = false;
    bool locals = false, localsv = false;
    const char* pairName = nullptr;
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--maskall")) maskall = true;
        if (!strcmp(argv[i], "--refs")) refs = true;
        if (!strcmp(argv[i], "--mint")) mint = true;
        if (!strcmp(argv[i], "--cls")) cls = true;
        if (!strcmp(argv[i], "--locals")) locals = true;
        if (!strcmp(argv[i], "--localsv")) { locals = true; localsv = true; }
        if (!strncmp(argv[i], "--pairs=", 8)) pairName = argv[i] + 8;
    }
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
    const BaseClass* HL = c.m_failedLhs;
    const BaseClass* HR = c.m_failedRhs;
    if (HL) chain("golden", HL);
    if (HR) chain("ours  ", HR);
    if (HL) printf("  golden head Instance = %s\n", ident(tsInstance(HL)).c_str());
    if (HR) printf("  ours   head Instance = %s\n", ident(tsInstance(HR)).c_str());
    if (refs) {
        if (HL) referrers("GOLDEN", sg, HL, true);
        if (HR) referrers("OURS  ", so, HR, true);
    }
    if (mint) {
        if (HL) mintCensus("GOLDEN", sg, HL);
        if (HR) mintCensus("OURS  ", so, HR);
    }
    if (cls) { clsReport("GOLDEN", sg); clsReport("OURS  ", so); }
    if (locals) {
        localsReport("GOLDEN", sg, localsv);
        localsReport("OURS  ", so, localsv);
    }
    if (pairName) { pairs("GOLDEN", sg, pairName); pairs("OURS  ", so, pairName); }
    if (HL) {
        CompareContext c2;
        c2.m_visited.insert(HL);
        int r2 = dg->Compare(dou, &c2);
        printf("ABLATION (mask the golden head only):\n");
        printf("  design::Compare r=%d\n", r2);
        printf("  NEXT LHS(golden) = %s\n", ident(c2.m_failedLhs).c_str());
        printf("  NEXT RHS(ours)   = %s\n", ident(c2.m_failedRhs).c_str());
        printf("  VERDICT: %s\n",
               (c2.m_failedLhs != HL || c2.m_failedRhs != HR)
                   ? "THE HEAD MOVED (this object was the whole head)"
                   : "REFUTED — the judge stopped on the same pair again");
    }
    if (maskall) {
        CompareContext c3;
        size_t nm = 0;
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* o = (const BaseClass*)kv.first;
            if (o && o->UhdmType() == uhdmunsupported_typespec) {
                c3.m_visited.insert(o);
                ++nm;
            }
        }
        int r3 = dg->Compare(dou, &c3);
        printf("MASKALL (%zu golden unsupported_typespec masked):\n", nm);
        printf("  design::Compare r=%d\n", r3);
        printf("  NEXT LHS(golden) = %s\n", ident(c3.m_failedLhs).c_str());
        printf("  NEXT RHS(ours)   = %s\n", ident(c3.m_failedRhs).c_str());
    }
    return 0;
}
