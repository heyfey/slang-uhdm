// VERIFIER's scorer.  ct6clsref's walkExpr uses any_cast<ref_obj*> FIRST, which
// is IS-A: bit_select / part_select / indexed_part_select / var_select are all
// `final : public ref_obj`, so it stops at the select and NEVER descends into
// its index/ranges.  It also never walks a tf_call PREFIX or a hier_path.
// This scorer walks EVERY container and prints the node's EXACT UhdmType, so a
// cell whose only references live under a select cannot read as "empty".
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
static long rows=0, refs=0, containers=0;
static std::string desc(const BaseClass* o){
  if(!o) return "<null>";
  std::string n(o->VpiName());
  if(auto* v=any_cast<const variables*>(o)) if(!v->VpiFullName().empty()) n=v->VpiFullName();
  return std::string(UhdmName(o->UhdmType()))+"("+n+")";
}
static void walk(const std::string& cls,const std::string& var,const any* e,int depth,const char* via){
  if(!e||depth>20) return;
  UHDM_OBJECT_TYPE t=e->UhdmType();
  // ref-family LEAF/CONTAINER printing, keyed on the EXACT type
  if(t==uhdmref_obj||t==uhdmbit_select||t==uhdmpart_select||t==uhdmindexed_part_select||t==uhdmvar_select){
    auto* ro=any_cast<ref_obj*>((any*)e);
    printf("REF  %-40s %-20s %-20s d=%d via=%-10s name=%-24s full=%-56s actual=%s\n",
      cls.c_str(),var.c_str(),std::string(UhdmName(t)).c_str(),depth,via,
      std::string(ro->VpiName()).c_str(),std::string(ro->VpiFullName()).c_str(),
      desc(ro->Actual_group()).c_str());
    refs++;
    if(t==uhdmbit_select) walk(cls,var,((bit_select*)e)->VpiIndex(),depth+1,"bsIndex");
    else if(t==uhdmpart_select){ walk(cls,var,((part_select*)e)->Left_range(),depth+1,"psL");
                                 walk(cls,var,((part_select*)e)->Right_range(),depth+1,"psR"); }
    else if(t==uhdmindexed_part_select){ walk(cls,var,((indexed_part_select*)e)->Base_expr(),depth+1,"ipsBase");
                                         walk(cls,var,((indexed_part_select*)e)->Width_expr(),depth+1,"ipsW"); }
    else if(t==uhdmvar_select){ if(auto* ix=((var_select*)e)->Exprs()) for(auto* x:*ix) walk(cls,var,x,depth+1,"vsIndex"); }
    return;
  }
  if(t==uhdmref_var){
    auto* rv=any_cast<ref_var*>((any*)e);
    printf("REF  %-40s %-20s %-20s d=%d via=%-10s name=%-24s full=%-56s actual=%s\n",
      cls.c_str(),var.c_str(),"ref_var",depth,via,
      std::string(rv->VpiName()).c_str(),std::string(rv->VpiFullName()).c_str(),
      desc(rv->Actual_group()).c_str());
    refs++; return;
  }
  containers++;
  if(t==uhdmoperation){ if(auto* ops=((operation*)e)->Operands()) for(auto* o:*ops) walk(cls,var,o,depth+1,"op"); return; }
  if(t==uhdmhier_path){
    printf("HIER %-40s %-20s hier_path d=%d full=%s\n",cls.c_str(),var.c_str(),depth,
           std::string(((hier_path*)e)->VpiFullName()).c_str());
    if(auto* pe=((hier_path*)e)->Path_elems()) for(auto* p:*pe) walk(cls,var,p,depth+1,"hpElem");
    return;
  }
  if(auto* tc=any_cast<tf_call*>((any*)e)){
    if(auto* pfx=any_cast<method_func_call*>((any*)e)) if(pfx->Prefix()) walk(cls,var,pfx->Prefix(),depth+1,"PREFIX");
    if(auto* args=tc->Tf_call_args()) for(auto* a:*args) walk(cls,var,a,depth+1,"arg");
    return;
  }
  if(t==uhdmarray_expr){ if(auto* ex=((array_expr*)e)->Exprs()) for(auto* x:*ex) walk(cls,var,x,depth+1,"arrElem"); return; }
}
static std::set<const class_defn*> seen;
static void doClass(const class_defn* cd){
  if(!cd||!seen.insert(cd).second) return;
  if(cd->Variables()) for(auto* v:*cd->Variables()){ if(!v) continue; rows++; if(!v->Expr()) continue;
    walk(std::string(cd->VpiFullName()),std::string(v->VpiName()),v->Expr(),0,"root"); }
  if(cd->Deriveds()) for(auto* d:*cd->Deriveds()) doClass(d);
}
int32_t main(int32_t argc,char** argv){
  if(argc<2){fprintf(stderr,"usage: vsd6ref <db.uhdm>\n");return 2;}
  Serializer s; auto restored=s.Restore(std::string(argv[1]));
  if(restored.empty()){printf("RESTORE-FAIL\n");return 3;}
  design* d=(design*)((const uhdm_handle*)restored[0])->object;
  if(d->AllClasses()) for(auto* c:*d->AllClasses()) doClass(c);
  auto pk=[&](VectorOfpackage* v){ if(!v) return; for(auto* p:*v) if(p&&p->Class_defns()) for(auto* c:*p->Class_defns()) doClass(c); };
  pk(d->AllPackages()); pk(d->TopPackages());
  printf("-- classes=%zu entries=%ld refs=%ld containers=%ld\n",seen.size(),rows,refs,containers);
  if(rows==0){printf("REFUSING: EMPTY POPULATION\n");return 5;}
  return 0;
}
