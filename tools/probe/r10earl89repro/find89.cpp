// r10earl89 — locate a constant by SPAN in a .uhdm and print its parent chain
// + its typespec.  Direct reader.  MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <string>
using namespace UHDM;
static unsigned L1,C1,L2,C2;
static std::string chain(const any* o){std::string r;const any*p=o->VpiParent();
 for(int i=0;i<40&&p;i++){std::string e(UhdmName(p->UhdmType()));
  if(!p->VpiName().empty())e+="("+std::string(p->VpiName())+")";
  char b[64];snprintf(b,sizeof b,"@%u:%u",(unsigned)p->VpiLineNo(),(unsigned)p->VpiColumnNo());e+=b;
  r=r.empty()?e:(e+"/"+r);p=p->VpiParent();}return r;}
struct F:public UhdmListener{
 void enterConstant(const constant* const c) final {
  if(c->VpiLineNo()!=L1||c->VpiColumnNo()!=C1||c->VpiEndLineNo()!=L2||c->VpiEndColumnNo()!=C2)return;
  const char* ts="none"; std::string tsd;
  if(auto* rt=c->Typespec()){ if(auto* at=rt->Actual_typespec()){tsd=UhdmName(at->UhdmType());
    char b[80];snprintf(b,sizeof b," rtFull='%s' tsLine=%u",std::string(rt->VpiFullName()).c_str(),(unsigned)at->VpiLineNo());tsd+=b;}
    else tsd="ref/none"; ts=tsd.c_str(); }
  printf("CONST file=%s val=%s dec=%s sz=%d ct=%d TS=%s\n  chain=%s\n",
   std::string(c->VpiFile()).c_str(),std::string(c->VpiValue()).c_str(),
   std::string(c->VpiDecompile()).c_str(),c->VpiSize(),c->VpiConstType(),ts,chain(c).c_str());}
};
int main(int argc,char**argv){ if(argc<6){fprintf(stderr,"usage: find89 <db> l1 c1 l2 c2\n");return 2;}
 L1=atoi(argv[2]);C1=atoi(argv[3]);L2=atoi(argv[4]);C2=atoi(argv[5]);
 Serializer s; auto r=s.Restore(std::string(argv[1])); if(r.empty())return 3;
 F f; for(auto h:r){const any*o=(const any*)((const uhdm_handle*)h)->object;
  if(auto*d=any_cast<const design*>(o))f.listenDesign(d);} return 0;}
