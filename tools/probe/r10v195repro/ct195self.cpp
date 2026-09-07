// r10v195 — is a clone body ref_var's vpiActual the HOME object or ITSELF?
// MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string chain(const BaseClass* o){std::string s;int g=0;
 for(const BaseClass*p=o->VpiParent();p&&g<40;p=p->VpiParent(),++g){s+="/";s+=UhdmName(p->UhdmType());s+=":";s+=std::string(p->VpiName());}return s;}
int main(int argc,char**argv){
 Serializer S; if(S.Restore(std::string(argv[1])).empty()){printf("RESTORE_FAIL\n");return 3;}
 const char* nm=argv[2];
 for(auto&kv:S.AllObjects()){const BaseClass*X=kv.first;if(!X)continue;
  if(X->UhdmType()!=uhdmref_var)continue;
  if(std::string(X->VpiName())!=nm)continue;
  const ref_var* r=(const ref_var*)X; const any* a=r->Actual_group();
  printf("obj=%p id=%u chain=%s\n", (const void*)X, X->UhdmId(), chain(X).c_str());
  if(!a) printf("    actual=<null>\n");
  else printf("    actual=%p id=%u kind=%s SELF=%s chain=%s\n",(const void*)a,a->UhdmId(),
       UhdmName(a->UhdmType()), (a==(const any*)X?"YES":"no"), chain(a).c_str());
 }
 return 0;}
