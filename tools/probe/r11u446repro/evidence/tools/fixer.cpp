#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
  std::set<const any*> listed; std::map<std::string,package*> top; std::map<const package*, std::set<const any*>> topListed; std::map<std::string,std::set<const any*>> defL;
  auto cl=[&](VectorOftypespec*v){ if(v) for(auto*t:*v) listed.insert(t);};
  for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l){ cl(p->Typespecs()); if(!k && p->Typespecs()) for(auto*t:*p->Typespecs()) defL[std::string(p->VpiName())].insert(t); if(k){ top[std::string(p->VpiName())]=p; if(p->Typespecs()) for(auto*t:*p->Typespecs()) topListed[p].insert(t);} }
    auto*m=k?d->TopModules():d->AllModules(); if(m) for(auto*x:*m) cl(x->Typespecs()); }
  cl(d->Typespecs());
  int n=0; std::set<const any*> seen;
  auto fixc=[&](class_defn*c){ if(!c||!c->Typespecs()) return; for(auto*t:*c->Typespecs()){ if(!seen.insert(t).second) continue; if(t->UhdmType()!=uhdmclass_typespec||t->VpiParent()!=c||listed.count(t)) continue; auto*ra=t->Typedef_alias(); auto*a=ra?ra->Actual_typespec():nullptr; if(!a) continue; std::string an(a->VpiName()); auto pp=an.find("::"); if(pp==std::string::npos) continue; auto ti=top.find(an.substr(0,pp)); if(ti==top.end()||!topListed[ti->second].count(a)) continue; if(defL[an.substr(0,pp)].count(a)) continue; if(t->Instance()==ti->second) continue; if(argc>3) std::cerr<<"chg "<<t->VpiName()<<" "<<t->VpiFile()<<":"<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<" cls="<<c->VpiName()<<" from="<<(t->Instance()?std::string(t->Instance()->VpiName()):"null")<<" alias="<<an<<"\n"; t->Instance(ti->second); n++; }};
  for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if(p->Class_defns()) for(auto*c:*p->Class_defns()) fixc(c);}
  if(d->AllClasses()) for(auto*c:*d->AllClasses()) fixc(c);
  std::cerr<<"fixed "<<n<<"\n";
  s.Save(std::filesystem::path(argv[2]));
}
