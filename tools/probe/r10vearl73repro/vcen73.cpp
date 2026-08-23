// r10v73 — ALL-CONSTANT census, direct .uhdm reader.  MEASUREMENT ONLY.
// One line per constant the UhdmListener reaches:
//   C <owner-chain-no-span> || ct= sz= val= dec= ts= tssgn= | SPAN=<0|1>
// Payload carries ONLY judge-visible fields (VpiType/VpiDecompile/VpiSize/
// Typespec/VpiConstType) + VpiValue; the SPAN is a SEPARATE column so a
// span-carrying payload cannot hide a field flip (earl60/65 lesson).
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;
static std::string esc(std::string_view v){std::string r;for(char c:v)r+=(c==' '?'_':c);if(r.empty())r="-";return r;}
static void tsInfo(const ref_typespec* rt,std::string&kind,int&sgn){
  kind="-";sgn=-1;if(!rt)return;kind="REF_NO_ACTUAL";const typespec*at=rt->Actual_typespec();
  if(!at)return;kind=std::string(UhdmName(at->UhdmType()));
  switch(at->UhdmType()){
    case uhdmint_typespec: sgn=((const int_typespec*)at)->VpiSigned();break;
    case uhdminteger_typespec: sgn=((const integer_typespec*)at)->VpiSigned();break;
    case uhdmbit_typespec: sgn=((const bit_typespec*)at)->VpiSigned();break;
    case uhdmlogic_typespec: sgn=((const logic_typespec*)at)->VpiSigned();break;
    default:break;}
}
static std::string chainOf(const any*o){
  std::string r;const any*p=o->VpiParent();
  for(int i=0;i<40&&p;i++){std::string e(UhdmName(p->UhdmType()));
    if(!p->VpiName().empty())e+="("+esc(p->VpiName())+")";
    else if(p->UhdmType()==uhdmparam_assign){
      const any* lh=((const param_assign*)p)->Lhs();
      if(lh&&!lh->VpiName().empty())e+="["+esc(lh->VpiName())+"]";
    } else if(p->UhdmType()==uhdmcont_assign){
      const any* lh=((const cont_assign*)p)->Lhs();
      if(lh&&!lh->VpiName().empty())e+="["+esc(lh->VpiName())+"]";
    }
    r=r.empty()?e:(e+"/"+r);p=p->VpiParent();}
  if(r.empty())r="-";return r;
}
struct Cen: public UhdmListener{
  void enterConstant(const constant* const c) final{
    std::string tk;int tsgn;tsInfo(c->Typespec(),tk,tsgn);
    int span = (c->VpiLineNo()!=0||c->VpiColumnNo()!=0)?1:0;
    printf("C %s || ct=%d sz=%d val=%s dec=%s ts=%s tssgn=%d | SPAN=%d\n",
      chainOf(c).c_str(),c->VpiConstType(),c->VpiSize(),
      esc(c->VpiValue()).c_str(),esc(c->VpiDecompile()).c_str(),
      tk.c_str(),tsgn,span);
  }
};
int main(int argc,char**argv){
  if(argc<2){fprintf(stderr,"usage: vcen73 <db.uhdm>\n");return 2;}
  Serializer s;const std::vector<vpiHandle> r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"EMPTY %s\n",argv[1]);return 3;}
  Cen c;for(vpiHandle h:r){const any*o=(const any*)((const uhdm_handle*)h)->object;
    if(auto*d=any_cast<const design*>(o))c.listenDesign(d);}
  return 0;
}
