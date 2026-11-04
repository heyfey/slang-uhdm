// refbind <db> <tf name> <ref name>: every ref_obj <ref name> inside a task_func whose VpiName is <tf name>: package view of the tf,
// line:col, the actual's kind, id, owner tf's package view, and whether the actual is listed in its own tf's Variables
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static const any* ownerTf(const any* x){ for(;x;x=x->VpiParent()) if(x->UhdmType()==uhdmfunction||x->UhdmType()==uhdmtask) return x; return nullptr; }
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string T=argv[2], N=argv[3];
 std::map<const any*,std::string> view; for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) view[p]=std::string(p->VpiName())+(k?"[top]":"[all]"); }
 auto vw=[&](const any*tf){ if(!tf) return std::string("-"); auto*p=tf->VpiParent(); while(p&&p->UhdmType()!=uhdmpackage) p=p->VpiParent(); return p?(view.count(p)?view[p]:std::string(p->VpiName())):std::string("-"); };
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if(o->UhdmType()!=uhdmref_obj||o->VpiName()!=N) continue; auto*tf=ownerTf(o); if(!tf||tf->VpiName()!=T) continue;
  auto*a=((ref_obj*)o)->Actual_group(); std::cout<<vw(tf)<<" tf="<<tf->UhdmId()<<" @"<<o->VpiLineNo()<<":"<<o->VpiColumnNo()<<" -> ";
  if(!a){ std::cout<<"null\n"; continue;} auto*atf=ownerTf(a); bool listed=false; if(atf){ auto*vs=((task_func*)atf)->Variables(); if(vs) for(auto*v:*vs) if(v==a) listed=true; }
  std::cout<<UhdmName(a->UhdmType())<<" id="<<a->UhdmId()<<" in "<<vw(atf)<<" tf="<<(atf?atf->UhdmId():0)<<" parent="<<(a->VpiParent()?UhdmName(a->VpiParent()->UhdmType()):"null")<<" listed="<<listed<<" aparent="<<(a->VpiParent()?a->VpiParent()->UhdmId():0)<<" atf_stmt="<<(atf&&((task_func*)atf)->Stmt()?((task_func*)atf)->Stmt()->UhdmId():0)<<"\n"; } }
