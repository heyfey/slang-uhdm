// r10scr8a: dump one instance's array_var / array_net RANGES as a tree, with
// every node's constant encoding and whether it carries a Typespec() ref (and
// to what).  Built to settle how Surelog folds a PARAM-SIZED unpacked
// dimension — the encoding AND the typespec ref are both CMP-compared.
//   r10scr8a <file.uhdm> <instance-fullname> [var-name]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    std::string r = std::string(UhdmName(o->UhdmType())) + "(" +
                    std::string(o->VpiName()) + ")@" +
                    std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo());
    if (o->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)o;
        r += "{ct=" + std::to_string(c->VpiConstType()) +
             ",sz=" + std::to_string(c->VpiSize()) +
             ",v=" + std::string(c->VpiValue()) +
             ",dc=" + std::string(c->VpiDecompile()) + "}";
    }
    if (o->UhdmType() == uhdmoperation)
        r += "{op=" + std::to_string(((const operation*)o)->VpiOpType()) + "}";
    return r;
}

static void walk(const any* e, int d) {
    if (!e) return;
    std::cout << std::string(d * 2, ' ') << nm(e);
    if (auto* x = dynamic_cast<const expr*>(e)) {
        if (auto* t = x->Typespec())
            std::cout << " TS=" << nm(t->Actual_typespec()) << " fn='"
                      << t->VpiFullName() << "'";
        else
            std::cout << " TS=<none>";
    }
    std::cout << "\n";
    if (e->UhdmType() == uhdmoperation)
        if (auto* ops = ((const operation*)e)->Operands())
            for (auto* o : *ops) walk(o, d + 1);
}

static void dumpRanges(const char* kind, const std::string& name,
                       const VectorOfrange* rs) {
    if (!rs) return;
    for (auto* r : *rs) {
        std::cout << kind << " " << name << " range@" << r->VpiLineNo() << ":"
                  << r->VpiColumnNo() << "\n";
        walk(r->Left_expr(), 1);
        walk(r->Right_expr(), 1);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string want = argc > 3 ? argv[3] : "";
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmmodule_inst) continue;
        auto* m = (const module_inst*)o;
        if (std::string(m->VpiFullName()) != argv[2]) continue;
        if (m->Variables())
            for (auto* v : *m->Variables()) {
                std::string n(v->VpiName());
                if (!want.empty() && n.find(want) == std::string::npos) continue;
                if (v->UhdmType() == uhdmarray_var)
                    dumpRanges("array_var", n, ((const array_var*)v)->Ranges());
            }
        if (m->Array_nets())
            for (auto* v : *m->Array_nets()) {
                std::string n(v->VpiName());
                if (!want.empty() && n.find(want) == std::string::npos) continue;
                dumpRanges("array_net", n, v->Ranges());
            }
        return 0;
    }
    return 0;
}
