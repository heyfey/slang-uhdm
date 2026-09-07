// r10uvm200 — THE OWNER-FINDER + JUDGE DECODER for the IMPORT-COPY
// `param_assign` Rhs head: golden's importing-PACKAGE copy of
// `uvm_pkg::UVM_LARGE_STRING` carries NO `Rhs`; ours carries the folded
// constant 115199.
//
// MEASUREMENT ONLY.  The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge; this tool links the SAME generated `Compare` and only
// reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Derived from r10uvm198repro/ct198own.cpp (owner chain / referrer index /
// ablation), with the mode this head needs:
//
//   --pa[=<scope name substring>]  — EVERY `param_assign` reachable from the
//       design's four listings (AllPackages / TopPackages / AllModules /
//       TopModules), on BOTH sides, keyed by  view | scope | parameter name,
//       printing the parameter KIND, its `VpiImported` tag, its typespec kind,
//       and the Rhs PRESENCE + kind + decompile.  This is question (1)'s
//       "every param_assign in the importing package's listing both sides with
//       Rhs presence and kind".
//   --refs / --mint / --ablate as in ct198own.
//   --maskpa — mask EVERY golden `param_assign` at once: says how much of the
//       design is behind this one family.
//
// build: g++ -O2 -std=c++17 ct200own.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct200own
// usage: ct200own <golden.uhdm> <ours.uhdm> [--refs] [--mint] [--maskpa]
//                 [--pa[=<scope substr>]]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <map>
#include <set>
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
static void chain(const char* tag, const BaseClass* o) {
    printf("  %s owner chain:\n", tag);
    int g = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && g < 24;
         p = p->VpiParent(), ++g)
        printf("      < %s\n", ident(p).c_str());
    if (g == 0) printf("      < <no parent>\n");
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
            printf("      REF .%-20s %-9s %s\n", f.name, isvec ? w : "rel1",
                   ident(X).c_str());
            chain("        ", X);
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
        printf("      OBJ %s refs=%zu parent=%s\n", ident(X).c_str(),
               referrers("", s, X, false), ident(X->VpiParent()).c_str());
    }
    printf("      OBJECTS=%zu\n", n);
}

