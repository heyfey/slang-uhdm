// r10scr8pa: print the design-level ($unit) param_assign RHS EXPRESSION TREES,
// one indented block per assign, filtered by the Lhs parameter name.  The
// $unit fold model is decided by what Surelog substitutes INTO an unfolded
// tree, so the tree shape (not a scalar census) is the measurement.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr8pa.cpp -o /tmp/r10scr8_pa \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
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
    if (const ref_obj* ro = dynamic_cast<const ref_obj*>(o))
        r += " act=" + std::string(ro->Actual_group()
                                       ? UhdmName(ro->Actual_group()->UhdmType())
                                       : "<null>");
    return r;
}

static void walk(const any* e, int d) {
    if (!e) return;
    std::cout << std::string(d * 2, ' ') << nm(e) << "\n";
    if (e->UhdmType() == uhdmoperation)
        if (auto* ops = ((const operation*)e)->Operands())
            for (auto* o : *ops) walk(o, d + 1);
    if (auto* rt = dynamic_cast<const expr*>(e))
        if (auto* t = rt->Typespec())
            std::cout << std::string(d * 2 + 2, ' ') << "ts-> "
                      << nm(t->Actual_typespec()) << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string want = argc > 2 ? argv[2] : "";
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmdesign) continue;
        auto* d = (const design*)o;
        if (!d->Param_assigns()) continue;
        int i = 0;
        for (auto* pa : *d->Param_assigns()) {
            std::string ln =
                pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : std::string("?");
            ++i;
            if (!want.empty() && ln.find(want) == std::string::npos) continue;
            std::cout << "== Param_assigns[" << (i - 1) << "] " << ln << " @"
                      << pa->VpiLineNo() << ":" << pa->VpiColumnNo() << "\n";
            walk(pa->Rhs(), 1);
        }
    }
    return 0;
}
