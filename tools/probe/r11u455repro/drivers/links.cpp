// links <db>: every func_call / task_call: its chain (kinds, names, locations) and its linked subroutine's owner (package name + TOP/ALL view, or other)
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::set<const any*> top, all;
static std::string ch(const BaseClass*o,int n=12){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()){ std::string v; if(top.count((const any*)o)) v="[TOP]"; if(all.count((const any*)o)) v="[ALL]"; s+=std::string(i?"<":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+v+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo());} return s;}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 if(d->AllPackages()) for(auto*p:*d->AllPackages()) all.insert(p); if(d->TopPackages()) for(auto*p:*d->TopPackages()) top.insert(p);
 for(auto& [o,id]: s.AllObjects()){ (void)id; const any* tgt=nullptr; bool is=false;
  if(o->UhdmType()==uhdmfunc_call){ tgt=((const func_call*)o)->Function(); is=true;} else if(o->UhdmType()==uhdmtask_call){ tgt=((const task_call*)o)->Task(); is=true;}
  if(!is) continue; std::string t="null"; if(tgt){ const BaseClass* q=tgt; std::string own="?"; while(q){ if(q->UhdmType()==uhdmpackage||q->UhdmType()==uhdmmodule_inst||q->UhdmType()==uhdmclass_defn||q->UhdmType()==uhdminterface_inst||q->UhdmType()==uhdmprogram){ own=std::string(UhdmName(q->UhdmType()))+":"+std::string(q->VpiName())+(top.count((const any*)q)?"[TOP]":all.count((const any*)q)?"[ALL]":""); break;} q=q->VpiParent(); } t=std::string(tgt->VpiName())+" in "+own; }
  std::cout<<ch(o)<<"\t-> "<<t<<"\n"; } }
