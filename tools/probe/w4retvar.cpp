// Every *_var object of a given NAME in the arena with its parent chain and
// the typespec it binds: the return-value local a task_func's body refs
// resolve to. Counts the clone forest from the VAR side (rp32 enc32: golden
// 9 per view, one per `enc32 = ...` assignment).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 20;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
    }
    return out;
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: w4retvar <uhdm> <var-name>\n"; return 2; }
    std::string want = argv[2];
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    int n = 0;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        auto* v = dynamic_cast<const variables*>(obj);
        if (!v || std::string(v->VpiName()) != want) continue;
        std::cout << "#" << n++ << " " << UhdmName(obj->UhdmType()) << " ts=";
        if (auto* rt = v->Typespec()) {
            if (auto* a = rt->Actual_typespec())
                std::cout << UhdmName(a->UhdmType()) << "(" << a->VpiName()
                          << ") @" << (const void*)a;
        }
        std::cout << "\n   " << chain((const BaseClass*)v->VpiParent()) << "\n";
    }
    return 0;
}
