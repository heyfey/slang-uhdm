// pkgvec <g> <o> <pkg>: vector sizes of a package (both views) and first name mismatch per vector
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
template<class V> void cmpv(const char*n,const V*a,const V*b){ size_t sa=a?a->size():0, sb=b?b->size():0; std::cout<<"  "<<n<<" "<<sa<<" vs "<<sb; if(a&&b) for(size_t i=0;i<std::min(sa,sb);i++){ auto*x=(*a)[i]; auto*y=(*b)[i]; if(x->VpiName()!=y->VpiName()||x->UhdmType()!=y->UhdmType()){ std::cout<<"  first@"<<i<<": "<<UhdmName(x->UhdmType())<<":"<<x->VpiName()<<"@"<<x->VpiLineNo()<<" vs "<<UhdmName(y->UhdmType())<<":"<<y->VpiName()<<"@"<<y->VpiLineNo(); break;} } std::cout<<"\n"; }
int main(int argc,char**argv){ Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
  auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object;
  for(int k=0;k<2;k++){ auto*la=k?da->TopPackages():da->AllPackages(); auto*lb=k?db->TopPackages():db->AllPackages(); package*a=0,*b=0; if(la) for(auto*p:*la) if(p->VpiName()==argv[3]) a=p; if(lb) for(auto*p:*lb) if(p->VpiName()==argv[3]) b=p; if(!a||!b){std::cout<<"missing\n";continue;}
    std::cout<<(k?"TOP\n":"DEF\n"); cmpv("Variables",a->Variables(),b->Variables()); cmpv("Task_funcs",a->Task_funcs(),b->Task_funcs()); cmpv("Typespecs",a->Typespecs(),b->Typespecs()); cmpv("Class_defns",a->Class_defns(),b->Class_defns()); cmpv("Parameters",a->Parameters(),b->Parameters()); cmpv("Param_assigns",a->Param_assigns(),b->Param_assigns()); cmpv("Nets",a->Nets(),b->Nets()); }
}
