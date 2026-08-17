// r10uvm83 — MEASUREMENT-ONLY.  THE MOVER PREDICTOR for
// § scopedTdUnsupTsHomePkgInstance83, run on PRISTINE databases ONLY.
//
// The law stamps `vpiInstance` on the `unsupported_typespec` placeholder that a
// declaration written `Owner::td` (Owner a CLASS) binds, using the same pointer
// the site's resolved typespec takes: the HOME PACKAGE for an OUT-OF-BODY class
// method, nothing for an in-body one.  A pristine database therefore predicts a
// mover exactly where it holds:
//
//   an `unsupported_typespec` whose VpiName contains "::" and whose
//   `Instance()` is NULL, bound through a `ref_typespec` whose enclosing
//   `function` / `task` HAS a non-null `Instance()`
//
// — because a subroutine's own `vpiInstance` is set (and only set) for an
// out-of-body definition, which is the same `oobHomePkg` the stamp uses.
//
//   usage: ct83pred <db.uhdm> [--list]
// build: g++ -O2 -std=c++17 ct83pred.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83pred
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <set>
#include <string>
using namespace UHDM;
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
int main(int argc,char** argv){
  bool list=(argc>2&&!strcmp(argv[2],"--list"));
  Serializer s; s.Restore(std::string(argv[1]));
  std::set<const BaseClass*> hit;
  size_t scoped=0;
  for(auto& kv:s.AllObjects()){
    const BaseClass* o=(const BaseClass*)kv.first; if(!o) continue;
    if(o->UhdmType()!=uhdmref_typespec) continue;
    auto* rt=(const ref_typespec*)o;
    const typespec* a=rt->Actual_typespec();
    if(!a||a->UhdmType()!=uhdmunsupported_typespec) continue;
    std::string nm(a->VpiName());
    if(nm.find("::")==std::string::npos) continue;
    scoped++;
    if(((const unsupported_typespec*)a)->Instance()) continue;
    // the enclosing subroutine of the BINDING, via the ref_typespec's parents
    const BaseClass* p=rt->VpiParent(); const BaseClass* tf=nullptr;
    for(int i=0;i<12&&p;i++){
      if(p->UhdmType()==uhdmfunction||p->UhdmType()==uhdmtask){ tf=p; break; }
      p=p->VpiParent();
    }
    if(!tf) continue;
    const instance* inst = (tf->UhdmType()==uhdmfunction)
        ? ((const function*)tf)->Instance() : ((const task*)tf)->Instance();
    if(!inst) continue;
    hit.insert(a);
    if(list) printf("PRED\t%s\t%u:%u-%u:%u\tvia %s(%s)\tinst=%s\n",nm.c_str(),
      a->VpiLineNo(),(unsigned)a->VpiColumnNo(),a->VpiEndLineNo(),(unsigned)a->VpiEndColumnNo(),
      std::string(UhdmName(tf->UhdmType())).c_str(),std::string(tf->VpiName()).c_str(),
      std::string(inst->VpiName()).c_str());
  }
  printf("PRED %zu %zu %s\n",hit.size(),scoped,argv[1]);
  return 0;
}
