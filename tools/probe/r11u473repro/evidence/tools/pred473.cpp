// pred473 <list>: for each database path in <list>, counts the roles § modImpCopyTdChainHomeTop473 fires on
// (module/interface/program import copies whose typespec's alias target is named <H>::<x>, H != vpiImported, hop1 named x, H a top package)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <fstream>
#include <functional>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
int main(int argc,char**argv){ std::ifstream in(argv[1]); std::string f;
  long cnt=0, mods=0; while(std::getline(in,f)){ cnt++; Serializer sa; auto ha=sa.Restore(std::filesystem::path(f)); if(ha.empty()){ std::cout<<"NOREAD "<<f<<"\n"; continue;} auto*d=(design*)((uhdm_handle*)ha[0])->object;
    std::set<std::string> tops; if(d->TopPackages()) for(auto*p:*d->TopPackages()) tops.insert(std::string(p->VpiName()));
    int n=0; std::set<std::string> what;
    auto chk=[&](const ref_typespec*rt,const std::string&imp,const std::string&w){ if(!rt) return; auto*h1=rt->Actual_typespec(); if(!h1||!h1->Typedef_alias()) return; auto*h2=h1->Typedef_alias()->Actual_typespec(); if(!h2||h2==h1||h2->Typedef_alias()||h2->UhdmType()!=h1->UhdmType()) return;
      std::string n2(h2->VpiName()); auto c=n2.find("::"); if(c==std::string::npos||n2.find("::",c+2)!=std::string::npos) return; std::string home=n2.substr(0,c), bare=n2.substr(c+2); if(home==imp||h1->VpiName()!=bare||!tops.count(home)) return; if(!h2->Instance()||h2->Instance()->UhdmType()!=uhdmpackage||h2->Instance()->VpiName()==home){ std::cout<<"ABSTAIN-HOMEALIAS "<<f<<" | "<<w<<"\n"; return; } n++; what.insert(w); };
    std::set<const scope*> seen;
    std::function<void(const scope*)> walk=[&](const scope*sc){ if(!sc||!seen.insert(sc).second) return; std::string sn(sc->VpiFullName().empty()?sc->VpiName():sc->VpiFullName());
      if(sc->Parameters()) for(auto*a:*sc->Parameters()) if(a->UhdmType()==uhdmparameter){auto*p=(const parameter*)a; if(!p->VpiImported().empty()) chk(p->Typespec(),std::string(p->VpiImported()),sn+" "+std::string(p->VpiName()));}
      if(sc->Param_assigns()) for(auto*pa:*sc->Param_assigns()){ if(!pa->Lhs()||pa->Lhs()->UhdmType()!=uhdmparameter) continue; auto*lp=(const parameter*)pa->Lhs(); if(lp->VpiImported().empty()) continue; std::string imp(lp->VpiImported()); chk(lp->Typespec(),imp,sn+" "+std::string(lp->VpiName())); if(pa->Rhs()&&pa->Rhs()->UhdmType()==uhdmconstant) chk(((const constant*)pa->Rhs())->Typespec(),imp,sn+" "+std::string(lp->VpiName())); }
      { const VectorOfcont_assign* cas = sc->UhdmType()==uhdmmodule_inst?((const module_inst*)sc)->Cont_assigns(): sc->UhdmType()==uhdminterface_inst?((const interface_inst*)sc)->Cont_assigns():nullptr;
        std::function<void(const any*,int)> rr=[&](const any*e,int dep){ if(!e||dep>64) return; if(e->UhdmType()==uhdmconstant){ chk(((const constant*)e)->Typespec(),"",sn+" cafold"); return;} if(e->UhdmType()==uhdmoperation&&((const operation*)e)->Operands()) for(auto*o:*((const operation*)e)->Operands()) rr(o,dep+1); };
        if(cas) for(auto*ca:*cas) rr(ca->Rhs(),0);
        if(sc->UhdmType()==uhdmmodule_inst&&((const module_inst*)sc)->Variables()) for(auto*v:*((const module_inst*)sc)->Variables()) if(v->Expr()&&v->Expr()->UhdmType()==uhdmconstant) chk(((const constant*)v->Expr())->Typespec(),"",sn+" varinit"); }
      if(sc->UhdmType()==uhdmmodule_inst){ auto*m=(const module_inst*)sc; if(m->Modules()) for(auto*c:*m->Modules()) walk(c); if(m->Interfaces()) for(auto*c:*m->Interfaces()) walk(c);} };
    if(d->AllModules()) for(auto*m:*d->AllModules()) walk(m); if(d->AllInterfaces()) for(auto*m:*d->AllInterfaces()) walk(m); if(d->AllPrograms()) for(auto*m:*d->AllPrograms()) walk(m); if(d->TopModules()) for(auto*m:*d->TopModules()) walk(m);
    if(d->AllModules()) mods++; if(n){ std::cout<<"FIRE "<<n<<" "<<f; for(auto&w:what) std::cout<<" | "<<w; std::cout<<"\n";} }
  std::cout<<"PROCESSED "<<cnt<<" WITHMODULES "<<mods<<"\n"; }
