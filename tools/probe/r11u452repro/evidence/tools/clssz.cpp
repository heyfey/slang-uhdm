#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
#define SZ(x) std::cout<<" " #x "="<<(c->x()?c->x()->size():0)
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*de=(design*)((uhdm_handle*)h[0])->object;
 auto*l=std::string(argv[4])=="top"?de->TopPackages():de->AllPackages(); for(auto*p:*l){ if(p->VpiName()!=argv[2]||!p->Class_defns()) continue; for(auto*c:*p->Class_defns()){ if(c->VpiName()!=argv[3]) continue;
 SZ(Array_var_mems);SZ(Class_typespecs);SZ(Concurrent_assertions);SZ(Constraints);SZ(Deriveds);SZ(Instance_items);SZ(Let_decls);SZ(Named_events);SZ(Param_assigns);SZ(Parameters);SZ(Property_decls);SZ(Scopes);SZ(Sequence_decls);SZ(Task_funcs);SZ(Typespecs);SZ(Variables);SZ(Virtual_interface_vars); std::cout<<" ext="<<(c->Extends()?1:0)<<"\n";
 if(argc>5 && c->Task_funcs()) for(auto*t:*c->Task_funcs()) std::cout<<"  tf "<<t->VpiName()<<" @"<<t->VpiLineNo()<<" par="<<(t->VpiParent()?std::string(t->VpiParent()->VpiName()):"null")<<"\n";
 if(argc>5 && c->Parameters()) for(auto*t:*c->Parameters()) std::cout<<"  pa "<<t->VpiName()<<" @"<<t->VpiLineNo()<<"\n";
 }}}
