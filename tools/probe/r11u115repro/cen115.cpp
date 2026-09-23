// cen115 <uhdm>: read-only DATABASE signatures for the r11u115 census.
//   F1 lines: per cont_assign home (G = under a gen_scope, M = otherwise), the constants
//     reached from the Rhs through OPERATIONS only (kind OP) or through operations and one
//     sys_func_call argument (kind SYS), split by whether they carry a typespec:
//       F1 <G|M> <OP|SYS> T=<typed> U=<untyped>
//     plus kind VS: constants that ARE a var_select index reached the same way
//     (containment walk from the cont_assign, not a parent walk: golden re-parents a folded
//      replication count at the package param_assign)
//   PV lines: every interface_inst param_assign whose Rhs is a constant:
//       PV <interface path> <param name> <value> <ts:Y|N> <size> <consttype>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;
static std::map<std::string, long> F1;
static void walk(const any* e, bool g, bool viaSys, int depth) {
    if (!e || depth > 64) return;
    switch (e->UhdmType()) {
    case uhdmconstant: {
        auto* c = (const constant*)e;
        std::string k = std::string("F1 ") + (g ? "G " : "M ") + (viaSys ? "SYS " : "OP ") + (c->Typespec() ? "T" : "U");
        F1[k]++;
        return;
    }
    case uhdmoperation: {
        auto* op = (const operation*)e;
        if (op->Operands()) for (auto* o : *op->Operands()) walk(o, g, viaSys, depth + 1);
        return;
    }
    case uhdmvar_select: {
        auto* vs = (const var_select*)e;
        if (vs->Exprs())
            for (auto* o : *vs->Exprs())
                if (o && o->UhdmType() == uhdmconstant) {
                    auto* c = (const constant*)o;
                    std::string k = std::string("F1 ") + (g ? "G " : "M ") + "VS " + (c->Typespec() ? "T" : "U");
                    F1[k]++;
                }
        return;
    }
    case uhdmsys_func_call: {
        if (viaSys) return;
        auto* sc = (const sys_func_call*)e;
        if (sc->Tf_call_args()) for (auto* o : *sc->Tf_call_args()) walk(o, g, true, depth + 1);
        return;
    }
    default: return;
    }
}
static std::string path(const any* o) {
    if (auto* ii = any_cast<const instance*>(o)) {
        std::string fn(ii->VpiFullName());
        if (!fn.empty()) return fn;
    }
    std::string p;
    for (const any* u = o; u; u = u->VpiParent()) {
        std::string n(u->VpiName());
        if (n.empty()) continue;
        p = p.empty() ? n : n + "." + p;
    }
    return p;
}
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s; s.Restore(std::filesystem::path(argv[1]));
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        if (obj->UhdmType() == uhdmcont_assign) {
            auto* ca = (const cont_assign*)obj;
            bool g = false;
            for (const any* u = ca->VpiParent(); u; u = u->VpiParent())
                if (u->UhdmType() == uhdmgen_scope) { g = true; break; }
            if (ca->Rhs() && ca->Rhs()->UhdmType() != uhdmconstant) walk(ca->Rhs(), g, false, 0);
        }
        if (obj->UhdmType() == uhdminterface_inst) {
            auto* ii = (const interface_inst*)obj;
            if (!ii->Param_assigns()) continue;
            std::string ip = path(ii);
            for (auto* pa : *ii->Param_assigns()) {
                if (!pa || !pa->Rhs() || pa->Rhs()->UhdmType() != uhdmconstant || !pa->Lhs()) continue;
                auto* c = (const constant*)pa->Rhs();
                std::cout << "PV " << ip << " " << pa->Lhs()->VpiName() << " " << c->VpiValue() << " "
                          << (c->Typespec() ? "Y" : "N") << " " << c->VpiSize() << " " << c->VpiConstType() << "\n";
            }
        }
    }
    for (auto& [k, v] : F1) std::cout << k << " " << v << "\n";
    return 0;
}
