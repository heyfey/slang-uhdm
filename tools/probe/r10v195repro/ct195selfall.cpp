// r10v195 — count ref_vars whose vpiActual is THEMSELVES.  MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
int main(int argc,char**argv){
 Serializer S; if(S.Restore(std::string(argv[1])).empty()){printf("RESTORE_FAIL\n");return 3;}
 long self=0,bound=0,tot=0;
 for(auto&kv:S.AllObjects()){const BaseClass*X=kv.first;if(!X)continue;
  if(X->UhdmType()!=uhdmref_var)continue; ++tot;
  const any*a=((const ref_var*)X)->Actual_group(); if(!a)continue; ++bound;
  if(a==(const any*)X){++self; if(argc>2) printf("SELF %s id=%u\n",std::string(X->VpiName()).c_str(),X->UhdmId());}}
 printf("ref_var=%ld bound=%ld SELF=%ld\n",tot,bound,self);
 return 0;}
