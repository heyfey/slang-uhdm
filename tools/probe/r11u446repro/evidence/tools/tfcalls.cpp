// tfcalls <db> <pkg> top|def <class> <func>: every func/task call in that method, with bound target view
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <algorithm>
using namespace UHDM;
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string pn=argv[2]; bool top=std::string(argv[3])=="top"; std::string cn=argv[4], fn=argv[5];
  const any* F=nullptr; auto*l=top?d->TopPackages():d->AllPackages(); for(auto*p:*l) if(p->VpiName()==pn && p->Class_defns()) for(auto*c:*p->Class_defns()) if(c->VpiName()==cn && c->Task_funcs()) for(auto*f:*c->Task_funcs()) if(f->VpiName()==fn) F=f;
  auto view=[&](const any*r){ while(r&&r->VpiParent()&&r->VpiParent()->UhdmType()!=uhdmdesign) r=r->VpiParent(); std::string tag="?"; for(int t=0;t<2;t++){ auto*l=t?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if((const any*)p==r) tag=std::string(p->VpiName())+(t?"#TOP":"#DEF");} return tag;};
  std::vector<std::pair<int,std::string>> out;
  for(auto&[o,_]: s.AllObjects()){ const any*a=(const any*)o; const any* tgt=nullptr; bool call=false;
    if(a->UhdmType()==uhdmfunc_call){ tgt=((const func_call*)a)->Function(); call=true;} else if(a->UhdmType()==uhdmtask_call){ tgt=((const task_call*)a)->Task(); call=true;} else if(a->UhdmType()==uhdmmethod_func_call){ tgt=((const method_func_call*)a)->Function(); call=true;}
    if(!call) continue; const any*p=a; bool in=false; while(p){ if(p==F){in=true;break;} p=p->VpiParent(); } if(!in) continue;
    out.push_back(std::make_pair((int)(a->VpiLineNo()*1000+a->VpiColumnNo()), std::string(UhdmName(a->UhdmType()))+" "+std::string(a->VpiName())+"@"+std::to_string(a->VpiLineNo())+":"+std::to_string(a->VpiColumnNo())+" -> "+(tgt?std::string(tgt->VpiName())+" ["+view(tgt)+"]":"null"))); }
  std::sort(out.begin(),out.end()); for(auto&x:out) std::cout<<x.second<<"\n";
}
