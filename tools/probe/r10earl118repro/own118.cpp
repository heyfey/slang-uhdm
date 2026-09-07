// r10earl118 -- THE JUDGE, DECODED FIRST.  Owner-finder / FIELD BISECTOR for a
// NULL head (`LHS: <null>` against one of OUR objects), plus the WHOLE-DATABASE
// NAME SEARCH that answers "does golden hold this object at all, in either
// mode?" without guessing.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// RESUME.md section 9's head-decode discipline: read BaseClass.h's SafeCompare
// overloads and the owning kind's GENERATED Compare order BEFORE naming a
// field.  For a null head the two overloads say DIFFERENT things:
//
//   SINGULAR  SafeCompare(lhs, rhs, ctx)
//       lhs == nullptr && rhs != nullptr  ->  m_failedRhs = THE VALUE, -1
//   VECTOR    SafeCompare(lhs_obj, lhs_vec, rhs_obj, rhs_vec, ctx)
//       lhs_vec == nullptr && rhs_vec non-empty -> m_failedRhs = THE CONTAINER
//
// so whether the printed RHS is the VALUE or the OWNER is itself the evidence
// for which field failed.  This tool prints that, then the two candidate
// owners' FULL listings side by side, then re-runs each vector field of
// `scope::Compare` / `gen_scope::Compare` IN THE GENERATED ORDER with a fresh
// CompareContext so the FIRST failing container is measured, not inferred.
//
// build:
//   g++ -O2 -std=c++17 own118.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own118
// usage:
//   own118 <golden.uhdm> <ours.uhdm> [<fullname-substring-to-search>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
    if (!o) return "<null>";
    char b[256];
    std::string f(o->VpiFile());
    auto p = f.rfind('/');
    if (p != std::string::npos) f = f.substr(p + 1);
    snprintf(b, sizeof b, "%s %u:%u-%u:%u", f.c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "<null>";
}
static std::string payload(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    s += " name='" + std::string(o->VpiName()) + "'";
    if (!o->VpiDefName().empty())
        s += " dn='" + std::string(o->VpiDefName()) + "'";
    if (auto* e = any_cast<const expr*>(o)) {
        if (!e->VpiDecompile().empty())
            s += " dec='" + std::string(e->VpiDecompile()) + "'";
        s += " size=" + std::to_string(e->VpiSize());
        s += " ts=" + kindOf(e->Typespec());
        if (auto* rt = e->Typespec())
            s += "->" + kindOf(rt->Actual_typespec());
    }
    if (auto* r = any_cast<const ref_obj*>(o))
        s += " actual=" + kindOf(r->Actual_group());
    if (auto* op = any_cast<const operation*>(o))
        s += " optype=" + std::to_string(op->VpiOpType());
    s += "  @" + spanOf(o);
    return s;
}

// the fullname the DUMP synthesises is not stored on every object; use the
// object's own VpiFullName when it has one, else walk the parent chain.
static std::string fullOf(const BaseClass* o) {
    if (!o) return "<null>";
    if (auto* s = any_cast<const scope*>(o))
        if (!s->VpiFullName().empty()) return std::string(s->VpiFullName());
    if (auto* v = any_cast<const variables*>(o))
        if (!v->VpiFullName().empty()) return std::string(v->VpiFullName());
    if (auto* n = any_cast<const nets*>(o))
        if (!n->VpiFullName().empty()) return std::string(n->VpiFullName());
    std::string s;
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        std::string n(p->VpiName());
        if (n.empty()) continue;
        s = s.empty() ? n : n + "." + s;
    }
    return s;
}

static void chain(const char* tag, const BaseClass* o) {
    printf("   -- OWNER CHAIN (%s) --\n", tag);
    const BaseClass* p = o ? o->VpiParent() : nullptr;
    for (int d = 0; d < 8 && p; d++) {
        printf("     %*s|vpiParent -> %s\n", d * 2, "", payload(p).c_str());
        p = p->VpiParent();
    }
}

