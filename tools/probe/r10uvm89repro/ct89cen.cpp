// r10uvm89 — MEASUREMENT-ONLY.  The hier_path NAME-TEXT census.
//
// Walks EVERY object of ONE database exactly once (Serializer::AllObjects) and
// emits ONE ROW PER hier_path (and, in --sel mode, per bit_select/part_select/
// indexed_part_select/var_select PATH ELEMENT), keyed by the fields
// `hier_path::Compare` actually reads -- VpiName (this head IS a name-text
// fact) -- plus the position that lets a golden row join an ours row.
//
//   FILE:SPAN   basename(VpiFile):line:col-endln:endcol   (the JOIN key)
//   NAME        vpiName of the hier_path                  (CMP-JUDGED)
//   NELEM       Path_elems size
//   ELEMS       kind[/name] of each path element, '>'-joined
//   IDXK        for every element that carries an index: the INDEX OBJECT's
//               UHDM kind, and whether the element is MID (followed by further
//               elements) or TRAILING, and the bracket text the NAME carries
//               for that element
//   SITE        nearest enclosing named container, kind:fullname
//   LVAL        1 when the hier_path is the vpiLhs of an assignment /
//               assign_stmt / cont_assign (walk one parent up)
//
// modes:
//   --paths     every hier_path row
//   --brk       only hier_paths whose NAME contains '['   <- the F1 population
//   --idx       one row per INDEX-CARRYING path element (the index-kind grid)
//
// usage: ct89cen <db.uhdm> [--paths|--brk|--idx]
// build: g++ -O2 -std=c++17 ct89cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct89cen
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
// The index expression(s) an element carries, in name order.
static void indicesOf(const any* e, std::vector<const any*>& out) {
  if (auto* bs = any_cast<const bit_select*>(e)) { out.push_back(bs->VpiIndex()); return; }
  if (auto* ps = any_cast<const part_select*>(e)) {
    out.push_back(ps->Left_range()); out.push_back(ps->Right_range()); return; }
  if (auto* ip = any_cast<const indexed_part_select*>(e)) {
    out.push_back(ip->Base_expr()); out.push_back(ip->Width_expr()); return; }
  if (auto* vs = any_cast<const var_select*>(e)) {
    if (vs->Exprs()) for (auto* x : *vs->Exprs()) out.push_back(x);
    return; }
}
// The bracket text this element's name contributes, recovered from the PATH
// NAME by scanning for the element's own name followed by '[' groups.  Purely
// textual, so it reports what the DATABASE says, not what a rule would say.
static std::string brkTextFor(const std::string& pathName, const std::string& elemName,
                              size_t& from) {
  if (elemName.empty()) return "?";
  size_t p = pathName.find(elemName, from);
  if (p == std::string::npos) return "?";
  size_t q = p + elemName.size();
  from = q;
  std::string r;
  while (q < pathName.size() && pathName[q] == '[') {
    int d = 0; size_t st = q;
    while (q < pathName.size()) { if (pathName[q]=='[') d++; else if (pathName[q]==']') { d--; if(!d){q++;break;} } q++; }
    r += pathName.substr(st, q - st);
  }
  from = q;
  return r.empty() ? "-" : r;
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
  return 2;  // some other parent kind
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct89cen <db.uhdm> [--paths|--brk|--idx]\n"); return 2; }
  const std::string mode = argc > 2 ? argv[2] : "--brk";
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();

  long nPath = 0, nBrk = 0;
  std::vector<std::string> rows;
  for (auto& pr : all) {
    const BaseClass* o = pr.first;
    if (!o || o->UhdmType() != uhdmhier_path) continue;
    auto* hp = (const hier_path*)o;
    nPath++;
    std::string name(hp->VpiName());
    bool brk = name.find('[') != std::string::npos;
    if (brk) nBrk++;
    if (mode == "--brk" && !brk) continue;
    auto* elems = hp->Path_elems();
    size_t n = elems ? elems->size() : 0;
    std::string es, idxs;
    size_t from = 0;
    for (size_t i = 0; i < n; i++) {
      const any* e = elems->at(i);
      std::string en(e->VpiName());
      if (i) es += ">";
      es += kindName(e) + (en.empty() ? "" : "/" + en);
      std::vector<const any*> ix; indicesOf(e, ix);
      if (!ix.empty()) {
        std::string bt = brkTextFor(name, en, from);
        std::string ks;
        for (size_t k = 0; k < ix.size(); k++) { if (k) ks += ","; ks += kindName(ix[k]); }
        if (!idxs.empty()) idxs += ";";
        idxs += (i + 1 < n ? "MID:" : "TRAIL:") + kindName(e) + ":IDX=" + ks +
                ":BRK=" + bt;
      } else {
        from = 0;  // reset: a bare element name may repeat
      }
    }
    if (mode == "--idx" && idxs.empty()) continue;
    char line[8192];
    snprintf(line, sizeof line,
             "%s|%s\tNAME=%s\tNELEM=%zu\tLVAL=%d\tIDXK=%s\tELEMS=%s\tSITE=%s",
             base(o->VpiFile()).c_str(), spanOf(o).c_str(), name.c_str(), n,
             lvalFlag(o), idxs.empty() ? "-" : idxs.c_str(), es.c_str(),
             ownerStr(o).c_str());
    rows.push_back(line);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& l : rows) printf("%s\n", l.c_str());
  fprintf(stderr, "-- hier_path=%ld  name-has-bracket=%ld  rows=%zu\n",
          nPath, nBrk, rows.size());
  return 0;
}
