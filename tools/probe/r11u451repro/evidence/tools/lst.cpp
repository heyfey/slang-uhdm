// lst <db> <all|top> <module|package name> : list Nets / Variables / Parameters / Param_assigns names with line:col
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
template<class V> void pr(const char* f, V* v){ if(!v) return; std::cout<<f<<" "<<v->size()<<"\n"; for(auto*o:*v){ const any* x=o; std::string n(x->VpiName()); if(x->UhdmType()==uhdmparam_assign){ auto*pa=(param_assign*)x; if(pa->Lhs()) n=std::string(pa->Lhs()->VpiName());} std::cout<<"  "<<UhdmName(x->UhdmType())<<" "<<n<<" @"<<x->VpiLineNo()<<":"<<x->VpiColumnNo()<<"\n";} }
int main(int c,char**a){ Serializer s; auto h=s.Restore(std::filesystem::path(a[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; bool top=std::string(a[2])=="top"; std::string nm=a[3];
 auto*ms=top?d->TopModules():d->AllModules(); if(ms) for(auto*m:*ms) if(std::string(m->VpiName())==nm||std::string(m->VpiDefName())==nm){ pr("Nets",m->Nets()); pr("Variables",m->Variables()); pr("Parameters",m->Parameters()); pr("Param_assigns",m->Param_assigns()); }
 auto*ps=top?d->TopPackages():d->AllPackages(); if(ps) for(auto*p:*ps) if(std::string(p->VpiName())==nm){ pr("Nets",p->Nets()); pr("Variables",p->Variables()); pr("Parameters",p->Parameters()); pr("Param_assigns",p->Param_assigns()); }
}
