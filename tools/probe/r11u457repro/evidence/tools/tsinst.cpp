// tsinst: for every typespec reachable by vpiInstance, print id, kind, name, parent id, instance id; packages with ids
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
std::set<const any*> seen;
void walk(const any* o);
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 if(d->AllPackages()) for(auto*p:*d->AllPackages()) std::cout<<"ALLPKG "<<p->VpiName()<<" #"<<p->UhdmId()<<"\n";
 if(d->TopPackages()) for(auto*p:*d->TopPackages()) std::cout<<"TOPPKG "<<p->VpiName()<<" #"<<p->UhdmId()<<"\n";
 for (auto& kv : s.AllObjects()) { const any* o = kv.first; if (const typespec* t = any_cast<const typespec*>(o)) {
   std::cout<<"TS #"<<t->UhdmId()<<" "<<UhdmName(t->UhdmType())<<" '"<<t->VpiName()<<"' "<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<" par=#"<<(t->VpiParent()?t->VpiParent()->UhdmId():0)<<"("<<(t->VpiParent()?UhdmName(t->VpiParent()->UhdmType()):"")<<") inst=#"<<(t->Instance()?t->Instance()->UhdmId():0)<<"\n"; } }
}
