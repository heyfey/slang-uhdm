// vinst <db> <pkgname>: every object whose vpiInstance (via vpi_handle) is a package named pkgname: DEF/TOP, kind, short parent chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_user.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::string d1(const BaseClass*o){ return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo());}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string want=argv[2]; int depth=argc>3?atoi(argv[3]):4;
 std::set<const any*> defs,tops; for(auto*p:*d->AllPackages()) defs.insert(p); if(d->TopPackages()) for(auto*p:*d->TopPackages()) tops.insert(p);
 for(auto&[o,id]:s.AllObjects()){ auto*b=(const BaseClass*)o; vpiHandle oh=NewVpiHandle(b); vpiHandle ih=vpi_handle(vpiInstance,oh); if(!ih){vpi_release_handle(oh); continue;} auto*i=(const BaseClass*)((uhdm_handle*)ih)->object; if(i->VpiName()==want){ std::string k=defs.count(i)?"DEF":tops.count(i)?"TOP":"OTHER"; std::string s=k+" "+d1(b); int n=0; for(auto*p=b->VpiParent();p&&n<depth;p=p->VpiParent(),n++) s+=" < "+d1(p); std::cout<<s<<"\n";} vpi_release_handle(ih); vpi_release_handle(oh);} }
