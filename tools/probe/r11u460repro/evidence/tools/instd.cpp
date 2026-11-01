// instd <g> <o>: pair scopes (packages All/Top by index, their class_defns by index, modules All/Top by index, design) and, for each Typespecs entry pair by index, report differing Instance() names and differing names
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string nm(const BaseClass*o){ return o?std::string(o->VpiName()):std::string("null"); }
std::map<std::string,int> agg;
void lst(const std::string& where, const VectorOftypespec* a, const VectorOftypespec* b){
  if(!a||!b) { if((a?a->size():0)!=(b?b->size():0)) std::cout<<where<<" listing null/size\n"; return; }
  if(a->size()!=b->size()) std::cout<<where<<" listing size "<<a->size()<<" vs "<<b->size()<<"\n";
  for(size_t i=0;i<std::min(a->size(),b->size());i++){ auto*x=(*a)[i]; auto*y=(*b)[i];
    if(x->VpiName()!=y->VpiName()) { std::cout<<where<<"["<<i<<"] name "<<x->VpiName()<<" vs "<<y->VpiName()<<"\n"; continue; }
    std::string ix=nm(x->Instance()), iy=nm(y->Instance()); if(ix!=iy) agg[where.substr(0,where.find(' '))+" "+std::string(x->VpiName())+" inst "+ix+" vs "+iy]++; }
}
int main(int argc,char**argv){ Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
  auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object;
  lst("design",da->Typespecs(),db->Typespecs());
  for(int k=0;k<2;k++){ auto*la=k?da->TopPackages():da->AllPackages(); auto*lb=k?db->TopPackages():db->AllPackages(); if(la&&lb) for(size_t i=0;i<std::min(la->size(),lb->size());i++){ auto*a=(*la)[i]; auto*b=(*lb)[i]; std::string w=std::string(k?"TOP:":"DEF:")+std::string(a->VpiName()); lst(w,a->Typespecs(),b->Typespecs());
      auto*ca=a->Class_defns(); auto*cb=b->Class_defns(); if(ca&&cb) for(size_t j=0;j<std::min(ca->size(),cb->size());j++) lst(w+"/"+std::string((*ca)[j]->VpiName()),(*ca)[j]->Typespecs(),(*cb)[j]->Typespecs()); }
    auto*ma=k?da->TopModules():da->AllModules(); auto*mb=k?db->TopModules():db->AllModules(); if(ma&&mb) for(size_t i=0;i<std::min(ma->size(),mb->size());i++) lst(std::string(k?"MTOP:":"MDEF:")+std::string((*ma)[i]->VpiDefName()),(*ma)[i]->Typespecs(),(*mb)[i]->Typespecs()); }
  if(da->AllClasses()&&db->AllClasses()) for(size_t j=0;j<std::min(da->AllClasses()->size(),db->AllClasses()->size());j++) lst("CLS:"+std::string((*da->AllClasses())[j]->VpiName()),(*da->AllClasses())[j]->Typespecs(),(*db->AllClasses())[j]->Typespecs());
  for(auto&[k,v]:agg) std::cout<<v<<"x "<<k<<"\n";
}
