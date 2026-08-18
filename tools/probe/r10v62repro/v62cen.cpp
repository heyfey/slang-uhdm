// v62 VERIFIER — WHOLE-DATABASE reference-binding + typespec census, read
// straight from a .uhdm via Serializer::AllObjects().  Unlike cacen62 (which
// walks cont_assigns only) this reaches EVERY ref_obj/ref_var/variable/net in
// the database, including procedural statements, ports, params, initial/always
// blocks and task/function bodies -- the shapes the implementer's census could
// not see.  Payload is COMPARE-VISIBLE only (Actual kind + VpiName).
// MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string kn(const any* o){ return o? std::string(UhdmName(o->UhdmType())) : std::string("-"); }
static std::string nm(const any* o){ return o? std::string(o->VpiName()) : std::string(""); }
static std::string base(std::string_view f){ auto p=f.rfind('/'); return std::string(p==std::string_view::npos?f:f.substr(p+1)); }
int main(int argc,char**argv){
  if(argc<2){fprintf(stderr,"usage: v62cen <db.uhdm>\n");return 2;}
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if(restored.empty()){fprintf(stderr,"EMPTY\n");return 3;}
  for(const auto& [o,id] : s.AllObjects()){
    const any* a=(const any*)o;
    if(!a) continue;
    char loc[512];
    snprintf(loc,sizeof loc,"%s:%u:%u",base(a->VpiFile()).c_str(),a->VpiLineNo(),(unsigned)a->VpiColumnNo());
    switch(a->UhdmType()){
      case uhdmref_obj: printf("REF ref_obj %s %s -> %s(%s)\n",nm(a).c_str(),loc,
          kn(((const ref_obj*)a)->Actual_group()).c_str(),nm(((const ref_obj*)a)->Actual_group()).c_str()); break;
      case uhdmref_var: printf("REF ref_var %s %s -> %s(%s)\n",nm(a).c_str(),loc,
          kn(((const ref_var*)a)->Actual_group()).c_str(),nm(((const ref_var*)a)->Actual_group()).c_str()); break;
      case uhdmref_typespec: { auto* r=(const ref_typespec*)a;
          printf("RTS ref_typespec %s %s -> %s(%s)\n",nm(a).c_str(),loc,
            kn(r->Actual_typespec()).c_str(),nm(r->Actual_typespec()).c_str()); break; }
      default: break;
    }
    if(auto* v=any_cast<const variables*>(a)){
      auto* rt=v->Typespec();
      printf("VAR %s %s %s -> %s(%s)\n",kn(a).c_str(),nm(a).c_str(),loc,
        kn(rt?rt->Actual_typespec():nullptr).c_str(),nm(rt?rt->Actual_typespec():nullptr).c_str());
    } else if(auto* n=any_cast<const nets*>(a)){
      auto* rt=n->Typespec();
      printf("NET %s %s %s -> %s(%s)\n",kn(a).c_str(),nm(a).c_str(),loc,
        kn(rt?rt->Actual_typespec():nullptr).c_str(),nm(rt?rt->Actual_typespec():nullptr).c_str());
    }
  }
  return 0;
}
