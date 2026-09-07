#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
#include <string>
using namespace UHDM;
static std::string kindOf(const BaseClass* o){return o?std::string(UhdmName(o->UhdmType())):"<null>";}
static const any* actOf(const BaseClass* e){
    if(!e) return nullptr;
    switch(e->UhdmType()){
      case uhdmref_obj: return ((const ref_obj*)e)->Actual_group();
      case uhdmbit_select: return ((const bit_select*)e)->Actual_group();
      case uhdmref_var: return ((const ref_var*)e)->Actual_group();
      default: return nullptr;
    }
}
int main(int argc,char**argv){
    Serializer s; auto h=s.Restore(std::string(argv[1]));
    if(h.empty()) return 3;
    const design* d=(const design*)((const uhdm_handle*)h[0])->object;
    // objects reachable from TopModules
    std::set<const BaseClass*> topSet;
    // crude: mark module_insts in TopModules and their descendants via parent walk later
    unsigned want1=atoi(argv[2]);
    for(const auto& p:s.AllObjects()){
      const BaseClass* q=p.first;
      if(!q||q->UhdmType()!=uhdmhier_path) continue;
      if(q->VpiLineNo()!=want1) continue;
      auto* hp=(const hier_path*)q;
      printf("HP id=%u %u:%u name='%s' rv=%s ts=%s\n",q->UhdmId(),q->VpiLineNo(),
             (unsigned)q->VpiColumnNo(),std::string(q->VpiName()).c_str(),
             kindOf(hp->Root_value()).c_str(),
             hp->Typespec()?"set":"null");
      if(hp->Path_elems())
        for(size_t i=0;i<hp->Path_elems()->size();i++){
          auto* e=hp->Path_elems()->at(i);
          const any* a=actOf(e);
          printf("    [%zu] %s id=%u act=%s(%s)\n",i,kindOf(e).c_str(),e->UhdmId(),
                 kindOf(a).c_str(),a?std::string(a->VpiName()).c_str():"");
        }
      std::string ch;
      for(const BaseClass* p2=q->VpiParent(); p2; p2=p2->VpiParent()){
        ch += " -> "+kindOf(p2);
        if(!p2->VpiName().empty()) ch+="('"+std::string(p2->VpiName())+"')";
        if(p2->UhdmType()==uhdmmodule_inst)
          ch += ((const module_inst*)p2)->VpiTopModule()?"[TOP]":"[notop]";
      }
      printf("    chain:%s\n",ch.c_str());
    }
    // Also: is it in design TopModules / AllModules listing?
    printf("-- design TopModules: %zu  AllModules: %zu\n",
           d->TopModules()?d->TopModules()->size():0,
           d->AllModules()?d->AllModules()->size():0);
    return 0;
}
