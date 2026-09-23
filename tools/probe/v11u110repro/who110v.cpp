// v11u110 identity probe: for every elaborated module_inst port, print typespec object identity.
#include <uhdm/uhdm.h>
#include <cstdio>
#include <string>
#include <filesystem>
using namespace UHDM;
static std::string d(const any* o){ if(!o) return "<null>"; char b[256]; snprintf(b,256,"%s(%s)#%u@%d:%d",UhdmName(o->UhdmType()).c_str(),std::string(o->VpiName()).c_str(),o->UhdmId(),o->VpiLineNo(),o->VpiColumnNo()); return b;}
static void walk(const any* o){
  if(!o) return;
  if(o->UhdmType()==uhdmmodule_inst){ auto* mi=(const module_inst*)o;
    if(mi->Ports()) for(auto* p:*mi->Ports()){ const typespec* t=p->Typespec()?p->Typespec()->Actual_typespec():nullptr;
      printf("PORT %s.%s ts=%s parent=%s", std::string(mi->VpiFullName()).c_str(), std::string(p->VpiName()).c_str(), d(t).c_str(), t?d(t->VpiParent()).c_str():"-");
      if(t&&t->UhdmType()==uhdmpacked_array_typespec){ auto* pa=(const packed_array_typespec*)t; auto* e=pa->Elem_typespec();
        printf(" ranges=%p elemref=%s full=%s elem=%s elemparent=%s", (void*)pa->Ranges(), e?std::string(e->VpiName()).c_str():"-", e?std::string(e->VpiFullName()).c_str():"-", e?d(e->Actual_typespec()).c_str():"-", (e&&e->Actual_typespec())?d(e->Actual_typespec()->VpiParent()).c_str():"-");}
      printf("\n");}
    if(mi->Parameters()) for(auto* p:*mi->Parameters()) if(p->UhdmType()==uhdmtype_parameter){auto* tp=(const type_parameter*)p; const typespec* t=tp->Typespec()?tp->Typespec()->Actual_typespec():nullptr; printf("TPAR %s.%s ts=%s\n",std::string(mi->VpiFullName()).c_str(),std::string(p->VpiName()).c_str(),d(t).c_str());}
    if(mi->Modules()) for(auto* m:*mi->Modules()) walk(m);
    if(mi->Gen_scope_arrays()) for(auto* g:*mi->Gen_scope_arrays()) walk(g);
  } else if(o->UhdmType()==uhdmgen_scope_array){ auto* ga=(const gen_scope_array*)o; if(ga->Gen_scopes()) for(auto* g:*ga->Gen_scopes()) walk(g);
  } else if(o->UhdmType()==uhdmgen_scope){ auto* g=(const gen_scope*)o; if(g->Modules()) for(auto* m:*g->Modules()) walk(m); if(g->Gen_scope_arrays()) for(auto* a:*g->Gen_scope_arrays()) walk(a);}
}
int main(int c,char**v){ Serializer s; auto ds=s.Restore(std::filesystem::path(v[1])); for(auto* h:ds){ auto* dd=(design*)((const uhdm_handle*)h)->object;
  if(dd->AllModules()) for(auto* m:*dd->AllModules()) if(m->Ports()) for(auto* p:*m->Ports()){const typespec* t=p->Typespec()?p->Typespec()->Actual_typespec():nullptr; printf("DEFPORT %s.%s ts=%s\n",std::string(m->VpiDefName()).c_str(),std::string(p->VpiName()).c_str(),d(t).c_str());}
  if(dd->AllModules()) for(auto* m:*dd->AllModules()) if(m->Parameters()) for(auto* p:*m->Parameters()) if(p->UhdmType()==uhdmtype_parameter){auto* tp=(const type_parameter*)p; const typespec* t=tp->Typespec()?tp->Typespec()->Actual_typespec():nullptr; printf("DEFTPAR %s.%s ts=%s\n",std::string(m->VpiDefName()).c_str(),std::string(p->VpiName()).c_str(),d(t).c_str()); if(t&&t->UhdmType()==uhdmpacked_array_typespec) printf("   ranges=%p\n",(void*)((const packed_array_typespec*)t)->Ranges());}
  if(dd->TopModules()) for(auto* t:*dd->TopModules()) walk(t);} }
