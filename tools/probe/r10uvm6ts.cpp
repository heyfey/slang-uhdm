// r10uvm6ts: whole-pool census of every typespec object, projected onto
// (uhdm type, name-is-qualified?, VpiName, file:line).  Serializer::AllObjects
// reaches objects no listing walk can, so this answers "does golden EVER
// qualify a <kind>_typespec name, or is bare universal" without guessing which
// container to look in.
//   r10uvm6ts <file.uhdm> [mode]
//     mode=sum   (default) per-uhdm-type qualified/bare counts
//     mode=rows  one line per object: type|qual|name|line
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
    std::map<std::string, std::pair<long, long>> sum;  // type -> (qual, bare)
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const any* a = (const any*)o;
        if (!a->UhdmType()) continue;
        std::string tn(UhdmName(a->UhdmType()));
        if (tn.find("typespec") == std::string::npos) continue;
        std::string nm(o->VpiName());
        bool qual = nm.find("::") != std::string::npos;
        if (mode == "rows") {
            std::cout << tn << "|" << (qual ? "Q" : (nm.empty() ? "-" : "B"))
                      << "|" << nm << "|" << o->VpiLineNo() << ":"
                      << o->VpiColumnNo() << "\n";
        } else {
            if (nm.empty()) continue;
            if (qual)
                sum[tn].first++;
            else
                sum[tn].second++;
        }
    }
    if (mode != "rows")
        for (auto& kv : sum)
            std::cout << kv.first << " qual=" << kv.second.first
                      << " bare=" << kv.second.second << "\n";
    return 0;
}
