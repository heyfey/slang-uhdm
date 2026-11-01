// enumbase <db> <enum name substr>: each enum_typespec: own instance, parent chain, base typespec actual id+instance
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::string d1(const BaseClass*o){ return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo());}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string want=argv[2];
 std::set<const any*> defs,tops; for(auto*p:*d->AllPackages()) defs.insert(p); if(d->TopPackages()) for(auto*p:*d->TopPackages()) tops.insert(p);
 auto ik=[&](const any*i){ return !i?std::string("null"):defs.count(i)?"DEF":tops.count(i)?"TOP":std::string("OTHER:")+std::string(i->VpiName()); };
 for(auto&[o,id]:s.AllObjects()){ auto*b=(const BaseClass*)o; if(b->UhdmType()!=uhdmenum_typespec) continue; auto*e=(const enum_typespec*)b; if(std::string(e->VpiName()).find(want)==std::string::npos) continue; std::string s="enum inst="+ik(e->Instance()); auto*bt=e->Base_typespec(); if(bt&&bt->Actual_typespec()) s+=" base#"+std::to_string(bt->Actual_typespec()->UhdmId())+" binst="+ik(bt->Actual_typespec()->Instance()); else s+=" base=none"; int n=0; for(auto*p=b->VpiParent();p&&n<4;p=p->VpiParent(),n++) s+=" < "+d1(p); std::cout<<s<<"\n";}}
