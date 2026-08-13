// r10sd2 — WHO POINTS AT THE PACKAGE?  A whole-database, relation-by-relation
// census of every SINGULAR slot whose value is a `package` with the given name.
//
// The head is `LHS:<null>` / `RHS: package uvm_pkg`, i.e. BaseClass.h's singular
// arm: a slot filled on our side, NULL on golden's.  Rather than chase the
// traversal (which cycles through `vpiInstance`, see ct2find/ct2slot), this tool
// enumerates every object in each database out of the Serializer and asks, for
// each of the 154 relations the VPI layer exposes, whether that slot holds the
// package.  The result is a per-(owner type, relation) count on each side, so a
// shape we emit and golden does not is visible without any traversal at all.
//
// build: g++ -O2 -std=c++17 ct2ptr.cpp -I ~/.local/include -I. \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2ptr
// usage: ct2ptr <golden.uhdm> <ours.uhdm> <pkgName> [maxexamples]
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

struct Rel {
    int id;
    const char* name;
};
static const Rel kRels[] = {
#include "ct2rels.inc"
};
static const int kNRels = sizeof(kRels) / sizeof(kRels[0]);

static std::string g_pkg;
static int g_maxex = 6;

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    return s;
}

static bool isPkg(const BaseClass* p) {
    return p && p->UhdmType() == UHDM_OBJECT_TYPE::uhdmpackage &&
           std::string(p->VpiName()) == g_pkg;
}

static void census(const char* path, std::map<std::string, int>& out,
                   std::map<std::string, std::vector<std::string>>& ex,
                   int& nobj) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(path));
    if (h.empty()) { std::cerr << "RESTORE_FAIL " << path << "\n"; exit(3); }
    auto objs = s.AllObjects();
    nobj = (int)objs.size();
    for (const auto& [p, id] : objs) {
        if (!p) continue;
        vpiHandle ph = NewVpiHandle(p);
        for (int k = 0; k < kNRels; k++) {
            vpiHandle a = vpi_handle(kRels[k].id, ph);
            if (!a) continue;
            const BaseClass* v = (const BaseClass*)((uhdm_handle*)a)->object;
            if (!isPkg(v)) continue;
            std::string key =
                std::string(UhdmName(p->UhdmType())) + " . " + kRels[k].name;
            out[key]++;
            if ((int)ex[key].size() < g_maxex) ex[key].push_back(ident(p));
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 4) {
        std::cerr << "usage: ct2ptr <golden.uhdm> <ours.uhdm> <pkg> [maxex]\n";
        return 2;
    }
    g_pkg = argv[3];
    if (argc > 4) g_maxex = atoi(argv[4]);
    std::map<std::string, int> gc, oc;
    std::map<std::string, std::vector<std::string>> ge, oe;
    int gn = 0, on = 0;
    census(argv[1], gc, ge, gn);
    census(argv[2], oc, oe, on);
    std::cout << "objects: golden=" << gn << " ours=" << on << "\n";
    std::set<std::string> keys;
    for (const auto& [k, v] : gc) keys.insert(k);
    for (const auto& [k, v] : oc) keys.insert(k);
    std::cout << "\nslots holding package(" << g_pkg << "):\n";
    printf("%-46s %8s %8s %8s\n", "owner . relation", "GOLDEN", "OURS", "DELTA");
    for (const std::string& k : keys) {
        int a = gc.count(k) ? gc[k] : 0, b = oc.count(k) ? oc[k] : 0;
        printf("%-46s %8d %8d %+8d%s\n", k.c_str(), a, b, b - a,
               (a == 0 && b > 0) ? "   <-- OURS ONLY" : "");
    }
    for (const std::string& k : keys) {
        int a = gc.count(k) ? gc[k] : 0, b = oc.count(k) ? oc[k] : 0;
        if (a == b) continue;
        std::cout << "\n" << k << "   golden examples:\n";
        for (const auto& e : ge[k]) std::cout << "    G " << e << "\n";
        std::cout << k << "   ours examples:\n";
        for (const auto& e : oe[k]) std::cout << "    O " << e << "\n";
    }
    return 0;
}
