// r10uvm98 — MEASUREMENT-ONLY.  The CLASS-TYPESPEC BIND census.
//
// One row per site in the database whose typespec (through its ref_typespec)
// is a `class_typespec`, keyed on what `uhdm-cmp` can actually read:
//
//   SITE   the kind of the referring object (IODECL / VAR / PARAM / TPARAM /
//          MEMBER / RETURN / LISTING = an entry of a class_defn's Typespecs()
//          vector, i.e. the class's own vpiTypedef listing)
//   OWNER  the referring object's vpiFullName (synthesised from the parent
//          chain by the dump; used ONLY as a census key, never as evidence)
//   TSNAME the class_typespec's VpiName            <- READ by typespec::Compare
//   DEFN   the class_typespec's Class_defn fullname<- READ by class_typespec::Compare (last field)
//   ALIAS  1 when the class_typespec carries a Typedef_alias  <- READ
//   INST   the class_typespec's Instance name                  <- READ
//
// The value half is (TSNAME, DEFN, ALIAS, INST); the key half is (SITE, OWNER).
// Spans and files are NEVER keyed (no generated Compare reads them, and golden
// legitimately locates a shared typedef at a different declaration).
//
// build: g++ -O2 -std=c++17 ct98cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct98cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <algorithm>
#include <cstdlib>
using namespace UHDM;

static std::string fn(const BaseClass* p) {
  if (!p) return "-";
  vpiHandle h = NewVpiHandle(p);
  const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
  std::string r = s ? s : std::string();
  if (h) vpi_free_object(h);
  if (r.empty()) r = std::string(p->VpiName());
  return r.empty() ? "<anon>" : r;
}

// CEN98_ALL=1 widens the census from class_typespec-typed sites to EVERY
// typespec kind (needed for the grid: `typedef int my_t;` never produces a
// class_typespec, so the class-only census cannot see an inherited INT
// typedef name move).  DEFN is then `<kind>` for a non-class typespec.
static const bool kAll = getenv("CEN98_ALL") != nullptr;

static void emit(std::vector<std::string>& rows, const char* site,
                 const std::string& owner, const typespec* a) {
  if (!a) return;
  char b[2048];
  if (a->UhdmType() != uhdmclass_typespec) {
    if (!kAll) return;
    const ref_typespec* al = a->Typedef_alias();
    snprintf(b, sizeof b, "%s\t%s\t%s\t%s\t%d\t%s", site, owner.c_str(),
             std::string(a->VpiName()).c_str(),
             std::string(UhdmName(a->UhdmType())).c_str(), al ? 1 : 0,
             fn(a->Instance()).c_str());
    rows.push_back(b);
    return;
  }
  const class_typespec* ct = (const class_typespec*)a;
  const ref_typespec* al = ct->Typedef_alias();
  snprintf(b, sizeof b, "%s\t%s\t%s\t%s\t%d\t%s", site, owner.c_str(),
           std::string(ct->VpiName()).c_str(), fn(ct->Class_defn()).c_str(),
           al ? 1 : 0, fn(ct->Instance()).c_str());
  rows.push_back(b);
}

// An io_decl has no synthesised vpiFullName; key it on its OWNING task/func
// plus its own name, so the eight socket `provider` formals stay eight
// DISTINCT keys instead of collapsing into one.
static std::string owner_of(const BaseClass* o) {
  std::string f = fn(o);
  if (f == "-" || f == "<anon>" || f == std::string(o->VpiName())) {
    std::string pf = o->VpiParent() ? fn(o->VpiParent()) : std::string("-");
    return pf + "::" + std::string(o->VpiName());
  }
  return f;
}

int main(int argc, char** argv) {
  if (argc < 2) { printf("usage: ct98cen <db>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAILED\n"); return 3; }
  std::vector<std::string> rows;
  for (auto& p : s.AllObjects()) {
    const BaseClass* o = p.first;
    if (!o) continue;
    switch (o->UhdmType()) {
      case uhdmio_decl: {
        const io_decl* x = (const io_decl*)o;
        if (const ref_typespec* rt = x->Typespec())
          emit(rows, "IODECL", owner_of(o), rt->Actual_typespec());
        break;
      }
      case uhdmtypespec_member: {
        const typespec_member* x = (const typespec_member*)o;
        if (const ref_typespec* rt = x->Typespec())
          emit(rows, "MEMBER", owner_of(o), rt->Actual_typespec());
        break;
      }
      case uhdmparameter: {
        const parameter* x = (const parameter*)o;
        if (const ref_typespec* rt = x->Typespec())
          emit(rows, "PARAM", owner_of(o), rt->Actual_typespec());
        break;
      }
      case uhdmtype_parameter: {
        const type_parameter* x = (const type_parameter*)o;
        if (const ref_typespec* rt = x->Typespec())
          emit(rows, "TPARAM", owner_of(o), rt->Actual_typespec());
        break;
      }
      case uhdmclass_defn: {
        const class_defn* c = (const class_defn*)o;
        if (c->Typespecs())
          for (auto* t : *c->Typespecs()) emit(rows, "LISTING", fn(o), t);
        break;
      }
      case uhdmfunction: {
        const function* f = (const function*)o;
        if (const variables* rv = f->Return())
          if (const ref_typespec* rt = rv->Typespec())
            emit(rows, "RETURN", fn(o), rt->Actual_typespec());
        break;
      }
      default: {
        if (auto* v = any_cast<const variables*>(o))
          if (const ref_typespec* rt = v->Typespec())
            emit(rows, "VAR", owner_of(o), rt->Actual_typespec());
        break;
      }
    }
  }
  std::sort(rows.begin(), rows.end());
  for (auto& x : rows) printf("%s\n", x.c_str());
  return 0;
}
