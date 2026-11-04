// ctsp <db> <class_typespec name>: every class_typespec of that name: id, parent kind/name (and grandparent), alias target id/name,
// its parameters (kind, stored full name, parent kind) and param_assign Lhs/Rhs stored full names
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::string N=argv[2]; int lim=argc>3?atoi(argv[3]):1000000;
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if(o->UhdmType()!=uhdmclass_typespec||o->VpiName()!=N) continue; if(lim--<=0) break; auto*c=(class_typespec*)o;
  std::cout<<"class_typespec "<<N<<" id="<<o->UhdmId(); auto*p=o->VpiParent(); std::cout<<" parent="<<(p?UhdmName(p->UhdmType()):"null")<<":"<<(p?p->VpiName():"");
  if(p&&p->VpiParent()) std::cout<<" < "<<UhdmName(p->VpiParent()->UhdmType())<<":"<<p->VpiParent()->VpiName();
  if(p&&p->VpiParent()&&p->VpiParent()->VpiParent()) std::cout<<" < "<<UhdmName(p->VpiParent()->VpiParent()->UhdmType())<<":"<<p->VpiParent()->VpiParent()->VpiName();
  if(auto*a=c->Typedef_alias()){ auto*t=a->Actual_typespec(); std::cout<<" alias->"<<(t?std::to_string(t->UhdmId())+":"+std::string(t->VpiName()):"null"); }
  std::cout<<"\n";
  if(c->Parameters()) for(auto*x:*c->Parameters()) std::cout<<"   P "<<UhdmName(x->UhdmType())<<" "<<x->VpiName()<<" full='"<<(x->UhdmType()==uhdmparameter?std::string(((parameter*)x)->VpiFullName()):x->UhdmType()==uhdmtype_parameter?std::string(((type_parameter*)x)->VpiFullName()):"")<<"' par="<<(x->VpiParent()?x->VpiParent()->UhdmId():0)<<"\n";
  if(c->Param_assigns()) for(auto*pa:*c->Param_assigns()){ auto*l=pa->Lhs(); auto*r=pa->Rhs(); auto fn=[](const any*x)->std::string{ if(!x) return "null"; if(x->UhdmType()==uhdmparameter) return "parameter:"+std::string(((parameter*)x)->VpiFullName()); if(x->UhdmType()==uhdmtype_parameter) return "type_parameter:"+std::string(((type_parameter*)x)->VpiFullName()); return std::string(UhdmName(x->UhdmType())); };
   std::cout<<"   PA lhs="<<fn(l)<<" lhsid="<<(l?l->UhdmId():0)<<" lhspar="<<(l&&l->VpiParent()?std::to_string(l->VpiParent()->UhdmId())+UhdmName(l->VpiParent()->UhdmType()):std::string("null"))<<" rhs="<<fn(r)<<" rhspar="<<(r&&r->VpiParent()?r->VpiParent()->UhdmId():0)<<" pa="<<pa->UhdmId()<<"\n"; } } }
