// r11u120 porttree: the typespec tree an ELABORATED port reads, with object
// identity (serializer id per type) and every ref's target — the fields uhdm-dump
// elides for a repeated (shared) object.  usage: porttree <file.uhdm> <inst fullname> <port>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <functional>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;
static std::map<const BaseClass*, uint32_t> ids;
static std::string tag(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = std::string(UhdmName(o->UhdmType())) + "#" + std::to_string(ids[o]) + "(" +
                    std::string(o->VpiName()) + ")@" + std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo()) + "-" + std::to_string(o->VpiEndLineNo()) + ":" +
                    std::to_string(o->VpiEndColumnNo());
    if (auto* p = o->VpiParent())
        s += " ^" + std::string(UhdmName(p->UhdmType())) + "#" + std::to_string(ids[p]) + "(" +
             std::string(p->VpiName()) + ")";
    return s;
}
static void tree(const BaseClass* o, int d) {
    std::string ind(d * 2, ' ');
    std::cout << ind << tag(o);
    if (!o) { std::cout << "\n"; return; }
    if (d > 14) { std::cout << " ...\n"; return; }
    switch (o->UhdmType()) {
    case uhdmconstant: std::cout << " val=" << ((const constant*)o)->VpiValue() << "\n"; return;
    case uhdmparameter: {
        auto* p = (const parameter*)o;
        std::cout << " full=" << p->VpiFullName() << " val=" << p->VpiValue() << "\n";
        return;
    }
    default: std::cout << "\n";
    }
    switch (o->UhdmType()) {
    case uhdmref_typespec: tree(((const ref_typespec*)o)->Actual_typespec(), d + 1); break;
    case uhdmref_obj: tree(((const ref_obj*)o)->Actual_group(), d + 1); break;
    case uhdmpacked_array_typespec: {
        auto* t = (const packed_array_typespec*)o;
        if (t->Ranges()) for (auto* r : *t->Ranges()) tree(r, d + 1);
        tree(t->Elem_typespec(), d + 1);
        break;
    }
    case uhdmlogic_typespec: {
        auto* t = (const logic_typespec*)o;
        if (t->Ranges()) for (auto* r : *t->Ranges()) tree(r, d + 1);
        break;
    }
    case uhdmrange: tree(((const range*)o)->Left_expr(), d + 1); tree(((const range*)o)->Right_expr(), d + 1); break;
    case uhdmoperation: {
        auto* op = (const operation*)o;
        if (op->Operands()) for (auto* x : *op->Operands()) tree(x, d + 1);
        break;
    }
    case uhdmtype_parameter: tree(((const type_parameter*)o)->Typespec(), d + 1); break;
    case uhdmsys_func_call: {
        auto* f = (const sys_func_call*)o;
        if (f->Tf_call_args()) for (auto* x : *f->Tf_call_args()) tree(x, d + 1);
        break;
    }
    case uhdmparam_assign: tree(((const param_assign*)o)->Lhs(), d + 1); tree(((const param_assign*)o)->Rhs(), d + 1); break;
    default: break;
    }
}
int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    ids = s.AllObjects();
    std::string inst = argv[2], port = argv[3];
    std::function<void(const module_inst*)> walk = [&](const module_inst* m) {
        if (std::string(m->VpiFullName()) == inst) {
            if (m->Ports()) for (auto* p : *m->Ports()) if (p->VpiName() == port) {
                std::cout << "PORT " << tag(p) << "\n";
                tree(p->Typespec(), 1);
                if (auto* lc = p->Low_conn()) { std::cout << " LOWCONN\n"; tree(lc, 1);
                    if (lc->UhdmType() == uhdmref_obj) if (auto* a = ((const ref_obj*)lc)->Actual_group())
                        if (a->UhdmType() == uhdmlogic_net) tree(((const logic_net*)a)->Typespec(), 2); }
            }
            if (m->Parameters()) for (auto* p : *m->Parameters()) { std::cout << "PARAM "; tree(p, 1); }
            if (m->Param_assigns()) for (auto* p : *m->Param_assigns()) { std::cout << "PA "; tree(p, 1); }
        }
        if (m->Modules()) for (auto* c : *m->Modules()) walk(c);
        if (m->Gen_scope_arrays()) for (auto* ga : *m->Gen_scope_arrays()) if (ga->Gen_scopes())
            for (auto* g : *ga->Gen_scopes()) if (g->Modules()) for (auto* c : *g->Modules()) walk(c);
    };
    for (auto hh : h) {
        auto* d = (const design*)((uhdm_handle*)hh)->object;
        if (d->TopModules()) for (auto* t : *d->TopModules()) walk((const module_inst*)t);
        // a DEFINITION (AllModules) by its VpiDefName, e.g. work@child
        if (d->AllModules()) for (auto* m : *d->AllModules())
            if (m->UhdmType() == uhdmmodule_inst && std::string(m->VpiDefName()) == inst) {
                auto* mm = (const module_inst*)m;
                if (mm->Ports()) for (auto* p : *mm->Ports()) if (p->VpiName() == port) {
                    std::cout << "DEFPORT " << tag(p) << "\n";
                    tree(p->Typespec(), 1);
                }
                if (mm->Parameters()) for (auto* p : *mm->Parameters()) { std::cout << "DEFPARAM "; tree(p, 1); }
            }
    }
    return 0;
}
