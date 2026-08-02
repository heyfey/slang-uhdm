// r10clscmp: per-class_defn, per-Task_func Compare with a FRESH context each,
// so a class-method BODY difference names the method instead of being hidden
// behind the package container that owns it.
//   r10clscmp <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static void one(const std::string& what, const BaseClass* a, const BaseClass* b) {
    if (!a && !b) return;
    if (!a || !b) {
        std::cout << what << ": NULLNESS lhs=" << (a ? "obj" : "null") << " rhs="
                  << (b ? "obj" : "null") << "\n";
        return;
    }
    CompareContext c;
    if (a->Compare(b, &c) != 0)
        std::cout << what << ": DIFF failLhs=" << nm(c.m_failedLhs)
                  << " failRhs=" << nm(c.m_failedRhs) << "\n";
    else
        std::cout << what << ": ok\n";
}

static void cls(const class_defn* a, const class_defn* b) {
    std::string t = std::string(a->VpiFullName());
    one(t + ".WHOLE", a, b);
    auto* va = a->Variables();
    auto* vb = b->Variables();
    if (va && vb && va->size() == vb->size())
        for (size_t i = 0; i < va->size(); i++)
            one(t + ".Var[" + std::to_string(i) + "]" +
                    std::string(va->at(i)->VpiName()),
                va->at(i), vb->at(i));
    auto* ta = a->Task_funcs();
    auto* tb = b->Task_funcs();
    if (!ta || !tb || ta->size() != tb->size()) {
        std::cout << t << ".Task_funcs SIZE " << (ta ? (int)ta->size() : -1)
                  << " vs " << (tb ? (int)tb->size() : -1) << "\n";
        return;
    }
    for (size_t i = 0; i < ta->size(); i++)
        one(t + ".Tf[" + std::to_string(i) + "]" +
                std::string(ta->at(i)->VpiName()) + "@" +
                std::to_string(ta->at(i)->VpiLineNo()),
            ta->at(i), tb->at(i));
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    auto walk = [&](const VectorOfpackage* pa, const VectorOfpackage* pb) {
        if (!pa || !pb || pa->size() != pb->size()) return;
        for (size_t i = 0; i < pa->size(); i++) {
            auto* ca = pa->at(i)->Class_defns();
            auto* cb = pb->at(i)->Class_defns();
            if (!ca || !cb || ca->size() != cb->size()) continue;
            for (size_t j = 0; j < ca->size(); j++) cls(ca->at(j), cb->at(j));
        }
    };
    walk(da->TopPackages(), db->TopPackages());
    walk(da->AllPackages(), db->AllPackages());
    return 0;
}
