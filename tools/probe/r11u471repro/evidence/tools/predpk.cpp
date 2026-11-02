// predpk <db>...: ref_objs in a package's DEFINITION listing (param_assign Rhs subtrees) whose name is
// qualified (x::P) while the source text at their span is a bare identifier: the unqualified
// imported-parameter reads that pristine keeps as cross-package refs.
#include <uhdm/uhdm.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <functional>
using namespace UHDM;
static std::map<std::string,std::vector<std::string>> files;
static std::string text(const std::string& f,int l,int c,int el,int ec){
  if(f.empty()||l<=0||el!=l) return ""; auto it=files.find(f); if(it==files.end()){ std::ifstream in(f); std::vector<std::string> v; std::string s; while(std::getline(in,s)) v.push_back(s); it=files.emplace(f,v).first; }
  auto& v=it->second; if(l>(int)v.size()) return ""; const std::string& s=v[l-1]; if(c<1||ec-1>(int)s.size()||ec<=c) return ""; return s.substr(c-1,ec-c); }
int main(int argc,char**argv){ for(int ai=1;ai<argc;ai++){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[ai])); if(h.empty()) continue; auto*d=(design*)((uhdm_handle*)h[0])->object; int n=0;
  if(d->AllPackages()) for(auto*p:*d->AllPackages()){ std::string f(p->VpiFile()); if(!p->Param_assigns()) continue;
   std::function<void(const any*)> w=[&](const any* e){ if(!e) return; auto k=e->UhdmType();
     if(k==uhdmref_obj){ std::string nm(e->VpiName()); if(nm.find("::")!=std::string::npos){ std::string tx=text(f,e->VpiLineNo(),e->VpiColumnNo(),e->VpiEndLineNo(),e->VpiEndColumnNo()); if(!tx.empty()&&tx.find("::")==std::string::npos){ n++; std::cout<<argv[ai]<<" "<<p->VpiName()<<" "<<e->VpiLineNo()<<":"<<e->VpiColumnNo()<<" "<<nm<<" text="<<tx<<"\n"; } } return; }
     if(k==uhdmoperation){ auto*o=(const operation*)e; if(o->Operands()) for(auto*x:*o->Operands()) w(x); return; }
     if(k==uhdmsys_func_call||k==uhdmfunc_call){ auto*fc=(const tf_call*)e; if(fc->Tf_call_args()) for(auto*x:*fc->Tf_call_args()) w(x); return; }
     if(k==uhdmbit_select){ w(((const bit_select*)e)->VpiIndex()); return; } };
   for(auto*pa:*p->Param_assigns()){ if(pa->Lhs() && pa->Lhs()->UhdmType()==uhdmparameter && !((const parameter*)pa->Lhs())->VpiImported().empty()) continue; w(pa->Rhs()); } }
  if(n) std::cout<<argv[ai]<<" TOTAL "<<n<<"\n"; } }