// ---------------------------------------------------------------- the --pa mode
// The typespec kind a `parameter`/`type_parameter` Lhs binds (through the
// ref_typespec indirection), and its own instance stamp.
static std::string tsOf(const any* p) {
    if (!p) return "-";
    auto it = kFields.find(std::string(UhdmName(p->UhdmType())));
    if (it == kFields.end()) return "-";
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, "Typespec")) {
            const BaseClass* rt = rel1((const BaseClass*)p, f);
            if (!rt) return "<none>";
            auto jt = kFields.find("ref_typespec");
            if (jt != kFields.end())
                for (const Field& g : jt->second)
                    if (g.kind == F_REL1 && !strcmp(g.name, "Actual_typespec")) {
                        const BaseClass* a = rel1(rt, g);
                        if (!a) return "ref_typespec-><null>";
                        std::string r(UhdmName(a->UhdmType()));
                        const std::string an(a->VpiName());
                        if (!an.empty()) r += "(" + an + ")";
                        const BaseClass* in = tsInstance(a);
                        if (in) r += "@" + std::string(in->VpiName());
                        return r;
                    }
            return "ref_typespec";
        }
    return "<no-ts-field>";
}
static std::string impOf(const any* p) {
    if (!p) return "-";
    if (p->UhdmType() == uhdmparameter) {
        const std::string v(((const parameter*)p)->VpiImported());
        return v.empty() ? "." : v;
    }
    if (p->UhdmType() == uhdmtype_parameter) {
        const std::string v(((const type_parameter*)p)->VpiImported());
        return v.empty() ? "." : v;
    }
    return ".";
}
// a short, judge-visible rendering of the Rhs
static std::string rhsOf(const param_assign* pa) {
    const any* r = pa->Rhs();
    if (!r) return "NO-RHS";
    std::string s(UhdmName(r->UhdmType()));
    if (r->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)r;
        char b[300];
        const std::string d(c->VpiDecompile());
        snprintf(b, sizeof b, "constant[ct=%d sz=%d dec=%.120s]",
                 (int)c->VpiConstType(), (int)c->VpiSize(), d.c_str());
        return b;
    }
    if (r->UhdmType() == uhdmoperation) {
        const operation* o = (const operation*)r;
        char b[120];
        snprintf(b, sizeof b, "operation[op=%d n=%zu]", (int)o->VpiOpType(),
                 o->Operands() ? o->Operands()->size() : 0);
        return b;
    }
    const std::string nm(r->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s;
}
struct PaRow {
    std::string view, scope, pname, pkind, imported, ts, rhs, span;
};
static void collectPa(const char* view, const any* scope,
                      const VectorOfparam_assign* v, std::vector<PaRow>& out) {
    if (!v) return;
    for (const param_assign* pa : *v) {
        if (!pa) continue;
        PaRow r;
        r.view = view;
        r.scope = std::string(UhdmName(scope->UhdmType())) + ":" +
                  std::string(scope->VpiName());
        const any* lhs = pa->Lhs();
        r.pname = lhs ? std::string(lhs->VpiName()) : std::string("<null-lhs>");
        r.pkind = lhs ? std::string(UhdmName(lhs->UhdmType())) : "<null>";
        r.imported = impOf(lhs);
        r.ts = tsOf(lhs);
        r.rhs = rhsOf(pa);
        char b[96];
        snprintf(b, sizeof b, "%s:%u:%u-%u:%u#%u", base(pa->VpiFile()).c_str(),
                 pa->VpiLineNo(), (unsigned)pa->VpiColumnNo(),
                 pa->VpiEndLineNo(), (unsigned)pa->VpiEndColumnNo(),
                 pa->UhdmId());
        r.span = b;
        out.push_back(r);
    }
}
static void walkScopes(const design* d, std::vector<PaRow>& out) {
    collectPa("design", d, d->Param_assigns(), out);
    if (auto* v = d->AllPackages())
        for (auto* p : *v) collectPa("defpkg", p, p->Param_assigns(), out);
    if (auto* v = d->TopPackages())
        for (auto* p : *v) collectPa("elabpkg", p, p->Param_assigns(), out);
    if (auto* v = d->AllModules())
        for (auto* m : *v) collectPa("defmod", m, m->Param_assigns(), out);
    if (auto* v = d->TopModules())
        for (auto* m : *v) collectPa("elabmod", m, m->Param_assigns(), out);
    if (auto* v = d->AllInterfaces())
        for (auto* m : *v) collectPa("defiface", m, m->Param_assigns(), out);
    if (auto* v = d->AllPrograms())
        for (auto* m : *v) collectPa("defprog", m, m->Param_assigns(), out);
}
static void paReport(const char* tag, const design* d, const char* filt) {
    std::vector<PaRow> rows;
    walkScopes(d, rows);
    size_t n = 0, norhs = 0;
    printf("  %s param_assign listing (view | scope | param | kind | imported | typespec | RHS | span)\n",
           tag);
    for (const PaRow& r : rows) {
        if (filt && *filt && r.scope.find(filt) == std::string::npos) continue;
        ++n;
        if (r.rhs == "NO-RHS") ++norhs;
        printf("    PA %-8s %-34s %-26s %-15s imp=%-14s ts=%-34s rhs=%-60s %s\n",
               r.view.c_str(), r.scope.c_str(), r.pname.c_str(),
               r.pkind.c_str(), r.imported.c_str(), r.ts.c_str(),
               r.rhs.c_str(), r.span.c_str());
    }
    printf("    PA-TOTAL=%zu PA-NO-RHS=%zu\n", n, norhs);
}

