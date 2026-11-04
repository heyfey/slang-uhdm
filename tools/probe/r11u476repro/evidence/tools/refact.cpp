// refact <db> <name>: every ref_obj named <name>: its package view, the actual's id, kind and the actual's owner package view and parent kind
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static const any* ownerPkg(const any* x){ for(;x;x=x->VpiParent()) if(x->UhdmType()==uhdmpackage) return x; return nullptr; }
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 std::map<const any*,std::string> view; for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) view[p]=std::string(p->VpiName())+(k?"[top]":"[all]"); }
 auto vn=[&](const any*p){ return p? (view.count(p)?view[p]:std::string(p->VpiName())):std::string("null"); };
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if(o->UhdmType()!=uhdmref_obj||o->VpiName()!=argv[2]) continue; auto*a=((const ref_obj*)o)->Actual_group();
  std::cout<<vn(ownerPkg(o))<<" ref#"<<o->UhdmId()<<" L"<<o->VpiLineNo()<<":"<<o->VpiColumnNo()<<" -> "; if(!a){std::cout<<"null\n";continue;}
  std::cout<<a->UhdmType()<<"#"<<a->UhdmId()<<" in "<<vn(ownerPkg(a))<<" parent="<<(a->VpiParent()?a->VpiParent()->UhdmType():0)<<"#"<<(a->VpiParent()?a->VpiParent()->UhdmId():0)<<"\n"; } }
