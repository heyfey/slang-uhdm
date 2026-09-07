// r10uvm187 — sharer count + identity of a NAMED typespec.  MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: sh187 <file.uhdm> <VpiName>\n"; return 2; }
    Serializer s; auto r = s.Restore(std::string(argv[1]));
    if (r.empty()) { std::cerr << "RESTORE-FAILED\n"; return 3; }
    std::string want = argv[2];
    std::map<uint32_t,int> sh;
    for (auto& it : s.AllObjects())
        if (it.first && it.first->UhdmType() == uhdmref_typespec)
            if (auto* a = ((const ref_typespec*)it.first)->Actual_typespec()) sh[a->UhdmId()]++;
    for (auto& it : s.AllObjects()) {
        const BaseClass* o = it.first;
        if (!o) continue;
        auto t = o->UhdmType();
        if (t < uhdmarray_typespec || t > uhdmvoid_typespec) { }
        const typespec* ts = dynamic_cast<const typespec*>(o);
        if (!ts) continue;
        if (std::string(ts->VpiName()) != want) continue;
        std::cout << UhdmName(t) << " id=" << ts->UhdmId()
                  << " name='" << ts->VpiName() << "'"
                  << " @" << ts->VpiLineNo() << ":" << ts->VpiColumnNo()
                  << "-" << ts->VpiEndLineNo() << ":" << ts->VpiEndColumnNo()
                  << " parent=" << (ts->VpiParent() ? UhdmName(ts->VpiParent()->UhdmType()) : "NULL")
                  << " alias=" << (ts->Typedef_alias() ? "yes" : "no")
                  << " inst=" << (ts->Instance() ? "yes" : "no")
                  << " sharers=" << (sh.count(ts->UhdmId()) ? sh[ts->UhdmId()] : 0) << "\n";
    }
    return 0;
}
