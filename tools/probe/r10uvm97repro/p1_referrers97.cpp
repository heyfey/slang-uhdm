#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <map>
#include <vector>
#include <algorithm>
using namespace UHDM;
static std::string kn(const BaseClass* o){ return o?std::string(UHDM::UhdmName(o->UhdmType())):"<null>"; }
static std::string fn(const BaseClass* p){ if(!p) return "-"; vpiHandle h=NewVpiHandle(p); const char* s=h?vpi_get_str(vpiFullName,h):nullptr; std::string r=s?s:std::string(p->VpiName()); if(h) vpi_free_object(h); if(r.empty()) r=std::string(p->VpiName()); return r.empty()?"<anon>":r; }
int main(int argc,char**argv){
  Serializer s; auto r=s.Restore(std::string(argv[1])); if(r.empty()){printf("RESTORE_FAILED\n");return 3;}
  auto all=s.AllObjects();
  // targets: class_typespec named *this_type at line 199
  std::vector<const BaseClass*> tgt;
  for(auto&p:all){const BaseClass*o=p.first; if(!o||o->UhdmType()!=uhdmclass_typespec)continue; if(o->VpiLineNo()!=199||o->VpiColumnNo()!=11)continue; tgt.push_back(o);}
  for(auto*t:tgt) printf("TARGET id=%u name=%s alias=%s parent=%s(%s)\n", t->UhdmId(), std::string(t->VpiName()).c_str(), ((const typespec*)t)->Typedef_alias()?"YES":"no", kn(t->VpiParent()).c_str(), fn(t->VpiParent()).c_str());
  for(auto&p:all){
    const BaseClass*o=p.first; if(!o||o->UhdmType()!=uhdmref_typespec) continue;
    auto*rt=(const ref_typespec*)o; const typespec* a=rt->Actual_typespec();
    if(!a) continue;
    for(auto*t:tgt) if(a==t){
      const BaseClass* par=rt->VpiParent();
      printf("REF -> id=%u  refname=%s  refparent=%s(%s) @%u:%u  grandparent=%s(%s)\n", a->UhdmId(),
        std::string(rt->VpiName()).c_str(), kn(par).c_str(), fn(par).c_str(), par?par->VpiLineNo():0, par?par->VpiColumnNo():0,
        kn(par?par->VpiParent():nullptr).c_str(), fn(par?par->VpiParent():nullptr).c_str());
    }
  }
  return 0;
}
