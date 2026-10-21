// listers2 <db> <name-suffix> [file-substr]: all typespecs whose name ends with suffix; line:col, file, inst, parent, listings
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string iname(const BaseClass*i,design*d){ if(!i) return "null"; std::string tag="?"; for(int top=0;top<2;top++){ auto*l=top?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if(p==i) tag=top?"TOP":"DEF"; auto*m=top?d->TopModules():d->AllModules(); if(m) for(auto*p:*m) if(p==i) tag=top?"TOPM":"DEFM";} if(i==d) tag="design"; return std::string(i->VpiName())+"#"+tag; }
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
  std::string nm=argv[2]; std::string fs=argc>3?argv[3]:"";
  std::map<const any*,std::string> where;
  auto add=[&](std::string tag, VectorOftypespec* v){ if(!v) return; for(auto*t:*v) where[t]+=" "+tag; };
  for(int top=0;top<2;top++){ auto*l=top?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) add((top?"TOP:":"DEF:")+std::string(p->VpiName()),p->Typespecs());
    auto*m=top?d->TopModules():d->AllModules(); if(m) for(auto*x:*m) add((top?"TOPM:":"DEFM:")+std::string(x->VpiName()),x->Typespecs()); }
  add("design", d->Typespecs());
  for(auto&[o,id]: s.AllObjects()){ auto*t=any_cast<const typespec*>((const any*)o); if(!t) continue; std::string n(t->VpiName()); if(!(n.size()>=nm.size() && n.substr(n.size()-nm.size())==nm)) continue; std::string f(t->VpiFile()); if(!fs.empty() && f.find(fs)==std::string::npos) continue;
    std::cout<<UhdmName(t->UhdmType())<<" '"<<n<<"' "<<t->VpiFile()<<":"<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<" inst="<<iname(t->Instance(),d)<<" parent="<<(t->VpiParent()?std::string(UhdmName(t->VpiParent()->UhdmType()))+":"+std::string(t->VpiParent()->VpiName()):"null")<<" alias="<<(t->Typedef_alias()&&t->Typedef_alias()->Actual_typespec()?std::string(t->Typedef_alias()->Actual_typespec()->VpiName())+"/inst="+iname(t->Typedef_alias()->Actual_typespec()->Instance(),d)+"/listed:"+where[t->Typedef_alias()->Actual_typespec()]:std::string("none"))<<" listed:"<<where[t]<<"\n"; }
}