template <typename T>
static void listVec(const char* label, const std::vector<T*>* v) {
    if (!v) {
        printf("      %-22s <NULL VECTOR>\n", label);
        return;
    }
    printf("      %-22s size=%zu\n", label, v->size());
    for (auto* x : *v) printf("          %s\n", payload(x).c_str());
}

// THE LISTING, both sides, in the GENERATED Compare order for a scope.
static void listScope(const char* tag, const scope* s) {
    printf("   -- %s SCOPE LISTING (%s) --\n", tag, payload(s).c_str());
    if (!s) return;
    listVec("scope::Named_events", s->Named_events());
    listVec("scope::Variables", s->Variables());
    listVec("scope::Logic_vars", s->Logic_vars());
    listVec("scope::Array_vars", s->Array_vars());
    listVec("scope::Parameters", s->Parameters());
    listVec("scope::Param_assigns", s->Param_assigns());
    listVec("scope::Scopes", s->Scopes());
    listVec("scope::Typespecs", s->Typespecs());
    listVec("scope::Instance_items", s->Instance_items());
    if (auto* g = any_cast<const gen_scope*>(s)) {
        listVec("gen_scope::Nets", g->Nets());
        listVec("gen_scope::Array_nets", g->Array_nets());
        listVec("gen_scope::Process", g->Process());
        listVec("gen_scope::Cont_assigns", g->Cont_assigns());
        listVec("gen_scope::Modules", g->Modules());
        listVec("gen_scope::Gen_scope_arrays", g->Gen_scope_arrays());
    }
}

// re-run the SafeCompare of each container IN ORDER with a FRESH context, so
// the FIRST failing container is measured.  m_visited is per-context, so this
// does not inherit the whole-design walk's memo.
// BaseClass::SafeCompare is `protected`, so the vector overload is transcribed
// here VERBATIM from ~/.local/include/uhdm/BaseClass.h:202-238 (checked against
// that file; if it ever drifts this bisector is wrong and must be re-copied).
template <typename T>
static int32_t vecSafeCompare(const BaseClass* lhs_obj,
                              const std::vector<T*>* lhs,
                              const BaseClass* rhs_obj,
                              const std::vector<T*>* rhs,
                              CompareContext* context) {
    if ((lhs != nullptr) && (rhs != nullptr)) {
        int32_t r = 0;
        if ((r = static_cast<int32_t>(lhs->size() - rhs->size())) != 0) {
            context->m_failedLhs = lhs_obj;
            context->m_failedRhs = rhs_obj;
            return 1;
        }
        for (size_t i = 0, n = lhs->size(); i < n; ++i) {
            const BaseClass* a = lhs->at(i);
            const BaseClass* b = rhs->at(i);
            if ((a != nullptr) && (b != nullptr)) {
                if ((r = a->Compare(b, context)) != 0) return r;
            } else if ((a != nullptr) && (b == nullptr)) {
                context->m_failedLhs = a;
                return 1;
            } else if ((a == nullptr) && (b != nullptr)) {
                context->m_failedRhs = b;
                return -1;
            }
        }
    } else if ((lhs != nullptr) && !lhs->empty() && (rhs == nullptr)) {
        context->m_failedLhs = lhs_obj;
        return 1;
    } else if ((lhs == nullptr) && (rhs != nullptr) && !rhs->empty()) {
        context->m_failedRhs = rhs_obj;
        return -1;
    }
    return 0;
}

#define CELL(NAME, GET)                                                       \
    do {                                                                      \
        CompareContext c;                                                     \
        int32_t r = vecSafeCompare(L, L->GET, R, R->GET, &c);                 \
        printf("      %-26s L=%-4s R=%-4s -> %d%s\n", NAME,                   \
               L->GET ? std::to_string(L->GET->size()).c_str() : "null",      \
               R->GET ? std::to_string(R->GET->size()).c_str() : "null", r,   \
               r ? "   <== FAILS" : "");                                      \
    } while (0)

