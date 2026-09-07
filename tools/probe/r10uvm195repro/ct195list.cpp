// r10uvm195 — ct195list: every `ref_var` of a given NAME in one database, with
// its `vpiActual` and its parent chain.  MEASUREMENT ONLY; the official
// `uhdm-cmp` is the sole judge.  This is the tool that settled question 1 —
// golden does NOT omit the variable, it holds TWO objects where we hold one.
//
// build: g++ -O2 -std=c++17 ct195list.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct195list
// usage: ct195list <db.uhdm> <varname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string chain(const BaseClass* o) {
    std::string s; int g=0;
    for (const BaseClass* p=o->VpiParent(); p&&g<40; p=p->VpiParent(),++g) {
        s += "/"; s += UhdmName(p->UhdmType()); s += ":"; s += std::string(p->VpiName());
    }
    return s;
}
int main(int argc,char**argv){
  Serializer S; if(S.Restore(std::string(argv[1])).empty()){printf("FAIL\n");return 3;}
  const char* nm = argv[2];
  for (auto& kv : S.AllObjects()) {
    const BaseClass* X = kv.first; if(!X) continue;
    if (X->UhdmType()!=uhdmref_var) continue;
    if (std::string(X->VpiName()) != nm) continue;
    const ref_var* r = (const ref_var*)X;
    const any* a = r->Actual_group();
    printf("id=%u full=%s @%u:%u actual=%s chain=%s\n", X->UhdmId(),
      std::string(((const ref_var*)X)->VpiFullName()).c_str(), X->VpiLineNo(),(unsigned)X->VpiColumnNo(),
      a? (std::string(UhdmName(a->UhdmType()))+"("+std::string("")+")#"+std::to_string(a->UhdmId())).c_str() : "<null>",
      chain(X).c_str());
  }
  return 0;
}
