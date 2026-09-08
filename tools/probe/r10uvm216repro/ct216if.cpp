// r10uvm216 — THE INTERFACE SUBROUTINE-LISTING PROBE.  MEASUREMENT ONLY;
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.  This tool
// only reads and prints.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHY IT EXISTS.  The r10uvm214 R0 head on MiniAmiq x2 is an element-wise
// mismatch inside an `interface_inst`'s `Task_funcs` VECTOR: golden's element
// and ours are BOTH present but are DIFFERENT objects, so the singular overload
// prints both faces and neither face names the field.  Only the full listing,
// side by side and keyed by DPI-ness, says which entries one side holds and the
// other does not.
//
// It enumerates, per interface (both the `AllInterfaces` DEF view and every
// `interface_inst` reachable from the design's top-module/instance tree), every
// Task_funcs element with:
//    index, kind, name, line span, vpiAccessType (3 = vpiDPIExportAcc,
//    4 = vpiDPIImportAcc), vpiDPICStr (2 = vpiDPIC), vpiDPIContext,
//    vpiDPICIdentifier, #IODecls, has-body.
//
// build: g++ -O2 -std=c++17 ct216if.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct216if
// usage: ct216if <db.uhdm> [<label>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static const char *accName(int a) {
    switch (a) {
        case 0: return "-";
        case vpiDPIExportAcc: return "EXPORT";
        case vpiDPIImportAcc: return "IMPORT";
        default: return "?";
    }
}

static void dumpTF(const char *label, const char *ifname, const char *view,
                   const BaseClass *owner) {
    const instance *inst = dynamic_cast<const instance *>(owner);
    if (!inst) return;
    VectorOftask_func *tf = inst->Task_funcs();
    if (!tf) {
        printf("%s IFACE %s view=%s id=%u NULLVEC\n", label, ifname, view,
               owner->UhdmId());
        return;
    }
    printf("%s IFACE %s view=%s id=%u size=%u\n", label, ifname, view,
           owner->UhdmId(), (unsigned)tf->size());
    for (size_t i = 0; i < tf->size(); i++) {
        const task_func *f = (*tf)[i];
        if (!f) { printf("%s   [%3u] <null>\n", label, (unsigned)i); continue; }
        size_t nio = f->Io_decls() ? f->Io_decls()->size() : 0;
        bool body = false;
        if (const function *fn = dynamic_cast<const function *>(f))
            body = fn->Stmt() != nullptr;
        else if (const task *tk = dynamic_cast<const task *>(f))
            body = tk->Stmt() != nullptr;
        printf("%s   [%3u] %-8s %-34s @%u:%u-%u:%u acc=%-6s cstr=%d ctx=%d "
               "cid=%s io=%u body=%d id=%u\n",
               label, (unsigned)i, std::string(UhdmName(f->UhdmType())).c_str(),
               std::string(f->VpiName()).c_str(), f->VpiLineNo(),
               (unsigned)f->VpiColumnNo(), f->VpiEndLineNo(),
               (unsigned)f->VpiEndColumnNo(), accName(f->VpiAccessType()),
               f->VpiDPICStr(), (int)f->VpiDPIContext(),
               f->VpiDPICIdentifier().empty()
                   ? "-"
                   : std::string(f->VpiDPICIdentifier()).c_str(),
               (unsigned)nio, (int)body, f->UhdmId());
    }
}

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct216if <db.uhdm> [label]\n"); return 2; }
    const char *label = argc > 2 ? argv[2] : "DB";
    Serializer s;
    s.Restore(std::string(argv[1]));

    // 1) DEF view: every interface object in the arena, by identity.
    std::set<const BaseClass *> seen;
    std::vector<const BaseClass *> defs, insts;
    for (auto &kv : s.AllObjects()) {
        const BaseClass *o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdminterface_inst) {
            // Distinguish DEF listing (parent is the design, held by
            // AllInterfaces) from an instance under a module.
            insts.push_back(o);
        }
    }
    // Print the design's AllInterfaces first, then everything else.
    const design *d = nullptr;
    for (auto &kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign) d = (const design *)kv.first;
    if (d && d->AllInterfaces())
        for (auto *i : *d->AllInterfaces()) {
            seen.insert(i);
            dumpTF(label, std::string(i->VpiDefName()).empty()
                              ? std::string(i->VpiName()).c_str()
                              : std::string(i->VpiDefName()).c_str(),
                   "ALLIFACE", i);
        }
    if (d && d->TopModules())
        for (auto *m : *d->TopModules())
            if (m->Interfaces())
                for (auto *i : *m->Interfaces()) {
                    if (!seen.insert(i).second) continue;
                    dumpTF(label, std::string(i->VpiDefName()).c_str(), "TOPMOD-IFACE", i);
                }
    for (const BaseClass *o : insts) {
        if (!seen.insert(o).second) continue;
        const interface_inst *i = (const interface_inst *)o;
        std::string par = i->VpiParent()
                              ? std::string(UhdmName(i->VpiParent()->UhdmType()))
                              : std::string("<null>");
        std::string vw = "OTHER:" + par;
        dumpTF(label, std::string(i->VpiDefName()).empty()
                          ? std::string(i->VpiName()).c_str()
                          : std::string(i->VpiDefName()).c_str(),
               vw.c_str(), o);
    }
    return 0;
}
