#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string sp(const any*o){char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",(unsigned)o->VpiLineNo(),(unsigned)o->VpiColumnNo(),(unsigned)o->VpiEndLineNo(),(unsigned)o->VpiEndColumnNo());return b;}
static std::string chain(const any* o){std::string r;const any*p=o->VpiParent();
 for(int i=0;i<30&&p;i++){std::string e(UhdmName(p->UhdmType()));
  if(!p->VpiName().empty())e+="("+std::string(p->VpiName())+")";
  r=r.empty()?e:(e+"/"+r);p=p->VpiParent();}return r;}
struct F:public UhdmListener{
 void enterIndexed_part_select(const indexed_part_select* const s) final {
  const any* w=s->Width_expr(); const any* b=s->Base_expr();
  if(!w) return;
  if(w->VpiLineNo()!=82||w->VpiColumnNo()!=58) return;
  printf("IPS %s name=%s base=%s width=%s ts=%s\n  chain=%s\n", sp(s).c_str(),
    std::string(s->VpiName()).c_str(), b?sp(b).c_str():"-", sp(w).c_str(),
    (w->UhdmType()==uhdmconstant && ((const constant*)w)->Typespec())?"TS":"none",
    chain(s).c_str());}
};
int main(int argc,char**argv){Serializer s;auto r=s.Restore(std::string(argv[1]));if(r.empty())return 3;
 F f;for(auto h:r){const any*o=(const any*)((const uhdm_handle*)h)->object;
 if(auto*d=any_cast<const design*>(o))f.listenDesign(d);}return 0;}
