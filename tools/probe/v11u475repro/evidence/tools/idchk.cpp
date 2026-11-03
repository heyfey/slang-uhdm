// idchk <db>: for every module param_assign whose Rhs is a constant with a typespec,
// says whether the Rhs's typespec (hop 1) and its alias (hop 2) are the SAME OBJECT as the
// Lhs parameter's own chain (own), as the definition listing's same-named parameter's chain
// (def), or neither (fresh); lines "<view> <defname> <param> h1=<own|def|fresh> h2=<...>"
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::map<std::string, const module_inst*> defs;
static const typespec* h(const ref_typespec* r){ return r? r->Actual_typespec():nullptr; }
static const typespec* a(const typespec* t){ return t && t->Typedef_alias()? t->Typedef_alias()->Actual_typespec():nullptr; }
static const parameter* defParam(const std::string& dn, const std::string& pn){
  auto it=defs.find(dn); if(it==defs.end()||!it->second->Param_assigns()) return nullptr;
  for(auto* pa:*it->second->Param_assigns()) if(pa->Lhs()&&pa->Lhs()->UhdmType()==uhdmparameter&&std::string(pa->Lhs()->VpiName())==pn) return (const parameter*)pa->Lhs();
  return nullptr; }
static std::string cls(const typespec* x,const typespec* own,const typespec* def){ if(!x) return "null"; if(x==own) return "own"; if(x==def) return "def"; return "fresh"; }
static void walk(const module_inst* m,const char* view){
  if(m->Param_assigns()) for(auto* pa:*m->Param_assigns()){
    if(!pa->Lhs()||pa->Lhs()->UhdmType()!=uhdmparameter||!pa->Rhs()||pa->Rhs()->UhdmType()!=uhdmconstant) continue;
    auto* lp=(const parameter*)pa->Lhs(); auto* c=(const constant*)pa->Rhs(); if(!c->Typespec()) continue;
    auto* dp=defParam(std::string(m->VpiDefName()),std::string(lp->VpiName()));
    auto* r1=h(c->Typespec()); auto* o1=h(lp->Typespec()); auto* d1=dp?h(dp->Typespec()):nullptr;
    std::cout<<view<<" "<<m->VpiDefName()<<" "<<lp->VpiName()<<" h1="<<cls(r1,o1,d1)<<" h2="<<cls(a(r1),a(o1),a(d1))<<"\n"; }
  if(std::string(view)=="elab"&&m->Modules()) for(auto* c:*m->Modules()) walk(c,view);
}
int main(int argc,char**argv){
  Serializer s; auto hs=s.Restore(std::filesystem::path(argv[1])); if(hs.empty()) return 1;
  auto* d=(design*)((uhdm_handle*)hs[0])->object;
  if(d->AllModules()) for(auto* m:*d->AllModules()) defs[std::string(m->VpiDefName())]=m;
  if(d->AllModules()) for(auto* m:*d->AllModules()) walk(m,"def");
  if(d->TopModules()) for(auto* m:*d->TopModules()) walk(m,"elab");
}
