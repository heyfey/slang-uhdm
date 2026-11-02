// plist <db>: per package/module (both views) the Parameters and Param_assigns listing (name/imported)
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
template<class T> static void one(const char* v, T* m){
  std::cout<<v<<" "<<m->VpiName()<<"\n  P:";
  if(m->Parameters()) for(auto*a:*m->Parameters()){ std::cout<<" "<<a->VpiName(); if(a->UhdmType()==uhdmparameter && !((parameter*)a)->VpiImported().empty()) std::cout<<"<"<<((parameter*)a)->VpiImported(); }
  std::cout<<"\n  A:";
  if(m->Param_assigns()) for(auto*pa:*m->Param_assigns()){ auto*l=pa->Lhs(); if(!l) {std::cout<<" ?";continue;} std::cout<<" "<<l->VpiName(); if(l->UhdmType()==uhdmparameter && !((parameter*)l)->VpiImported().empty()) std::cout<<"<"<<((parameter*)l)->VpiImported(); }
  std::cout<<"\n";
}
int main(int c,char**v){ Serializer s; auto h=s.Restore(std::filesystem::path(v[1])); if(h.empty()) return 1; auto*d=(design*)((uhdm_handle*)h[0])->object;
 if(d->AllPackages()) for(auto*p:*d->AllPackages()) one("pkgDEF",p);
 if(d->TopPackages()) for(auto*p:*d->TopPackages()) one("pkgTOP",p);
 if(d->AllModules()) for(auto*p:*d->AllModules()) one("modDEF",p);
 if(d->TopModules()) for(auto*p:*d->TopModules()) one("modTOP",p);
 one("design",d);
}
