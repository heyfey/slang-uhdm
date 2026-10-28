#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*de=(design*)((uhdm_handle*)h[0])->object;
 auto*l=std::string(argv[3])=="top"?de->TopModules():de->AllModules(); if(!l) return 0; for(auto*m:*l){ if(m->VpiName()!=argv[2] && m->VpiDefName()!=argv[2]) continue;
 if(m->Nets()) for(auto*n:*m->Nets()) std::cout<<"net "<<UhdmName(n->UhdmType())<<" "<<n->VpiName()<<" @"<<n->VpiLineNo()<<":"<<n->VpiColumnNo()<<"\n";
 if(m->Variables()) for(auto*n:*m->Variables()) std::cout<<"var "<<UhdmName(n->UhdmType())<<" "<<n->VpiName()<<" @"<<n->VpiLineNo()<<":"<<n->VpiColumnNo()<<"\n"; }}
