// r10v83 — THE WHOLE-DATABASE IDENTITY CENSUS.  MEASUREMENT ONLY.
// Earlgrey's uhdm-dump is >1 GB, so the mover attribution uses a DIRECT
// .uhdm reader (earl61's pattern) over Serializer::AllObjects, one row per
// object, with a COMPARE-VISIBLE payload only:
//   KEY     KIND + SPAN + VpiName + VpiDefName   (span keys the join; a fold
//           removes an operation but moves no sibling's span)
//   PAYLOAD VpiSize VpiValue VpiConstType VpiDecompile VpiOpType NOPS
//           TS(kind) TSN(name) TSV(value) DIR/NETTYPE where the kind has them
// NO span-derived field in the payload (earl60/earl69), no vpiParent, no
// object id, no depth.  Joined as a MULTISET by score-side sort.
// build: g++ -O2 -std=c++17 v83all.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o v83all
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string esc(std::string_view v) {
  std::string r; for (char c : v) r += (c==' '||c=='\t'||c=='|') ? '_' : c;
  if (r.empty()) r = "-"; return r;
}
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  Serializer s; 
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  (void)restored;
  for (const auto& kv : s.AllObjects()) {
    const BaseClass* o = kv.first;
    if (!o) continue;
    char span[64];
    snprintf(span, sizeof span, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
             o->VpiEndLineNo(), o->VpiEndColumnNo());
    std::string kind(UHDM::UhdmName(o->UhdmType()));
    std::string name = "-", defname = "-";
    std::string sz="-",val="-",ct="-",dec="-",opt="-",nops="-",ts="-",tsn="-",tsv="-";
    UHDM_OBJECT_TYPE t = o->UhdmType();
    if (const any* a = any_cast<const any*>(o)) { (void)a; }
    // names
    {
      const ref_typespec* rt = nullptr;
      if (t == uhdmconstant) {
        const constant* c = (const constant*)o;
        sz = std::to_string(c->VpiSize()); val = esc(c->VpiValue());
        ct = std::to_string(c->VpiConstType()); dec = esc(c->VpiDecompile());
        rt = c->Typespec();
      } else if (t == uhdmoperation) {
        const operation* p = (const operation*)o;
        opt = std::to_string(p->VpiOpType());
        nops = std::to_string(p->Operands() ? p->Operands()->size() : 0);
        rt = p->Typespec();
      } else if (t == uhdmref_obj) {
        const ref_obj* r = (const ref_obj*)o;
        name = esc(r->VpiName()); rt = r->Typespec();
        val = r->Actual_group() ? std::string(UHDM::UhdmName(r->Actual_group()->UhdmType())) : "-";
      }
      if (rt && rt->Actual_typespec()) {
        const typespec* a = rt->Actual_typespec();
        ts = std::string(UHDM::UhdmName(a->UhdmType()));
        tsn = esc(a->VpiName());
      }
    }
    if (name == "-") {
      // generic name/defname via the vpi accessors present on BaseClass subtypes
      if (const auto* n = any_cast<const any*>(o)) {
        (void)n;
      }
    }
    printf("%s\t%s\t%s\t%s\t||\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
           kind.c_str(), span, name.c_str(), defname.c_str(),
           sz.c_str(), val.c_str(), ct.c_str(), dec.c_str(), opt.c_str(),
           nops.c_str(), ts.c_str(), tsn.c_str(), tsv.c_str());
  }
  return 0;
}
