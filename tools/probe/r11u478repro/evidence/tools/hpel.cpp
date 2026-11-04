// hpel <db> <hier_path name>: for every hier_path with that VpiName, its owner package view (all/top) and task_func,
// and per path element: kind, name, the actual's kind, id and the package view / tf of the actual's owner
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static const any* ownerOf(const any* x, UHDM_OBJECT_TYPE t){ for(;x;x=x->VpiParent()) if(x->UhdmType()==t) return x; return nullptr; }
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string N=argv[2];
 std::map<const any*,std::string> view; for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) view[p]=std::string(p->VpiName())+(k?"[top]":"[all]"); }
 auto vw=[&](const any*o){ auto*p=ownerOf(o,uhdmpackage); return p? (view.count(p)?view[p]:std::string(p->VpiName())+"[?]") : std::string("-"); };
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if(o->UhdmType()!=uhdmhier_path||o->VpiName()!=N) continue; auto*hp=(hier_path*)o;
  std::cout<<"hier_path id="<<o->UhdmId()<<" in "<<vw(o)<<"\n"; if(!hp->Path_elems()) continue;
  for(auto*e:*hp->Path_elems()){ std::cout<<"   "<<UhdmName(e->UhdmType())<<" "<<e->VpiName();
   if(auto*r=any_cast<const ref_obj*>(e)){ if(auto*a=r->Actual_group()){ std::cout<<" -> "<<UhdmName(a->UhdmType())<<" "<<a->VpiName()<<" id="<<a->UhdmId()<<" in "<<vw(a);
     const any* p=a->VpiParent(); std::cout<<" parent="<<(p?UhdmName(p->UhdmType()):"null")<<" "<<(p?p->VpiName():"");
     if(a->UhdmType()==uhdmarray_var){ const any* t=nullptr; if(auto*rt=((array_var*)a)->Typespec()) t=rt->Actual_typespec(); std::cout<<" ts="<<(t?UhdmName(t->UhdmType()):"null");
       if(t&&t->UhdmType()==uhdmarray_typespec){ auto*ert=((array_typespec*)t)->Elem_typespec(); auto*et=ert?ert->Actual_typespec():nullptr; std::cout<<" elem="<<(et?UhdmName(et->UhdmType()):"null")<<" "<<(et?et->VpiName():"");
         if(et&&et->UhdmType()==uhdmstruct_typespec&&((struct_typespec*)et)->Members()&&!((struct_typespec*)et)->Members()->empty()){ auto*m0=((struct_typespec*)et)->Members()->front(); std::cout<<" elemid="<<et->UhdmId()<<" m0ts='"<<(m0->Typespec()?m0->Typespec()->VpiFullName():"")<<"'"; }
         if(et){ std::cout<<" elemchain:"; int g=0; for(auto*x=et->VpiParent();x&&g<6;x=x->VpiParent(),g++) std::cout<<" < "<<UhdmName(x->UhdmType())<<":"<<x->VpiName(); } } }
     if(a->UhdmType()==uhdmtypespec_member){ auto*tm=(typespec_member*)a; if(auto*rt=tm->Typespec()) std::cout<<" tsref='"<<rt->VpiFullName()<<"'"; } }
    else std::cout<<" -> null"; }
   std::cout<<"\n"; } } }
