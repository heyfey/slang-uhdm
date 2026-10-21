// cmptrace <golden> <ours>: find the golden typespec whose Instance comparison produced a package-pair failure
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <vector>
using namespace UHDM;
static std::string desc(const BaseClass*o){ if(!o) return "null"; std::string s=std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); auto*p=o->VpiParent(); for(int i=0;i<4&&p;i++,p=p->VpiParent()) s+=" < "+std::string(UhdmName(p->UhdmType()))+":"+std::string(p->VpiName())+"@"+std::to_string(p->VpiLineNo()); return s;}
int main(int argc,char**argv){
  Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
  auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object;
  CompareContext c0; int r=da->Compare(db,&c0);
  std::cout<<"r="<<r<<" L="<<desc(c0.m_failedLhs)<<"\n   R="<<desc(c0.m_failedRhs)<<"\n";
  if(!r) return 0;
  const BaseClass* fl=c0.m_failedLhs;
  // candidates: visited golden objects whose any pointer field equals fl: check typespec Instance, and generic: parent==fl? use typespec Instance
  std::vector<const any*> cand;
  for(auto*o: c0.m_visited){ if(auto*t=any_cast<const typespec*>(o)){ if((const BaseClass*)t->Instance()==fl) cand.push_back(o);} }
  std::cout<<"candidates "<<cand.size()<<"\n";
  // bisect by seeding
  std::vector<const any*> cur=cand;
  while(cur.size()>1){ size_t h=cur.size()/2; std::vector<const any*> A(cur.begin(),cur.begin()+h), B(cur.begin()+h,cur.end());
    CompareContext c; for(auto*x:A) c.m_visited.insert(x); da->Compare(db,&c);
    bool changed = !(c.m_failedLhs==c0.m_failedLhs && c.m_failedRhs==c0.m_failedRhs);
    cur = changed? A : B; }
  if(cur.size()==1){ std::cout<<"culprit golden: "<<desc(cur[0])<<"\n"; CompareContext c; c.m_visited.insert(cur[0]); int r2=da->Compare(db,&c); std::cout<<"after seeding: r="<<r2<<" L="<<desc(c.m_failedLhs)<<"\n   R="<<desc(c.m_failedRhs)<<"\n"; }
}
