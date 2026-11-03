// pchain <db> <paramName>: for every class_defn listing a parameter of that name, the typespec chain ids and range ids
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string rng(const typespec* t){ std::string s; const VectorOfrange* r=nullptr;
  if(t->UhdmType()==uhdmbit_typespec) r=((bit_typespec*)t)->Ranges(); else if(t->UhdmType()==uhdmlogic_typespec) r=((logic_typespec*)t)->Ranges();
  if(r) for(auto*x:*r) s+=" r#"+std::to_string(x->UhdmId())+"(par#"+std::to_string(x->VpiParent()?x->VpiParent()->UhdmId():0)+")"; return s; }
int main(int argc,char**argv){ Serializer s; s.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2];
  for(auto& kv: s.AllObjects()){ auto*o=(BaseClass*)kv.first; if(o->UhdmType()!=uhdmclass_defn) continue; auto*cd=(class_defn*)o; if(!cd->Parameters()) continue;
    for(auto*p:*cd->Parameters()){ if(p->VpiName()!=nm||p->UhdmType()!=uhdmparameter) continue; auto*pp=(parameter*)p;
      auto*rt=pp->Typespec(); std::cout<<cd->VpiName()<<" p#"<<pp->UhdmId()<<" rt#"<<(rt?rt->UhdmId():0)<<" al#"<<(rt&&rt->Actual_typespec()&&rt->Actual_typespec()->Typedef_alias()?rt->Actual_typespec()->Typedef_alias()->UhdmId():0); const typespec* t=rt?rt->Actual_typespec():nullptr;
      int d=0; while(t&&d<4){ std::cout<<" -> ts#"<<t->UhdmId()<<"(par#"<<(t->VpiParent()?t->VpiParent()->UhdmId():0)<<")"<<rng(t); auto*al=t->Typedef_alias(); t=al?al->Actual_typespec():nullptr; d++; }
      std::cout<<"\n"; break; } } }
