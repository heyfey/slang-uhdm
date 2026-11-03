// headwalk <golden> <ours> [N]: list up to N uhdm-cmp heads, skipping each culprit golden object (seeded visited)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <vector>
#include <set>
#include <algorithm>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo());}
static std::string ch(const BaseClass*o,int n=5){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=(i?" < ":"")+one(o); return s;}
static int depth(const BaseClass*o){int d=0; while(o){d++; o=o->VpiParent();} return d;}
int main(int argc,char**argv){
  Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
  int N=argc>3?atoi(argv[3]):5; bool verbose=getenv("HW_V")!=nullptr;
  auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object;
  std::set<const any*> seeds;
  auto run=[&](const std::set<const any*>& extra, CompareContext& c){ for(auto*x:seeds) c.m_visited.insert(x); for(auto*x:extra) c.m_visited.insert(x); return da->Compare(db,&c); };
  for(int it=0;it<N;it++){
    CompareContext c0; int r=run({},c0);
    if(!r){ std::cout<<"EQUAL after "<<it<<" heads\n"; return 0; }
    auto fl=c0.m_failedLhs, fr=c0.m_failedRhs;
    std::cout<<"#"<<it<<" L="<<ch(fl)<<"\n    R="<<ch(fr)<<"\n";
    const any* X=nullptr;
    if(fl && fl!=(const BaseClass*)da && !getenv("HW_PATH")) X=(const any*)fl;
    else {
      std::vector<const any*> V; for(auto*o:c0.m_visited) if(!seeds.count(o) && o!=(const any*)da) V.push_back(o);
      std::vector<const any*> P; std::vector<const any*> pool=V;
      auto same=[&](CompareContext&c){ return c.m_failedLhs==fl && c.m_failedRhs==fr; };
      for(int k=0;k<(fr==(const BaseClass*)db?60:12);k++){
        { CompareContext c; std::set<const any*> e(pool.begin(),pool.end()); run(e,c); if(same(c)) break; }
        std::vector<const any*> cur=pool;
        while(cur.size()>1){ size_t h=cur.size()/2; std::vector<const any*> A(cur.begin(),cur.begin()+h), B(cur.begin()+h,cur.end()); CompareContext c; std::set<const any*> e(A.begin(),A.end()); run(e,c); cur = same(c)? B : A; }
        P.push_back(cur[0]); pool.erase(std::find(pool.begin(),pool.end(),cur[0]));
      }
      int bd=-1; for(auto*p:P){ int d=depth(p); if(verbose) std::cout<<"    path d"<<d<<" "<<ch(p,3)<<"\n"; if(d>bd){bd=d;X=p;} }
      if(fr==(const BaseClass*)db) for(auto*p:P) if(auto*t=any_cast<const typespec*>(p)) if(!t->Instance()){ X=p; break; }
    }
    if(!X){ std::cout<<"  no culprit\n"; return 0; }
    std::cout<<"  skip "<<ch(X,3)<<"\n";
    seeds.insert(X);
  }
}
