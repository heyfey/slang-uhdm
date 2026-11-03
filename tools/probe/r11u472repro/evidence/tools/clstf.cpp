// clstf <db> <pkg> <namefilter>: for each class of each view of pkg, task_funcs whose name contains filter: name, parent chain, which package view lists it
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string pd(const any* x){ std::string s; for(int i=0;x&&i<3;i++,x=x->VpiParent()) s+=(i?"<":"")+std::string(UhdmName(x->UhdmType()))+":"+std::string(x->VpiName()); return s;}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  auto*d=(design*)((uhdm_handle*)h[0])->object; std::string P=argv[2], F=argv[3];
  std::map<const any*,std::string> owner;
  auto reg=[&](const char*v, const package*p){ if(p->Task_funcs()) for(auto*t:*p->Task_funcs()) owner[t]+=std::string(v)+":"+std::string(p->VpiName())+" ";
     if(p->Class_defns()) for(auto*c:*p->Class_defns()) if(c->Task_funcs()) for(auto*t:*c->Task_funcs()) owner[t]+=std::string(v)+":"+std::string(p->VpiName())+"::"+std::string(c->VpiName())+" ";};
  if(d->AllPackages()) for(auto*p:*d->AllPackages()) reg("all",p);
  if(d->TopPackages()) for(auto*p:*d->TopPackages()) reg("top",p);
  auto dump=[&](const char*v,const package*p){ if(p->Class_defns()) for(auto*c:*p->Class_defns()){ int i=0; if(c->Task_funcs()) for(auto*t:*c->Task_funcs()){ i++; if(std::string(t->VpiName()).find(F)!=std::string::npos) std::cout<<v<<" "<<p->VpiName()<<"::"<<c->VpiName()<<" ["<<i<<"/"<<c->Task_funcs()->size()<<"] "<<pd(t)<<" @"<<t->VpiLineNo()<<" in: "<<owner[t]<<"\n";}}};
  if(d->AllPackages()) for(auto*p:*d->AllPackages()) if(p->VpiName()==P) dump("all",p);
  if(d->TopPackages()) for(auto*p:*d->TopPackages()) if(p->VpiName()==P) dump("top",p);
}
