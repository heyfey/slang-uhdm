// vbuvm15 VERIFIER census — the implementer's r10buvm15cen with ITS BLIND SPOT
// CLOSED.  r10buvm15cen reads only a tf_call's DIRECT ref_obj arguments, so a
// ref nested inside an OPERATION / CONCAT / SELECT / nested-call argument is
// invisible to it — and v1_homes15.sv cell v16 proves such refs DO move
// (`mk.one(f1 + loc)`, golden binds both operands).  This walks the WHOLE
// argument subtree of every tf_call in a subroutine body.
// MEASUREMENT ONLY.  usage: vbuvm15_cen2 <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>
using namespace UHDM;
static std::string nm(const any* t){ return t? std::string(t->VpiName()):"-"; }
static std::string kd(const any* t){ return t? std::string(UhdmName(t->UhdmType())):"NULL"; }
static std::string fileOf(const any* o){
  for(const any* p=o;p;p=p->VpiParent()){ std::string f(p->VpiFile()); if(f.empty()) continue;
    auto s=f.rfind('/'); return s==std::string::npos?f:f.substr(s+1);} return ""; }
static std::string loc(const any* o){ return o? std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()):"-"; }
int main(int argc,char** argv){
  if(argc<2){std::cerr<<"usage\n";return 2;}
  std::string tag=argc>2?argv[2]:"T";
  Serializer s;
  if(s.Restore(std::string(argv[1])).empty()){std::cout<<"RESTORE_FAIL "<<tag<<"\n";return 3;}
  long ncall=0,ncoll=0;
  // ONE pass over ref_objs: find the NEAREST enclosing tf_call (stopping at the
  // subroutine), then one pass over calls to print.  The naive nested loop is
  // O(calls x objects) and does not finish on BuildUVMPkg.
  std::unordered_map<const any*, std::vector<const any*>> byCall;
  for(auto& kv:s.AllObjects()){
    const any* r=kv.first;
    if(!r||r->UhdmType()!=uhdmref_obj) continue;
    for(const any* p=r->VpiParent(), *g=nullptr; p; p=p->VpiParent()){
      (void)g;
      UHDM_OBJECT_TYPE t=p->UhdmType();
      if(t==uhdmfunc_call||t==uhdmtask_call||t==uhdmmethod_func_call||t==uhdmmethod_task_call){
        byCall[p].push_back(r); break; }
      if(t==uhdmfunction||t==uhdmtask||t==uhdmdesign) break;
    }
  }
  for(auto& kv:s.AllObjects()){
    const any* o=kv.first; if(!o) continue;
    UHDM_OBJECT_TYPE ot=o->UhdmType();
    if(ot!=uhdmfunc_call&&ot!=uhdmtask_call&&ot!=uhdmmethod_func_call&&ot!=uhdmmethod_task_call) continue;
    const any* encl=nullptr; int g=0;
    for(const any* p=o->VpiParent();p&&g<80;p=p->VpiParent(),g++){
      UHDM_OBJECT_TYPE t=p->UhdmType();
      if(t==uhdmfunction||t==uhdmtask){encl=p;break;}
      if(t==uhdmdesign) break; }
    if(!encl) continue;
    ncall++;
    int coll=0;
    if(ot==uhdmfunc_call){ auto* fc=(const func_call*)o;
      if(fc->Function()==(const function*)encl) coll=1;
      else if(encl->UhdmType()==uhdmfunction&&!nm(o).empty()&&nm(o)==nm(encl)) coll=1; }
    if(coll) ncoll++;
    std::string as; int nref=0;
    auto it=byCall.find(o);
    if(it!=byCall.end()){
      std::vector<std::string> parts;
      for(auto* r:it->second){
        const any* ag=((const ref_obj*)r)->Actual_group();
        parts.push_back(loc(r)+":"+nm(r)+"->"+(ag?kd(ag)+"("+nm(ag)+")":"BARE"));
        nref++; }
      std::sort(parts.begin(),parts.end());
      for(auto& x:parts){ if(!as.empty()) as+=";"; as+=x; }
    }
    std::cout<<"CALL2 "<<tag<<" key="<<fileOf(o)<<"|"<<loc(o)<<" ck="<<UhdmName(ot)
             <<" nm="<<nm(o)<<" coll="<<coll<<" sub="<<nm(encl)<<" sk="<<kd(encl)
             <<" nref="<<nref<<" r="<<(as.empty()?"<none>":as)<<"\n";
  }
  std::cout<<"SUMMARY2 "<<tag<<" calls="<<ncall<<" collapsed="<<ncoll<<"\n";
  return 0;
}
