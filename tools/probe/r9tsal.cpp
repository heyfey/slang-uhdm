// r9tsal: per-package typespec census — kind, name, Typedef_alias presence and
// Instance — for both files side by side. uhdm-dump does not print
// vpiTypedefAlias in every nesting context, so a missing self-alias ref is
// invisible in a dump diff while typespec::Compare fails on it
// (`failLhs=ref_typespec failRhs=<null>`).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static void dumpPkg(const char* tag, const package* p) {
    std::cout << tag << " " << p->VpiName() << " typespecs="
              << (p->Typespecs() ? (int)p->Typespecs()->size() : -1) << "\n";
    if (p->Nets())
        for (auto* n : *p->Nets()) {
            auto* rt = n->Typespec();
            auto* act = rt ? rt->Actual_typespec() : nullptr;
            std::cout << "   NET " << n->VpiName() << " ts=" << (rt ? 1 : 0)
                      << " actual=" << (act ? UhdmName(act->UhdmType()) : "-")
                      << " same-as-ts0="
                      << (act && p->Typespecs() && !p->Typespecs()->empty() &&
                                  act == (*p->Typespecs())[0]
                              ? 1
                              : 0)
                      << " alias=" << (act && act->Typedef_alias() ? 1 : 0)
                      << "\n";
        }
    if (!p->Typespecs()) return;
    int i = 0;
    for (auto* t : *p->Typespecs()) {
        std::cout << "   [" << i++ << "] " << UhdmName(t->UhdmType()) << " '"
                  << t->VpiName() << "' alias="
                  << (t->Typedef_alias() ? 1 : 0)
                  << " inst=" << (t->Instance() ? 1 : 0) << "\n";
        if (t == (p->Typespecs() ? (*p->Typespecs())[0] : nullptr))
            std::cout << "        (ts[0])\n";
        if (auto* a = t->Typedef_alias())
            std::cout << "        alias.full='" << a->VpiFullName()
                      << "' actual="
                      << (a->Actual_typespec()
                              ? std::string(a->Actual_typespec()->VpiName())
                              : std::string("<null>"))
                      << "\n";
    }
}

static std::string nm2(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

// Elementwise compare of one package's vectors with FRESH contexts, so the
// first genuinely-unequal member is named instead of the container.
template <typename V>
static void pairwise(const char* tag, const V* a, const V* b) {
    if (!a || !b) return;
    for (size_t i = 0; i < a->size() && i < b->size(); i++) {
        CompareContext c;
        int r = (*a)[i]->Compare((*b)[i], &c);
        if (r != 0)
            std::cout << "  " << tag << "[" << i << "] r=" << r << " "
                      << nm2((*a)[i]) << " vs " << nm2((*b)[i])
                      << "\n      failLhs " << nm2(c.m_failedLhs)
                      << "\n      failRhs " << nm2(c.m_failedRhs) << "\n";
    }
}

// Instance() is chased by typespec::Compare, so a missing package stamp shows
// up as `failLhs=package failRhs=<null>` with no dump-visible difference.
static void tsInst(const char* tag, const any* a, const any* b) {
    auto ts = [](const any* o) -> const typespec* {
        if (!o) return nullptr;
        if (o->UhdmType() == uhdmparameter) {
            auto* rt = ((const parameter*)o)->Typespec();
            return rt ? rt->Actual_typespec() : nullptr;
        }
        return nullptr;
    };
    auto* ta = ts(a);
    auto* tb = ts(b);
    if (!ta && !tb) return;
    std::cout << "    " << tag << " tsA=" << (ta ? UhdmName(ta->UhdmType()) : "-")
              << " instA=" << (ta && ta->Instance() ? 1 : 0)
              << " tsB=" << (tb ? UhdmName(tb->UhdmType()) : "-")
              << " instB=" << (tb && tb->Instance() ? 1 : 0) << "\n";
}

static void pairwisePkg(const package* a, const package* b) {
    if (a->Parameters() && b->Parameters())
        for (size_t i = 0; i < a->Parameters()->size() &&
                           i < b->Parameters()->size();
             i++) {
            CompareContext c0;
            if ((*a->Parameters())[i]->Compare((*b->Parameters())[i], &c0) != 0)
                tsInst(std::string(std::string("P") + std::to_string(i)).c_str(),
                       (*a->Parameters())[i], (*b->Parameters())[i]);
        }
    pairwise("Parameters", a->Parameters(), b->Parameters());
    pairwise("ParamAssigns", a->Param_assigns(), b->Param_assigns());
    pairwise("Typespecs", a->Typespecs(), b->Typespecs());
    pairwise("TaskFuncs", a->Task_funcs(), b->Task_funcs());
    pairwise("Nets", a->Nets(), b->Nets());
    pairwise("Variables", a->Variables(), b->Variables());
    pairwise("ClassDefns", a->Class_defns(), b->Class_defns());
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::string want = argc > 3 ? argv[3] : "";
    auto walk = [&](const char* tag, const VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v)
            if (want.empty() || p->VpiName() == want) dumpPkg(tag, p);
    };
    if (argc > 4 && std::string(argv[4]) == "pair") {
        auto pw = [&](const char* t, const VectorOfpackage* av,
                      const VectorOfpackage* bv) {
            if (!av || !bv) return;
            std::map<std::string, const package*> bm;
            for (auto* p : *bv) bm[std::string(p->VpiName())] = p;
            for (auto* p : *av) {
                if (!want.empty() && p->VpiName() != want) continue;
                auto it = bm.find(std::string(p->VpiName()));
                if (it == bm.end()) continue;
                std::cout << t << " " << p->VpiName() << "\n";
                pairwisePkg(p, it->second);
            }
        };
        pw("def", da->AllPackages(), db->AllPackages());
        pw("top", da->TopPackages(), db->TopPackages());
        return 0;
    }
    walk("GOLD-def", da->AllPackages());
    walk("GOLD-top", da->TopPackages());
    walk("SLANG-def", db->AllPackages());
    walk("SLANG-top", db->TopPackages());
    return 0;
}
