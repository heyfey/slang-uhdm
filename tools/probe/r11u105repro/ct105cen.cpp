// r11u105 — DATABASE CENSUS for § caTopNamesakeKeyAtEntry105 (LAW A),
// § caProgramNamesakeKeyAtEntry105 (LAW B) and § caIfaceNamesakeKeyAtEntry105
// (LAW C); ct103cen.cpp lineage.  MEASUREMENT ONLY; `uhdm-cmp` is the sole
// acceptance judge.
//
// Reads each database named on stdin (one path per line), restores it, and
// prints one line per design->AllModules / AllPrograms / AllInterfaces /
// TopModules entry:
//   DEF <db> <kind>:<vpiDefName> ports=<n>      kind = MOD PROG IFACE TOP
// plus, per database, every BARE name X published as a nested module
// `work@<outer>::X` AND as a file-scope entry of some kind:
//   NAMESAKE <db> <kind> <X>
// (MOD = pass 102's shape; TOP = LAW A; PROG = LAW B; IFACE = LAW C).
//
// build: g++ -O2 -std=c++17 ct105cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct105cen
// usage: ct105cen < list-of-databases
#include <uhdm/uhdm.h>

#include <cstdio>
#include <iostream>
#include <map>
#include <set>
#include <string>

using namespace UHDM;

static std::string bareOf(std::string_view dn) {
    std::string s(dn);
    auto at = s.find('@');
    return at == std::string::npos ? s : s.substr(at + 1);
}

int main() {
    std::string db;
    long nDb = 0, nFail = 0, nNs = 0;
    while (std::getline(std::cin, db)) {
        if (db.empty()) continue;
        ++nDb;
        Serializer s;
        auto designs = s.Restore(db);
        if (designs.empty()) {
            printf("RESTORE_FAIL %s\n", db.c_str());
            ++nFail;
            continue;
        }
        std::map<std::string, std::set<std::string>> fileScope;  // kind -> bare names
        std::set<std::string> nestedLeaf;
        auto note = [&](const char* kind, std::string_view dn, size_t np) {
            printf("DEF %s %s:%s ports=%zu\n", db.c_str(), kind,
                   std::string(dn).c_str(), np);
            std::string nm = bareOf(dn);
            auto cc = nm.rfind("::");
            if (cc == std::string::npos) fileScope[kind].insert(nm);
            else if (std::string(kind) == "MOD") nestedLeaf.insert(nm.substr(cc + 2));
        };
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != uhdmdesign) continue;
            const design* dz = (const design*)o;
            if (dz->AllModules())
                for (auto* m : *dz->AllModules())
                    note("MOD", m->VpiDefName(), m->Ports() ? m->Ports()->size() : 0);
            if (dz->AllPrograms())
                for (auto* m : *dz->AllPrograms())
                    note("PROG", m->VpiDefName(), m->Ports() ? m->Ports()->size() : 0);
            if (dz->AllInterfaces())
                for (auto* m : *dz->AllInterfaces())
                    note("IFACE", m->VpiDefName(), m->Ports() ? m->Ports()->size() : 0);
            if (dz->TopModules())
                for (auto* m : *dz->TopModules())
                    note("TOP", m->VpiDefName(), m->Ports() ? m->Ports()->size() : 0);
        }
        bool hit = false;
        for (auto& [kind, names] : fileScope)
            for (auto& b : names)
                if (nestedLeaf.count(b)) {
                    printf("NAMESAKE %s %s %s\n", db.c_str(), kind.c_str(), b.c_str());
                    hit = true;
                }
        if (hit) ++nNs;
    }
    printf("#DATABASES %ld RESTORE_FAIL %ld WITH-NAMESAKE %ld\n", nDb, nFail, nNs);
    return 0;
}
