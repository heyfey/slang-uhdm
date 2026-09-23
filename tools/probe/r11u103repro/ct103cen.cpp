// r11u103 — DATABASE CENSUS for § caNestedModFileScopeKeyAtEntry103 (LAW A)
// and § caUnelabBodyChildPorts103 (LAW B).  MEASUREMENT ONLY; `uhdm-cmp` is
// the sole acceptance judge.
//
// Reads each database named on stdin (one path per line), restores it, and
// prints one line per design->AllModules entry:
//   DEF <db> <vpiDefName> ports=<n>
// plus, per database, every BARE name that is published BOTH as a file-scope
// definition `work@X` and as a nested one `work@<outer>::X` (LAW A's shape):
//   NAMESAKE <db> <X>
// cen103.py joins the golden and ours lines of one test: an entry golden
// publishes WITH ports and ours WITHOUT (or not at all) is LAW B's / LAW A's
// cell, predicted BY NAME from the pristine databases.
//
// build: g++ -O2 -std=c++17 ct103cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct103cen
// usage: ct103cen < list-of-databases
#include <uhdm/uhdm.h>

#include <cstdio>
#include <iostream>
#include <set>
#include <string>

using namespace UHDM;

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
        std::set<std::string> bare, nestedLeaf;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != uhdmdesign) continue;
            const design* dz = (const design*)o;
            if (!dz->AllModules()) continue;
            for (auto* m : *dz->AllModules()) {
                std::string dn(m->VpiDefName());
                size_t np = m->Ports() ? m->Ports()->size() : 0;
                printf("DEF %s %s ports=%zu\n", db.c_str(), dn.c_str(), np);
                auto at = dn.find('@');
                std::string nm = at == std::string::npos ? dn : dn.substr(at + 1);
                auto cc = nm.rfind("::");
                if (cc == std::string::npos) bare.insert(nm);
                else nestedLeaf.insert(nm.substr(cc + 2));
            }
        }
        bool hit = false;
        for (auto& b : bare)
            if (nestedLeaf.count(b)) {
                printf("NAMESAKE %s %s\n", db.c_str(), b.c_str());
                hit = true;
            }
        if (hit) ++nNs;
    }
    printf("#DATABASES %ld RESTORE_FAIL %ld WITH-NAMESAKE %ld\n", nDb, nFail, nNs);
    return 0;
}
