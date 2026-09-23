// tsref112 <uhdm> <line> <col>: every ref_typespec whose Actual sits at line:col,
// with the ref's fullname, the REFERRER chain, the actual's UhdmId and whether the
// actual carries a Typedef_alias (and that alias's actual id).  Read-only.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;
static std::string chain(const BaseClass* n) {
    std::string out; int guard = 0;
    for (const BaseClass* p = n; p && guard < 20; p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
        out += "@" + std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo());
    }
    return out;
}
int main(int argc, char** argv) {
    if (argc < 4) { std::cerr << "usage: tsref112 <uhdm> <line> <col>\n"; return 2; }
    unsigned wl = atoi(argv[2]), wc = atoi(argv[3]);
    Serializer s; s.Restore(std::filesystem::path(argv[1]));
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmref_typespec) continue;
        auto* r = (const ref_typespec*)obj;
        auto* a = r->Actual_typespec();
        if (!a || a->VpiLineNo() != wl || a->VpiColumnNo() != wc) continue;
        std::string al = "-";
        if (auto* ta = a->Typedef_alias())
            al = std::string("alias->") + (ta->Actual_typespec() ? std::to_string(ta->Actual_typespec()->UhdmId()) : "null");
        std::cout << "ref[" << r->VpiFullName() << "] actual=" << UhdmName(a->UhdmType()) << "(" << a->VpiName()
                  << ")#" << a->UhdmId() << " " << al << "\n   ref < " << chain(r->VpiParent()) << "\n";
    }
    return 0;
}
