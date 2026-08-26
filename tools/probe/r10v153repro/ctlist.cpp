// r10v153 — the PACKAGE Variables() listing, in ORDER (MEASUREMENT ONLY).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmpackage) continue;
        auto* p = (package*)obj;
        auto* v = p->Variables();
        printf("PACKAGE %s ELAB=%d VARS=%zu\n", std::string(p->VpiName()).c_str(),
               (int)p->VpiTop(), v ? v->size() : 0);
        if (v) for (size_t k = 0; k < v->size(); k++)
            printf("  [%zu] %s %s @%u:%u-%u:%u\n", k,
                   std::string(UhdmName((*v)[k]->UhdmType())).c_str(),
                   std::string((*v)[k]->VpiName()).c_str(),
                   (*v)[k]->VpiLineNo(), (unsigned)(*v)[k]->VpiColumnNo(),
                   (*v)[k]->VpiEndLineNo(), (unsigned)(*v)[k]->VpiEndColumnNo());
    }
    return 0;
}
