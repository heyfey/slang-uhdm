// ftrace <g> <o> <pkg> <class> <func> [top|def]: localize a function compare failure to the deepest golden object on the failing path
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <algorithm>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"-"+std::to_string(o->VpiEndLineNo())+":"+std::to_string(o->VpiEndColumnNo());}
static std::string ch(const BaseClass*o,int n=8){ std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=(i?" < ":"")+one(o); return s;}
static int depth(const BaseClass*o){int d=0; while(o){d++; o=o->VpiParent();} return d;}
int main(int argc,char**argv){
  Serializer sa,sb; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto hb=sb.Restore(std::filesystem::path(argv[2]));
  auto*da=(design*)((uhdm_handle*)ha[0])->object; auto*db=(design*)((uhdm_handle*)hb[0])->object;
  std::string pk=argv[3], cl=argv[4], fn=argv[5]; bool top=argc<=6||std::string(argv[6])=="top"; int cidx=argc>7?atoi(argv[7]):0; int fidx=argc>8?atoi(argv[8]):0;
  std::vector<const any*> seed; for(int k=0;k<2;k++){ auto*l=k?da->TopPackages():da->AllPackages(); if(l) for(auto*p:*l){ seed.push_back(p); if(p->Class_defns()) for(auto*c:*p->Class_defns()) seed.push_back(c);} auto*m=k?da->TopModules():da->AllModules(); if(m) for(auto*x:*m) seed.push_back(x);} seed.push_back(da); if(da->AllClasses()) for(auto*c:*da->AllClasses()) seed.push_back(c);
  auto findf=[&](design*d)->const any*{ auto*l=top?d->TopPackages():d->AllPackages(); if(!l) return nullptr; for(auto*p:*l) if(p->VpiName()==pk){ if(cl=="-"){ if(p->Task_funcs()) for(auto*f:*p->Task_funcs()) if(f->VpiName()==fn) return f; } else if(p->Class_defns()){ int ci=0; for(auto*c:*p->Class_defns()){ if(c->VpiName()==cl && ci==cidx && c->Task_funcs()) { int fi=0; for(auto*f:*c->Task_funcs()) { if(f->VpiName()==fn && fi==fidx) return f; if(f->VpiName()==fn) fi++; } } if(c->VpiName()==cl) ci++; } } } return nullptr; };
  auto*x=findf(da); auto*y=findf(db); if(!x||!y){ std::cout<<"not found "<<(x!=nullptr)<<(y!=nullptr)<<"\n"; return 1; }
  auto pr=[&](const function*f){ if(!f->Io_decls()) return; for(auto*io:*f->Io_decls()){ auto*rt=io->Typespec(); if(!rt) continue; auto*t=rt->Actual_typespec(); std::cout<<" io "<<io->VpiName()<<" -> "<<one(t)<<" parent="<<ch(t?t->VpiParent():nullptr,3); if(t&&t->UhdmType()==uhdmclass_typespec){ auto*ct=(const class_typespec*)t; std::cout<<" inst="<<one(ct->Instance())<<" cdef="<<one(ct->Class_defn())<<" alias="<<one(ct->Typedef_alias())<<" params="<<(ct->Parameters()?ct->Parameters()->size():0)<<" pa="<<(ct->Param_assigns()?ct->Param_assigns()->size():0); } std::cout<<"\n"; } };
  std::cout<<"G:\n"; pr((const function*)x); std::cout<<"O:\n"; pr((const function*)y);
  CompareContext c0; for(auto*s:seed) c0.m_visited.insert(s); int r=x->Compare(y,&c0);
  if(!r){ std::cout<<"EQUAL\n"; return 0; }
  std::cout<<"L="<<ch(c0.m_failedLhs)<<"\nR="<<ch(c0.m_failedRhs)<<"\n";
  std::vector<const BaseClass*> V; for(auto*o:c0.m_visited){ bool s=false; for(auto*z:seed) if(z==o) s=true; if(!s) V.push_back(o);}
  std::cout<<"visited "<<V.size()<<"\n";
  std::vector<std::pair<int,const BaseClass*>> path;
  for(auto*o:V){ CompareContext c; for(auto*s:seed) c.m_visited.insert(s); if(o!=x) c.m_visited.insert(o); else continue; x->Compare(y,&c); if(!(c.m_failedLhs==c0.m_failedLhs && c.m_failedRhs==c0.m_failedRhs)) path.push_back({depth(o),o}); }
  std::sort(path.begin(),path.end(),[](auto&a,auto&b){return a.first>b.first;});
  for(size_t i=0;i<path.size()&&i<12;i++) std::cout<<"path d"<<path[i].first<<" "<<ch(path[i].second,4)<<"\n";
}
// (appended helper not used)
