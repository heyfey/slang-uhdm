// r10iarng: interface_array range EXPR shapes (def + elab), one line per bound.
//   r10iarng <a.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string ex(const any* e) {
    if (!e) return "<null>";
    std::string r = UhdmName(e->UhdmType());
    if (auto* c = any_cast<const constant*>(e))
        r += "{" + std::string(c->VpiValue()) + ",dc=" +
             std::string(c->VpiDecompile()) + ",sz=" +
             std::to_string(c->VpiSize()) + ",ct=" +
             std::to_string(c->VpiConstType()) + "}";
    else if (auto* o = any_cast<const operation*>(e)) {
        r += "(op" + std::to_string(o->VpiOpType()) + " ";
        if (o->Operands())
            for (auto* p : *o->Operands()) r += ex(p) + " ";
        r += ")";
    }
    else if (auto* ro = any_cast<const ref_obj*>(e))
        r += "'" + std::string(ro->VpiName()) + "'";
    return r;
}

static void one(const std::string& tag, const module_inst* m) {
    if (m->Interface_arrays())
        for (auto* a : *m->Interface_arrays()) {
            std::cout << tag << " '" << a->VpiName() << "' size=" << a->VpiSize()
                      << " insts="
                      << (a->Instances() ? (int)a->Instances()->size() : -1);
            if (a->Ranges())
                for (auto* r : *a->Ranges())
                    std::cout << " [" << ex(r->Left_expr()) << " : "
                              << ex(r->Right_expr()) << "]";
            std::cout << "\n";
        }
    if (m->Modules())
        for (auto* c : *m->Modules())
            one(tag + "." + std::string(c->VpiName()), c);
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            one(std::string("DEF:") + std::string(m->VpiDefName()), m);
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            one(std::string("TOP:") + std::string(m->VpiName()), m);
    return 0;
}
