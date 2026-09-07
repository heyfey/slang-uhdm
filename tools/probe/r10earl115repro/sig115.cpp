// r10earl115 -- per-element BINDING SIGNATURE census of every hier_path.
// MEASUREMENT ONLY.  Prints one row per (hier_path span, name, element index,
// position class, element kind) with the bound object's KIND, so both sides
// can be joined as a MULTISET.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/UhdmListener.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;
static std::string kindOf(const BaseClass* o){return o?std::string(UhdmName(o->UhdmType())):"<null>";}
static const any* actOf(const BaseClass* e){
    if(!e) return nullptr;
    switch(e->UhdmType()){
      case uhdmref_obj: return ((const ref_obj*)e)->Actual_group();
      case uhdmref_var: return ((const ref_var*)e)->Actual_group();
      case uhdmbit_select: return ((const bit_select*)e)->Actual_group();
      case uhdmvar_select: return ((const var_select*)e)->Actual_group();
      default: return nullptr;
    }
}
static const char* posClass(size_t i,size_t n){
    if(n==1) return "only"; if(i==0) return "first";
    if(i+1==n) return "trail"; return "mid";
}
static std::string scopeOf(const BaseClass* hp){
    const BaseClass* p=hp?hp->VpiParent():nullptr; int gd=0;
    for(int d=0;d<24&&p;d++){
      auto t=p->UhdmType();
      if(t==uhdmgen_scope||t==uhdmgen_scope_array) gd++;
      if(t==uhdmmodule_inst||t==uhdminterface_inst||t==uhdmpackage||
         t==uhdmclass_defn||t==uhdmgen_scope)
        return std::string(UhdmName(t))+"/gd"+std::to_string(gd);
      p=p->VpiParent();
    }
    return "?";
}
static std::string carrierOf(const BaseClass* hp){
    const BaseClass* p=hp?hp->VpiParent():nullptr;
    if(!p) return "<none>";
    std::string s=kindOf(p);
    if(auto* op=any_cast<const operation*>(p)) s+="/op"+std::to_string(op->VpiOpType());
    if(auto* q=p->VpiParent()) s+="<-"+kindOf(q);
    return s;
}

// THE LIVE TREE ONLY.  `Serializer::AllObjects` on a RESTORED database also
// hands back objects the emitter minted and abandoned (r10earl114's R3 arena
// residue), which would put a phantom `<null>` in every payload SET.  The
// UhdmListener walks the design exactly as `uhdm-dump` and the JUDGE do, so a
// cell here is an object the judge can actually reach.
class HpWalk final : public UhdmListener {
 public:
  std::string tag, db;
  void enterHier_path(const hier_path* const hp) final {
    auto* es = hp->Path_elems(); size_t n = es ? es->size() : 0;
    char span[128];
    snprintf(span, sizeof span, "%u:%u-%u:%u", hp->VpiLineNo(),
             (unsigned)hp->VpiColumnNo(), hp->VpiEndLineNo(),
             (unsigned)hp->VpiEndColumnNo());
    const any* rv = hp->Root_value();
    for (size_t i = 0; i < n; i++) {
      const BaseClass* e = es->at(i);
      const any* a = actOf(e);
      printf("ROW\t%s\t%s\t%s\tnm=%s\tidx=%zu/%zu\tpos=%s\tek=%s\tACT=%s\tACTNM=%s\tACTOWN=%s\tRV=%s\tSC=%s\tCAR=%s\n",
             tag.c_str(), db.c_str(), span, std::string(hp->VpiName()).c_str(),
             i, n, posClass(i, n), kindOf(e).c_str(), kindOf(a).c_str(),
             a ? std::string(a->VpiName()).c_str() : "",
             a && a->VpiParent() ? kindOf(a->VpiParent()).c_str() : "",
             kindOf(rv).c_str(), scopeOf(hp).c_str(), carrierOf(hp).c_str());
    }
  }
};

int main(int argc,char**argv){
    if(argc<3){fprintf(stderr,"usage: sig115 <db> <tag>\n");return 2;}
    Serializer s; auto h=s.Restore(std::string(argv[1]));
    if(h.empty()){printf("CENRC 3\n");return 3;}
    const design* d=(const design*)((const uhdm_handle*)h[0])->object;
    HpWalk w; w.tag=argv[2]; w.db=argv[1];
    w.listenDesign(d);
    printf("CENRC 0\n");
    return 0;
}
