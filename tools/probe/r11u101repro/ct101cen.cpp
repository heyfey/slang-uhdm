// r11u101 — PRISTINE-DATABASE PREDICTOR for the nested-module publication laws.
// MEASUREMENT ONLY; `uhdm-cmp` is the sole acceptance judge.
//
// Reads each database named on stdin (one path per line), restores it, and
// prints every DEFINITION-listing entry (design->AllModules) whose VpiDefName
// is SCOPED (`work@<outer>::<inner>`) — the population r11u99's LAW B1
// publishes, and the precondition of this pass's LAW B (a nested definition
// that WON a bare-key collision is published; the one that lost is not).
// A database that prints no
// NESTDEF line holds no nested definition our pristine binary published.
//
// LAW A's population (a ported/parameterized nested module) is ABSENT from a
// pristine database by construction — that is the bug — so it is predicted
// from SOURCE by cellcen101.py's R11U101NESTANY superset, not here.
//
// build: g++ -O2 -std=c++17 ct101cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct101cen
// usage: ct101cen < list-of-databases
#include <uhdm/uhdm.h>

#include <cstdio>
#include <iostream>
#include <string>

using namespace UHDM;

int main() {
    std::string db;
    long nDb = 0, nFail = 0, nHit = 0;
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
        bool hit = false;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != uhdmdesign) continue;
            const design* dz = (const design*)o;
            if (!dz->AllModules()) continue;
            for (auto* m : *dz->AllModules()) {
                std::string dn(m->VpiDefName());
                if (dn.find("::") != std::string::npos) {
                    printf("NESTDEF %s %s\n", db.c_str(), dn.c_str());
                    hit = true;
                }
            }
        }
        if (hit) ++nHit;
    }
    printf("#DATABASES %ld RESTORE_FAIL %ld WITH-NESTDEF %ld\n", nDb, nFail, nHit);
    return 0;
}
