// simenum <in> <out>: enum_typespec copies (instance = DEF pkg, base actual instance = TOP pkg) rebind the base actual to the DEF package's same-named enum's base actual
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 std::set<const any*> defs,tops; for(auto*p:*d->AllPackages()) defs.insert(p); if(d->TopPackages()) for(auto*p:*d->TopPackages()) tops.insert(p);
 std::map<std::string,const typespec*> defBase; for(auto*p:*d->AllPackages()) if(p->Typespecs()) for(auto*t:*p->Typespecs()) if(t->UhdmType()==uhdmenum_typespec){ auto*e=(enum_typespec*)t; if(e->Base_typespec()) defBase[std::string(e->VpiName())]=e->Base_typespec()->Actual_typespec(); }
 int n=0; for(auto&[o,id]:s.AllObjects()){ auto*b=(BaseClass*)o; if(b->UhdmType()!=uhdmenum_typespec) continue; auto*e=(enum_typespec*)b; auto*bt=e->Base_typespec(); if(!bt||!bt->Actual_typespec()) continue; if(!defs.count(e->Instance())||!tops.count(bt->Actual_typespec()->Instance())) continue; auto it=defBase.find(std::string(e->VpiName())); if(it==defBase.end()) continue; bt->Actual_typespec((typespec*)it->second); n++; }
 std::cerr<<"rebased "<<n<<"\n"; s.Save(std::filesystem::path(argv[2])); }
