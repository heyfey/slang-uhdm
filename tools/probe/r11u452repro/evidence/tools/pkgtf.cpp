#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*de=(design*)((uhdm_handle*)h[0])->object;
 for(int k=0;k<2;k++){ auto*l=k?de->TopPackages():de->AllPackages(); if(!l) continue; for(auto*p:*l){ if(p->VpiName()!=argv[2]) continue; std::cout<<(k?"TOP":"DEF")<<" tfs="<<(p->Task_funcs()?p->Task_funcs()->size():0)<<"\n"; if(p->Task_funcs()) { size_t n=p->Task_funcs()->size(); size_t from = n>12? n-12:0; for(size_t i=from;i<n;i++){auto*t=(*p->Task_funcs())[i]; std::cout<<"  "<<t->VpiName()<<" @"<<t->VpiLineNo()<<" par="<<(t->VpiParent()?std::string(t->VpiParent()->VpiName()):"null")<<"\n";}} }}}
