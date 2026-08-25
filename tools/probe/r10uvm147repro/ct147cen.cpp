// r10uvm147 — MEASUREMENT-ONLY.  The hier_path SELECT-ELEMENT SHAPE census.
//
// Walks EVERY object of ONE database once (Serializer::AllObjects) and emits
// ONE ROW PER hier_path whose element list carries at least one SELECT element
// (bit_select / part_select / indexed_part_select / var_select), keyed by the
// fields a golden row and an ours row can be joined on:
//
//   KEY   basename(VpiFile):line:col-endln:endcol "|" hier_path VpiName
//         (VpiName IS read by hier_path::Compare — a TEXT law; VpiFullName is
//          NOT read and is never in the key or the payload)
//   PAY   the ELEMENT SHAPE SIGNATURE: per element, its UHDM kind and its
//         VpiName, plus for each SELECT element the number of index STEPS it
//         carries and the KIND of each step object, and whether the element is
//         MID (further elements follow) or TRAILing.
//
// A step of a var_select is one entry of Exprs(); a bit_select has one step
// (VpiIndex); a part_select / indexed_part_select is itself one step object.
// TRAILSEL names the LAST select object of the whole element list — the
// "trailing select kind" axis of the census.
//
// usage: ct147cen <db.uhdm> [--sel|--all]
// build: g++ -O2 -std=c++17 ct147cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct147cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
using namespace UHDM;

static std::string kindName(const BaseClass* o) {
  if (!o) return "<null>";
  return std::string(UHDM::UhdmName(o->UhdmType()));
}
static std::string base(std::string_view p) {
  size_t i = p.find_last_of('/');
  return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string spanOf(const BaseClass* o) {
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return std::string(b);
}
static std::string fullOf(const BaseClass* o) {
  if (!o) return "<null>";
  vpiHandle h = NewVpiHandle(o);
  const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
  std::string r = s ? s : "";
  if (h) vpi_free_object(h);
  if (r.empty()) r = std::string(o->VpiName());
  if (r.empty()) r = "<anon>";
  return r;
}
static const BaseClass* ownerObj(const BaseClass* o) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 60 && p; i++) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst ||
        t == uhdmfunction || t == uhdmtask || t == uhdmgen_scope)
      return p;
    p = p->VpiParent();
  }
  return nullptr;
}
static std::string ownerStr(const BaseClass* o) {
  const BaseClass* p = ownerObj(o);
  if (!p) return "<unparented>";
  return kindName(p) + ":" + fullOf(p);
}
static bool isSel(const any* e) {
  if (!e) return false;
  UHDM_OBJECT_TYPE t = e->UhdmType();
  return t == uhdmbit_select || t == uhdmpart_select ||
         t == uhdmindexed_part_select || t == uhdmvar_select;
}
// The index STEP objects an element carries, in order.
static void stepsOf(const any* e, std::vector<const any*>& out) {
  if (auto* bs = any_cast<const bit_select*>(e)) { out.push_back(bs->VpiIndex()); return; }
  if (auto* vs = any_cast<const var_select*>(e)) {
    if (vs->Exprs()) for (auto* x : *vs->Exprs()) out.push_back(x);
    return; }
  // part_select / indexed_part_select ARE the step.
  out.push_back(e);
}
static int lvalFlag(const BaseClass* o) {
  const BaseClass* p = o->VpiParent();
  if (!p) return -1;
  if (auto* a = any_cast<const assignment*>((const any*)p))
    return a->Lhs() == (const any*)o ? 1 : 0;
  if (auto* a = any_cast<const assign_stmt*>((const any*)p))
    return a->Lhs() == (const any*)o ? 1 : 0;
  if (auto* a = any_cast<const cont_assign*>((const any*)p))
    return a->Lhs() == (const any*)o ? 1 : 0;
  return 2;
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct147cen <db.uhdm> [--sel|--all]\n"); return 2; }
  const std::string mode = argc > 2 ? argv[2] : "--sel";
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();

  long nPath = 0, nSelPath = 0;
  std::vector<std::string> rows;
  for (auto& pr : all) {
    const BaseClass* o = pr.first;
    if (!o || o->UhdmType() != uhdmhier_path) continue;
    auto* hp = (const hier_path*)o;
    nPath++;
    auto* elems = hp->Path_elems();
    size_t n = elems ? elems->size() : 0;
    bool anySel = false;
    for (size_t i = 0; i < n; i++) if (isSel(elems->at(i))) anySel = true;
    if (anySel) nSelPath++;
    if (mode == "--sel" && !anySel) continue;

    std::string name(hp->VpiName());
    std::string sig;            // element shape signature
    std::string trailSel = "-"; // kind of the LAST select object in the list
    long totSteps = 0;
    for (size_t i = 0; i < n; i++) {
      const any* e = elems->at(i);
      std::string en(e->VpiName());
      if (i) sig += ">";
      sig += kindName(e);
      sig += "/" + (en.empty() ? std::string("<anon>") : en);
      if (isSel(e)) {
        std::vector<const any*> st; stepsOf(e, st);
        totSteps += (long)st.size();
        sig += "{";
        for (size_t k = 0; k < st.size(); k++) {
          if (k) sig += ",";
          sig += kindName(st[k]);
        }
        sig += "}";
        sig += (i + 1 < n ? "@MID" : "@TRAIL");
        trailSel = kindName(e);
        // for a var_select the trailing kind of interest is its LAST step
        if (e->UhdmType() == uhdmvar_select && !st.empty() && isSel(st.back()))
          trailSel = kindName(e) + "<" + kindName(st.back()) + ">";
      }
    }
    char line[16384];
    snprintf(line, sizeof line,
             "%s:%s|%s\tNELEM=%zu\tNSTEP=%ld\tTRAILSEL=%s\tLVAL=%d\tSIG=%s\tSITE=%s",
             base(o->VpiFile()).c_str(), spanOf(o).c_str(), name.c_str(), n,
             totSteps, trailSel.c_str(), lvalFlag(o), sig.c_str(),
             ownerStr(o).c_str());
    rows.push_back(line);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- hier_path=%ld  with-select-elem=%ld  rows=%zu\n",
          nPath, nSelPath, rows.size());
  return 0;
}
