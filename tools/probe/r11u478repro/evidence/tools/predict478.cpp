// predict478 <db>...: per database, candidate counts for this pass's four laws, read from a PRISTINE database
// (measurement only; a tf "has a twin" when another package lists a task_func of the same name at the same
// file:line:col, which holds for every import clone and its home):
//  AF  an enum_typespec parented at an io_decl and referenced by io_decl ref_typespecs of two or more task_funcs
//  AM  a hier_path element after the first, in a twinned tf, unbound, after a ref_obj kind bound to an
//      array_var / packed_array_var whose element typespec is a struct/union (not class-parented) with that member
//  AP  a class_typespec parented at a ref_typespec whose param_assign Lhs parameter's full name does not end
//      with <copy name>.<name> or <copy name>::<name>
//  PB  a ref in a twinned tf bound to a variable that neither its parent's list nor its tf's wrapper begin lists,
//      while one of those lists holds one of the same kind, name and site
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <algorithm>
using namespace UHDM;
static const task_func* tfOf(const any* x){ for(;x;x=x->VpiParent()) if(x->UhdmType()==uhdmfunction||x->UhdmType()==uhdmtask) return (const task_func*)x; return nullptr; }
static const any* pkgOf(const any* x){ for(;x;x=x->VpiParent()) if(x->UhdmType()==uhdmpackage) return x; return nullptr; }
static const typespec* elemTs(const any* a){ const typespec* t=nullptr;
 if(a->UhdmType()==uhdmarray_var){ auto*rt=((array_var*)a)->Typespec(); t=rt?rt->Actual_typespec():nullptr; if(t&&t->UhdmType()==uhdmarray_typespec){ auto*e=((array_typespec*)t)->Elem_typespec(); t=e?e->Actual_typespec():nullptr; } }
 else if(a->UhdmType()==uhdmpacked_array_var){ auto*rt=((packed_array_var*)a)->Typespec(); t=rt?rt->Actual_typespec():nullptr; if(t&&t->UhdmType()==uhdmpacked_array_typespec){ auto*e=((packed_array_typespec*)t)->Elem_typespec(); t=e?e->Actual_typespec():nullptr; } }
 else return nullptr;
 if(t&&t->UhdmType()==uhdmpacked_array_typespec){ auto*e=((packed_array_typespec*)t)->Elem_typespec(); t=e?e->Actual_typespec():nullptr; }
 else if(t&&t->UhdmType()==uhdmarray_typespec){ auto*e=((array_typespec*)t)->Elem_typespec(); t=e?e->Actual_typespec():nullptr; }
 return t; }
