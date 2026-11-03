// clbind <db>: for each package view and each of its task_funcs, the ref_objs in the body whose actual is a
// variable or io_decl: count by the package that owns the actual's task_func (own / other:<name>)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/VpiListener.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static const any* ownerPkg(const any* x){ for(;x;x=x->VpiParent()) if(x->UhdmType()==uhdmpackage) return x; return nullptr; }
static const any* ownerTf(const any* x){ for(;x;x=x->VpiParent()) if(x->UhdmType()==uhdmfunction||x->UhdmType()==uhdmtask) return x; return nullptr; }
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 std::map<std::string,std::map<std::string,int>> cnt;
 std::map<const any*,std::string> view; for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) view[p]=std::string(p->VpiName())+(k?"[top]":"[all]"); }
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if(o->UhdmType()!=uhdmref_obj) continue; auto*r=(const ref_obj*)o; auto*a=r->Actual_group(); if(!a) continue;
  if(a->UhdmType()==uhdmio_decl || dynamic_cast<const variables*>(a)){ auto*tf=ownerTf(o); auto*atf=ownerTf(a); if(!tf||!atf) continue; auto*p=tf->VpiParent(); if(!p||p->UhdmType()!=uhdmpackage) continue;
   auto*ap=atf->VpiParent(); std::string key = (atf==tf)?"own-tf": (ap==p? "same-pkg-other-tf": "other:"+(view.count(ap)?view[ap]:std::string(ap?ap->VpiName():"null")));
   cnt[view.count(p)?view[p]:std::string(p->VpiName())][key]++; } }
 for(auto&[p,m]:cnt){ std::cout<<p<<":"; for(auto&[k,v]:m) std::cout<<" "<<k<<"="<<v; std::cout<<"\n"; } }
