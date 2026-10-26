// cmphead <golden> <ours> [skip]: run cmptrace2's seeded loop `skip` times, then decompile the failing pair and the parents
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <filesystem>
#include <iostream>
#include <vector>
#include <algorithm>
using namespace UHDM;
int main(int argc,char**argv){
  Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
  int K=argc>3?atoi(argv[3]):0; int up=argc>4?atoi(argv[4]):0;
  auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object;
  std::vector<const any*> seeds;
  for(int it=0;;it++){
    CompareContext c0; for(auto*x:seeds) c0.m_visited.insert(x); int r=da->Compare(db,&c0);
    if(!r){ std::cout<<"EQUAL\n"; return 0; }
    const BaseClass* fl=c0.m_failedLhs; const BaseClass* fr=c0.m_failedRhs;
    if(it==K || !fl){
      for(int u=0;u<up && fl && fl->VpiParent();u++) fl=fl->VpiParent();
      for(int u=0;u<up && fr && fr->VpiParent();u++) fr=fr->VpiParent();
      std::cout<<"=== GOLDEN\n"<<(fl?decompile(fl):"null")<<"\n=== OURS\n"<<(fr?decompile(fr):"null")<<"\n"; return 0; }
    seeds.push_back((const any*)fl);
  }
}
