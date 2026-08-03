// r10bbp8x: WHOLE-ARENA census of the nullable `expr`/`constant` child slots
// that UHDM's generated Compare reads, tallied by (holder type, holder span,
// child projection) so the two databases line-diff independently of arena
// order.  Written to locate the r10bbp8 uhdm-cmp head — "golden holds
// constant 64 @14986:34 where ours holds nullptr", reachable from every view
// root and invisible to both the param_assign census (r10bbp7d) and the
// parameter projection (r10bbp8p), which only walk the four top-level
// listings.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp8x.cpp -o /tmp/r10bbp8xq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp8xq <db.uhdm> [line]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static int wantLine = 0;

static std::string one(const any* n) {
    if (!n) return "NULL";
    std::string s(UhdmName(n->UhdmType()));
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += "{ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) +
             " dec=" + std::string(c->VpiDecompile()) + "}";
    }
    else {
        std::string nm(n->VpiName());
        if (!nm.empty()) s += "(" + nm + ")";
    }
    return s + "@" + std::to_string(n->VpiLineNo()) + ":" +
           std::to_string(n->VpiColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    if (argc > 2) wantLine = atoi(argv[2]);
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    std::map<std::string, int> tally;
    auto note = [&](const any* holder, const char* slot, const any* child) {
        if (!child) return;
        if (wantLine && (int)child->VpiLineNo() != wantLine) return;
        tally[std::string(UhdmName(holder->UhdmType())) + "@" +
              std::to_string(holder->VpiLineNo()) + ":" +
              std::to_string(holder->VpiColumnNo()) + "." + slot + " = " +
              one(child)]++;
    };
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj) continue;
        switch (obj->UhdmType()) {
            case uhdmparameter: {
                auto* p = (parameter*)obj;
                note(p, "Expr", p->Expr());
                note(p, "Left_range", p->Left_range());
                note(p, "Right_range", p->Right_range());
                break;
            }
            case uhdmparam_assign: note((param_assign*)obj, "Rhs",
                                        ((param_assign*)obj)->Rhs());
                break;
            case uhdmrange: {
                auto* r = (range*)obj;
                note(r, "Left_expr", r->Left_expr());
                note(r, "Right_expr", r->Right_expr());
                break;
            }
            case uhdmtypespec_member: {
                auto* m = (typespec_member*)obj;
                note(m, "Default_value", m->Default_value());
                break;
            }
            case uhdmenum_const: break;
            case uhdmint_typespec:
                note(obj, "Cast_to_expr", ((int_typespec*)obj)->Cast_to_expr());
                break;
            case uhdmoperation: {
                auto* o = (operation*)obj;
                if (auto* ops = o->Operands()) {
                    int i = 0;
                    for (auto* x : *ops)
                        note(o, ("Operand" + std::to_string(i++)).c_str(), x);
                }
                break;
            }
            default: break;
        }
    }
    for (auto& [k, n] : tally) std::cout << n << "  " << k << "\n";
    return 0;
}
