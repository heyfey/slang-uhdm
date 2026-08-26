// r10earl96 -- MEASUREMENT ONLY.  For one instance fullname, print every
// param_assign / parameter and the FULL typespec chain hanging off it, with
// each link's kind, VpiName, id, parent kind and Typedef_alias target.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <set>
#include <algorithm>
using namespace UHDM;
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
static std::string nm(const BaseClass*o){if(!o)return "-";std::string n(((const any*)o)->VpiName());return n.empty()?std::string("~"):n;}
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u",o->VpiLineNo(),o->VpiColumnNo());return b;}
static void walk(const any* t, int d, std::set<const any*>& seen){
  if(!t||d>10) return;
  for(int i=0;i<d;i++) printf("  ");
  printf("%s id=%llu name=%s span=%s par=%s(id=%llu)\n", kn(t).c_str(),
     (unsigned long long)t->UhdmId(), nm(t).c_str(), sp(t).c_str(),
     kn(t->VpiParent()).c_str(), t->VpiParent()?(unsigned long long)t->VpiParent()->UhdmId():0ULL);
  if(!seen.insert(t).second){for(int i=0;i<d;i++)printf("  ");printf("  <repeat>\n");return;}
  if(t->UhdmType()==uhdmref_typespec){ walk(((const ref_typespec*)t)->Actual_typespec(), d+1, seen); return; }
  const typespec* ts = any_cast<const typespec*>(t);
  if(ts){
    if(ts->Typedef_alias()){ for(int i=0;i<d;i++)printf("  "); printf("  ALIAS:\n"); walk(ts->Typedef_alias(), d+1, seen); }
    if(ts->Instance()){ for(int i=0;i<d;i++)printf("  "); printf("  INSTANCE: %s %s\n", kn(ts->Instance()).c_str(), nm(ts->Instance()).c_str()); }
  }
  if(t->UhdmType()==uhdmarray_typespec){ for(int i=0;i<d;i++)printf("  "); printf("  ELEM:\n"); walk(((const array_typespec*)t)->Elem_typespec(), d+1, seen); }
  if(t->UhdmType()==uhdmpacked_array_typespec){ for(int i=0;i<d;i++)printf("  "); printf("  ELEM:\n"); walk(((const packed_array_typespec*)t)->Elem_typespec(), d+1, seen); }
}
int main(int argc,char**argv){
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  std::string want = argv[2];
  std::string pname = argc>3?argv[3]:"";
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo) continue;
    if(bo->UhdmType()!=uhdmmodule_inst) continue;
    const module_inst* m=(const module_inst*)bo;
    if(std::string(m->VpiFullName())!=want) continue;
    printf("=== module_inst %s id=%llu\n", want.c_str(), (unsigned long long)m->UhdmId());
    if(m->Param_assigns()) for(auto*pa:*m->Param_assigns()){
      const any* lhs=pa->Lhs();
      if(!pname.empty() && nm(lhs)!=pname) continue;
      printf("-- param_assign id=%llu lhs=%s(%s) rhs=%s id=%llu\n",(unsigned long long)pa->UhdmId(),nm(lhs).c_str(),kn(lhs).c_str(),kn(pa->Rhs()).c_str(),pa->Rhs()?(unsigned long long)pa->Rhs()->UhdmId():0ULL);
      std::set<const any*> seen;
      if(const expr* e=any_cast<const expr*>(pa->Rhs())) if(e->Typespec()){ printf("   RHS TYPESPEC:\n"); walk(e->Typespec(),2,seen); }
      if(const parameter* p=any_cast<const parameter*>(lhs)) if(p->Typespec()){ printf("   LHS TYPESPEC:\n"); std::set<const any*> s2; walk(p->Typespec(),2,s2); }
    }
    if(m->Typespecs()){ printf("-- Typespecs listing (%zu):\n", m->Typespecs()->size());
      for(auto*t:*m->Typespecs()) printf("     %s id=%llu name=%s\n", kn(t).c_str(),(unsigned long long)t->UhdmId(), nm(t).c_str()); }
  }
  return 0;
}
