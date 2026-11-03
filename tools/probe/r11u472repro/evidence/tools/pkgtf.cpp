// pkgtf <db> <pkg>: task_funcs of each package view named pkg: name, line, parent, identity shared with other views/classes
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static const design* D;
static std::string pd(const any* x){ if(!x) return "null"; std::string s=std::string(UhdmName(x->UhdmType()))+":"+std::string(x->VpiName()); if(auto*p=x->VpiParent()) s+="<"+std::string(UhdmName(p->UhdmType()))+":"+std::string(p->VpiName()); return s;}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  auto*d=(design*)((uhdm_handle*)h[0])->object; D=d; std::string P=argv[2];
  std::map<const any*,std::string> owner;
  auto reg=[&](const char*v, const package*p){ if(p->Task_funcs()) for(auto*t:*p->Task_funcs()) owner[t]+=std::string(v)+":"+std::string(p->VpiName())+" ";
     if(p->Class_defns()) for(auto*c:*p->Class_defns()) if(c->Task_funcs()) for(auto*t:*c->Task_funcs()) owner[t]+=std::string(v)+":"+std::string(p->VpiName())+"::"+std::string(c->VpiName())+" ";};
  if(d->AllPackages()) for(auto*p:*d->AllPackages()) reg("all",p);
  if(d->TopPackages()) for(auto*p:*d->TopPackages()) reg("top",p);
  auto dump=[&](const char*v,const package*p){ std::cout<<"== "<<v<<" "<<p->VpiName()<<" tf="<<(p->Task_funcs()?p->Task_funcs()->size():0)<<"\n";
    if(p->Task_funcs()) for(auto*t:*p->Task_funcs()) std::cout<<"  "<<pd(t)<<" @"<<t->VpiLineNo()<<" listed-in: "<<owner[t]<<"\n";};
  if(d->AllPackages()) for(auto*p:*d->AllPackages()) if(p->VpiName()==P) dump("all",p);
  if(d->TopPackages()) for(auto*p:*d->TopPackages()) if(p->VpiName()==P) dump("top",p);
}
