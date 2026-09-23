// v11u110 census: elaborated-instance PORT cells whose golden typedef is a packed_array_typespec
// parented at a type_parameter with a NAMED element ref (the law-1 shape); scored per cell vs ours.
#include <uhdm/uhdm.h>
#include <cstdio>
#include <string>
#include <map>
#include <filesystem>
using namespace UHDM;
typedef std::map<std::string,const typespec*> C;
static void walk(const any* o, C& c){
  if(!o) return;
  if(o->UhdmType()==uhdmmodule_inst){ auto* mi=(const module_inst*)o;
    if(mi->Ports()) for(auto* p:*mi->Ports()) c[std::string(mi->VpiFullName())+"."+std::string(p->VpiName())]= p->Typespec()?p->Typespec()->Actual_typespec():nullptr;
    if(mi->Modules()) for(auto* m:*mi->Modules()) walk(m,c);
    if(mi->Gen_scope_arrays()) for(auto* g:*mi->Gen_scope_arrays()) walk(g,c);
  } else if(o->UhdmType()==uhdmgen_scope_array){ auto* ga=(const gen_scope_array*)o; if(ga->Gen_scopes()) for(auto* g:*ga->Gen_scopes()) walk(g,c);
  } else if(o->UhdmType()==uhdmgen_scope){ auto* g=(const gen_scope*)o; if(g->Modules()) for(auto* m:*g->Modules()) walk(m,c); if(g->Gen_scope_arrays()) for(auto* a:*g->Gen_scope_arrays()) walk(a,c);}
}
static bool shape(const typespec* t){ if(!t||t->UhdmType()!=uhdmpacked_array_typespec) return false; auto* pa=(const packed_array_typespec*)t;
  return t->VpiParent() && t->VpiParent()->UhdmType()==uhdmtype_parameter && pa->Elem_typespec() && !pa->Elem_typespec()->VpiName().empty(); }
static C load(Serializer& s,const char* f){ C c; auto ds=s.Restore(std::filesystem::path(f)); for(auto* h:ds){auto* dd=(design*)((const uhdm_handle*)h)->object; if(dd->TopModules()) for(auto* t:*dd->TopModules()) walk(t,c);} return c;}
int main(int argc,char**v){ Serializer sg, so; C g=load(sg,v[1]); C o=load(so,v[2]);
  int gs=0, os=0;
  for(auto& [k,t]:g) if(shape(t)){ gs++; auto it=o.find(k); const char* r="OURS-MISSING";
     if(it!=o.end()){ CompareContext cc; r = (it->second && t->Compare(it->second,&cc)==0)?"EQ":"NE"; }
     printf("GSHAPE %s %s\n",k.c_str(),r);}
  for(auto& [k,t]:o) if(shape(t)) os++;
  printf("TOTAL gshape=%d oshape=%d\n",gs,os);
}
