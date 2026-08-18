// r10uvm97 — MEASUREMENT-ONLY.  THE A-PRIORI MOVER PREDICTOR.
//
// Reads ONE of OUR PRISTINE databases and reports every class_typespec that
// carries the shape § classNestedTdOneObjectPerSurelogTypedef97 removes: a
// `Typedef_alias` whose `Actual_typespec` is ANOTHER class_typespec with the
// SAME VpiName, the SAME Class_defn and the SAME span — i.e. a clone of the
// very same written declaration, which Surelog compiles once and never
// aliases.  A genuine cross-class clone (§ classNestedClassTdGroupNoAnchor54)
// keeps its OWN typedef name and so never matches.
//
// The SAME-DECLARATION test is what separates it from the 53 legitimate
// `type_id` clones every UVM database carries (golden has them too): the alias
// ref's `VpiFullName` is `<the CLONE's declaring class>::<name>`, so a clone of
// the same declaration spells the BASE's own declaring class — read off the
// base's `VpiParent`, which is the `class_defn` that lists it.  Without this
// test the raw signature counts 54 on SimpleUVM against golden's 53 and the
// prediction drowns in noise.
//
// OVER-PREDICTION, stated up front: two DISTINCT classes that share a name and
// a typedef name (arm `g97_a5_samename.sv`: `dup97e::n97e` in two modules) also
// match and are NOT touched by the patch.  The predictor is an UPPER bound; no
// corpus database contains that shape.
//
// usage: pred97 <db.uhdm>      prints one line per hit + a COUNT line
// build: g++ -O2 -std=c++17 pred97.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred97
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;
static std::string fn(const BaseClass* p) {
  if (!p) return "-";
  vpiHandle h = NewVpiHandle(p);
  const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
  std::string r = s ? s : std::string(p->VpiName());
  if (h) vpi_free_object(h);
  if (r.empty()) r = std::string(p->VpiName());
  return r.empty() ? "<anon>" : r;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pred97 <db.uhdm>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAILED\n"); return 3; }
  std::vector<std::string> rows;
  for (auto& p : s.AllObjects()) {
    const BaseClass* o = p.first;
    if (!o || o->UhdmType() != uhdmclass_typespec) continue;
    auto* ts = (const class_typespec*)o;
    const ref_typespec* al = ts->Typedef_alias();
    if (!al) continue;
    const typespec* act = al->Actual_typespec();
    if (!act || act == ts || act->UhdmType() != uhdmclass_typespec) continue;
    if (ts->VpiName() != act->VpiName()) continue;
    if (((const class_typespec*)act)->Class_defn() != ts->Class_defn()) continue;
    if (ts->VpiLineNo() != act->VpiLineNo() ||
        ts->VpiColumnNo() != act->VpiColumnNo() ||
        ts->VpiEndLineNo() != act->VpiEndLineNo() ||
        ts->VpiEndColumnNo() != act->VpiEndColumnNo()) continue;
    // SAME DECLARATION: the alias ref names the CLONE's declaring class, and
    // the base's parent class_defn names the BASE's.  Equal => one declaration.
    const BaseClass* bp = act->VpiParent();
    if (!bp) continue;
    std::string owner = fn(bp);
    if (owner == "-" || owner.empty()) continue;
    // The typedef's BARE name: `UhdmWriter::writeDataTypes` stamps a
    // package prefix onto a typespec listed under a package, so `VpiName()`
    // reads `adpcm_pkg::this_type` on SeqDriver and plain `this_type` on
    // SimpleUVM.  Comparing the qualified spelling under-counted the mover set
    // by two databases before this line existed.
    std::string nm(ts->VpiName());
    size_t q = nm.rfind("::");
    if (q != std::string::npos) nm = nm.substr(q + 2);
    if (std::string(al->VpiFullName()) != owner + "::" + nm)
      continue;
    char b[512];
    snprintf(b, sizeof b, "  HIT name=%s defn=%s @%u:%u-%u:%u aliasfull=%s",
             std::string(ts->VpiName()).c_str(), fn(ts->Class_defn()).c_str(),
             ts->VpiLineNo(), ts->VpiColumnNo(), ts->VpiEndLineNo(),
             ts->VpiEndColumnNo(), std::string(al->VpiFullName()).c_str());
    rows.push_back(b);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  printf("COUNT %zu\n", rows.size());
  return 0;
}
