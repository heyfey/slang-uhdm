// hpact <db>: every hier_path's first path element ref_obj: package view of the hier_path, the actual's kind/id, its owner tf's package view and whether same tf
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static const any* ownerPkg(const any* x){ for(;x;x=x->VpiParent()) if(x->UhdmType()==uhdmpackage) return x; return nullptr; }
static const any* ownerTf(const any* x){ for(;x;x=x->VpiParent()) if(x->UhdmType()==uhdmfunction||x->UhdmType()==uhdmtask) return x; return nullptr; }
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 std::map<const any*,std::string> view; for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) view[p]=std::string(p->VpiName())+(k?"[top]":"[all]"); }
 auto vn=[&](const any*p){ return p? (view.count(p)?view[p]:std::string(p->VpiName())):std::string("null"); };
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if(o->UhdmType()!=uhdmhier_path) continue; auto*hp=(const hier_path*)o; if(!hp->Path_elems()||hp->Path_elems()->empty()) continue; auto*e=hp->Path_elems()->at(0); if(e->UhdmType()!=uhdmref_obj) continue;
  auto*a=((const ref_obj*)e)->Actual_group(); std::cout<<vn(ownerPkg(o))<<" "<<e->VpiName()<<" L"<<o->VpiLineNo()<<" -> ";
  if(!a){std::cout<<"null\n";continue;} std::cout<<a->UhdmType()<<" in "<<vn(ownerPkg(a))<<(ownerTf(a)==ownerTf(o)?" own":" other")<<"\n"; } }