int main(int argc,char**argv){
 for(int ai=1;ai<argc;ai++){ Serializer s; std::vector<vpiHandle> h; try{ h=s.Restore(std::filesystem::path(argv[ai])); }catch(...){ std::cout<<argv[ai]<<" ERR\n"; continue; } if(h.empty()){ std::cout<<argv[ai]<<" EMPTY\n"; continue; }
  std::map<std::string,std::set<const any*>> site; std::vector<const any*> all;
  for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; all.push_back(o); if(o->UhdmType()==uhdmfunction||o->UhdmType()==uhdmtask){ auto*p=pkgOf(o); if(!p) continue; site[std::string(o->VpiName())+"@"+std::string(o->VpiFile())+":"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())].insert(p);} }
  auto twinned=[&](const task_func*tf){ if(!tf) return false; auto it=site.find(std::string(tf->VpiName())+"@"+std::string(tf->VpiFile())+":"+std::to_string(tf->VpiLineNo())+":"+std::to_string(tf->VpiColumnNo())); return it!=site.end()&&it->second.size()>=2; };
  int af=0,am=0,ap=0,pb=0; std::map<const any*,std::set<const any*>> enumUsers;
  for(auto*o:all){ auto t=o->UhdmType();
   if(t==uhdmref_typespec && o->VpiParent() && o->VpiParent()->UhdmType()==uhdmio_decl){ auto*a=((ref_typespec*)o)->Actual_typespec(); if(a&&a->UhdmType()==uhdmenum_typespec&&a->VpiParent()&&a->VpiParent()->UhdmType()==uhdmio_decl) enumUsers[a].insert(tfOf(o)); }
   if(t==uhdmhier_path){ auto*pe=((hier_path*)o)->Path_elems(); if(!pe||pe->size()<2||!twinned(tfOf(o))) continue;
    for(size_t i=1;i<pe->size();i++){ auto*pr=dynamic_cast<const ref_obj*>((*pe)[i-1]); auto*cu=dynamic_cast<const ref_obj*>((*pe)[i]); if(!pr||!cu||cu->Actual_group()||!pr->Actual_group()) continue; std::string_view nm=cu->VpiName(); if(nm.empty()||nm[0]=='[') continue;
     auto*et=elemTs(pr->Actual_group()); if(!et||(et->VpiParent()&&et->VpiParent()->UhdmType()==uhdmclass_defn)) continue; const VectorOftypespec_member* m=nullptr; if(et->UhdmType()==uhdmstruct_typespec) m=((struct_typespec*)et)->Members(); else if(et->UhdmType()==uhdmunion_typespec) m=((union_typespec*)et)->Members(); if(!m) continue; for(auto*x:*m) if(x->VpiName()==nm){ am++; break; } } }
   if(t==uhdmclass_typespec && o->VpiParent() && o->VpiParent()->UhdmType()==uhdmref_typespec){ auto*c=(class_typespec*)o; if(!c->Param_assigns()||c->VpiName().empty()) continue; std::string cn(c->VpiName());
    for(auto*pa:*c->Param_assigns()){ auto*l=pa->Lhs(); if(!l||l->UhdmType()!=uhdmparameter) continue; if(l->VpiParent()!=pa&&l->VpiParent()!=c) continue; std::string fn(((parameter*)l)->VpiFullName()), nm(l->VpiName()); auto ends=[&](const std::string& x){ return fn.size()>=x.size()&&fn.compare(fn.size()-x.size(),x.size(),x)==0; }; if(!fn.empty()&&!ends(cn+"."+nm)&&!ends(cn+"::"+nm)) ap++; } }
   const any* act=nullptr; if(auto*r=dynamic_cast<const ref_obj*>(o)) act=r->Actual_group(); else if(t==uhdmref_var) act=((ref_var*)o)->Actual_group();
   auto*v=dynamic_cast<const variables*>(act); if(v&&v->VpiParent()){ auto*ctf=tfOf(o); auto*vtf=tfOf(v); if(!ctf||!vtf||ctf==vtf||!twinned(ctf)||!twinned(vtf)||pkgOf(vtf)==pkgOf(ctf)) continue;
    std::vector<const std::vector<const BaseClass*>*> L; if(auto*l1=std::get<2>(v->VpiParent()->GetByVpiType(vpiVariables))) L.push_back(l1); if(auto*st=vtf->Stmt(); st&&st!=v->VpiParent()) if(auto*l2=std::get<2>(st->GetByVpiType(vpiVariables))) L.push_back(l2);
    bool listed=L.empty(); for(auto*l:L) if(std::find(l->begin(),l->end(),v)!=l->end()) listed=true; if(listed) continue; int n=0; const any* w=nullptr;
    for(auto*l:L) for(auto*e:*l){ auto*ev=dynamic_cast<const variables*>(e); if(ev&&ev->UhdmType()==v->UhdmType()&&ev->VpiName()==v->VpiName()&&ev->VpiLineNo()==v->VpiLineNo()&&ev->VpiColumnNo()==v->VpiColumnNo()){ if(ev!=w) n++; w=ev; } }
    if(n==1) pb++; }
  }
  for(auto&[e,u]:enumUsers) if(u.size()>=2) af+=u.size();
  std::cout<<argv[ai]<<" AF="<<af<<" AM="<<am<<" AP="<<ap<<" PB="<<pb<<"\n"; } }
