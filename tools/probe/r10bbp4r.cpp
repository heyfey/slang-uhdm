// r10bbp4r: REFERRER scan — find every ref_typespec / typespec_member whose
// actual (or every enum_typespec sharing a name) points at a named typespec,
// and print the referrer's parent chain.  uhdm-cmp names the failing OBJECT
// but not the container that reached it; this answers "who points here".
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp4r.cpp -o /tmp/r10bbp4rq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp4rq <db.uhdm> <typespec-name>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 12;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
        if (p->VpiLineNo())
            out += "@" + std::to_string(p->VpiLineNo()) + ":" +
                   std::to_string(p->VpiColumnNo());
    }
    return out;
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::string want = argv[2];
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    auto all = ser.AllObjects();
    std::set<const BaseClass*> targets;
    for (auto& [obj, id] : all) {
        if (!obj) continue;
        if (obj->UhdmType() == uhdmenum_typespec &&
            std::string(((const typespec*)obj)->VpiName()) == want)
            targets.insert(obj);
    }
    // Aggregate mode: name matches a struct/union typespec -> list its member
    // refs and what each one actually points at (per copy).
    for (auto& [obj, id] : all) {
        if (!obj) continue;
        VectorOftypespec_member* mems = nullptr;
        if (obj->UhdmType() == uhdmunion_typespec &&
            std::string(((const typespec*)obj)->VpiName()) == want)
            mems = ((const union_typespec*)obj)->Members();
        else if (obj->UhdmType() == uhdmstruct_typespec &&
                 std::string(((const typespec*)obj)->VpiName()) == want)
            mems = ((const struct_typespec*)obj)->Members();
        if (!mems) continue;
        std::cout << "AGG #" << obj->UhdmId() << " " << chain(obj) << "\n";
        for (auto* tm : *mems) {
            auto* r = tm->Typespec();
            auto* a = r ? r->Actual_typespec() : nullptr;
            std::cout << "   m " << tm->VpiName() << " ref"
                      << (r ? "#" + std::to_string(r->UhdmId()) + "{" +
                                  std::string(r->VpiFullName()) + "}"
                            : std::string("=null"))
                      << " -> "
                      << (a ? std::string(UhdmName(a->UhdmType())) + " '" +
                                  std::string(a->VpiName()) + "' #" +
                                  std::to_string(a->UhdmId()) + " inst=" +
                                  (a->Instance()
                                       ? std::string(a->Instance()->VpiName())
                                       : std::string("-"))
                            : std::string("null"))
                      << "\n";
        }
    }
    std::cout << "targets=" << targets.size() << "\n";
    for (auto* t : targets)
        std::cout << "  TARGET #" << t->UhdmId() << " " << chain(t) << "\n";
    for (auto& [obj, id] : all) {
        if (!obj || obj->UhdmType() != uhdmref_typespec) continue;
        auto* r = (const ref_typespec*)obj;
        if (!r->Actual_typespec()) continue;
        if (!targets.count((const BaseClass*)r->Actual_typespec())) continue;
        std::cout << "REF #" << r->UhdmId() << " {" << r->VpiFullName()
                  << "} -> #" << r->Actual_typespec()->UhdmId() << " :: "
                  << chain(r) << "\n";
    }
    return 0;
}
