// clsloc <g> <o> <pkg> top|def [funcs]: per class_defn (and per function) compare with all packages and other classes pre-seeded
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string ch(const BaseClass*o,int n=10){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::filesystem::path(std::string(o->VpiFile())).filename().string()+":"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); return s;}
int main(int argc,char**argv){
  Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
  auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object; std::string nm=argv[3]; bool top=std::string(argv[4])=="top"; bool funcs=argc>5;
  std::vector<const any*> seed; for(int k=0;k<2;k++){ auto*l=k?da->TopPackages():da->AllPackages(); if(l) for(auto*p:*l){ seed.push_back(p); if(p->Class_defns()) for(auto*c:*p->Class_defns()) seed.push_back(c);} auto*m=k?da->TopModules():da->AllModules(); if(m) for(auto*x:*m) seed.push_back(x);} seed.push_back(da); if(da->AllClasses()) for(auto*c:*da->AllClasses()) seed.push_back(c);
  auto find=[&](design*d){ auto*l=top?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if(p->VpiName()==nm) return p; return (package*)nullptr;};
  int nf=0;
  auto run=[&](const any*x,const any*y,std::string what){ CompareContext c; for(auto*s:seed) if(s!=x) c.m_visited.insert(s); if(x->Compare(y,&c)){ nf++; std::cout<<what<<" "<<x->VpiName()<<" vs "<<y->VpiName()<<"\n   L="<<ch(c.m_failedLhs)<<"\n   R="<<ch(c.m_failedRhs)<<"\n";} };
  if(nm=="ALL"){
    for(int k=0;k<2;k++){ auto*la=k?da->TopPackages():da->AllPackages(); auto*lb=k?db->TopPackages():db->AllPackages(); if(!la||!lb) continue;
      for(size_t pi=0;pi<std::min(la->size(),lb->size());pi++){ auto*a=(*la)[pi]; auto*b=(*lb)[pi]; std::string pv=std::string(a->VpiName())+(k?"#TOP":"#DEF");
        { CompareContext c; for(auto*s:seed) c.m_visited.insert(s); c.m_visited.erase(a); if(a->Compare(b,&c)){ std::cout<<"pkgshallow "<<pv<<"\n   L="<<ch(c.m_failedLhs)<<"\n   R="<<ch(c.m_failedRhs)<<"\n"; } }
        auto*va=a->Class_defns(); auto*vb=b->Class_defns(); if(va&&vb) for(size_t i=0;i<std::min(va->size(),vb->size());i++){ auto*fa=(*va)[i]->Task_funcs(); auto*fb=(*vb)[i]->Task_funcs(); if(fa&&fb) for(size_t j=0;j<std::min(fa->size(),fb->size());j++) run((*fa)[j],(*fb)[j],"func "+pv+" "+std::string((*va)[i]->VpiName())); }
        auto*ta=a->Task_funcs(); auto*tb=b->Task_funcs(); if(ta&&tb) for(size_t j=0;j<std::min(ta->size(),tb->size());j++) run((*ta)[j],(*tb)[j],"pkgfunc "+pv);
      } }
    { CompareContext c; for(auto*s:seed) c.m_visited.insert(s); c.m_visited.erase(da); if(da->Compare(db,&c)) std::cout<<"designshallow\n   L="<<ch(c.m_failedLhs)<<"\n   R="<<ch(c.m_failedRhs)<<"\n"; }
    for(int k=0;k<2;k++){ auto*ma=k?da->TopModules():da->AllModules(); auto*mb=k?db->TopModules():db->AllModules(); if(ma&&mb) for(size_t i=0;i<std::min(ma->size(),mb->size());i++){ CompareContext c; for(auto*s:seed) c.m_visited.insert(s); c.m_visited.erase((*ma)[i]); if((*ma)[i]->Compare((*mb)[i],&c)) std::cout<<"module "<<(k?"TOP ":"DEF ")<<(*ma)[i]->VpiName()<<"\n   L="<<ch(c.m_failedLhs)<<"\n   R="<<ch(c.m_failedRhs)<<"\n"; } }
    std::cout<<"failures "<<nf<<"\n"; return 0; }
  auto*a=find(da); auto*b=find(db);
  if(!funcs){ auto*va=a->Class_defns(); auto*vb=b->Class_defns(); if(va&&vb) for(size_t i=0;i<std::min(va->size(),vb->size());i++) run((*va)[i],(*vb)[i],"class");
    // fields of the package other than classes
  } else { // compare each class's functions individually
    auto*va=a->Class_defns(); auto*vb=b->Class_defns(); if(va&&vb) for(size_t i=0;i<std::min(va->size(),vb->size());i++){ auto*fa=(*va)[i]->Task_funcs(); auto*fb=(*vb)[i]->Task_funcs(); if(fa&&fb) for(size_t j=0;j<std::min(fa->size(),fb->size());j++) run((*fa)[j],(*fb)[j],"func"); }
    auto*ta=a->Task_funcs(); auto*tb=b->Task_funcs(); if(ta&&tb) for(size_t j=0;j<std::min(ta->size(),tb->size());j++) run((*ta)[j],(*tb)[j],"pkgfunc");
  }
  std::cout<<"failures "<<nf<<"\n";
}
