// kinds112 <uhdm>: for every module_inst in AllModules (DEF) and the TopModules tree
// (ELAB, recursive), print one line per vpiNet / vpiVariables object:
//   <view> <inst fullname> <net|var> <kind> <name> nt=<VpiNetType> ts=<actual typespec kind>
//   el=<first element kind> rg=<range count>
// Read-only; a SHAPE LISTER for the face-3 census.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;
static std::string tsk(const any* o) {
    const ref_typespec* rt = nullptr;
    if (auto* n = any_cast<const nets*>(o)) rt = n->Typespec();
    else if (auto* v = any_cast<const variables*>(o)) rt = v->Typespec();
    if (!rt) return "-";
    if (!rt->Actual_typespec()) return "null";
    return std::string(UhdmName(rt->Actual_typespec()->UhdmType()));
}
static void line(const char* view, const module_inst* m, const char* k, const any* o) {
    std::string el = "-", nt = "-"; int rg = -1;
    if (auto* pn = any_cast<const packed_array_net*>(o)) {
        if (pn->Elements() && !pn->Elements()->empty()) el = UhdmName((*pn->Elements())[0]->UhdmType());
        rg = pn->Ranges() ? (int)pn->Ranges()->size() : 0;
    }
    if (auto* pv = any_cast<const packed_array_var*>(o)) {
        if (pv->Elements() && !pv->Elements()->empty()) el = UhdmName((*pv->Elements())[0]->UhdmType());
        rg = pv->Ranges() ? (int)pv->Ranges()->size() : 0;
    }
    if (auto* n = any_cast<const nets*>(o)) nt = std::to_string(n->VpiNetType());
    std::cout << view << " " << m->VpiFullName() << " " << k << " " << UhdmName(o->UhdmType()) << " "
              << o->VpiName() << " nt=" << nt << " ts=" << tsk(o) << " el=" << el << " rg=" << rg << "\n";
}
static void walk(const char* view, const module_inst* m) {
    if (m->Nets()) for (auto* n : *m->Nets()) line(view, m, "net", n);
    if (m->Variables()) for (auto* v : *m->Variables()) line(view, m, "var", v);
    if (m->Modules()) for (auto* c : *m->Modules()) walk(view, c);
}
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s; auto hs = s.Restore(std::filesystem::path(argv[1]));
    for (auto h : hs) {
        auto* d = (const design*)((uhdm_handle*)h)->object;
        if (d->AllModules()) for (auto* m : *d->AllModules()) walk("DEF", (const module_inst*)m);
        if (d->TopModules()) for (auto* m : *d->TopModules()) walk("ELAB", (const module_inst*)m);
    }
    return 0;
}
