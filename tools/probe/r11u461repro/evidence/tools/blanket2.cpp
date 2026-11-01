// blanket2 <in> <out> <pkg> <listfile> <lo> <hi>: typespecs with Instance TOP pkg: index i (in AllObjects order among candidates not in types pkg param) moved when lo<=i<hi
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <algorithm>
using namespace UHDM;
static std::string d1(const BaseClass*o){ return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo());}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string pk=argv[3]; int lo=atoi(argv[5]), hi=atoi(argv[6]);
 package*def=nullptr,*top=nullptr; for(auto*p:*d->AllPackages()) if(p->VpiName()==pk) def=p; for(auto*p:*d->TopPackages()) if(p->VpiName()==pk) top=p;
 std::vector<std::pair<unsigned long,typespec*>> c; for(auto&[o,id]:s.AllObjects()){ auto*b=(BaseClass*)o; auto*t=dynamic_cast<typespec*>(b); if(!t||t->Instance()!=top) continue; if(t->VpiParent()&&t->VpiParent()->VpiParent()==top) continue; c.push_back({b->UhdmId(),t}); }
 std::sort(c.begin(),c.end(),[](auto&a,auto&b){return a.first<b.first;}); FILE*f=fopen(argv[4],"w");
 for(int i=0;i<(int)c.size();i++){ auto*b=c[i].second; std::string ch=d1(b); int k=0; for(auto*p=b->VpiParent();p&&k<7;p=p->VpiParent(),k++) ch+=" < "+d1(p); fprintf(f,"%d #%lu %s\n",i,c[i].first,ch.c_str()); if(i>=lo&&i<hi) b->Instance(def);} fclose(f);
 std::cerr<<"total "<<c.size()<<"\n"; s.Save(std::filesystem::path(argv[2])); }
