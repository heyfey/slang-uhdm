// r10earl97 -- MEASUREMENT ONLY.  The SIGNEDNESS CENSUS: every INTEGER-KIND
// typespec of a .uhdm, keyed by the things the two producers agree on and
// carrying a COMPARE-VISIBLE payload (VpiSigned -- the only field
// <kind>_typespec::Compare reads besides Cast_to_expr/Ranges/name).
//
//   KEY  = kind | span | VpiName | ROLE | ownername | HOMEKIND | HOME | expr | rng
//   PAY  = sgn=<0|1>
//
// ROLE is the OWNER category asked of the grid: param / localparam / var /
// port / funcret / tdlist / member / cast / range / other.  The DEF-vs-ELAB
// view is NOT in the key (the two producers label it differently); the HOME
// full name separates a def listing from an elaborated instance by itself.
// Derived from r10earl95repro/ln95.cpp + r10earl96repro/ct96cen.cpp.
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
static std::string nm(const BaseClass*o){ if(!o) return "-"; auto v=((const any*)o)->VpiName(); return v.empty()?std::string("-"):std::string(v); }
int main(int argc,char**argv){
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  std::vector<std::string> rows;
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo) continue;
    auto t=bo->UhdmType();
    int sgn=0,hasx=0,nr=0; const char*k=nullptr;
    switch(t){
      case uhdmint_typespec:{auto*x=(const int_typespec*)bo;k="int";sgn=x->VpiSigned();hasx=x->Cast_to_expr()?1:0;nr=x->Ranges()?(int)x->Ranges()->size():0;break;}
      case uhdminteger_typespec:{auto*x=(const integer_typespec*)bo;k="integer";sgn=x->VpiSigned();break;}
      case uhdmshort_int_typespec:{auto*x=(const short_int_typespec*)bo;k="shortint";sgn=x->VpiSigned();break;}
      case uhdmlong_int_typespec:{auto*x=(const long_int_typespec*)bo;k="longint";sgn=x->VpiSigned();break;}
      case uhdmbyte_typespec:{auto*x=(const byte_typespec*)bo;k="byte";sgn=x->VpiSigned();break;}
      case uhdmtime_typespec:{auto*x=(const time_typespec*)bo;k="time";sgn=x->VpiSigned();break;}
      case uhdmbit_typespec:{auto*x=(const bit_typespec*)bo;k="bit";sgn=x->VpiSigned();nr=x->Ranges()?(int)x->Ranges()->size():0;break;}
      case uhdmlogic_typespec:{auto*x=(const logic_typespec*)bo;k="logic";sgn=x->VpiSigned();nr=x->Ranges()?(int)x->Ranges()->size():0;break;}
      case uhdmreal_typespec:{k="real";break;}
      case uhdmshort_real_typespec:{k="shortreal";break;}
      default: break;
    }
    if(!k) continue;
    std::string home="-",homek="-";
    for(const BaseClass*p=bo->VpiParent();p;p=p->VpiParent()){
      auto pt=p->UhdmType();
      if(pt==uhdmmodule_inst||pt==uhdminterface_inst||pt==uhdmpackage||pt==uhdmclass_defn){
        home=std::string(((const scope*)p)->VpiFullName()); homek=UHDM::UhdmName(pt); break;}
      if(pt==uhdmgen_scope||pt==uhdmgen_scope_array){ if(homek=="-") homek="gen_scope"; home=nm(p)+"@"+home; }
    }
    const BaseClass*ow=bo->VpiParent();
    if(ow&&ow->UhdmType()==uhdmref_typespec) ow=ow->VpiParent();
    std::string role="other";
    if(ow){
      switch(ow->UhdmType()){
        case uhdmparameter: role=((const parameter*)ow)->VpiLocalParam()?"localparam":"param"; break;
        case uhdmtype_parameter: role="typeparam"; break;
        case uhdmoperation: role="cast"; break;
        case uhdmio_decl: role="port"; break;
        case uhdmtypespec_member: role="member"; break;
        case uhdmfunction: role="funcret"; break;
        case uhdmenum_typespec: case uhdmstruct_typespec: case uhdmunion_typespec:
        case uhdmarray_typespec: case uhdmpacked_array_typespec: role="elem"; break;
        case uhdmrange: role="range"; break;
        case uhdmconstant: role="const"; break;
        case uhdmtypespec: role="tdlist"; break;
        default:
          if(dynamic_cast<const variables*>((const any*)ow)) role="var";
          else if(dynamic_cast<const nets*>((const any*)ow)) role="net";
          else role=kn(ow);
      }
    } else role="unparented";
    char b[8192];
    snprintf(b,sizeof b,"%s|%s|%s|%s|%s|%s|%s|%d|%d\tsgn=%d",
      k,sp(bo).c_str(),nm(bo).c_str(),role.c_str(),nm(ow).c_str(),homek.c_str(),home.c_str(),hasx,nr,sgn);
    rows.push_back(b);
  }
  std::sort(rows.begin(),rows.end());
  for(auto&x:rows) printf("%s\n",x.c_str());
  return 0;
}