static void bisectScope(const scope* L, const scope* R) {
    printf("   -- CONTAINER BISECTION (generated scope::Compare order, fresh"
           " context each) --\n");
    if (!L || !R) {
        printf("      one side missing entirely\n");
        return;
    }
    printf("      %-26s '%s' vs '%s' -> %d\n", "scope::VpiName",
           std::string(L->VpiName()).c_str(), std::string(R->VpiName()).c_str(),
           std::string(L->VpiName()).compare(std::string(R->VpiName())));
    CELL("scope::Named_events", Named_events());
    CELL("scope::Variables", Variables());
    CELL("scope::Logic_vars", Logic_vars());
    CELL("scope::Array_vars", Array_vars());
    CELL("scope::Parameters", Parameters());
    CELL("scope::Param_assigns", Param_assigns());
    CELL("scope::Scopes", Scopes());
    CELL("scope::Typespecs", Typespecs());
    CELL("scope::Instance_items", Instance_items());
    auto* Lg = any_cast<const gen_scope*>(L);
    auto* Rg = any_cast<const gen_scope*>(R);
    if (Lg && Rg) {
        const gen_scope* L = Lg;
        const gen_scope* R = Rg;
        CELL("gen_scope::Nets", Nets());
        CELL("gen_scope::Array_nets", Array_nets());
        CELL("gen_scope::Process", Process());
        CELL("gen_scope::Cont_assigns", Cont_assigns());
        CELL("gen_scope::Modules", Modules());
        CELL("gen_scope::Gen_scope_arrays", Gen_scope_arrays());
    }
}

// WHOLE-DATABASE NAME SEARCH -- does this database hold ANY object of this
// name, anywhere, under any parent?  Serializer::AllObjects enumerates the
// whole arena, including objects no container reaches.
static void nameSearch(const char* tag, Serializer& s, const char* needle) {
    printf("   -- WHOLE-DB NAME SEARCH (%s) for '%s' --\n", tag, needle);
    std::map<std::string, int> byKind;
    int n = 0;
    std::set<const BaseClass*> seen;
    for (const auto& p : s.AllObjects()) {
        const BaseClass* o = p.first;
        if (!o || !seen.insert(o).second) continue;
        std::string nm(o->VpiName());
        if (nm != needle) continue;
        byKind[kindOf(o) + "  under " + kindOf(o->VpiParent())]++;
        if (n < 12)
            printf("      %s  parent=%s  full='%s'\n", payload(o).c_str(),
                   kindOf(o->VpiParent()).c_str(), fullOf(o).c_str());
        n++;
    }
    printf("      TOTAL objects named '%s' = %d\n", needle, n);
    for (const auto& kv : byKind)
        printf("      %6d  %s\n", kv.second, kv.first.c_str());
}

