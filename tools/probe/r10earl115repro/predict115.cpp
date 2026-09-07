// r10earl115 -- THE PREDICTION, made from PRISTINE databases only.
// MEASUREMENT ONLY.  Reads OUR pristine database and applies the law's gate,
// expressed in UHDM terms (the same three halves the emitter's record site
// applies in slang terms):
//   * an ELABORATED gen-scope cont_assign (TOP modules only) whose Rhs is an
//     `operation` with vpiAssignmentPatternOp;
//   * NOT the one shape golden binds through -- a Lhs that is EXACTLY a
//     `ref_obj` (not a bit_select) whose `Actual_group` is a `struct_var`
//     parented OUTSIDE the gen scope (arm t4 f2);
//   * a `hier_path` operand with at least one BOUND element after index 0.
// Prints one line per predicted moving cell and a per-database summary, so the
// mover ROW set can be named BEFORE the patched sweep is read.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <functional>
#include <string>
using namespace UHDM;
static std::string K(const BaseClass*o){return o?std::string(UhdmName(o->UhdmType())):"<null>";}
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
int main(int argc,char**argv){
    if(argc<3){fprintf(stderr,"usage: predict115 <ours.uhdm> <tag>\n");return 2;}
    Serializer s; auto h=s.Restore(std::string(argv[1]));
    if(h.empty()){printf("PRC 3 %s\n",argv[2]);return 3;}
    const design* d=(const design*)((const uhdm_handle*)h[0])->object;
    std::string tag=argv[2];
    long cells=0, gate=0, keep=0;
    std::function<void(const any*)> walk = [&](const any* sc){
      if(!sc) return;
      const VectorOfcont_assign* cas=nullptr;
      const VectorOfgen_scope_array* gsas=nullptr;
      const VectorOfmodule_inst* mods=nullptr;
      const VectorOfinterface_inst* ifs=nullptr;
      bool isGen=false;
      if(auto* mi=any_cast<const module_inst*>(sc)){
        cas=mi->Cont_assigns(); gsas=mi->Gen_scope_arrays();
        mods=mi->Modules(); ifs=mi->Interfaces();
      } else if(auto* ii=any_cast<const interface_inst*>(sc)){
        cas=ii->Cont_assigns(); gsas=ii->Gen_scope_arrays(); ifs=ii->Interfaces();
      } else if(auto* gs=any_cast<const gen_scope*>(sc)){
        cas=gs->Cont_assigns(); gsas=gs->Gen_scope_arrays();
        mods=gs->Modules(); ifs=gs->Interfaces(); isGen=true;
      } else if(auto* ga=any_cast<const gen_scope_array*>(sc)){
        if(ga->Gen_scopes()) for(auto* g:*ga->Gen_scopes()) walk(g);
        return;
      }
      if(isGen && cas) for(auto* ca:*cas){
        const any* r=ca->Rhs();
        if(!r||r->UhdmType()!=uhdmoperation) continue;
        auto* op=(const operation*)r;
        if(op->VpiOpType()!=vpiAssignmentPatternOp||!op->Operands()) continue;
        const any* lh=ca->Lhs();
        bool wholeRef = lh && lh->UhdmType()==uhdmref_obj;
        bool genLocal = false;
        if(wholeRef){
          const any* la=((const ref_obj*)lh)->Actual_group();
          if(la&&la->VpiParent()&&la->VpiParent()->UhdmType()==uhdmgen_scope)
            genLocal=true;
        }
        bool fenced = wholeRef && !genLocal;   // arm t4 f2
        for(auto* o:*op->Operands()){
          if(!o||o->UhdmType()!=uhdmhier_path) continue;
          auto* es=((const hier_path*)o)->Path_elems();
          if(!es) continue;
          for(size_t i=1;i<es->size();i++){
            const any* a=actOf(es->at(i));
            if(!a) continue;
            cells++;
            if(fenced){ keep++;
              printf("KEEP\t%s\t%u:%u\t%s\t[%zu]\t%s(%s)\n",tag.c_str(),
                     o->VpiLineNo(),(unsigned)o->VpiColumnNo(),
                     std::string(o->VpiName()).c_str(),i,
                     K(a).c_str(),std::string(a->VpiName()).c_str());
            } else { gate++;
              printf("MOVE\t%s\t%u:%u\t%s\t[%zu]\t%s(%s)->null\n",tag.c_str(),
                     o->VpiLineNo(),(unsigned)o->VpiColumnNo(),
                     std::string(o->VpiName()).c_str(),i,
                     K(a).c_str(),std::string(a->VpiName()).c_str());
            }
          }
        }
      }
      if(gsas) for(auto* g:*gsas) walk(g);
      if(mods) for(auto* m:*mods) walk(m);
      if(ifs) for(auto* i2:*ifs) walk(i2);
    };
    if(d->TopModules()) for(auto* t:*d->TopModules()) walk(t);
    printf("SUMMARY\t%s\tbound_nonfirst_in_genpat=%ld\tPREDICT_MOVE=%ld\tFENCED_KEEP=%ld\n",
           tag.c_str(),cells,gate,keep);
    printf("PRC 0 %s\n",tag.c_str());
    return 0;
}
