// r10uvmnull: every class_typespec in the database, with whether its
// vpiClassDefn is set.  Used to find the one link the other side has and we
// do not.
//   r10uvmnull <db.uhdm> [onlynull]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer sa;
    sa.Restore(std::filesystem::path(argv[1]));
    bool onlyNull = argc > 2;
    std::map<std::string, int> tally;
    for (auto& [obj, id] : sa.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmclass_typespec) continue;
        auto* c = (class_typespec*)obj;
        bool has = c->Class_defn() != nullptr;
        if (onlyNull && has) continue;
        std::string key = std::string(c->VpiName()) + "|" +
                          (has ? std::string(c->Class_defn()->VpiName()) : std::string("<null>")) +
                          "|" + std::to_string(c->VpiLineNo()) + ":" +
                          std::to_string(c->VpiColumnNo());
        tally[key]++;
    }
    for (auto& [k, n] : tally) std::cout << n << "  " << k << "\n";
    return 0;
}
