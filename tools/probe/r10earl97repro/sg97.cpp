// r10earl97 -- MEASUREMENT ONLY.  Lists every INTEGER-KIND typespec in a .uhdm
// with exactly the fields the generated Compares read for signedness decode:
//   kind | span | VpiName | VpiSigned | has-Cast_to_expr | #Ranges | parent kind
//   | parent name | HOME (enclosing gen-scope chain + module/package/class)
// Derived from r10earl95repro/ln95.cpp.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
static const char* nm(const BaseClass*o){ if(!o) return "-"; const any*a=(const any*)o; auto v=a->VpiName(); return v.empty()?"-":v.data(); }
int main(int argc,char**argv){
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  std::vector<std::string> rows;
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo) continue;
    auto t=bo->UhdmType();
    int sgn=-1; int hasx=0; int nr=0; const char*k=nullptr;
    switch(t){
      case uhdmint_typespec:{auto*x=(const int_typespec*)bo;k="int";sgn=x->VpiSigned();hasx=x->Cast_to_expr()?1:0;nr=x->Ranges()?x->Ranges()->size():0;break;}
      case uhdminteger_typespec:{auto*x=(const integer_typespec*)bo;k="integer";sgn=x->VpiSigned();break;}
      case uhdmshort_int_typespec:{auto*x=(const short_int_typespec*)bo;k="shortint";sgn=x->VpiSigned();break;}
      case uhdmlong_int_typespec:{auto*x=(const long_int_typespec*)bo;k="longint";sgn=x->VpiSigned();break;}
      case uhdmbyte_typespec:{auto*x=(const byte_typespec*)bo;k="byte";sgn=x->VpiSigned();break;}
      case uhdmtime_typespec:{auto*x=(const time_typespec*)bo;k="time";sgn=x->VpiSigned();break;}
      case uhdmbit_typespec:{auto*x=(const bit_typespec*)bo;k="bit";sgn=x->VpiSigned();nr=x->Ranges()?x->Ranges()->size():0;break;}
      case uhdmlogic_typespec:{auto*x=(const logic_typespec*)bo;k="logic";sgn=x->VpiSigned();nr=x->Ranges()?x->Ranges()->size():0;break;}
      case uhdmreal_typespec:{k="real";break;}
      case uhdmshort_real_typespec:{k="shortreal";break;}
      default: break;
    }
    if(!k) continue;
    std::string home="-";
    for(const BaseClass*p=bo->VpiParent();p;p=p->VpiParent()){
      auto pt=p->UhdmType();
      if(pt==uhdmmodule_inst||pt==uhdminterface_inst||pt==uhdmpackage||pt==uhdmclass_defn){home=std::string(((const scope*)p)->VpiFullName())+"|"+home;break;}
      if(pt==uhdmgen_scope||pt==uhdmgen_scope_array) home=std::string(((const any*)p)->VpiName())+"@|"+home;
    }
    // OWNER = the first non-ref_typespec ancestor
    const BaseClass*ow=bo->VpiParent();
    if(ow&&ow->UhdmType()==uhdmref_typespec) ow=ow->VpiParent();
    char b[4096];
    snprintf(b,sizeof b,"%-10s span=%-16s name=%-24s sgn=%d expr=%d rng=%d par=%-16s own=%-16s ownname=%-28s HOME=%s",
      k,sp(bo).c_str(),nm(bo),sgn,hasx,nr,kn(bo->VpiParent()).c_str(),kn(ow).c_str(),nm(ow),home.c_str());
    rows.push_back(b);
  }
  std::sort(rows.begin(),rows.end());
  for(auto&x:rows) printf("%s\n",x.c_str());
  return 0;
}
