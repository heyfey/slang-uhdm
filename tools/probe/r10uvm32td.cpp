// r10uvm32td — the PACKAGE TYPEDEF-LISTING census.
//
// Pass 31's ranked #1 (SeqDriver's 1148 `INST` rows, golden `@adpcm_pkg` where
// we say `@uvm_pkg`) and its #2 (the 76 `uvm_pkg::uvm_hdl_data_t` NAME rows)
// were decoded per-ROW.  The model this probe tests is one level down:
//
//   Surelog's UhdmWriter emits a TYPEDEF LISTING per package (`writeDataTypes`)
//   and stamps `vpiInstance` on each entry as it writes it.  A WILDCARD-IMPORTED
//   typedef is SHARED into the importing package's listing — the same object,
//   not a copy — so the LAST package written re-stamps it and wins for every
//   reader in the whole design.
//
// Output:
//   LIST <view> <pkg> [i] <kind> '<name>' inst=<inst> ts#<gid>
//   OBJ  ts#<gid> <kind> '<name>' inst=<inst> listings=<pkgA,pkgB,...>
//
// `listings` in emission order is exactly the "who wrote last" evidence.
//
//   r10uvm32td <file.uhdm>            both sections
//   r10uvm32td <file.uhdm> --objects  only the OBJ section
//   r10uvm32td <file.uhdm> --shared   only OBJ rows listed by >1 package
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static bool objectsOnly = false, sharedOnly = false;
static std::map<const BaseClass*, int> ids;
static std::vector<const typespec*> order;
static std::map<int, std::vector<std::string>> listings;

static int idOf(const typespec* o) {
    auto it = ids.find(o);
    if (it != ids.end()) return it->second;
    int n = (int)ids.size();
    ids[o] = n;
    if ((int)order.size() <= n) order.resize(n + 1, nullptr);
    order[n] = o;
    return n;
}
static std::string tn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}

template <typename V>
static void doScope(const char* tag, const V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string nm(p->VpiName());
        auto* tss = p->Typespecs();
        if (!tss) continue;
        size_t i = 0;
        for (auto* ts : *tss) {
            int g = idOf(ts);
            listings[g].push_back(std::string(tag) + ":" + nm);
            if (!objectsOnly && !sharedOnly)
                std::cout << "LIST " << tag << " " << nm << " [" << i << "] "
                          << tn(ts) << " '" << ts->VpiName() << "' inst="
                          << (ts->Instance() ? ts->Instance()->VpiName() : "<null>")
                          << " ts#" << g << "\n";
            i++;
        }
    }
}

int main(int argc, char** argv) {
    for (int i = 2; i < argc; i++) {
        std::string a(argv[i]);
        if (a == "--objects") objectsOnly = true;
        if (a == "--shared") sharedOnly = true;
    }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    doScope("DEFPKG", d->AllPackages());
    doScope("ELABPKG", d->TopPackages());
    doScope("DEFMOD", d->AllModules());
    doScope("TOPMOD", d->TopModules());
    for (size_t i = 0; i < order.size(); i++) {
        const typespec* ts = order[i];
        if (!ts) continue;
        auto& ls = listings[(int)i];
        if (sharedOnly && ls.size() < 2) continue;
        std::cout << "OBJ ts#" << i << " " << tn(ts) << " '" << ts->VpiName()
                  << "' inst="
                  << (ts->Instance() ? ts->Instance()->VpiName() : "<null>")
                  << " listings=";
        for (size_t j = 0; j < ls.size(); j++)
            std::cout << (j ? "," : "") << ls[j];
        std::cout << "\n";
    }
    return 0;
}
