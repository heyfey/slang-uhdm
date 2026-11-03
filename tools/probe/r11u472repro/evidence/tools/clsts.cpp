// clsts <db> <pkg> <cls>: typespecs of class cls in each view of pkg: kind name line, instance view, parent
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static const design* D;
static std::string vw(const any* x){ if(!x) return "null"; std::string n(x->VpiName()); if(D->AllPackages()) for(auto*p:*D->AllPackages()) if(p==x) return n+"[all]"; if(D->TopPackages()) for(auto*p:*D->TopPackages()) if(p==x) return n+"[top]"; return n+"[?"+std::string(UhdmName(x->UhdmType()))+"]";}
static std::string pd(const any* x){ std::string s; for(int i=0;x&&i<3;i++,x=x->VpiParent()) s+=(i?"<":"")+std::string(UhdmName(x->UhdmType()))+":"+std::string(x->VpiName()); return s;}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  auto*d=(design*)((uhdm_handle*)h[0])->object; D=d; std::string P=argv[2],C=argv[3];
  auto dump=[&](const char*v,const package*p){ if(p->Class_defns()) for(auto*c:*p->Class_defns()) if(c->VpiName()==C){ std::cout<<"== "<<v<<" "<<P<<"::"<<C<<" ts="<<(c->Typespecs()?c->Typespecs()->size():0)<<"\n"; if(c->Typespecs()) for(auto*t:*c->Typespecs()) if(std::string(argc>4?argv[4]:"")==""||t->VpiName().find(argv[4])!=std::string::npos) std::cout<<"  "<<UhdmName(t->UhdmType())<<" "<<t->VpiName()<<" @"<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<" inst="<<vw(t->Instance())<<" par="<<pd(t->VpiParent())<<"\n";}};
  if(d->AllPackages()) for(auto*p:*d->AllPackages()) if(p->VpiName()==P) dump("all",p);
  if(d->TopPackages()) for(auto*p:*d->TopPackages()) if(p->VpiName()==P) dump("top",p);
}
