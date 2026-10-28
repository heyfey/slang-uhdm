// modts <g> <o> <all|top> <name>: per Nets/Variables entry: kind, name, line, typespec kind+line; print mismatches
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <sstream>
using namespace UHDM;
static std::string d(const any* x){ std::ostringstream o; o<<UhdmName(x->UhdmType())<<" "<<x->VpiName()<<" @"<<x->VpiLineNo()<<":"<<x->VpiColumnNo(); const ref_typespec* rt=nullptr;
 if(auto*n=any_cast<const net*>(x)) rt=n->Typespec(); else if(auto*v=any_cast<const variables*>(x)) rt=v->Typespec();
 if(rt){ auto*t=rt->Actual_typespec(); o<<" ts="<<(t?std::string(UhdmName(t->UhdmType()))+"@"+std::to_string(t->VpiLineNo())+":"+std::to_string(t->VpiColumnNo())+" "+std::string(t->VpiName()):std::string("null"));} else o<<" nots"; return o.str();}
static const any* fm(design*D,bool top,std::string nm){ auto*ms=top?D->TopModules():D->AllModules(); if(ms) for(auto*m:*ms) if(std::string(m->VpiName())==nm||std::string(m->VpiDefName())==nm) return m; return nullptr;}
int main(int c,char**a){ Serializer s1,s2; auto h1=s1.Restore(std::filesystem::path(a[1])); auto h2=s2.Restore(std::filesystem::path(a[2])); auto*d1=(design*)((uhdm_handle*)h1[0])->object; auto*d2=(design*)((uhdm_handle*)h2[0])->object; bool top=std::string(a[3])=="top";
 auto*m1=(module_inst*)fm(d1,top,a[4]); auto*m2=(module_inst*)fm(d2,top,a[4]); if(!m1||!m2){std::cout<<"nomod\n";return 1;}
 auto cmpv=[&](const char*f,auto*v1,auto*v2){ size_t n1=v1?v1->size():0,n2=v2?v2->size():0; std::cout<<f<<" "<<n1<<" "<<n2<<"\n"; int k=0; for(size_t i=0;i<std::max(n1,n2)&&k<8;i++){ std::string x=i<n1?d((*v1)[i]):"-", y=i<n2?d((*v2)[i]):"-"; if(x!=y){ std::cout<<" ["<<i<<"] G: "<<x<<"\n      O: "<<y<<"\n"; k++;} } };
 cmpv("Nets",m1->Nets(),m2->Nets()); cmpv("Variables",m1->Variables(),m2->Variables());
}
