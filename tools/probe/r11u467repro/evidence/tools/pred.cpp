// pred <db>...: § unitCopyOwnTsEveryPath467's predicate on a pristine database:
// design-listing copies (vpiImported) whose ref_typespec is still the reference
// of a same-named parameter of the imported package's listing.  Prints "<db> <n>" for n>0.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
int main(int argc,char**argv){ for(int k=1;k<argc;k++){ Serializer sa; auto v=sa.Restore(std::filesystem::path(argv[k])); int n=0; std::string ex;
 for(auto* h: v){ design* d=(design*)((uhdm_handle*)h)->object; if(!d||!d->TopPackages()) continue;
  std::map<std::pair<std::string,std::string>,std::set<const ref_typespec*>> src;
  auto add=[&](const std::string& pk,const any* a){ if(a&&a->UhdmType()==uhdmparameter&&((const parameter*)a)->Typespec()) src[{pk,std::string(a->VpiName())}].insert(((const parameter*)a)->Typespec()); };
  for(auto*p:*d->TopPackages()){ if(!p) continue; std::string pn(p->VpiName()); if(p->Parameters()) for(auto*a:*p->Parameters()) add(pn,a); if(p->Param_assigns()) for(auto*pa:*p->Param_assigns()) if(pa) add(pn,pa->Lhs()); }
  auto chk=[&](const any* o){ if(!o||o->UhdmType()!=uhdmparameter) return; auto*cp=(const parameter*)o; if(cp->VpiImported().empty()||!cp->Typespec()) return; auto it=src.find({std::string(cp->VpiImported()),std::string(cp->VpiName())}); if(it==src.end()||!it->second.count(cp->Typespec())) return; n++; if(ex.empty()) ex=std::string(cp->VpiImported())+"::"+std::string(cp->VpiName()); };
  if(d->Parameters()) for(auto*a:*d->Parameters()) chk(a);
  if(d->Param_assigns()) for(auto*pa:*d->Param_assigns()) if(pa) chk(pa->Lhs());
 }
 if(n) std::cout<<argv[k]<<" "<<n<<" "<<ex<<"\n"; }
}
