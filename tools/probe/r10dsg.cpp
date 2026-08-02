// r10dsg: design-level vector inventory (the containers uhdm-cmp walks first).
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10dsg.cpp -o /tmp/r10dsg \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

// A task_func's return-var typespec: the ctor `class_typespec` whose
// Class_defn link uhdm-dump never prints (it shows a bare
// `\_class_typespec:` either way).
static void retTs(const std::string& tag, const VectorOftask_func* v) {
    if (!v)
        return;
    for (auto* tf : *v) {
        auto* rv = tf->Return();
        if (!rv || !rv->Typespec())
            continue;
        auto* at = rv->Typespec()->Actual_typespec();
        if (!at || at->UhdmType() != uhdmclass_typespec)
            continue;
        auto* ct = (class_typespec*)at;
        std::cout << tag << " ret-ts '" << tf->VpiFullName() << "' name='"
                  << ct->VpiName() << "' defn="
                  << (ct->Class_defn()
                          ? std::string(ct->Class_defn()->VpiFullName())
                          : "<null>")
                  << " inst="
                  << (ct->Instance() ? std::string(ct->Instance()->VpiName())
                                     : "<null>")
                  << "\n";
    }
}

template <typename V>
static void lst(const std::string& tag, const V* v) {
    if (!v) {
        std::cout << tag << " <null>\n";
        return;
    }
    std::cout << tag << " n=" << v->size() << "\n";
    int i = 0;
    for (auto* e : *v) {
        std::cout << tag << "[" << i++ << "] "
                  << (e ? UhdmName(e->UhdmType()) : "<NULL>") << " '"
                  << (e ? std::string(e->VpiName()) : std::string()) << "'";
        if (e && e->UhdmType() == uhdmclass_typespec) {
            auto* ct = (class_typespec*)e;
            std::cout << " defn="
                      << (ct->Class_defn()
                              ? std::string(ct->Class_defn()->VpiName())
                              : "<null>")
                      << " inst="
                      << (ct->Instance()
                              ? std::string(UhdmName(
                                    ct->Instance()->UhdmType())) +
                                    ":" + std::string(ct->Instance()->VpiName())
                              : "<null>");
        }
        std::cout << "\n";
    }
}

int main(int argc, char** argv) {
    if (argc < 2)
        return 1;
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    {
        std::cout << "design '" << d->VpiName() << "'\n";
        lst("AllPackages", d->AllPackages());
        lst("TopPackages", d->TopPackages());
        lst("AllClasses", d->AllClasses());
        lst("AllModules", d->AllModules());
        lst("TopModules", d->TopModules());
        lst("AllInterfaces", d->AllInterfaces());
        lst("AllPrograms", d->AllPrograms());
        lst("AllUdps", d->AllUdps());
        lst("TaskFuncs", d->Task_funcs());
        lst("Typespecs", d->Typespecs());
        lst("LetDecls", d->Let_decls());
        if (auto* cs = d->AllClasses())
            for (auto* c : *cs) {
                std::string t = "class[" + std::string(c->VpiName()) + "]";
                std::cout << t << ".extends="
                          << (c->Extends() ? "yes" : "<null>") << " virt="
                          << c->VpiVirtual() << "\n";
                if (auto* ex = c->Extends()) {
                    auto* rt = ex->Class_typespec();
                    auto* ct = rt && rt->Actual_typespec() &&
                                       rt->Actual_typespec()->UhdmType() ==
                                           uhdmclass_typespec
                                   ? (class_typespec*)rt->Actual_typespec()
                                   : nullptr;
                    std::cout << t << ".extends.ts="
                              << (ct ? std::string(ct->VpiName()) : "<null>")
                              << " defn="
                              << (ct && ct->Class_defn()
                                      ? std::string(ct->Class_defn()->VpiName())
                                      : "<null>")
                              << "\n";
                }
                lst(t + ".Deriveds", c->Deriveds());
                lst(t + ".TaskFuncs", c->Task_funcs());
                lst(t + ".Variables", c->Variables());
                lst(t + ".Typespecs", c->Typespecs());
                lst(t + ".Parameters", c->Parameters());
                lst(t + ".ParamAssigns", c->Param_assigns());
                lst(t + ".Scopes", c->Scopes());
                lst(t + ".Constraints", c->Constraints());
                lst(t + ".NamedEvents", c->Named_events());
                retTs(t, c->Task_funcs());
            }
        retTs("design", d->Task_funcs());
        if (auto* ps = d->AllPackages())
            for (auto* p : *ps)
                retTs("pkg[" + std::string(p->VpiName()) + ":top" +
                          std::to_string((int)p->VpiTop()) + "]",
                      p->Task_funcs());
        if (auto* ms = d->AllModules())
            for (auto* p : *ms)
                retTs("mod[" + std::string(p->VpiName()) + "]",
                      p->Task_funcs());
    }
    return 0;
}
