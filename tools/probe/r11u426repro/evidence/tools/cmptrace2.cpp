// cmptrace2 <golden> <ours> [N]: iterate heads, seeding each culprit
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <vector>
#include <set>
#include <algorithm>
using namespace UHDM;
static std::string desc(const BaseClass*o){ if(!o) return "null"; std::string s=std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); auto*p=o->VpiParent(); for(int i=0;i<4&&p;i++,p=p->VpiParent()) s+=" < "+std::string(UhdmName(p->UhdmType()))+":"+std::string(p->VpiName())+"@"+std::to_string(p->VpiLineNo()); return s;}
int main(int argc,char**argv){
  Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
  int N=argc>3?atoi(argv[3]):10;
  auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object;
  std::vector<const any*> seeds;
  for(int it=0;it<N;it++){
    CompareContext c0; for(auto*x:seeds) c0.m_visited.insert(x); int r=da->Compare(db,&c0);
    if(!r){ std::cout<<"EQUAL after "<<it<<" seeds\n"; return 0; }
    const BaseClass* fl=c0.m_failedLhs;
    std::cout<<"#"<<it<<" L="<<desc(fl)<<"\n    R="<<desc(c0.m_failedRhs)<<"\n";
    if(!fl){ std::cout<<"  (null LHS: stop)\n"; return 0; }
    bool inst = fl->UhdmType()==uhdmpackage || fl->UhdmType()==uhdmmodule_inst || fl->UhdmType()==uhdmdesign;
    std::vector<const any*> cand;
    if(inst) for(auto*o: c0.m_visited){ if(std::find(seeds.begin(),seeds.end(),o)!=seeds.end()) continue; if(auto*t=any_cast<const typespec*>(o)){ if((const BaseClass*)t->Instance()==fl) cand.push_back(o);} }
    if(inst && !cand.empty()){
      std::vector<const any*> cur=cand;
      while(cur.size()>1){ size_t h=cur.size()/2; std::vector<const any*> A(cur.begin(),cur.begin()+h), B(cur.begin()+h,cur.end());
        CompareContext c; for(auto*x:seeds) c.m_visited.insert(x); for(auto*x:A) c.m_visited.insert(x); da->Compare(db,&c);
        bool changed = !(c.m_failedLhs==c0.m_failedLhs && c.m_failedRhs==c0.m_failedRhs); cur = changed? A : B; }
      std::cout<<"  instance-culprit: "<<desc(cur[0])<<" inst-of-golden="<<(((const typespec*)cur[0])->Instance()?std::string(((const typespec*)cur[0])->Instance()->VpiName()):"null")<<"\n";
      seeds.push_back(cur[0]);
    } else seeds.push_back((const any*)fl);
  }
}
