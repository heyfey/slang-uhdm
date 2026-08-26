// r10v153 — module_inst Nets() vector sizes and members (MEASUREMENT ONLY).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;
int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj) continue;
        if (obj->UhdmType() != uhdmmodule_inst) continue;
        auto* m = (module_inst*)obj;
        auto* nets = m->Nets();
        size_t n = nets ? nets->size() : 0;
        printf("MODULE %s NETS=%zu\n", std::string(m->VpiName()).c_str(), n);
        if (argc > 2 && nets)
            for (size_t k = 0; k < nets->size(); k++)
                printf("  NET[%zu] %s %s @%u:%u\n", k,
                       std::string(UhdmName((*nets)[k]->UhdmType())).c_str(),
                       std::string((*nets)[k]->VpiName()).c_str(),
                       (*nets)[k]->VpiLineNo(), (unsigned)(*nets)[k]->VpiColumnNo());
    }
    return 0;
}
