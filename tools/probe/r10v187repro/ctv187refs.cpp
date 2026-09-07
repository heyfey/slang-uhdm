// r10v187 -- list the REFERRERS of every typespec with a given VpiName, so an
// nsh (sharer-count) delta can be attributed to a named object.
// MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string pk(const any* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "NULL";
}
static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: v187refs <file.uhdm> <VpiName>\n"; return 2; }
    Serializer s;
    auto r = s.Restore(std::string(argv[1]));
    if (r.empty()) { std::cerr << "RESTORE-FAILED " << argv[1] << "\n"; return 3; }
    std::string want = argv[2];
    std::map<uint32_t, std::vector<const ref_typespec*>> refs;
    for (auto& it : s.AllObjects())
        if (it.first && it.first->UhdmType() == uhdmref_typespec)
            if (auto* a = ((const ref_typespec*)it.first)->Actual_typespec())
                refs[a->UhdmId()].push_back((const ref_typespec*)it.first);
    for (auto& it : s.AllObjects()) {
        const BaseClass* o = it.first;
        if (!o) continue;
        const typespec* ts = dynamic_cast<const typespec*>(o);
        if (!ts || std::string(ts->VpiName()) != want) continue;
        std::cout << UhdmName(ts->UhdmType()) << " id=" << ts->UhdmId()
                  << " '" << ts->VpiName() << "' @" << loc(ts)
                  << " parent=" << pk(ts->VpiParent())
                  << " alias=" << (ts->Typedef_alias() ? "yes" : "no")
                  << " sharers=" << refs[ts->UhdmId()].size() << "\n";
        for (auto* rt : refs[ts->UhdmId()]) {
            const any* p = rt->VpiParent();
            std::cout << "    <- ref_typespec id=" << rt->UhdmId()
                      << " full='" << rt->VpiFullName() << "'"
                      << " refparent=" << pk(p) << "@" << loc(p);
            if (p && p->VpiParent())
                std::cout << " gp=" << pk(p->VpiParent()) << "@" << loc(p->VpiParent());
            std::cout << "\n";
        }
    }
    return 0;
}
