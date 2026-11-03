// modroles <db>: for every module (all + top, recursively into instances), its parameters' and param_assigns' typespec chain:
// role name | per hop: ref name, actual kind, actual name, instance, actual's parent kind:name, line
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
static bool gId=getenv("MR_ID")!=nullptr;
static std::string nm(const BaseClass* b){ if(!b) return "null"; return std::string(UhdmName(b->UhdmType()))+":"+std::string(b->VpiName())+(gId?"#"+std::to_string(b->UhdmId()):""); }
static std::string ch(const ref_typespec* rt){ std::string s; std::set<const void*> seen; int h=0;
  while(rt&&h<5){ auto*t=rt->Actual_typespec(); s+=" [ref '"+std::string(rt->VpiName())+"' fn='"+std::string(rt->VpiFullName())+"' par="+nm(rt->VpiParent());
    if(!t){ s+=" -> null]"; break;} if(!seen.insert(t).second){s+=" loop]";break;}
    s+=" -> "+nm(t)+" inst="+nm(t->Instance())+(getenv("MR_NOPAR")?std::string(""):" tpar="+nm(t->VpiParent()))+" @"+std::to_string(t->VpiLineNo())+":"+std::to_string(t->VpiColumnNo())+"]"; rt=t->Typedef_alias(); h++; }
  return s; }
template<class M> static void dumpInst(const M* m, const std::string& view, int depth){
  std::string mn=view+" "+std::string(m->VpiFullName().empty()? m->VpiName(): m->VpiFullName());
  if(m->Parameters()) for(auto*a:*m->Parameters()){ if(a->UhdmType()==uhdmparameter){ auto*p=(const parameter*)a; std::cout<<mn<<" param "<<p->VpiName()<<" imp="<<p->VpiImported()<<ch(p->Typespec())<<"\n";} else std::cout<<mn<<" param "<<nm(a)<<"\n"; }
  if(m->Typespecs()) for(auto*t:*m->Typespecs()) std::cout<<mn<<" typedef "<<nm(t)<<" inst="<<nm(t->Instance())<<(getenv("MR_NOPAR")?std::string(""):" tpar="+nm(t->VpiParent()))<<(t->Typedef_alias()?" alias->"+nm(t->Typedef_alias()->Actual_typespec()):"")<<"\n";
  if(m->Param_assigns()) for(auto*pa:*m->Param_assigns()){ auto*l=pa->Lhs(); std::string ln=l?std::string(l->VpiName()):"?"; if(l&&l->UhdmType()==uhdmparameter) std::cout<<mn<<" pa-lhs "<<ln<<ch(((const parameter*)l)->Typespec())<<"\n";
    auto*r=pa->Rhs(); if(r&&r->UhdmType()==uhdmconstant){ auto*c=(const constant*)r; std::cout<<mn<<" pa-rhs "<<ln<<" "<<c->VpiDecompile()<<" "<<c->VpiValue()<<" ct="<<c->VpiConstType()<<" sz="<<c->VpiSize()<<ch(c->Typespec())<<"\n";} else std::cout<<mn<<" pa-rhs "<<ln<<" "<<nm(r)<<"\n"; }
  if constexpr (std::is_same_v<M,module_inst>) { if(m->Cont_assigns()) for(auto*ca:*m->Cont_assigns()){ auto*e=ca->Rhs(); if(e&&e->UhdmType()==uhdmconstant){auto*c=(const constant*)e; std::cout<<mn<<" ca-rhs @"<<ca->VpiLineNo()<<" "<<c->VpiDecompile()<<" sz="<<c->VpiSize()<<ch(c->Typespec())<<"\n";} } }
  if constexpr (std::is_same_v<M,module_inst>) { if(m->Variables()) for(auto*v:*m->Variables()){ std::cout<<mn<<" var "<<v->VpiName()<<ch(v->Typespec()); if(auto*e=v->Expr()){ std::cout<<" expr="<<nm(e); if(e->UhdmType()==uhdmconstant){auto*c=(const constant*)e; std::cout<<" "<<c->VpiDecompile()<<" "<<c->VpiValue()<<" sz="<<c->VpiSize()<<ch(c->Typespec());} if(e->UhdmType()==uhdmref_obj){auto*r=(const ref_obj*)e; std::cout<<" actual="<<nm(r->Actual_group());} } std::cout<<"\n"; } }
  if constexpr (std::is_same_v<M,module_inst>) { if(m->Modules()) for(auto*c:*m->Modules()) dumpInst(c,view,depth+1); }
}
int main(int argc,char**argv){ Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); if(ha.empty()) return 1; auto*d=(design*)((uhdm_handle*)ha[0])->object;
  if(d->AllPackages()) for(auto*m:*d->AllPackages()) dumpInst(m,"PDEF",0);
  if(d->TopPackages()) for(auto*m:*d->TopPackages()) dumpInst(m,"PTOP",0);
  if(d->AllModules()) for(auto*m:*d->AllModules()) dumpInst(m,"DEF",0);
  if(d->TopModules()) for(auto*m:*d->TopModules()) dumpInst(m,"TOP",0);
}
