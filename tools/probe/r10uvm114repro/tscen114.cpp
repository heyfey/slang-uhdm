// r10uvm114 — TYPESPEC RANGE-BOUND CENSUS.
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// Every `range` the UhdmListener reaches is printed as ONE ROW PER SIDE
// (L and R) with:
//   OWNER   = the range's vpiParent kind + VpiName (the typespec fullname)
//   CHAIN   = the vpiParent chain above the owner (kinds + names, NO span)
//   OSPAN   = the OWNER's own span  (line:col-line:col)
//   RSPAN   = the RANGE's own span
//   SIDE    = L | R
//   SHAPE   = the bound's rendered shape (Compare-visible fields only)
//   BSPAN   = the bound object's own span
// Spans are printed but the join key is chosen by the scorer, not here.
//
//   build: g++ -O2 -std=c++17 tscen114.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o tscen114
//   usage: tscen114 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string spanOf(const any* o) {
  if (!o) return "-";
  char b[80];
  snprintf(b, sizeof b, "%u:%hu-%u:%hu", (unsigned)o->VpiLineNo(),
           o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 40 && p; i++) {
    std::string e(UhdmName(p->UhdmType()));
    if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  if (r.empty()) r = "-";
  return r;
}
// The bound's shape: constants rendered with every Compare-visible field,
// operations rendered with their opType and their operands' shapes.
static void shape(const any* e, int depth, std::string& out) {
  if (!e) { out += "<null>"; return; }
  if (depth > 6) { out += "..."; return; }
  char b[400];
  switch (e->UhdmType()) {
    case uhdmconstant: {
      auto* c = (const constant*)e;
      snprintf(b, sizeof b, "C{ct=%d,sz=%d,v=%s,d=%s}", c->VpiConstType(),
               c->VpiSize(), esc(c->VpiValue()).c_str(),
               esc(c->VpiDecompile()).c_str());
      out += b;
      return;
    }
    case uhdmoperation: {
      auto* op = (const operation*)e;
      snprintf(b, sizeof b, "OP%d(", op->VpiOpType());
      out += b;
      if (op->Operands()) {
        int i = 0;
        for (auto* o : *op->Operands()) {
          if (i++) out += ",";
          shape(o, depth + 1, out);
        }
      }
      out += ")";
      return;
    }
    case uhdmref_obj: {
      snprintf(b, sizeof b, "REF{%s}", esc(e->VpiName()).c_str());
      out += b;
      return;
    }
    default: {
      snprintf(b, sizeof b, "%s{%s}",
               std::string(UhdmName(e->UhdmType())).c_str(),
               esc(e->VpiName()).c_str());
      out += b;
      return;
    }
  }
}
struct Cen : public UhdmListener {
  std::string pathOf() {
    std::string r;
    for (const any* p : getCallstack()) {
      std::string e(UhdmName(p->UhdmType()));
      if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
      r = r.empty() ? e : (r + "/" + e);
    }
    if (r.empty()) r = "-";
    return r;
  }
  void enterRange(const range* const r) final {
    std::string pth = pathOf();
    const any* ow = r->VpiParent();
    std::string ok = ow ? std::string(UhdmName(ow->UhdmType())) : std::string("-");
    std::string on = ow ? esc(ow->VpiName()) : std::string("-");
    std::string ch = chainOf(ow);
    for (int side = 0; side < 2; side++) {
      const expr* b = side ? r->Right_expr() : r->Left_expr();
      std::string sh;
      shape(b, 0, sh);
      printf("TS %s %s OSPAN=%s RSPAN=%s SIDE=%c BSPAN=%s SH=%s OID=%u RID=%u BID=%u PATH=%s CH=%s\n",
             ok.c_str(), on.c_str(), spanOf(ow).c_str(), spanOf(r).c_str(),
             side ? 'R' : 'L', spanOf(b).c_str(), sh.c_str(),
             ow ? (unsigned)ow->UhdmId() : 0u, (unsigned)r->UhdmId(),
             b ? (unsigned)b->UhdmId() : 0u, pth.c_str(), ch.c_str());
    }
  }
};
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: tscen114 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  Cen c;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) c.listenDesign(d);
  }
  return 0;
}
