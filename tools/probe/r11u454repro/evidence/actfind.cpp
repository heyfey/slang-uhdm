// actfind <db> <name> <line> <col>: every ref_obj/port high_conn/low_conn whose actual is the named object at line:col
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string desc(const BaseClass*o){ if(!o) return "null"; std::string s=std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); auto*p=o->VpiParent(); for(int i=0;i<8&&p;i++,p=p->VpiParent()) s+=" < "+std::string(UhdmName(p->UhdmType()))+":"+std::string(p->VpiName())+"@"+std::to_string(p->VpiLineNo()); return s;}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
 std::string n=argv[2]; int L=atoi(argv[3]), C=atoi(argv[4]);
 auto match=[&](const BaseClass*a){ return a && a->VpiName()==n && (int)a->VpiLineNo()==L && (int)a->VpiColumnNo()==C; };
 for(auto& [o,id]: s.AllObjects()){ (void)id; auto*b=(const BaseClass*)o;
  if(b->UhdmType()==uhdmref_obj){ auto*r=(const ref_obj*)b; if(match(r->Actual_group())) std::cout<<"REFOBJ "<<desc(r)<<"  ->"<<UhdmName(r->Actual_group()->UhdmType())<<" P="<<desc(r->Actual_group()->VpiParent())<<"\n"; }
 } }
