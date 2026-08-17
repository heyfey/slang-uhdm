// r10uvm83 — MEASUREMENT-ONLY.  The BACK-REFERENCE census.
// variables::Compare compares FOUR singular back-references — Module_inst(),
// Instance(), Scope(), plus Path_term/Tchk_term — and `SafeCompare(lhs, nullptr)`
// sets ONLY m_failedLhs, which is how a head can print as
// `LHS: <some scope>  RHS: <null>` with every vector of that scope agreeing.
// This prints those pointers for every entry of a package's Variables /
// Parameters / Typespecs / Task_funcs listing, on both sides.
//   usage: ct83back <db.uhdm> [--pkg <name>] [--via AllPackages|TopPackages]
// build: g++ -O2 -std=c++17 ct83back.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83back
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
static std::string ident(const BaseClass* o){
  if(!o) return "<null>";
  char b[256];
  snprintf(b,sizeof b,"%s(%s)#%u",std::string(UhdmName(o->UhdmType())).c_str(),
           std::string(o->VpiName()).c_str(),o->UhdmId());
  return b;
}
static design* getdesign(Serializer& s,const char* p){
  auto restored=s.Restore(std::string(p));
  for(auto h:restored){auto* o=(BaseClass*)((const uhdm_handle*)h)->object; if(o->UhdmType()==uhdmdesign) return (design*)o;}
  return nullptr;
}
int main(int argc,char** argv){
  const char* onlypkg=nullptr; const char* onlyvia=nullptr;
  for(int i=2;i<argc;i++){
    if(!strcmp(argv[i],"--pkg")&&i+1<argc) onlypkg=argv[++i];
    else if(!strcmp(argv[i],"--via")&&i+1<argc) onlyvia=argv[++i];
  }
  Serializer s; design* d=getdesign(s,argv[1]);
  if(!d){printf("NO_DESIGN\n");return 2;}
  auto run=[&](const std::vector<package*>* v,const char* via){
    if(!v) return; if(onlyvia&&strcmp(via,onlyvia)) return;
    for(size_t pi=0;pi<v->size();pi++){
      const package* p=v->at(pi);
      if(onlypkg&&std::string(p->VpiName())!=onlypkg) continue;
      printf("== PKG %s via %s[%zu] #%u\n",std::string(p->VpiName()).c_str(),via,pi,p->UhdmId());
      if(auto* vv=p->Variables()) for(size_t i=0;i<vv->size();i++){
        const variables* x=vv->at(i);
        printf("VAR\t%zu\t%s\tModule_inst=%s\tInstance=%s\tScope=%s\tTypespec=%s\tExpr=%s\n",
               i,ident(x).c_str(),ident(x->Module_inst()).c_str(),ident(x->Instance()).c_str(),
               ident(x->Scope()).c_str(),ident(x->Typespec()).c_str(),ident(x->Expr()).c_str());
      }
    }
  };
  run(d->AllPackages(),"AllPackages");
  run(d->TopPackages(),"TopPackages");
  return 0;
}
