// lst <db> <kind-substr> <name> <line>: every scope whose vpiTypedef listing holds a matching typespec; plus the typespec's parent
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"/"+std::string(o->VpiDefName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"#"+std::to_string(o->UhdmId()); }
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
  std::string kind=argv[2], nm=argv[3]; int line=atoi(argv[4]);
  auto match=[&](const any*a){ std::string kk(UhdmName(a->UhdmType())); return kk.find(kind)!=std::string::npos && a->VpiName()==nm && (!line||(int)a->VpiLineNo()==line); };
  auto scan=[&](const any*sc, const VectorOftypespec*v, std::string tag){ if(!v) return; int i=0; for(auto*t:*v){ if(match(t)) std::cout<<tag<<" "<<one(sc)<<" ["<<i<<"/"<<v->size()<<"] -> "<<one(t)<<" par="<<one(t->VpiParent())<<" inst="<<one(t->Instance())<<"\n"; i++; } };
  scan(d,d->Typespecs(),"design");
  for(auto&[o,id]: s.AllObjects()){ const any*a=(const any*)o; 
    if(auto*m=any_cast<const instance*>(a)) scan(a,m->Typespecs(),"inst");
    else if(auto*c=any_cast<const scope*>(a)) scan(a,c->Typespecs(),"scope");
  }
}
