// nets <db> <uhdmId>: list Nets of instance id: name line:col file-basename
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; s.Restore(std::filesystem::path(argv[1])); unsigned id=atoi(argv[2]);
 for(auto&[o,i]:s.AllObjects()){ auto*a=(const any*)o; if(a->UhdmId()!=id) continue; auto*m=any_cast<const module_inst*>(a); if(!m||!m->Nets()) continue; for(auto*n:*m->Nets()) std::cout<<UhdmName(n->UhdmType())<<" "<<n->VpiName()<<" @"<<n->VpiLineNo()<<":"<<n->VpiColumnNo()<<" "<<std::filesystem::path(std::string(n->VpiFile())).filename().string()<<"\n"; } }
