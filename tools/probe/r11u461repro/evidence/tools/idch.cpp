// idch <db> <id>...: describe objects by UhdmId with parent chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string d1(const BaseClass*o){ std::string fn; if(auto*i=dynamic_cast<const instance*>(o)) fn=" fn="+std::string(i->VpiFullName()); return std::string(UhdmName(o->UhdmType()))+"#"+std::to_string(o->UhdmId())+":"+std::string(o->VpiName())+fn+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo());}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
 std::set<unsigned long> want; for(int i=2;i<argc;i++) want.insert(atol(argv[i]));
 for(auto& [o,id]: s.AllObjects()){ auto*b=(const BaseClass*)o; if(!want.count(b->UhdmId())) continue; std::string s=d1(b); for(auto*p=b->VpiParent();p;p=p->VpiParent()) s+=" < "+d1(p); std::cout<<s<<"\n";}}
