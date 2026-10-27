// calls <db> <callee> [line]: every func_call/method_func_call named callee: chain + bound function's chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string ch(const BaseClass*o,int n=7){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo()); return s;}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2]; auto*d=(design*)((uhdm_handle*)h[0])->object; int line=argc>3?atoi(argv[3]):0;
  for(auto&[o,_]: s.AllObjects()){ const any*a=(const any*)o; if(a->VpiName()!=nm) continue; if(line && (int)a->VpiLineNo()!=line) continue;
    const function* f=nullptr; if(a->UhdmType()==uhdmfunc_call) f=((const func_call*)a)->Function(); else if(a->UhdmType()==uhdmmethod_func_call) f=(const function*)((const method_func_call*)a)->Function(); else continue;
    std::string tag="?"; const any*r=f; while(r&&r->VpiParent()&&r->VpiParent()->UhdmType()!=uhdmdesign) r=r->VpiParent(); for(int t=0;t<2;t++){ auto*l=t?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if((const any*)p==r) tag=std::string(p->VpiName())+(t?"#TOP":"#DEF");} std::cout<<ch(a)<<"\n   -> "<<ch(f,3)<<" ["<<tag<<"]\n"; }
}
