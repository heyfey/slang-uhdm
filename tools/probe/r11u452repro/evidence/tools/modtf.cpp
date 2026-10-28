#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*de=(design*)((uhdm_handle*)h[0])->object;
 for(int k=0;k<2;k++){ auto*l=k?de->TopModules():de->AllModules(); if(!l) continue; for(auto*m:*l){ if(m->VpiDefName()!=argv[2]) continue; std::cout<<(k?"TOP":"DEF")<<" tfs="<<(m->Task_funcs()?m->Task_funcs()->size():0)<<"\n"; if(m->Task_funcs()) for(auto*t:*m->Task_funcs()){ std::string n(t->VpiName()); if(argc>3 && n.find(argv[3])==std::string::npos) continue; std::cout<<"  "<<n<<" @"<<t->VpiLineNo()<<" par="<<(t->VpiParent()?std::string(UhdmName(t->VpiParent()->UhdmType()))+":"+std::string(t->VpiParent()->VpiName()):"null")<<"\n";} }}}
