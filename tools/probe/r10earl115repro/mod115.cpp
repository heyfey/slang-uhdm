#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string K(const BaseClass*o){return o?std::string(UhdmName(o->UhdmType())):"<null>";}
int main(int argc,char**argv){
    Serializer s; auto h=s.Restore(std::string(argv[1]));
    if(h.empty()) return 3;
    const design* d=(const design*)((const uhdm_handle*)h[0])->object;
    auto dump=[&](const module_inst* m,const char* tag){
      printf("== %s module_inst '%s' top=%d\n",tag,std::string(m->VpiName()).c_str(),(int)m->VpiTopModule());
      printf("   Variables: ");
      if(m->Variables()) for(auto* v:*m->Variables()) printf("%s('%s') ",K(v).c_str(),std::string(v->VpiName()).c_str());
      printf("\n   Array_vars: ");
      if(m->Array_vars()) for(auto* v:*m->Array_vars()) printf("%s('%s') ",K(v).c_str(),std::string(v->VpiName()).c_str());
      printf("\n   Nets: ");
      if(m->Nets()) for(auto* v:*m->Nets()) printf("%s('%s') ",K(v).c_str(),std::string(v->VpiName()).c_str());
      printf("\n   Array_nets: ");
      if(m->Array_nets()) for(auto* v:*m->Array_nets()) printf("%s('%s') ",K(v).c_str(),std::string(v->VpiName()).c_str());
      printf("\n   Ports: ");
      if(m->Ports()) for(auto* v:*m->Ports()) printf("port('%s') ",std::string(v->VpiName()).c_str());
      printf("\n   GenScopeArrays: %zu  ContAssigns: %zu\n",
             m->Gen_scope_arrays()?m->Gen_scope_arrays()->size():0,
             m->Cont_assigns()?m->Cont_assigns()->size():0);
    };
    if(d->TopModules()) for(auto* m:*d->TopModules()) dump(m,"TOP");
    if(d->AllModules()) for(auto* m:*d->AllModules()) dump(m,"ALL");
    return 0;
}
