// r10scr6bg: list the Variables()/Stmts() of every begin/named_begin at a given
// source line, so a `failLhs=begin failRhs=begin r=1` (a child VECTOR size
// mismatch) can be read without dumping a 300k-line subtree.
//   r10scr6bg <file.uhdm> <lineno>
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10scr6bg.cpp -o /tmp/r10scr6bg \
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
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    uint32_t line = (uint32_t)atoi(argv[2]);
    Serializer ser;
    ser.Restore(std::filesystem::path(argv[1]));
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj) continue;
        auto t = obj->UhdmType();
        if (t != uhdmbegin && t != uhdmnamed_begin) continue;
        if (obj->VpiLineNo() != line) continue;
        const VectorOfvariables* vars = nullptr;
        const VectorOfany* sts = nullptr;
        if (t == uhdmbegin) {
            vars = ((const begin*)obj)->Variables();
            sts = ((const begin*)obj)->Stmts();
        } else {
            vars = ((const named_begin*)obj)->Variables();
            sts = ((const named_begin*)obj)->Stmts();
        }
        std::cout << "== " << nm(obj) << " parent=" << nm(obj->VpiParent())
                  << " vars=" << (vars ? vars->size() : 0)
                  << " stmts=" << (sts ? sts->size() : 0) << "\n";
        if (vars)
            for (size_t i = 0; i < vars->size(); i++)
                std::cout << "   var[" << i << "] " << nm((*vars)[i]) << "\n";
        if (sts)
            for (size_t i = 0; i < sts->size(); i++)
                std::cout << "   stmt[" << i << "] " << nm((*sts)[i]) << "\n";
    }
    return 0;
}
