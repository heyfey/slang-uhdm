// tdl <db> <uhdmId>: print typedef listing of the object with that id (kind name line par inst)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"/"+std::string(o->VpiDefName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); }
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); unsigned id=atoi(argv[2]);
  for(auto&[o,i]: s.AllObjects()){ const any*a=(const any*)o; if(a->UhdmId()!=id) continue;
    const VectorOftypespec* v=nullptr; if(auto*m=any_cast<const instance*>(a)) v=m->Typespecs(); else if(auto*c=any_cast<const scope*>(a)) v=c->Typespecs();
    std::cout<<one(a)<<" n="<<(v?v->size():0)<<"\n"; if(v) for(auto*t:*v) std::cout<<"  "<<one(t)<<" par="<<one(t->VpiParent())<<" inst="<<one(t->Instance())<<"\n"; }
}
