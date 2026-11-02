// who <db> <name> <line>: every ref_var/variables named <name> at <line>, with chain, typespec, and every ref_obj/ref_var whose actual points at it
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string ch(const BaseClass*o,int n=7){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); return s;}
static std::string ts(const any* v){ const ref_typespec* r=nullptr; if(auto*x=any_cast<const variables*>(v)) r=x->Typespec(); if(!r) return "ts=null"; auto*a=r->Actual_typespec(); std::string inst= a&&a->Instance()? std::string(" inst=")+std::string(a->Instance()->VpiName()):std::string(" inst=null"); std::string par=a?std::string(" tspar=")+ch(a->VpiParent(),3):""; return std::string("ts#")+std::to_string(a?a->UhdmId():0)+inst+par+"="+(a?std::string(UhdmName(a->UhdmType()))+":"+std::string(a->VpiName())+"@"+std::to_string(a->VpiLineNo())+":"+std::to_string(a->VpiColumnNo()):"null");}
int main(int argc,char**argv){ Serializer sa; sa.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2]; int ln=atoi(argv[3]); std::string pfx=argc>4?argv[4]:"";
 auto all=sa.AllObjects(); std::map<const any*,std::vector<const any*>> refs;
 for(auto&[o,id]:all){ const any* a=nullptr; if(o->UhdmType()==uhdmref_obj) a=((const ref_obj*)o)->Actual_group(); else if(o->UhdmType()==uhdmref_var) a=((const ref_var*)o)->Actual_group(); if(a) refs[a].push_back((const any*)o);} 
 for(auto&[o,id]:all){ if(o->VpiName()!=nm||(int)o->VpiLineNo()!=ln) continue; if(!any_cast<const variables*>((const any*)o)) continue; std::string c=ch(o); if(!pfx.empty()&&c.find(pfx)==std::string::npos) continue; std::cout<<id<<" "<<c<<" "<<ts((const any*)o)<<"\n"; for(auto*r:refs[(const any*)o]) std::cout<<"    <- "<<UhdmName(r->UhdmType())<<" "<<ch(r,6)<<"\n"; }
}