// every param_assign in the WHOLE serializer whose Rhs is null, with its owner
// chain — the population question "which copies lose the Rhs" answered without
// assuming the object is reachable from one of the design's listings.
static void noRhsScan(const char* tag, Serializer& s) {
    printf("  %s param_assign objects with NO Rhs (whole serializer):\n", tag);
    size_t tot = 0, n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X->UhdmType() != uhdmparam_assign) continue;
        ++tot;
        const param_assign* pa = (const param_assign*)X;
        if (pa->Rhs()) continue;
        ++n;
        const any* l = pa->Lhs();
        printf("      NORHS %s lhs=%s parent=%s\n", ident(X).c_str(),
               l ? ident(l).c_str() : "<null>", ident(X->VpiParent()).c_str());
    }
    printf("      PARAM_ASSIGN-TOTAL=%zu NO-RHS=%zu\n", tot, n);
}

// --------------------------------------------------------------- the --edge mode
// The head's real edge is a `ref_obj::Actual_group`, and a typespec has no
// VpiParent, so the owning construct has to be found by walking REFERRERS
// UPWARD.  For every `ref_obj` of the given name, print its Actual_group and
// the upward referrer chain (first referrer per level) to depth `d`.
static const BaseClass* firstReferrer(Serializer& s, const BaseClass* o,
                                      std::string& field) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X == o) continue;
        auto it = kFields.find(std::string(UhdmName(X->UhdmType())));
        if (it == kFields.end()) continue;
        for (const Field& f : it->second) {
            if (f.kind == F_REL1) {
                if (rel1(X, f) == o) { field = f.name; return X; }
            } else if (f.kind == F_RELV) {
                std::vector<const BaseClass*> v;
                relv(X, f, v);
                for (auto* e : v)
                    if (e == o) { field = f.name; return X; }
            }
        }
    }
    field = "<none>";
    return nullptr;
}
static void edgeReport(const char* tag, Serializer& s, const char* nm) {
    printf("  %s ref_obj named '%s' — Actual_group + upward owner chain:\n", tag,
           nm);
    size_t n = 0, bound = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X || X->UhdmType() != uhdmref_obj) continue;
        if (X->VpiName() != std::string_view(nm)) continue;
        ++n;
        const any* a = ((const ref_obj*)X)->Actual_group();
        if (a) ++bound;
        printf("      REFOBJ %s actual=%s\n", ident(X).c_str(),
               a ? ident((const BaseClass*)a).c_str() : "<null>");
        const BaseClass* cur = X;
        for (int d = 0; d < 8 && cur; d++) {
            std::string f;
            const BaseClass* up = cur->VpiParent();
            if (up) {
                printf("          ^parent  %s\n", ident(up).c_str());
            } else {
                up = firstReferrer(s, cur, f);
                if (!up) break;
                printf("          ^ref .%-18s %s\n", f.c_str(),
                       ident(up).c_str());
            }
            cur = up;
        }
    }
    printf("      REFOBJS=%zu BOUND=%zu UNBOUND=%zu\n", n, bound, n - bound);
}

