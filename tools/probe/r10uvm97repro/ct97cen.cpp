// r10uvm97 — MEASUREMENT-ONLY.  THE CLASS-NESTED TYPEDEF census.
//
// One row per typespec listed in a `class_defn`'s `Typespecs()` vector (the
// class's vpiTypedef listing), plus one row per class_typespec anywhere in the
// database that carries a `Typedef_alias` (so an alias we mint OUTSIDE a
// listing cannot hide).  The question this answers is the one uvm96 handed
// over as R0: for `typedef uvm_port_base #(IF) this_type;` inside
// `class uvm_port_base`, does golden give the listed class_typespec a
// `Typedef_alias` (a ref_typespec) or leave that singular slot EMPTY?
//
// row: SITE \t VIEW \t OWNER \t NAME \t KIND \t SPAN \t ALIAS \t TARGET \t INST \t ID
//
//   SITE    LISTING (in a class_defn's Typespecs) or ALIASED (any other
//           class_typespec that carries a Typedef_alias)
//   VIEW    the outermost named ancestor: package:<name> / module:<name> /
//           <root> — DEF listings hang off the package, ELAB copies off the
//           instance tree.
//   OWNER   the enclosing class_defn's vpiFullName
//   NAME    the typespec's VpiName (the TYPEDEF's name, per
//           ElaborationStep::bindTypedefs_'s `ts->VpiName(typd->getName())`)
//   KIND    the typespec's UHDM kind
//   SPAN    line:col-endline:endcol (no file: our objects carry an EMPTY
//           VpiFile and the nearest file-bearing ancestor differs per side)
//   ALIAS   `-` when Typedef_alias() is null, else
//           `<refname>-><actual kind>(<actual name>)@<actual span>`
//   TARGET  for a class_typespec: the Class_defn's vpiFullName (`-` when the
//           link is absent); for anything else `-`
//   INST    the Instance()'s name, `-` when absent
//   ID      the object's UhdmId — a READING column only (ids differ per
//           side and per run; never key a join on it)
//
// usage: ct97cen <db.uhdm>
// build: g++ -O2 -std=c++17 ct97cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct97cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
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
static std::string fullName(const BaseClass* p) {
  if (!p) return "-";
  vpiHandle h = NewVpiHandle(p);
  const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
  std::string r = s ? s : std::string(p->VpiName());
  if (h) vpi_free_object(h);
  if (r.empty()) r = std::string(p->VpiName());
  return r.empty() ? "<anon>" : r;
}
static std::string spanOf(const BaseClass* o) {
  if (!o) return "-";
  char b[128];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
// The outermost NAMED ancestor: tells DEF (package/root listing) from ELAB
// (under a module_inst).  Purely a reading/grouping column.
static std::string viewOf(const BaseClass* o) {
  std::string last = "<root>";
  for (int i = 0; i < 400 && o; i++) {
    UHDM_OBJECT_TYPE t = o->UhdmType();
    if (t == uhdmpackage) last = "package:" + std::string(o->VpiName());
    else if (t == uhdmmodule_inst) last = "module:" + std::string(o->VpiName());
    else if (t == uhdmdesign) break;
    o = o->VpiParent();
  }
  return last;
}
static std::string aliasOf(const typespec* ts) {
  const ref_typespec* a = ts->Typedef_alias();
  if (!a) return "-";
  const typespec* act = a->Actual_typespec();
  std::string rn(a->VpiName());
  if (rn.empty()) rn = "<empty>";
  return rn + "->" + kindName(act) + "(" +
         (act ? std::string(act->VpiName()) : std::string("-")) + ")@" +
         spanOf(act) + "#" + (act ? std::to_string(act->UhdmId()) : std::string("-"));
}
static std::string targetOf(const typespec* ts) {
  if (ts->UhdmType() != uhdmclass_typespec) return "-";
  const class_defn* cd = ((const class_typespec*)ts)->Class_defn();
  return cd ? fullName(cd) : "-";
}
static std::string instOf(const typespec* ts) {
  const instance* in = ts->Instance();
  return in ? std::string(in->VpiName()) : std::string("-");
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct97cen <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  std::vector<std::string> rows;
  std::set<const BaseClass*> listed;
  size_t nlist = 0, nalias = 0;
  for (auto& pr : all) {
    const BaseClass* o = pr.first;
    if (!o || o->UhdmType() != uhdmclass_defn) continue;
    auto* cd = (const class_defn*)o;
    if (!cd->Typespecs()) continue;
    for (auto* ts : *cd->Typespecs()) {
      if (!ts) continue;
      listed.insert(ts);
      nlist++;
      std::string nm(ts->VpiName());
      if (nm.empty()) nm = "<empty>";
      rows.push_back("LISTING\t" + viewOf(cd) + "\t" + fullName(cd) + "\t" +
                     nm + "\t" + kindName(ts) + "\t" + spanOf(ts) + "\t" +
                     aliasOf(ts) + "\t" + targetOf(ts) + "\t" + instOf(ts) +
                     "\t" + std::to_string(ts->UhdmId()));
    }
  }
  for (auto& pr : all) {
    const BaseClass* o = pr.first;
    if (!o || o->UhdmType() != uhdmclass_typespec) continue;
    if (listed.count(o)) continue;
    auto* ts = (const class_typespec*)o;
    if (!ts->Typedef_alias()) continue;
    nalias++;
    std::string nm(ts->VpiName());
    if (nm.empty()) nm = "<empty>";
    rows.push_back("ALIASED\t" + viewOf(ts) + "\t" + fullName(ts->VpiParent()) +
                   "\t" + nm + "\t" + kindName(ts) + "\t" + spanOf(ts) + "\t" +
                   aliasOf(ts) + "\t" + targetOf(ts) + "\t" + instOf(ts));
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  fprintf(stderr, "LISTING %zu  ALIASED-OUTSIDE %zu\n", nlist, nalias);
  return 0;
}
