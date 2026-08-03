// r10scr6ts: dump every typespec (any kind) whose VpiName matches a substring,
// listing its typespec_members with each member's Typespec actual and, most
// importantly, the member's Expr (vpiExpr) subtree head.  Surelog's def-compile
// can LEAK a function-body RHS expression onto a struct member's vpiExpr; this
// probe makes that visible without wading through a 300k-line uhdm-dump.
//   r10scr6ts <file.uhdm> <name-substring>
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10scr6ts.cpp -o /tmp/r10scr6ts \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
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
             ",sz=" + std::to_string(c->VpiSize()) + ",v=" +
             std::string(c->VpiValue()) + "}";
    }
    if (o->UhdmType() == uhdmoperation)
        r += "{op=" + std::to_string(((const operation*)o)->VpiOpType()) + "}";
    return r;
}

static void chain(const BaseClass* o, const char* tag) {
    int d = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && d < 7;
         p = p->VpiParent(), d++)
        std::cout << "        " << tag << " up: " << nm(p) << "\n";
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::string filt = argv[2];
    Serializer ser;
    ser.Restore(std::filesystem::path(argv[1]));
    int n = 0;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj) continue;
        if (std::string(obj->VpiName()).find(filt) == std::string::npos) continue;
        auto t = obj->UhdmType();
        if (t != uhdmstruct_typespec && t != uhdmenum_typespec &&
            t != uhdmlogic_typespec && t != uhdmunion_typespec &&
            t != uhdmpacked_array_typespec && t != uhdmarray_typespec)
            continue;
        n++;
        std::cout << "== [" << n << "] " << nm(obj) << "\n";
        chain(obj, "ts");
        if (t == uhdmenum_typespec) {
            auto* et = (const enum_typespec*)obj;
            auto* ecs = et->Enum_consts();
            std::cout << "    enum_consts=" << (ecs ? ecs->size() : 0) << "\n";
            if (ecs)
                for (size_t i = 0; i < ecs->size(); i++)
                    std::cout << "      [" << i << "] " << nm((*ecs)[i]) << "\n";
        }
        if (t == uhdmstruct_typespec) {
            auto* st = (const struct_typespec*)obj;
            if (st->Members())
                for (auto* m : *st->Members()) {
                    std::cout << "    member " << nm(m) << " ts="
                              << nm(m->Typespec() ? m->Typespec()->Actual_typespec()
                                                  : nullptr)
                              << " default=" << nm(m->Default_value())
                              << " actual=" << nm(m->Actual_value()) << "\n";
                    if (m->Default_value()) chain(m->Default_value(), "dflt");
                    if (m->Actual_value()) chain(m->Actual_value(), "act");
                }
        }
    }
    std::cout << "matched=" << n << "\n";
    return 0;
}
