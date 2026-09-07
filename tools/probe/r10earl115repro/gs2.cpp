#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string K(const BaseClass*o){return o?std::string(UhdmName(o->UhdmType())):"<null>";}
static const any* actOf(const BaseClass* e){
    if(!e) return nullptr;
    switch(e->UhdmType()){
      case uhdmref_obj: return ((const ref_obj*)e)->Actual_group();
      case uhdmbit_select: return ((const bit_select*)e)->Actual_group();
      default: return nullptr;
    }
}
int main(int argc,char**argv){
    Serializer s; auto h=s.Restore(std::string(argv[1]));
    if(h.empty()) return 3;
    std::string want=argv[2];
    const design* d=(const design*)((const uhdm_handle*)h[0])->object;
    if(!d->TopModules()) return 0;
    for(auto* m:*d->TopModules()){
      if(!m->Gen_scope_arrays()) continue;
      for(auto* gsa:*m->Gen_scope_arrays()){
        if(std::string(gsa->VpiName()).find(want)==std::string::npos) continue;
        printf("GSA id=%u '%s'\n",gsa->UhdmId(),std::string(gsa->VpiName()).c_str());
        if(!gsa->Gen_scopes()) continue;
        for(auto* gs:*gsa->Gen_scopes()){
          if(!gs->Cont_assigns()) continue;
          for(auto* ca:*gs->Cont_assigns()){
            printf("   CA id=%u lhs=%s(act=%s) rhs=%s id=%u\n",ca->UhdmId(),
                   K(ca->Lhs()).c_str(),K(actOf(ca->Lhs())).c_str(),
                   K(ca->Rhs()).c_str(),ca->Rhs()?ca->Rhs()->UhdmId():0);
            const any* r=ca->Rhs();
            if(r&&r->UhdmType()==uhdmoperation){
              auto* op=(const operation*)r;
              if(op->Operands()) for(auto* o:*op->Operands()){
                printf("      operand %s id=%u",K(o).c_str(),o->UhdmId());
                if(o->UhdmType()==uhdmhier_path){
                  auto* hp=(const hier_path*)o;
                  printf(" '%s' :",std::string(o->VpiName()).c_str());
                  if(hp->Path_elems()) for(auto* e:*hp->Path_elems())
                    printf(" %s(id=%u,act=%s)",K(e).c_str(),e->UhdmId(),K(actOf(e)).c_str());
                }
                printf("\n");
              }
            }
          }
        }
      }
    }
    return 0;
}
