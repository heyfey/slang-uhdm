// rebind <in> <out>: simulate widening § 146's binding branch to sys_func_call actuals
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 std::map<std::string,parameter*> m; if(d->Parameters()) for(auto*q:*d->Parameters()) if(q->UhdmType()==uhdmparameter) m.emplace(std::string(q->VpiName()),(parameter*)q);
 int n=0; for(auto&[o,id]:s.AllObjects()){ auto*b=(BaseClass*)o; if(b->UhdmType()!=uhdmref_obj) continue; auto*r=(ref_obj*)b; auto*a=r->Actual_group(); if(!a||a->UhdmType()!=uhdmsys_func_call) continue; auto it=m.find(std::string(r->VpiName())); if(it==m.end()) continue; bool ok=false; for(auto*u=b->VpiParent();u;u=u->VpiParent()){ if(u->UhdmType()==uhdmref_typespec) break; if(u->UhdmType()==uhdmdesign){ok=true;break;}} if(!ok) continue; r->Actual_group(it->second); n++; }
 std::cerr<<"rebound "<<n<<"\n"; std::vector<vpiHandle> v={h[0]}; s.Save(std::filesystem::path(argv[2])); }
