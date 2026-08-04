// r10uvm6in: whole-pool census of vpiInstance STAMPING, per typespec kind and
// per binder kind.  The post-LAW-S SeqDriver head is 681 rows of `L <null> vs
// R package` — a typespec we instance and golden does not — and the pair the
// localizer prints is the INSTANCE, never the typespec that carries it, so
// this projects the other way: for every typespec, does it have an instance,
// and what kind is it.
//   r10uvm6in <file.uhdm> [mode]
//     mode=sum   (default) per-uhdm-type stamped/unstamped counts
//     mode=rows  type|stamped|name|line for the stamped ones
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    std::string mode = argc > 2 ? argv[2] : "sum";
    std::map<std::string, std::pair<long, long>> sum;  // (stamped, bare)
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        auto* a = (const any*)o;
        std::string tn(UhdmName(a->UhdmType()));
        if (tn.find("typespec") == std::string::npos ||
            tn == "ref_typespec")
            continue;
        bool st = ((const typespec*)a)->Instance() != nullptr;
        if (mode == "rows") {
            if (st)
                std::cout << tn << "|" << std::string(o->VpiName()) << "|"
                          << o->VpiLineNo() << "\n";
        } else if (st)
            sum[tn].first++;
        else
            sum[tn].second++;
    }
    if (mode != "rows")
        for (auto& kv : sum)
            std::cout << kv.first << " stamped=" << kv.second.first
                      << " bare=" << kv.second.second << "\n";
    return 0;
}
