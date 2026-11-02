// pred469 <db>...: the predicate of § importCopyTsInstByRole469 + § importEnumCloneHomeInst469 (law4 semantics)
// prints: <db> <roles> <changing roles> <changing enum roles>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
int main(int argc,char**argv){
  for(int ai=1;ai<argc;ai++){
  Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[ai])); if(ha.empty()){ std::cout<<argv[ai]<<" NODB\n"; continue;} auto*d=(design*)((uhdm_handle*)ha[0])->object;
  if(!d->AllPackages()||!d->TopPackages()){ std::cout<<argv[ai]<<" 0 0 0\n"; continue; }
  std::map<std::string,const package*> D,T; std::map<const void*,std::string> P;
  for(auto*p:*d->AllPackages()) D.emplace(std::string(p->VpiName()),p); for(auto*p:*d->TopPackages()) T.emplace(std::string(p->VpiName()),p);
  for(auto&[n,p]:D) P[p]=n; for(auto&[n,p]:T) P[p]=n;
  auto ip=[&](const typespec*t){ auto it=P.find((const void*)t->Instance()); return it==P.end()?std::string():it->second; };
  auto hn=[](const typespec*t,const std::string&h){ std::string_view n=t->VpiName(); auto c=n.find("::"); return c==std::string_view::npos||n.substr(0,c)==h; };
  int roles=0, change=0, enm=0;
  // returns 0/1/2 and home; then counts change vs want
  auto chk=[&](const ref_typespec*rt,const std::string&imp,const std::string&pn,int role,int view){ if(!rt) return; auto*h1=rt->Actual_typespec(); if(!h1) return; std::string i1=ip(h1), home; int k=0;
    if(!h1->Typedef_alias()&&i1==pn){ if(h1->UhdmType()!=uhdmenum_typespec) return; std::string_view n=h1->VpiName(); auto c=n.find("::"); home=c==std::string_view::npos?imp:std::string(n.substr(0,c)); if(home==pn||!D.count(home)||!T.count(home)) return; k=2; }
    else { if(i1.empty()||i1==pn||!hn(h1,i1)) return; home=i1; k=1; if(h1->Typedef_alias()){ auto*h2=h1->Typedef_alias()->Actual_typespec(); if(!h2||h2==h1||ip(h2)!=home||h2->Typedef_alias()||!hn(h2,home)) return; } }
    const void* want = (role==0||view==1)? (const void*)T[home] : (const void*)D[home];
    roles++; bool ch=(const void*)h1->Instance()!=want; if(h1->Typedef_alias()&&(const void*)h1->Typedef_alias()->Actual_typespec()->Instance()!=want) ch=true; if(ch){ change++; if(k==2) enm++; } };
  for(int v=0;v<2;v++){ auto*l=v?d->TopPackages():d->AllPackages(); for(auto*pk:*l){ std::string pn(pk->VpiName());
    auto imp=[&](const parameter*cp){ return cp&&!cp->VpiImported().empty()&&cp->VpiImported()!=pn; };
    if(pk->Parameters()) for(auto*a:*pk->Parameters()) if(a->UhdmType()==uhdmparameter){ auto*cp=(const parameter*)a; if(imp(cp)) chk(cp->Typespec(),std::string(cp->VpiImported()),pn,0,v); }
    if(pk->Param_assigns()) for(auto*pa:*pk->Param_assigns()){ if(!pa->Lhs()||pa->Lhs()->UhdmType()!=uhdmparameter) continue; auto*lp=(const parameter*)pa->Lhs(); if(!imp(lp)) continue; chk(lp->Typespec(),std::string(lp->VpiImported()),pn,1,v); if(pa->Rhs()&&pa->Rhs()->UhdmType()==uhdmconstant) chk(((const constant*)pa->Rhs())->Typespec(),std::string(lp->VpiImported()),pn,1,v); }
  } }
  std::cout<<argv[ai]<<" "<<roles<<" "<<change<<" "<<enm<<"\n";
  }
}
