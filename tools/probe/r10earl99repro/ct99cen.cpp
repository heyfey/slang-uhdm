// r10earl99 -- MEASUREMENT ONLY.  THE CONSTANT CENSUS: every `constant` of a
// .uhdm, keyed by things the two producers agree on and carrying a payload of
// exactly the fields the OFFICIAL Compare reads for a constant --
//   expr::Compare      VpiDecompile, VpiSize, Typespec
//   constant::Compare  VpiConstType
// (VpiValue is NOT read by any generated Compare; it is carried in a SECOND,
// clearly separated column so a diagnosis can see it without the scorer ever
// counting a field the judge cannot see.)
//
//   KEY  = C | span | ownerkind[:optype] | ownerspan | role | HOMEKIND | HOME
//   PAY  = ct=<n> sz=<n> dec=<s> ts=<kind>(<name>)
//
// The DEF-vs-ELAB view is NOT in the key (the two producers label it
// differently); the HOME full name separates a def listing from an elaborated
// instance by itself.  Derived from r10earl97repro/ct97cen.cpp.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
static std::string nm(const BaseClass*o){ if(!o) return "-"; auto v=((const any*)o)->VpiName(); return v.empty()?std::string("-"):std::string(v); }
int main(int argc,char**argv){
  if(argc<2){fprintf(stderr,"usage: ct99cen <db.uhdm>\n");return 2;}
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo) continue;
    const bool isC = bo->UhdmType()==uhdmconstant;
    const expr* xe = any_cast<const expr*>((const any*)bo);
    if(!isC && !xe) {
      // IDENTITY row for every non-expr object: kind + span + name.  Proves
      // ADDED / REMOVED across a change without reading a payload at all.
      printf("O|%s|%s|%s\t-\t-\n", kn(bo).c_str(), sp(bo).c_str(), nm(bo).c_str());
      continue;
    }
    auto*c=(const constant*)bo;
    std::string home="-",homek="-";
    for(const BaseClass*p=bo->VpiParent();p;p=p->VpiParent()){
      auto pt=p->UhdmType();
      if(pt==uhdmmodule_inst||pt==uhdminterface_inst||pt==uhdmpackage||pt==uhdmclass_defn){
        home=std::string(((const scope*)p)->VpiFullName()); homek=UHDM::UhdmName(pt); break;}
      if(pt==uhdmgen_scope||pt==uhdmgen_scope_array){ if(homek=="-") homek="gen_scope"; home=nm(p)+"@"+home; }
    }
    const BaseClass*ow=bo->VpiParent();
    std::string owk=kn(ow);
    if(ow&&ow->UhdmType()==uhdmoperation){ char b[32]; snprintf(b,sizeof b,":op%d",((const operation*)ow)->VpiOpType()); owk+=b; }
    // ROLE: the nearest ENCLOSING carrier the emitter can name.
    std::string role="other";
    for(const BaseClass*p=bo->VpiParent();p;p=p->VpiParent()){
      auto pt=p->UhdmType();
      if(pt==uhdmcont_assign){role="cont_assign";break;}
      if(pt==uhdmparam_assign){role="param_assign";break;}
      if(pt==uhdmport){role="port";break;}
      if(pt==uhdmtypespec_member){role="member";break;}
      if(pt==uhdmassignment||pt==uhdmassign_stmt){role="assign_stmt";break;}
      if(pt==uhdmmodule_inst||pt==uhdminterface_inst||pt==uhdmpackage||pt==uhdmclass_defn) break;
    }
    std::string ts="-";
    if(const ref_typespec*rt=xe->Typespec()){
      const typespec*t=rt->Actual_typespec();
      ts = t? kn(t)+"("+nm(t)+")" : std::string("ref<null>");
    }
    if(isC)
      printf("C|%s|%s|%s|%s|%s|%s\tct=%d sz=%d dec=%s ts=%s\tVAL=%s\n",
             sp(bo).c_str(), owk.c_str(), sp(ow).c_str(), role.c_str(),
             homek.c_str(), home.c_str(),
             c->VpiConstType(), c->VpiSize(),
             std::string(c->VpiDecompile()).c_str(), ts.c_str(),
             std::string(c->VpiValue()).c_str());
    else
      // EVERY OTHER expr: the two fields expr::Compare reads besides the
      // typespec -- VpiDecompile and VpiSize.
      printf("E|%s|%s|%s|%s|%s|%s|%s\tdec=%s sz=%d ts=%s\t-\n",
             kn(bo).c_str(), sp(bo).c_str(), owk.c_str(), sp(ow).c_str(),
             role.c_str(), homek.c_str(), home.c_str(),
             std::string(xe->VpiDecompile()).c_str(), xe->VpiSize(),
             ts.c_str());
  }
  return 0;
}