// --------------------------------------------------------------- the --fn mode
// For every `function`/`task` of the given name in each database: the scope it
// is listed in, its Return variable, that variable's typespec, and the LEFT
// bound of the typespec's first range with its binding — i.e. the whole
// declared-range chain the head lives in, per COPY of the subroutine.
static std::string actualOf(const BaseClass* o) {
    if (!o) return "<null>";
    if (o->UhdmType() != uhdmref_obj) return ident(o);
    const any* a = ((const ref_obj*)o)->Actual_group();
    return ident(o) + " actual=" + (a ? ident((const BaseClass*)a) : "<null>");
}
static const BaseClass* fieldOf(const BaseClass* o, const char* name) {
    if (!o) return nullptr;
    auto it = kFields.find(std::string(UhdmName(o->UhdmType())));
    if (it == kFields.end()) return nullptr;
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, name)) return rel1(o, f);
    return nullptr;
}
static void tsChain(const char* lead, const BaseClass* holder) {
    // holder is a variables / io_decl: .Typespec -> ref_typespec
    //   -> .Actual_typespec -> <ts> -> Ranges[0] -> Left_expr
    const BaseClass* rt = fieldOf(holder, "Typespec");
    const BaseClass* ts = rt ? fieldOf(rt, "Actual_typespec") : nullptr;
    printf("%s ts=%s\n", lead, ident(ts).c_str());
    if (!ts) return;
    auto it = kFields.find(std::string(UhdmName(ts->UhdmType())));
    if (it == kFields.end()) return;
    for (const Field& f : it->second) {
        if (f.kind != F_RELV || strcmp(f.name, "Ranges")) continue;
        std::vector<const BaseClass*> v;
        relv(ts, f, v);
        for (size_t i = 0; i < v.size(); i++)
            printf("%s   range[%zu] left=%s\n", lead, i,
                   actualOf(fieldOf(v[i], "Left_expr")).c_str());
    }
}
static void fnReport(const char* tag, Serializer& s, const char* nm) {
    printf("  %s subroutine copies named '%s':\n", tag, nm);
    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = (const BaseClass*)kv.first;
        if (!X) continue;
        const UHDM_OBJECT_TYPE t = X->UhdmType();
        if (t != uhdmfunction && t != uhdmtask) continue;
        if (X->VpiName() != std::string_view(nm)) continue;
        ++n;
        printf("      FN %s scope=%s\n", ident(X).c_str(),
               ident(X->VpiParent()).c_str());
        const BaseClass* ret = fieldOf(X, "Return");
        printf("          return=%s\n", ident(ret).c_str());
        if (ret) tsChain("         ", ret);
        auto it = kFields.find(std::string(UhdmName(t)));
        if (it != kFields.end())
            for (const Field& f : it->second) {
                if (f.kind != F_RELV || strcmp(f.name, "Io_decls")) continue;
                std::vector<const BaseClass*> v;
                relv(X, f, v);
                for (size_t i = 0; i < v.size(); i++) {
                    printf("          io[%zu]=%s\n", i, ident(v[i]).c_str());
                    tsChain("         ", v[i]);
                }
            }
    }
    printf("      COPIES=%zu\n", n);
}

