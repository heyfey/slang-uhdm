// idrange <db> <lo> <hi>: objects by id in range with parent chain
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string d1(const BaseClass*o){ return std::string(UhdmName(o->UhdmType()))+"#"+std::to_string(o->UhdmId())+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo());}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); unsigned long lo=atol(argv[2]),hi=atol(argv[3]); std::map<unsigned long,const BaseClass*> m;
 for(auto&[o,id]:s.AllObjects()){ auto*b=(const BaseClass*)o; if(b->UhdmId()>=lo&&b->UhdmId()<=hi) m[b->UhdmId()]=b; }
 for(auto&[i,b]:m){ std::string s=d1(b); int n=0; for(auto*p=b->VpiParent();p&&n<4;p=p->VpiParent(),n++) s+=" < "+d1(p); if(auto*t=dynamic_cast<const typespec*>(b)) if(t->Instance()) s+="  INST="+std::string(t->Instance()->VpiName())+"#"+std::to_string(t->Instance()->UhdmId()); std::cout<<s<<"\n";}}
