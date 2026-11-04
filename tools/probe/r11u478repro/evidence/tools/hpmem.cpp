// hpmem <golden> <ours>: every hier_path element whose actual is a typespec_member, keyed by
// (package view or "-", owner task_func full name, line:col of the element, element name); prints the keys
// present on one side only, and a count of the keys on both
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
static const any* ownerOf(const any* x, UHDM_OBJECT_TYPE t){ for(;x;x=x->VpiParent()) if(x->UhdmType()==t) return x; return nullptr; }
static std::multiset<std::string> keys(const char* f){ Serializer s; auto h=s.Restore(std::filesystem::path(f)); auto*d=(design*)((uhdm_handle*)h[0])->object;
 std::map<const any*,std::string> view; for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) view[p]=std::string(p->VpiName())+(k?"[top]":"[all]"); }
 std::multiset<std::string> out;
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if(o->UhdmType()!=uhdmhier_path) continue; auto*pe=((hier_path*)o)->Path_elems(); if(!pe) continue;
  for(auto*e:*pe){ auto*r=dynamic_cast<const ref_obj*>(e); if(!r||!r->Actual_group()||r->Actual_group()->UhdmType()!=uhdmtypespec_member) continue;
   auto*p=ownerOf(o,uhdmpackage); const any*tf=nullptr; for(auto*x=o->VpiParent();x;x=x->VpiParent()) if(x->UhdmType()==uhdmfunction||x->UhdmType()==uhdmtask){tf=x;break;}
   std::string k=(p?(view.count(p)?view[p]:std::string(p->VpiName())):std::string("-"))+" "+(tf?std::string(((task_func*)tf)->VpiFullName()):std::string("-"))+" "+std::string(o->VpiName())+" @"+std::to_string(e->VpiLineNo())+":"+std::to_string(e->VpiColumnNo())+" "+std::string(e->VpiName());
   out.insert(k);} }
 return out; }
int main(int argc,char**argv){ auto a=keys(argv[1]); auto b=keys(argv[2]); size_t both=0;
 for(auto&k:a){ if(b.count(k)) both++; else std::cout<<"GOLDEN_ONLY "<<k<<"\n"; }
 for(auto&k:b) if(!a.count(k)) std::cout<<"OURS_ONLY "<<k<<"\n";
 std::cout<<"golden "<<a.size()<<" ours "<<b.size()<<" both "<<both<<"\n"; }
