// r10uvmts: list a package's Typespecs with class-typespec linkage detail.
//   r10uvmts <db.uhdm> <[top:]pkgname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string loc(const BaseClass* o) {
    return "@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static const package* find(const design* d, const std::string& n) {
    bool top = false;
    std::string want = n;
    if (want.size() > 4 && want.compare(0, 4, "top:") == 0) { top = true; want = want.substr(4); }
    const VectorOfpackage* v = top ? d->TopPackages() : d->AllPackages();
    if (!v) return nullptr;
    for (auto* p : *v)
        if (std::string(p->VpiName()) == want) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    Serializer sa;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    const package* a = find(da, argv[2]);
    if (!a || !a->Typespecs()) { std::cout << "not found\n"; return 1; }
    for (auto* t : *a->Typespecs()) {
        std::cout << UhdmName(t->UhdmType()) << " '" << t->VpiName() << "' " << loc(t)
                  << " inst=" << (t->Instance() ? std::string(t->Instance()->VpiName()) : "-");
        if (t->UhdmType() == uhdmclass_typespec) {
            auto* c = (class_typespec*)t;
            std::cout << " defn="
                      << (c->Class_defn() ? std::string(c->Class_defn()->VpiName()) : "<null>")
                      << (c->Class_defn() ? loc(c->Class_defn()) : "")
                      << "#" << (c->Class_defn() ? c->Class_defn()->UhdmId() : 0)
                      << " params=" << (c->Parameters() ? c->Parameters()->size() : 0);
            if (auto* ta = c->Typedef_alias())
                std::cout << " alias->"
                          << (ta->Actual_typespec()
                                  ? std::string(ta->Actual_typespec()->VpiName())
                                  : "<null>");
        }
        std::cout << "\n";
    }
    return 0;
}
