// ifloc <g> <o> <defname> [top]: compare an instance's child vectors element-wise, packages/classes/modules pre-seeded
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string ch(const BaseClass*o,int n=8){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); return s;}
int main(int argc,char**argv){ Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
 auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object; std::string nm=argv[3]; bool top=argc>4;
 std::vector<const any*> seed; for(int k=0;k<2;k++){ auto*l=k?da->TopPackages():da->AllPackages(); if(l) for(auto*p:*l){ seed.push_back(p); if(p->Class_defns()) for(auto*c:*p->Class_defns()) seed.push_back(c);} auto*m=k?da->TopModules():da->AllModules(); if(m) for(auto*x:*m) seed.push_back(x);} seed.push_back(da); if(da->AllClasses()) for(auto*c:*da->AllClasses()) seed.push_back(c);
 auto find=[&](design*d)->const interface_inst*{ auto*l=d->AllInterfaces(); if(l) for(auto*m:*l) if(m->VpiName()==nm||m->VpiDefName()==nm) return m; return nullptr;};
 auto*a=find(da); auto*b=find(db); if(!a||!b){std::cout<<"notfound\n";return 1;}
 auto run=[&](const any*x,const any*y,std::string what){ CompareContext c; for(auto*s:seed) c.m_visited.insert(s); if(x->Compare(y,&c)){ std::cout<<what<<" "<<x->VpiName()<<" vs "<<y->VpiName()<<"\n   L="<<ch(c.m_failedLhs)<<"\n   R="<<ch(c.m_failedRhs)<<"\n";} };
#define V(f) { auto*va=a->f(); auto*vb=b->f(); size_t na=va?va->size():0, nb=vb?vb->size():0; std::cout<<#f<<" "<<na<<" "<<nb<<"\n"; for(size_t i=0;i<std::min(na,nb);i++) run((*va)[i],(*vb)[i],#f); }
 V(Parameters) V(Param_assigns) V(Typespecs) V(Variables) V(Nets) V(Task_funcs) V(Ports) V(Modports) V(Process) V(Cont_assigns) V(Assertions) V(Named_events)
}
