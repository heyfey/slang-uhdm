// list every param_assign in package/module/interface listings: scope, id, parent, rhs kind, lhs name
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
std::string want;
static std::string nm(const any* o){ if(!o) return "null"; std::string f=std::string(o->VpiName()); if(auto*s=dynamic_cast<const scope*>(o)) {} return f; }
static std::string fn(const any*o){ if(!o) return "null"; if(auto*i=any_cast<const instance*>(o)) return std::string(i->VpiFullName())+"/"+std::string(i->VpiName()); return std::string(o->VpiName()); }
void lst(const std::string&tag,const instance*s){ if(!s) return; if(auto*v=s->Param_assigns()) for(auto*pa:*v){ std::string ln=pa->Lhs()?std::string(pa->Lhs()->VpiName()):"?"; if(!want.empty()&&ln.find(want)==std::string::npos) continue; auto*r=pa->Rhs(); std::cout<<tag<<" "<<fn(s)<<" pa#"<<pa->UhdmId()<<" par="<<fn(pa->VpiParent())<<" rhs="<<(r?UhdmName(r->UhdmType()):"null")<<"#"<<(r?r->UhdmId():0)<<" lhs="<<ln<<"#"<<(pa->Lhs()?pa->Lhs()->UhdmId():0)<<" line="<<pa->VpiLineNo()<<"\n";}}
void walk(const std::string&tag,const module_inst*m){ if(!m) return; lst(tag,m); if(m->Modules()) for(auto*c:*m->Modules()) walk(tag+">",c); if(m->Interfaces()) for(auto*c:*m->Interfaces()) walk(tag+">",(const module_inst*)c);}
void walki(const std::string&tag,const interface_inst*m){ lst(tag,m); }
int main(int argc,char**argv){ if(argc>2) want=argv[2]; Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 if(d->AllPackages()) for(auto*p:*d->AllPackages()) lst("DEFPKG",p);
 if(d->TopPackages()) for(auto*p:*d->TopPackages()) lst("TOPPKG",p);
 if(d->AllModules()) for(auto*p:*d->AllModules()) lst("DEFMOD",p);
 if(d->AllInterfaces()) for(auto*p:*d->AllInterfaces()) lst("DEFIF",p);
 if(d->TopModules()) for(auto*p:*d->TopModules()) {
   std::function<void(const std::string&,const instance*)> w=[&](const std::string&t,const instance*x){ lst(t,x); if(auto*mi=any_cast<const module_inst*>(x)){ if(mi->Modules()) for(auto*c:*mi->Modules()) w(t+">",c); if(mi->Interfaces()) for(auto*c:*mi->Interfaces()) w(t+">",c);} if(auto*ii=any_cast<const interface_inst*>(x)){ if(ii->Interfaces()) for(auto*c:*ii->Interfaces()) w(t+">",c);} };
   w("TOP",p);}
}
