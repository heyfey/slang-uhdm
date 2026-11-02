// pred471 <db>...: per database, the firing candidates of pass 471's laws, computed on a PRISTINE database:
//  E  § enumSharedCloneHomeInst471: an importing package's import-copy role whose enum typespec (no alias)
//     is Instanced at a package that is neither the importer nor the home its qualified name names;
//  C  § impTdParamCaFoldTs471: a constant without typespec under a cont_assign's Rhs whose source text is an
//     identifier naming an imported parameter (vpiImported) of the owning module/interface/program
//     (only typedef-typed ones fire; the type is printed);
//  P  § procAsgRhsPkgFoldTs471: a constant without typespec that is directly an assignment's Rhs inside a
//     process or task/function of a module or program, whose source text names an imported parameter.
// Prints "<db> <code> <detail>" per candidate and "<db> TOTAL E=.. C=.. P=..".
#include <uhdm/uhdm.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <sstream>
#include <set>
#include <functional>
using namespace UHDM;
static std::map<std::string,std::vector<std::string>> files;
static std::string text(const std::string& f,int l,int c,int el,int ec){
  if(f.empty()||l<=0||el<l) return ""; auto it=files.find(f); if(it==files.end()){ std::ifstream in(f); std::vector<std::string> v; std::string s; while(std::getline(in,s)) v.push_back(s); it=files.emplace(f,v).first; }
  auto& v=it->second; if(el>(int)v.size()) return ""; std::string out;
  for(int i=l;i<=el;i++){ const std::string& s=v[i-1]; int b=(i==l)?c-1:0; int e=(i==el)?ec-1:(int)s.size(); if(b<0) b=0; if(e>(int)s.size()) e=s.size(); if(e>b) out+=s.substr(b,e-b); if(i!=el) out+="\n"; }
  return out; }