static const scope* findScopeByFull(Serializer& s, const std::string& full) {
    std::set<const BaseClass*> seen;
    for (const auto& p : s.AllObjects()) {
        const BaseClass* o = p.first;
        if (!o || !seen.insert(o).second) continue;
        auto* sc = any_cast<const scope*>(o);
        if (!sc) continue;
        if (std::string(sc->VpiFullName()) == full) return sc;
    }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own118 <golden> <ours> [name] [ownerfull]\n");
        return 2;
    }
    const char* needle = argc > 3 ? argv[3] : "data_mux";
    Serializer sg, so;
    std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) {
        fprintf(stderr, "FATAL: load failed\n");
        return 3;
    }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dd = (const design*)((const uhdm_handle*)ho[0])->object;

    CompareContext ctx;
    int r = dg->Compare(dd, &ctx);
    printf("== design::Compare -> %d\n", r);
    const BaseClass* L = ctx.m_failedLhs;
    const BaseClass* R = ctx.m_failedRhs;
    printf("   HEAD LHS(golden) = %s id:%u  %s\n", kindOf(L).c_str(),
           L ? L->UhdmId() : 0, spanOf(L).c_str());
    printf("        payload: %s\n", payload(L).c_str());
    printf("   HEAD RHS(ours)   = %s id:%u  %s\n", kindOf(R).c_str(),
           R ? R->UhdmId() : 0, spanOf(R).c_str());
    printf("        payload: %s\n", payload(R).c_str());
    printf("        full   : %s\n", fullOf(R).c_str());
    if (!L && R) {
        printf("   ONE SIDE NULL.  BaseClass.h: the SINGULAR overload sets\n"
               "   m_failedRhs to THE VALUE; the VECTOR overload sets it to the\n"
               "   CONTAINER.  The printed RHS is a %s, so the failing field is\n"
               "   %s.\n",
               kindOf(R).c_str(),
               any_cast<const scope*>(R)
                   ? "AMBIGUOUS from the print alone -- bisect below"
                   : "a SINGULAR relation whose value is this object");
    }
    chain("ours  ", R);

    // the owner pair: our head's parent scope, and golden's scope of the same
    // fullname (nullptr if golden has none -- itself a measurement).
    const scope* Rs =
        R ? any_cast<const scope*>(R->VpiParent()) : nullptr;
    std::string full = argc > 4 ? argv[4] : (Rs ? std::string(Rs->VpiFullName())
                                               : std::string());
    printf("== OWNER SCOPE fullname: '%s'\n", full.c_str());
    const scope* Ls = full.empty() ? nullptr : findScopeByFull(sg, full);
    printf("   golden holds that scope: %s\n", Ls ? "YES" : "NO");
    listScope("GOLDEN", Ls);
    listScope("OURS  ", Rs);
    bisectScope(Ls, Rs);

    // DESCEND into the failing container: compare each cont_assign pairwise
    // with a FRESH context, and print both sides' Lhs / Rhs trees, so the
    // SINGULAR field that carries the null is measured, not guessed.
    if (Ls && Rs) {
        auto* Lg = any_cast<const gen_scope*>(Ls);
        auto* Rg = any_cast<const gen_scope*>(Rs);
        if (Lg && Rg && Lg->Cont_assigns() && Rg->Cont_assigns() &&
            Lg->Cont_assigns()->size() == Rg->Cont_assigns()->size()) {
            printf("   -- CONT_ASSIGN DESCENT (fresh context each) --\n");
            for (size_t i = 0; i < Lg->Cont_assigns()->size(); i++) {
                const cont_assign* a = Lg->Cont_assigns()->at(i);
                const cont_assign* b = Rg->Cont_assigns()->at(i);
                CompareContext c;
                int32_t rr = a->Compare(b, &c);
                printf("     [%zu] %s  vs  %s  -> %d\n", i, spanOf(a).c_str(),
                       spanOf(b).c_str(), rr);
                if (rr) {
                    printf("         failedLhs=%s\n", payload(c.m_failedLhs).c_str());
                    printf("         failedRhs=%s\n", payload(c.m_failedRhs).c_str());
                }
                printf("         GOLDEN Lhs: %s\n", payload(a->Lhs()).c_str());
                printf("         OURS   Lhs: %s\n", payload(b->Lhs()).c_str());
                printf("         GOLDEN Rhs: %s\n", payload(a->Rhs()).c_str());
                printf("         OURS   Rhs: %s\n", payload(b->Rhs()).c_str());
                if (auto* lr = any_cast<const ref_obj*>(a->Lhs()))
                    printf("         GOLDEN Lhs.Actual_group: %s\n",
                           payload(lr->Actual_group()).c_str());
                if (auto* rr2 = any_cast<const ref_obj*>(b->Lhs()))
                    printf("         OURS   Lhs.Actual_group: %s\n",
                           payload(rr2->Actual_group()).c_str());
            }
        }
    }

    nameSearch("GOLDEN", sg, needle);
    nameSearch("OURS  ", so, needle);
    return 0;
}
