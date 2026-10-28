// rtinst: every ref_typespec -> owner path (kinds/names up to the design), actual's kind/name and actual's vpiInstance (ALL/TOP pkg or module)
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
std::map<const any*,std::string> tag;
std::string path(const any* o){ std::string r; int n=0; while(o && n<12){ std::string nm(o->VpiName()); auto it=tag.find(o); r = std::string(UhdmName(o->UhdmType()))+"("+nm+(it!=tag.end()?"/"+it->second:"")+")" + (r.empty()?"":">")+r; o=o->VpiParent(); n++;} return r; }
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 if(d->AllPackages()) for(auto*p:*d->AllPackages()) tag[p]="ALL";
 if(d->TopPackages()) for(auto*p:*d->TopPackages()) tag[p]="TOP";
 if(d->AllModules()) for(auto*p:*d->AllModules()) tag[p]="ALLM";
 if(d->TopModules()) for(auto*p:*d->TopModules()) tag[p]="TOPM";
 for (auto& kv : s.AllObjects()) { const any* o = kv.first; if (o->UhdmType()==uhdmref_typespec) { auto* rt=(const ref_typespec*)o; const typespec* a=rt->Actual_typespec();
   std::string inst="-"; if(a && a->Instance()){ auto it=tag.find(a->Instance()); inst=std::string(a->Instance()->VpiName())+"/"+(it!=tag.end()?it->second:"?"); }
   std::cout<<path(rt->VpiParent())<<" => "<<(a?UhdmName(a->UhdmType()):"null")<<"("<<(a?std::string(a->VpiName()):"")<<") inst="<<inst<<"\n"; } }
}
