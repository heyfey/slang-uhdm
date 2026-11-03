// pkgvars <db> <pkg>: list variables of every package named pkg (allPackages, topPackages) with typespec kind + instance
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static const design* D; static std::string vw(const any* x){ if(!x) return "null"; std::string n(x->VpiName()); if(D->AllPackages()) for(auto*p:*D->AllPackages()) if(p==x) return n+"[all]"; if(D->TopPackages()) for(auto*p:*D->TopPackages()) if(p==x) return n+"[top]"; return n+"[?"+std::string(UhdmName(x->UhdmType()))+"]";}
static void dumpPkg(const char* view, const package* p){
  std::cout<<"== "<<view<<" "<<p->VpiName()<<" vars="<<(p->Variables()?p->Variables()->size():0)<<"\n";
  if(p->Variables()) for(auto*v:*p->Variables()){
    const typespec* ts=nullptr; if(auto*r=v->Typespec()) ts=r->Actual_typespec();
    std::cout<<"  "<<UhdmName(v->UhdmType())<<" "<<v->VpiName()<<" @"<<v->VpiLineNo()<<" ts="<<(ts?UhdmName(ts->UhdmType()):"-")<<" tsinst="<<(ts?vw(ts->Instance()):"-")<<" tsparent="<<(ts&&ts->VpiParent()?std::string(UhdmName(ts->VpiParent()->UhdmType()))+":"+std::string(ts->VpiParent()->VpiName()):"null")<<"\n";
  }
}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  auto*d=(design*)((uhdm_handle*)h[0])->object; D=d; std::string P=argv[2];
  if(d->AllPackages()) for(auto*p:*d->AllPackages()) if(p->VpiName()==P) dumpPkg("all",p);
  if(d->TopPackages()) for(auto*p:*d->TopPackages()) if(p->VpiName()==P) dumpPkg("top",p);
}
