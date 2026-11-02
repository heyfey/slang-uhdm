// rolecmp <golden> <ours>: importer-package import-copy roles: per (view pkg role name hop) the instance view, golden vs ours; prints mismatch count
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
static std::multiset<std::string> roles(const char* f){
  std::multiset<std::string> out; Serializer sa; auto ha=sa.Restore(std::filesystem::path(f)); if(ha.empty()) return out; auto*d=(design*)((uhdm_handle*)ha[0])->object;
  if(!d->AllPackages()||!d->TopPackages()) return out;
  std::map<const void*,std::string> view; for(auto*p:*d->AllPackages()) view[p]=std::string(p->VpiName())+"!DEF"; for(auto*p:*d->TopPackages()) view[p]=std::string(p->VpiName())+"!TOP";
  auto vi=[&](const BaseClass*i){ if(!i) return std::string("null"); auto it=view.find(i); return it==view.end()? std::string("other:")+std::string(i->VpiName()) : it->second; };
  auto ch=[&](const ref_typespec*rt){ std::string s; std::set<const void*> seen; int h=0; while(rt&&h<4){ auto*t=rt->Actual_typespec(); if(!t||!seen.insert(t).second) break; s+=" "+std::string(UhdmName(t->UhdmType()))+"@"+vi(t->Instance()); rt=t->Typedef_alias(); h++; } return s; };
  for(int v=0;v<2;v++){ auto*l=v?d->TopPackages():d->AllPackages(); for(auto*pk:*l){ std::string pn=std::string(pk->VpiName())+(v?"!TOP":"!DEF");
    if(pk->Parameters()) for(auto*a:*pk->Parameters()) if(a->UhdmType()==uhdmparameter){ auto*cp=(const parameter*)a; if(cp->VpiImported().empty()) continue; out.insert(pn+" param "+std::string(cp->VpiName())+ch(cp->Typespec())); }
    if(pk->Param_assigns()) for(auto*pa:*pk->Param_assigns()){ if(!pa->Lhs()||pa->Lhs()->UhdmType()!=uhdmparameter) continue; auto*lp=(const parameter*)pa->Lhs(); if(lp->VpiImported().empty()) continue; out.insert(pn+" pa-lhs "+std::string(lp->VpiName())+ch(lp->Typespec())); if(pa->Rhs()&&pa->Rhs()->UhdmType()==uhdmconstant) out.insert(pn+" pa-rhs "+std::string(lp->VpiName())+ch(((const constant*)pa->Rhs())->Typespec())); }
  } }
  return out;
}
int main(int argc,char**argv){
  auto g=roles(argv[1]); auto o=roles(argv[2]);
  // multiset difference
  std::multiset<std::string> og=g, oo=o; for(auto&x:o){ auto it=og.find(x); if(it!=og.end()) og.erase(it);} for(auto&x:g){ auto it=oo.find(x); if(it!=oo.end()) oo.erase(it);}
  std::cout<<"roles g="<<g.size()<<" o="<<o.size()<<" onlyG="<<og.size()<<" onlyO="<<oo.size()<<"\n";
  if(getenv("RC_ALL")){ for(auto&x:g) std::cout<<"GA "<<x<<"\n"; for(auto&x:o) std::cout<<"OA "<<x<<"\n"; }
  if(getenv("RC_V")){ for(auto&x:og) std::cout<<"G "<<x<<"\n"; for(auto&x:oo) std::cout<<"O "<<x<<"\n"; }
}
