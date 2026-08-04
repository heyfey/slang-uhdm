// r10bbp10e: dump arena objects BY UhdmId — type, name, loc, parent, and the
// handful of link slots that matter when a Compare stops on one of them
// (ref_typespec -> Actual_typespec, constant -> Typespec, ref_obj ->
// Actual_group).  The companion to r10bbp10c, which gives the containment
// path but not the object's own contents.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp10e.cpp -o /tmp/r10bbp10eq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp10eq <db.uhdm> <id>[,<id>...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string at(const any* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " id" +
                    std::to_string(n->UhdmId()) + " '" +
                    std::string(n->VpiName()) + "' " +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + " val=" +
             std::string(c->VpiValue()) + "}";
    }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::set<uint32_t> want;
    std::string ids(argv[2]);
    size_t p = 0;
    while (p < ids.size()) {
        size_t q = ids.find(',', p);
        if (q == std::string::npos) q = ids.size();
        want.insert((uint32_t)atoll(ids.substr(p, q - p).c_str()));
        p = q + 1;
    }
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj || want.find(obj->UhdmId()) == want.end()) continue;
        std::cout << at(obj) << "\n   parent=" << at(obj->VpiParent()) << "\n";
        if (obj->UhdmType() == uhdmref_typespec) {
            auto* rt = (const ref_typespec*)obj;
            std::cout << "   fullname='" << rt->VpiFullName()
                      << "'\n   actual_typespec=" << at(rt->Actual_typespec());
            if (auto* a = rt->Actual_typespec())
                std::cout << "\n   actual.parent=" << at(a->VpiParent());
            std::cout << "\n";
        }
        if (obj->UhdmType() == uhdmconstant) {
            auto* c = (const constant*)obj;
            std::cout << "   typespec=" << at(c->Typespec());
            if (auto* rt = c->Typespec())
                std::cout << "\n   ts.actual=" << at(rt->Actual_typespec());
            std::cout << "\n";
        }
        if (obj->UhdmType() == uhdmref_obj)
            std::cout << "   actual_group="
                      << at(((const ref_obj*)obj)->Actual_group()) << "\n";
    }
    return 0;
}
