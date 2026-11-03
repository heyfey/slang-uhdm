#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static const design* D;
static std::string vw(const any* x){ if(!x) return "null"; std::string n(x->VpiName()); if(D->AllPackages()) for(auto*p:*D->AllPackages()) if(p==x) return n+"[all]"; if(D->TopPackages()) for(auto*p:*D->TopPackages()) if(p==x) return n+"[top]"; return n+"[?"+std::string(UhdmName(x->UhdmType()))+"]";}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  auto*d=(design*)((uhdm_handle*)h[0])->object; D=d; std::string P=argv[2];
  auto dump=[&](const char*v,const package*p){ std::cout<<"== "<<v<<" "<<P<<" ts="<<(p->Typespecs()?p->Typespecs()->size():0)<<"\n"; if(p->Typespecs()) for(auto*t:*p->Typespecs()) if(argc<4||t->VpiName().find(argv[3])!=std::string::npos){ std::cout<<"  "<<UhdmName(t->UhdmType())<<" "<<t->VpiName()<<" @"<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<" inst="<<vw(t->Instance())<<" ptr="<<(const void*)t; if(t->UhdmType()==uhdmclass_typespec){auto*c=((const class_typespec*)t)->Class_defn(); std::cout<<" cls="<<(c?std::string(c->VpiName())+"<"+(c->VpiParent()?std::string(c->VpiParent()->VpiName()):""):"null");} std::cout<<"\n";}};
  if(d->AllPackages()) for(auto*p:*d->AllPackages()) if(p->VpiName()==P) dump("all",p);
  if(d->TopPackages()) for(auto*p:*d->TopPackages()) if(p->VpiName()==P) dump("top",p);
}