static bool ident(const std::string& s){ if(s.empty()) return false; if(!(isalpha((unsigned char)s[0])||s[0]=='_')) return false; for(char ch: s) if(!(isalnum((unsigned char)ch)||ch=='_'||ch=='$')) return false; return true; }
int main(int argc,char**argv){
 for(int ai=1;ai<argc;ai++){ const char* db=argv[ai]; Serializer s; auto h=s.Restore(std::filesystem::path(db)); if(h.empty()) { std::cout<<db<<" NODB\n"; continue; } auto*d=(design*)((uhdm_handle*)h[0])->object;
  int nE=0,nC=0,nP=0;
  // E
  std::map<const void*,std::string> pk; std::map<std::string,int> haveDef,haveTop;
  if(d->AllPackages()) for(auto*p:*d->AllPackages()){ pk[p]=std::string(p->VpiName()); haveDef[std::string(p->VpiName())]=1; }
  if(d->TopPackages()) for(auto*p:*d->TopPackages()){ pk[p]=std::string(p->VpiName()); haveTop[std::string(p->VpiName())]=1; }
  auto chk=[&](const std::string& pn,const ref_typespec* rt,const std::string& what){ if(!rt) return; auto*t=rt->Actual_typespec(); if(!t||t->Typedef_alias()||t->UhdmType()!=uhdmenum_typespec) return; auto it=pk.find(t->Instance()); if(it==pk.end()) return; std::string i1=it->second; if(i1==pn) return; std::string n(t->VpiName()); auto c=n.find("::"); if(c==std::string::npos) return; std::string home=n.substr(0,c); if(home==i1) return; if(home==pn||!haveDef.count(home)||!haveTop.count(home)) return; nE++; std::cout<<db<<" E "<<what<<" inst="<<i1<<" home="<<home<<"\n"; };
  for(int v=0;v<2;v++){ auto*l=v?d->TopPackages():d->AllPackages(); if(!l) continue; for(auto*p:*l){ std::string pn(p->VpiName()); const char* vw=v?"!TOP":"!DEF";
    if(p->Parameters()) for(auto*a:*p->Parameters()) if(a->UhdmType()==uhdmparameter){ auto*cp=(parameter*)a; if(cp->VpiImported().empty()||cp->VpiImported()==pn) continue; chk(pn,cp->Typespec(),pn+vw+" param "+std::string(cp->VpiName())); }
    if(p->Param_assigns()) for(auto*pa:*p->Param_assigns()){ if(!pa->Lhs()||pa->Lhs()->UhdmType()!=uhdmparameter) continue; auto*lp=(parameter*)pa->Lhs(); if(lp->VpiImported().empty()||lp->VpiImported()==pn) continue; chk(pn,lp->Typespec(),pn+vw+" pa-lhs "+std::string(lp->VpiName())); if(pa->Rhs()&&pa->Rhs()->UhdmType()==uhdmconstant) chk(pn,((constant*)pa->Rhs())->Typespec(),pn+vw+" pa-rhs "+std::string(lp->VpiName())); } } }
  // C / P
  auto ownerOf=[&](const any* q, bool& inProcTf)->const any*{ inProcTf=false; for(; q; q=q->VpiParent()){ auto k=q->UhdmType();
      if(k==uhdmalways||k==uhdminitial||k==uhdmfinal_stmt||k==uhdmtask||k==uhdmfunction) inProcTf=true;
      if(k==uhdmmodule_inst||k==uhdminterface_inst||k==uhdmprogram) return q;
      if(k==uhdmpackage||k==uhdmclass_defn) return nullptr; } return nullptr; };
  auto judge=[&](const constant* c, const any* owner, char code){
    std::string f(c->VpiFile()); if(f.empty()) f=std::string(owner->VpiFile());
    std::string tx=text(f,c->VpiLineNo(),c->VpiColumnNo(),c->VpiEndLineNo(),c->VpiEndColumnNo());
    if(!ident(tx)) return;
    const VectorOfany* ps=nullptr; auto k=owner->UhdmType();
    if(k==uhdmmodule_inst) ps=((const module_inst*)owner)->Parameters(); else if(k==uhdminterface_inst) ps=((const interface_inst*)owner)->Parameters(); else ps=((const program*)owner)->Parameters();
    const parameter* hit=nullptr; if(ps) for(auto*a:*ps) if(a->UhdmType()==uhdmparameter && a->VpiName()==tx && !((const parameter*)a)->VpiImported().empty()){ hit=(const parameter*)a; break; }
    if(!hit && k==uhdmprogram && d->AllPrograms()) for(auto*pg:*d->AllPrograms()) if(pg->VpiDefName()==owner->VpiDefName() && pg->Parameters()) for(auto*a:*pg->Parameters()) if(!hit && a->UhdmType()==uhdmparameter && a->VpiName()==tx && !((const parameter*)a)->VpiImported().empty()) hit=(const parameter*)a;
    if(!hit) return;
    std::string tsk="none"; if(hit->Typespec()&&hit->Typespec()->Actual_typespec()){ auto*t=hit->Typespec()->Actual_typespec(); tsk=std::string(UhdmName(t->UhdmType()))+(t->Typedef_alias()?"+alias":"")+":"+std::string(t->VpiName()); }
    std::string loc=std::string(owner->VpiName())+" "+std::to_string(c->VpiLineNo())+":"+std::to_string(c->VpiColumnNo())+" "+tx+" ts="+tsk;
    if(code=='P'){ nP++; } else nC++;
    std::cout<<db<<" "<<code<<" "<<loc<<"\n"; };
  std::set<const any*> seen;
  std::function<void(const any*, const any*)> walkCa=[&](const any* e, const any* owner){ if(!e||!seen.insert(e).second) return; auto k=e->UhdmType();
    if(k==uhdmconstant){ if(!((const constant*)e)->Typespec()) judge((const constant*)e, owner, 'C'); return; }
    if(k==uhdmoperation){ auto*op=(const operation*)e; if(op->Operands()) for(auto*x:*op->Operands()) walkCa(x,owner); return; }
    if(k==uhdmbit_select){ walkCa(((const bit_select*)e)->VpiIndex(),owner); return; }
    if(k==uhdmpart_select){ walkCa(((const part_select*)e)->Left_range(),owner); walkCa(((const part_select*)e)->Right_range(),owner); return; }
    if(k==uhdmindexed_part_select){ walkCa(((const indexed_part_select*)e)->Base_expr(),owner); walkCa(((const indexed_part_select*)e)->Width_expr(),owner); return; }
    if(k==uhdmsys_func_call||k==uhdmfunc_call){ auto*fc=(const tf_call*)e; if(fc->Tf_call_args()) for(auto*x:*fc->Tf_call_args()) walkCa(x,owner); return; } };
  for(auto& [obj,id]: s.AllObjects()){ (void)id; const any* o=(const any*)obj; if(!o) continue;
    if(o->UhdmType()==uhdmassignment){ auto*a=(const assignment*)o; auto*r=a->Rhs(); if(!r||r->UhdmType()!=uhdmconstant||((const constant*)r)->Typespec()) continue; bool pt=false; auto*ow=ownerOf(a,pt); if(!ow||!pt||ow->UhdmType()==uhdminterface_inst) continue; if(seen.insert(r).second) judge((const constant*)r, ow, 'P'); }
    else if(o->UhdmType()==uhdmcont_assign){ auto*a=(const cont_assign*)o; bool pt=false; auto*ow=ownerOf(a,pt); if(!ow) continue; walkCa(a->Rhs(), ow); } }
  std::cout<<db<<" TOTAL E="<<nE<<" C="<<nC<<" P="<<nP<<"\n";
 }
}
