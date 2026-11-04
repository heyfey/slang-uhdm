// hpelem <db> <line>: hier_path elements of hier_paths at <line>: package view, element name, actual kind, actual parent chain (kinds/names, 5 up), actual id
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static const any* ownerPkg(const any* x){ for(;x;x=x->VpiParent()) if(x->UhdmType()==uhdmpackage) return x; return nullptr; }
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; int L=atoi(argv[2]);
 std::map<const any*,std::string> view; for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) view[p]=std::string(p->VpiName())+(k?"[top]":"[all]"); }
 auto vn=[&](const any*p){ return p? (view.count(p)?view[p]:std::string(p->VpiName())):std::string("null"); };
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if(o->UhdmType()!=uhdmhier_path||(int)o->VpiLineNo()!=L) continue; auto*pe=((const hier_path*)o)->Path_elems(); if(!pe) continue;
  for(auto*e:*pe){ const any* a=nullptr; if(e->UhdmType()==uhdmref_obj) a=((const ref_obj*)e)->Actual_group(); else if(e->UhdmType()==uhdmbit_select) a=((const bit_select*)e)->Actual_group();
   std::cout<<vn(ownerPkg(o))<<" "<<e->VpiName()<<" kind="<<e->UhdmType()<<" -> "; if(!a){std::cout<<"null\n";continue;} std::cout<<a->UhdmType()<<" in "<<vn(ownerPkg(a))<<" chain:"; int n=0; for(auto*x=a->VpiParent(); x&&n<4; x=x->VpiParent(),n++) std::cout<<" "<<x->UhdmType()<<":"<<x->VpiName(); std::cout<<"\n"; } } }