// --------------------------------------------------------------- the --lst mode
// WHICH task_func OBJECT each design listing holds for a given name — the
// question "does the module listing share the home's subroutine or an import
// clone's?", which decides whether a clone-scoped law is object-safe.
static void lstReport(const char* tag, const design* d, const char* nm) {
    printf("  %s listings holding a task_func named '%s':\n", tag, nm);
    auto one = [&](const char* ln, const BaseClass* sc,
                   const VectorOftask_func* v) {
        if (!v) return;
        for (auto* t : *v)
            if (t && t->VpiName() == std::string_view(nm))
                printf("      LST %-9s %-34s -> %s\n", ln,
                       ident(sc).c_str(), ident((const BaseClass*)t).c_str());
    };
    if (auto* v = d->AllPackages())
        for (auto* p : *v) one("defpkg", p, p->Task_funcs());
    if (auto* v = d->TopPackages())
        for (auto* p : *v) one("elabpkg", p, p->Task_funcs());
    if (auto* v = d->AllModules())
        for (auto* m : *v) one("defmod", m, m->Task_funcs());
    if (auto* v = d->TopModules())
        for (auto* m : *v) one("elabmod", m, m->Task_funcs());
    if (auto* v = d->AllInterfaces())
        for (auto* m : *v) one("defiface", m, m->Task_funcs());
    if (auto* v = d->AllPrograms())
        for (auto* m : *v) one("defprog", m, m->Task_funcs());
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct200own <golden> <ours> [--refs] [--mint] [--maskpa]"
                " [--norhs] [--pa[=<scope substr>]] [--edge=<ref_obj name>]\n");
        return 2;
    }
    bool refs = false, mint = false, maskpa = false, pa = false, norhs = false;
    const char* paFilt = "";
    const char* edgeName = nullptr;
    const char* fnName = nullptr;
    const char* lstName = nullptr;
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--refs")) refs = true;
        if (!strcmp(argv[i], "--mint")) mint = true;
        if (!strcmp(argv[i], "--maskpa")) maskpa = true;
        if (!strcmp(argv[i], "--norhs")) norhs = true;
        if (!strcmp(argv[i], "--pa")) pa = true;
        if (!strncmp(argv[i], "--pa=", 5)) { pa = true; paFilt = argv[i] + 5; }
        if (!strncmp(argv[i], "--edge=", 7)) edgeName = argv[i] + 7;
        if (!strncmp(argv[i], "--fn=", 5)) fnName = argv[i] + 5;
        if (!strncmp(argv[i], "--lst=", 6)) lstName = argv[i] + 6;
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
    if (refs) {
        if (HL) referrers("GOLDEN", sg, HL, true);
        if (HR) referrers("OURS  ", so, HR, true);
    }
    if (mint) {
        if (HL) mintCensus("GOLDEN", sg, HL);
        if (HR) mintCensus("OURS  ", so, HR);
    }
    if (pa) {
        paReport("GOLDEN", dg, paFilt);
        paReport("OURS  ", dou, paFilt);
    }
    if (norhs) {
        noRhsScan("GOLDEN", sg);
        noRhsScan("OURS  ", so);
    }
    if (edgeName) {
        edgeReport("GOLDEN", sg, edgeName);
        edgeReport("OURS  ", so, edgeName);
    }
    if (fnName) {
        fnReport("GOLDEN", sg, fnName);
        fnReport("OURS  ", so, fnName);
    }
    if (lstName) {
        lstReport("GOLDEN", dg, lstName);
        lstReport("OURS  ", dou, lstName);
    }
    // ABLATION.  With a MIRROR head (golden null, ours present) there is no
    // golden object to seed, so the mask is the OWNER: the param_assign whose
    // .Rhs edge failed.  Seeding it makes its whole subtree return 0.
    const BaseClass* owner = nullptr;
    if (HR && !HL) {
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* X = (const BaseClass*)kv.first;
            if (!X || X->UhdmType() != uhdmparam_assign) continue;
            const param_assign* p = (const param_assign*)X;
            if (p->Rhs()) continue;
            if (p->VpiLineNo() != HR->VpiParent()->VpiLineNo()) continue;
            owner = X;
            break;
        }
        printf("MIRROR HEAD — golden .Rhs is null; candidate golden owner = %s\n",
               ident(owner).c_str());
    }
    const BaseClass* seed = HL ? HL : owner;
    if (seed) {
        CompareContext c2;
        c2.m_visited.insert(seed);
        int r2 = dg->Compare(dou, &c2);
        printf("ABLATION (mask %s):\n", ident(seed).c_str());
        printf("  design::Compare r=%d\n", r2);
        printf("  NEXT LHS(golden) = %s\n", ident(c2.m_failedLhs).c_str());
        printf("  NEXT RHS(ours)   = %s\n", ident(c2.m_failedRhs).c_str());
    }
    if (maskpa) {
        CompareContext c3;
        size_t nm = 0;
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* o = (const BaseClass*)kv.first;
            if (o && o->UhdmType() == uhdmparam_assign) {
                c3.m_visited.insert(o);
                ++nm;
            }
        }
        int r3 = dg->Compare(dou, &c3);
        printf("MASKPA (%zu golden param_assign masked):\n", nm);
        printf("  design::Compare r=%d\n", r3);
        printf("  NEXT LHS(golden) = %s\n", ident(c3.m_failedLhs).c_str());
        printf("  NEXT RHS(ours)   = %s\n", ident(c3.m_failedRhs).c_str());
    }
    return 0;
}
