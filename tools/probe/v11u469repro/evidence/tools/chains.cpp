// chains <uhdm>: every parameter / param_assign (lhs, rhs constant) in packages (both views),
// module definitions, top module instances (recursive) and the design: owner, role, name, imported,
// and the typespec chain as kind@instance-view per hop.  Used to find collateral moves of § 469.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
std::map<const void*,std::string> view;
static std::string vi(const BaseClass*i){ if(!i) return "null"; auto it=view.find(i); return it==view.end()? std::string("other:")+std::string(i->VpiName()) : it->second; }
static std::string ch(const ref_typespec*rt){ std::string s; std::set<const void*> seen; int h=0; while(rt&&h<5){ auto*t=rt->Actual_typespec(); if(!t||!seen.insert(t).second) break; s+=" "+std::string(UhdmName(t->UhdmType()))+":"+std::string(t->VpiName())+"@"+vi(t->Instance()); rt=t->Typedef_alias(); h++; } return s; }
static void scope469(const std::string& o, const VectorOfany* ps, const VectorOfparam_assign* pas){
  if(ps) for(auto*a:*ps) if(a->UhdmType()==uhdmparameter){ auto*p=(const parameter*)a; std::cout<<o<<" param "<<p->VpiName()<<" imp="<<p->VpiImported()<<ch(p->Typespec())<<"\n"; }
  if(pas) for(auto*pa:*pas){ if(!pa->Lhs()||pa->Lhs()->UhdmType()!=uhdmparameter) continue; auto*lp=(const parameter*)pa->Lhs();
    std::cout<<o<<" pa-lhs "<<lp->VpiName()<<" imp="<<lp->VpiImported()<<ch(lp->Typespec())<<"\n";
    if(pa->Rhs()&&pa->Rhs()->UhdmType()==uhdmconstant) std::cout<<o<<" pa-rhs "<<lp->VpiName()<<" imp="<<lp->VpiImported()<<ch(((const constant*)pa->Rhs())->Typespec())<<"\n"; }
}
static void mod(const module_inst*m, const std::string& pfx){ std::string o=pfx+std::string(m->VpiFullName()); scope469(o,m->Parameters(),m->Param_assigns()); if(m->Modules()) for(auto*c:*m->Modules()) mod(c,pfx); }
int main(int argc,char**argv){
  Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); if(ha.empty()) return 1; auto*d=(design*)((uhdm_handle*)ha[0])->object;
  if(d->AllPackages()) for(auto*p:*d->AllPackages()) view[p]=std::string(p->VpiName())+"!DEF";
  if(d->TopPackages()) for(auto*p:*d->TopPackages()) view[p]=std::string(p->VpiName())+"!TOP";
  if(d->AllModules()) for(auto*p:*d->AllModules()) view[p]=std::string(p->VpiName())+"!MDEF";
  if(d->AllPackages()) for(auto*p:*d->AllPackages()) scope469(std::string(p->VpiName())+"!DEF",p->Parameters(),p->Param_assigns());
  if(d->TopPackages()) for(auto*p:*d->TopPackages()) scope469(std::string(p->VpiName())+"!TOP",p->Parameters(),p->Param_assigns());
  if(d->AllModules()) for(auto*m:*d->AllModules()) scope469(std::string(m->VpiName())+"!MDEF",m->Parameters(),m->Param_assigns());
  if(d->TopModules()) for(auto*m:*d->TopModules()) mod(m,"INST:");
  scope469("DESIGN",d->Parameters(),d->Param_assigns());
}
