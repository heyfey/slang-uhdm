// cdc <g> <o> <gid> <oid>: compare two class_defns (or any scope) piecewise; seed every package's id set EXCEPT packages (so instance mismatches show)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"#"+std::to_string(o->UhdmId()); }
static std::string ch(const BaseClass*o,int n=6){ std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+one(o); return s;}
const any* byId(Serializer&s, unsigned id){ for(auto&[o,i]:s.AllObjects()) if(((const any*)o)->UhdmId()==id) return (const any*)o; return nullptr; }
template<class V> void cmpv(const char* nm, const V* a, const V* b){
  if(!a||!b){ if(a!=b) std::cout<<nm<<" null mismatch\n"; return; }
  if(a->size()!=b->size()) std::cout<<nm<<" size "<<a->size()<<" vs "<<b->size()<<"\n";
  for(size_t i=0;i<std::min(a->size(),b->size());i++){ CompareContext c; if((*a)[i]->Compare((*b)[i],&c)){ std::cout<<nm<<"["<<i<<"] "<<one((*a)[i])<<" vs "<<one((*b)[i])<<"\n   L="<<ch(c.m_failedLhs)<<"\n   R="<<ch(c.m_failedRhs)<<"\n"; } }
}
int main(int argc,char**argv){ Serializer sa,sb; sa.Restore(std::filesystem::path(argv[1])); sb.Restore(std::filesystem::path(argv[2]));
  auto*a=(const class_defn*)byId(sa,atoi(argv[3])); auto*b=(const class_defn*)byId(sb,atoi(argv[4]));
  std::cout<<one(a)<<" vs "<<one(b)<<"\n";
  cmpv("Typespecs",a->Typespecs(),b->Typespecs()); cmpv("Variables",a->Variables(),b->Variables()); cmpv("Task_funcs",a->Task_funcs(),b->Task_funcs()); cmpv("Parameters",a->Parameters(),b->Parameters()); cmpv("Param_assigns",a->Param_assigns(),b->Param_assigns());
}
