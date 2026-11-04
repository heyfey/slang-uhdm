// tfvids <db> <tf name>: every task_func of that name: package view, id, its Variables (kind name id parent-kind) and,
// when its statement is a begin, the begin's Variables
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string T=argv[2];
 std::map<const any*,std::string> view; for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) view[p]=std::string(p->VpiName())+(k?"[top]":"[all]"); }
 auto pr=[](const char*tag, VectorOfvariables* v){ if(!v) return; for(auto*x:*v) std::cout<<"   "<<tag<<" "<<UhdmName(x->UhdmType())<<" "<<x->VpiName()<<" id="<<x->UhdmId()<<" par="<<(x->VpiParent()?UhdmName(x->VpiParent()->UhdmType()):"null")<<"\n"; };
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if((o->UhdmType()!=uhdmfunction&&o->UhdmType()!=uhdmtask)||o->VpiName()!=T) continue; auto*tf=(task_func*)o;
  auto*p=o->VpiParent(); std::cout<<(p&&view.count(p)?view[p]:std::string(p?p->VpiName():"null"))<<" tf id="<<o->UhdmId()<<"\n"; pr("TF",tf->Variables());
  if(auto*st=tf->Stmt()) if(st->UhdmType()==uhdmbegin) pr("BEGIN",((begin*)st)->Variables()); } }
