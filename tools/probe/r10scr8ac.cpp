// r10scr8ac: WHOLE-DESIGN census of array_var / array_net UNPACKED RANGES.
// One sorted line per (instance, signal, range) giving the flattened bound
// tree with each node's CMP-relevant constant encoding and its typespec ref —
// so `diff golden ours` names every dimension whose FOLD SHAPE disagrees, and
// the agreeing rows supply the discriminator.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr8ac.cpp -o /tmp/r10scr8_ac \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string flat(const any* e) {
    if (!e) return "<null>";
    std::string r = UhdmName(e->UhdmType());
    if (e->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)e;
        r += "{ct=" + std::to_string(c->VpiConstType()) +
             ",sz=" + std::to_string(c->VpiSize()) +
             ",v=" + std::string(c->VpiValue()) + "}";
    }
    else if (e->UhdmType() == uhdmref_obj)
        r += "(" + std::string(e->VpiName()) + ")";
    if (auto* x = dynamic_cast<const expr*>(e))
        r += x->Typespec() ? "[ts]" : "[]";
    if (e->UhdmType() == uhdmoperation) {
        auto* o = (const operation*)e;
        r += "{op=" + std::to_string(o->VpiOpType()) + "}(";
        if (o->Operands())
            for (auto* q : *o->Operands()) r += flat(q) + " ";
        r += ")";
    }
    return r;
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmmodule_inst) continue;
        auto* m = (const module_inst*)o;
        std::string inst(m->VpiFullName());
        auto emit = [&](const char* k, std::string_view n,
                        const VectorOfrange* rs) {
            if (!rs) return;
            int i = 0;
            for (auto* r : *rs)
                rows.push_back(inst + " | " + k + " " + std::string(n) + "[" +
                               std::to_string(i++) + "] | " +
                               flat(r->Left_expr()) + " ... " +
                               flat(r->Right_expr()));
        };
        if (m->Variables())
            for (auto* v : *m->Variables())
                if (v->UhdmType() == uhdmarray_var)
                    emit("var", v->VpiName(), ((const array_var*)v)->Ranges());
        if (m->Array_nets())
            for (auto* v : *m->Array_nets()) emit("net", v->VpiName(), v->Ranges());
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
