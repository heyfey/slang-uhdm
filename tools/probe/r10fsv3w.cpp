// r10fsv3w: WHERE-IS.  Serializer::AllObjects() gives every restored object, so
// an id reported by a Compare failure (CompareContext names an object but not a
// location in the design) can be resolved back to its type / span / parent chain
// -- and, by scanning every object's parent, to its CHILDREN.  This is the
// cheap complement to r10fsv2c: that tool says WHICH design-list entry failed,
// this one says WHAT the failing object is.
//   g++ -std=c++17 -I$HOME/.local/include r10fsv3w.cpp -o r10fsv3w \
//       -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
//   r10fsv3w <a.uhdm> <id> [<id>...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string desc(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + " id" +
           std::to_string(o->UhdmId()) + " '" + std::string(o->VpiName()) +
           "' " + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    auto all = s.AllObjects();
    std::map<uint32_t, const BaseClass*> byId;
    std::map<const BaseClass*, std::vector<const BaseClass*>> kids;
    for (auto& [o, id] : all) {
        byId[o->UhdmId()] = o;
        if (o->VpiParent()) kids[o->VpiParent()].push_back(o);
    }
    for (int i = 2; i < argc; i++) {
        if (std::string(argv[i]) == "lists") {
            // Which package/module OBJECT sits in which design list: the def
            // (uhdmallPackages) and elab (uhdmtopPackages) views are distinct
            // objects with identical names and spans, so an id is the only way
            // to tell which view a Compare failure landed in.
            const design* d = nullptr;
            for (auto& [o, _] : all)
                if (o->UhdmType() == uhdmdesign) d = (const design*)o;
            auto dump = [&](const char* lbl, auto* v) {
                if (!v) return;
                for (auto* e : *v)
                    std::cout << lbl << ": " << desc(e) << "\n";
            };
            dump("AllPackages", d->AllPackages());
            dump("TopPackages", d->TopPackages());
            dump("AllModules", d->AllModules());
            dump("TopModules", d->TopModules());
            continue;
        }
        uint32_t id = (uint32_t)atoi(argv[i]);
        auto it = byId.find(id);
        if (it == byId.end()) {
            std::cout << "id" << id << ": NOT FOUND\n";
            continue;
        }
        const BaseClass* o = it->second;
        std::cout << "=== " << desc(o) << "\n";
        if (o->UhdmType() == uhdmconstant) {
            auto* c = (const constant*)o;
            std::cout << "    ct" << c->VpiConstType() << " sz" << c->VpiSize()
                      << " dc'" << c->VpiDecompile() << "' val'" << c->VpiValue()
                      << "'\n";
        }
        std::cout << "  parents:\n";
        for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
            std::cout << "    " << desc(p) << "\n";
        auto kit = kids.find(o);
        if (kit != kids.end()) {
            std::cout << "  children (" << kit->second.size() << "):\n";
            for (auto* k : kit->second)
                std::cout << "    " << desc(k) << "\n";
        }
    }
    return 0;
}
