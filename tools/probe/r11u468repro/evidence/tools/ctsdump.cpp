// ctsdump <db> <classdefn-name-substr> <typespec-name>: print a listed class_typespec's params/param_assigns
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"-"+std::to_string(o->VpiEndLineNo())+":"+std::to_string(o->VpiEndColumnNo())+"#"+std::to_string(o->UhdmId());}
int main(int argc,char**argv){ Serializer s; s.Restore(std::filesystem::path(argv[1])); std::string cn=argv[2], tn=argv[3];
  for(auto& kv: s.AllObjects()){ auto*o=(BaseClass*)kv.first; if(o->UhdmType()!=uhdmclass_defn) continue; auto*cd=(class_defn*)o; if(std::string(cd->VpiName()).find(cn)==std::string::npos||!cd->Typespecs()) continue;
    for(auto*t:*cd->Typespecs()){ if(t->VpiName()!=tn) continue; std::cout<<cd->VpiName()<<" "<<one(t)<<" par="<<one(t->VpiParent())<<"\n";
      if(t->UhdmType()!=uhdmclass_typespec) continue; auto*c=(class_typespec*)t; std::cout<<"  cdefn="<<one(c->Class_defn())<<" alias="<<(c->Typedef_alias()?one(c->Typedef_alias()->Actual_typespec()):"null")<<"\n";
      if(c->Parameters()) for(auto*p:*c->Parameters()){ std::cout<<"  param "<<one(p); if(p->UhdmType()==uhdmtype_parameter){ auto*tp=(type_parameter*)p; if(tp->Typespec()) std::cout<<" -> "<<one(tp->Typespec()->Actual_typespec());} std::cout<<"\n";}
      if(c->Param_assigns()) for(auto*pa:*c->Param_assigns()) std::cout<<"  pa "<<one(pa)<<" lhs="<<one(pa->Lhs())<<" lpar="<<(pa->Lhs()?one(pa->Lhs()->VpiParent()):"")<<" rhs="<<one(pa->Rhs())<<"\n"; } } }
