// thist <db> <cls> <tdname>: for every class_defn named cls (any package view), each class_typespec named tdname parented by it:
// its alias target name/kind, the target's parent, instance view, and which package views list the target
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static const design* D;
static std::string vw(const any* x){ if(!x) return "null"; std::string n(x->VpiName()); if(D->AllPackages()) for(auto*p:*D->AllPackages()) if(p==x) return n+"[all]"; if(D->TopPackages()) for(auto*p:*D->TopPackages()) if(p==x) return n+"[top]"; return n+"[?"+std::string(UhdmName(x->UhdmType()))+"]";}
static std::string lists(const any* t){ std::string r; for(int k=0;k<2;k++){ auto*l=k?D->TopPackages():D->AllPackages(); if(l) for(auto*p:*l) if(p->Typespecs()) for(auto*u:*p->Typespecs()) if(u==t) r+=std::string(p->VpiName())+(k?"[top] ":"[all] ");} if(D->Typespecs()) for(auto*u:*D->Typespecs()) if(u==t) r+="design "; for(int k=0;k<2;k++){ auto*m=k?D->TopModules():D->AllModules(); if(m) for(auto*x:*m) if(x->Typespecs()) for(auto*u:*x->Typespecs()) if(u==t) r+=std::string(x->VpiName())+(k?"[topmod] ":"[mod] ");} return r;}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  auto*d=(design*)((uhdm_handle*)h[0])->object; D=d; std::string C=argv[2],N=argv[3];
  for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if(p->Class_defns()) for(auto*c:*p->Class_defns()) if(c->VpiName()==C && c->Typespecs()) for(auto*t:*c->Typespecs()) if(t->VpiName()==N){
    std::cout<<(k?"top ":"all ")<<p->VpiName()<<"::"<<C<<" "<<UhdmName(t->UhdmType())<<" "<<t->VpiName()<<" @"<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<" file="<<t->VpiFile()<<" inst="<<vw(t->Instance())<<" par="<<(t->VpiParent()?std::string(t->VpiParent()->VpiName()):"null")<<" id="<<t->UhdmId()<<"\n";
    auto*ra=t->Typedef_alias(); auto*a=ra?ra->Actual_typespec():nullptr;
    if(a) std::cout<<"   alias -> "<<UhdmName(a->UhdmType())<<" "<<a->VpiName()<<" @"<<a->VpiLineNo()<<" inst="<<vw(a->Instance())<<" par="<<(a->VpiParent()?std::string(UhdmName(a->VpiParent()->UhdmType()))+":"+std::string(a->VpiParent()->VpiName()):"null")<<" listed: "<<lists(a)<<"\n";
    if(auto*ct=any_cast<const class_typespec*>(t)) if(auto*cd=ct->Class_defn()) std::cout<<"   class_defn "<<cd->VpiName()<<" par="<<(cd->VpiParent()?std::string(cd->VpiParent()->VpiName()):"null")<<"\n";
  }}
}
