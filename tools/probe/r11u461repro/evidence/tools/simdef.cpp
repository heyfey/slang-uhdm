// simdef <in> <out>: in every DEF package's param_assign whose Lhs is an imported parameter, re-point the
// Rhs and Lhs typespec's vpiInstance from the home TOP package to the home DEF package (cloned per ref)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 std::map<std::string,package*> defs; std::set<const any*> tops; for(auto*p:*d->AllPackages()) defs[std::string(p->VpiName())]=p; if(d->TopPackages()) for(auto*p:*d->TopPackages()) tops.insert(p);
 CloneContext ctx(&s); int n=0;
 auto fix=[&](ref_typespec* rt){ if(!rt) return; auto*a=rt->Actual_typespec(); if(!a||!a->Instance()||!tops.count(a->Instance())) return; auto it=defs.find(std::string(a->Instance()->VpiName())); if(it==defs.end()) return; typespec* c=nullptr; switch(a->UhdmType()){ case uhdmint_typespec:{auto*x=s.MakeInt_typespec(); *x=*(int_typespec*)a; c=x; break;} case uhdmlogic_typespec:{auto*x=s.MakeLogic_typespec(); *x=*(logic_typespec*)a; c=x; break;} case uhdmbit_typespec:{auto*x=s.MakeBit_typespec(); *x=*(bit_typespec*)a; c=x; break;} default: return; } c->VpiParent(rt); c->Instance(it->second); rt->Actual_typespec(c); n++; };
 for(auto*p:*d->AllPackages()){ if(!p->Param_assigns()) continue; for(auto*pa:*p->Param_assigns()){ auto*l=pa->Lhs(); if(!l||l->UhdmType()!=uhdmparameter) continue; auto*lp=(parameter*)l; if(lp->VpiImported().empty()) continue; fix(lp->Typespec()); if(auto*r=pa->Rhs()) if(auto*e=any_cast<expr*>((any*)r)) fix(e->Typespec()); } }
 std::cerr<<"fixed "<<n<<"\n"; s.Save(std::filesystem::path(argv[2])); }
