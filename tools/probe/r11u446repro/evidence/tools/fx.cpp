// fx <in> <out> <rules>: simulation fixers on OUR db (exploration only)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string rules=argv[3];
  std::map<std::string,package*> top,def; std::set<const any*> listed;
  for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l){ (k?top:def)[std::string(p->VpiName())]=p; if(p->Typespecs()) for(auto*t:*p->Typespecs()) listed.insert(t);} auto*m=k?d->TopModules():d->AllModules(); if(m) for(auto*x:*m) if(x->Typespecs()) for(auto*t:*x->Typespecs()) listed.insert(t);} if(d->Typespecs()) for(auto*t:*d->Typespecs()) listed.insert(t);
  int n=0;
  auto pfx=[&](std::string_view nm)->std::string{ auto p=nm.find("::"); return p==std::string_view::npos?std::string():std::string(nm.substr(0,p)); };
  for(auto&[o,id]: s.AllObjects()){ any*a=(any*)o;
    if(rules.find('B')!=std::string::npos && a->UhdmType()==uhdmstruct_typespec){ auto*st=(struct_typespec*)a; std::string P=pfx(st->VpiName()); auto ti=top.find(P); auto di=def.find(P); if(ti==top.end()||di==def.end()) continue;
      instance* view=ti->second; if(listed.count(st)) view=(st->Instance()==ti->second||st->Instance()==di->second)?(instance*)st->Instance():di->second;
      if(st->Members()) for(auto*m:*st->Members()){ auto*rt=m->Typespec(); auto*t=rt?(typespec*)rt->Actual_typespec():nullptr; if(t && !t->Instance() && t->UhdmType()==uhdmclass_typespec){ t->Instance(view); n++; } } }
  }
  std::cerr<<"fixed "<<n<<"\n"; s.Save(std::filesystem::path(argv[2]));
}
