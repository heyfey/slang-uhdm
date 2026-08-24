// r10earl78 — print every constant at a given line:col with its parent chain.
// Used to NAME the owner of a cmp head that carries no file (the dump
// synthesises fullnames from the parent chain — RESUME §9).  MEASUREMENT ONLY.
//   build: g++ -O2 -std=c++17 findspan78.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o findspan78
//   usage: findspan78 <db.uhdm> <line> <col>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s; s.Restore(std::string(argv[1]));
  unsigned L = atoi(argv[2]), C = atoi(argv[3]);
  for (auto& [v, id] : s.AllObjects()) {
    if (!v) continue;
    if (v->VpiLineNo() != L || v->VpiColumnNo() != C) continue;
    if (v->UhdmType() != uhdmconstant) continue;
    auto* c = (const constant*)v;
    printf("constant sz=%d ct=%d val=%s end=%u:%u file=%s\n", c->VpiSize(),
           c->VpiConstType(), std::string(c->VpiValue()).c_str(),
           c->VpiEndLineNo(), c->VpiEndColumnNo(),
           std::string(c->VpiFile()).c_str());
    int n = 0;
    for (const any* o = v->VpiParent(); o && n < 8; o = o->VpiParent(), n++)
      printf("   ^ %-20s %s:%u:%u name=%s\n",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiFile()).c_str(), o->VpiLineNo(),
             o->VpiColumnNo(), std::string(o->VpiName()).c_str());
  }
  return 0;
}
