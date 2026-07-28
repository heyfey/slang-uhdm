// r9tsid: report, per module_inst, the Actual_typespec POINTER of each
// parameter's ref_typespec, so def/elab typespec SHARING is visible.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const void*, int> ids;
static int idOf(const void* p) {
    if (!p) return -1;
    auto it = ids.find(p);
    if (it != ids.end()) return it->second;
    int n = (int)ids.size();
    ids[p] = n;
    return n;
}

static void walk(const module_inst* m) {
    std::cout << "MOD " << m->VpiFullName() << " (def=" << m->VpiDefName()
              << ")\n";
    if (m->Parameters())
        for (auto* p : *m->Parameters()) {
            const ref_typespec* rt = nullptr;
            if (p->UhdmType() == uhdmparameter)
                rt = ((const parameter*)p)->Typespec();
            std::cout << "   param " << p->VpiName() << " ts#"
                      << idOf(rt ? (const void*)rt->Actual_typespec() : nullptr)
                      << "\n";
        }
    if (m->Modules())
        for (auto* c : *m->Modules()) walk(c);
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (d->AllModules())
        for (auto* m : *d->AllModules()) walk(m);
    if (d->TopModules())
        for (auto* m : *d->TopModules()) walk(m);
    return 0;
}
