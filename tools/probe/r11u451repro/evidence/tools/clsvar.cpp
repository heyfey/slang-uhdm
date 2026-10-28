// clsvar <db> <pkg> <class>: class Variables: name, kind, typespec kind, typespec Instance (top packages view)
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int c,char**a){ Serializer s; auto h=s.Restore(std::filesystem::path(a[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 for(auto*p:*d->TopPackages()) if(std::string(p->VpiName())==a[2]) for(auto*cl:*p->Class_defns()) if(std::string(cl->VpiName())==a[3]){
  
  if(cl->Variables()) for(auto*v:*cl->Variables()){ const typespec* t=nullptr; if(auto*rt=v->Typespec()) t=rt->Actual_typespec();
   std::cout<<UhdmName(v->UhdmType())<<" "<<v->VpiName()<<" ts="<<(t?std::string(UhdmName(t->UhdmType())):std::string("none"))<<" tsInst="<<(t&&t->Instance()?std::string(t->Instance()->VpiName()):std::string("null"))<<" tsParent="<<(t&&t->VpiParent()?std::string(UhdmName(t->VpiParent()->UhdmType())):std::string("null"))<<"\n"; }
  if(cl->Typespecs()) for(auto*t:*cl->Typespecs()) std::cout<<"TS "<<UhdmName(t->UhdmType())<<" "<<t->VpiName()<<" inst="<<(t->Instance()?std::string(t->Instance()->VpiName()):std::string("null"))<<"\n";
 }
}
