// r10uvm84 — MEASUREMENT-ONLY.  The § thisDeepStepMockupConst84 census.
//
// Counts, over EVERY object of ONE database (Serializer::AllObjects, so each
// object is counted ONCE — a uhdm-dump reprints an object at every reference),
// the three populations this pass is about:
//
//   MOCKUP   a `constant` carrying ONLY VpiDecompile=="this": no value, no
//            size, no const type, no typespec.  This is Surelog's
//            CompileExpression.cpp:5250 "TODO: this is a mockup" object — the
//            whole EXPRESSION-position `this.<step>.<more>` chain reduced to
//            one field.  GOLDEN has these; a pristine build of ours has NONE.
//   THISKW   a `constant` with decompile "this" AND size 4 AND
//            vpiConstType==vpiStringConst (6): the ORDINARY `paThis_keyword`
//            primary (the vpiPrefix of a statement-position `this.q.m()`).
//            The CONTROL population — it must not move.
//   CAND     a `hier_path` whose VpiName is `this…`/`super…` with TWO OR MORE
//            dots: the shape OUR pristine emitter puts where golden puts a
//            MOCKUP.  (A one-dot `this.n` is golden's shape too and is NOT a
//            candidate.)
//
//   PRED     the MOVER PREDICTOR, run on PRISTINE databases only: a CAND whose
//            NAME passes the SHIPPED predicate — root `this`/`super`/`this.super`,
//            then a PLAIN-IDENTIFIER first step, then a `.`.  This is the same
//            rule ExprEmit.cpp's `thisDeepStepMockup84` applies to the WRITTEN
//            text, and our hier_path NAME *is* that written chain with the
//            indices erased, so `this.q[i].len` (a CAND golden also spells as a
//            hier_path) fails it while `this.h.arr` passes.  PRED>0 predicts a
//            byte MOVER; PRED==0 predicts byte-identity.
//
// usage: ct84cen <db.uhdm> [--list]
// build: g++ -O2 -std=c++17 ct84cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct84cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  if (argc < 2) { printf("usage: ct84cen <db.uhdm> [--list]\n"); return 2; }
  bool list = false;
  for (int i = 2; i < argc; i++) if (!strcmp(argv[i], "--list")) list = true;
  Serializer s; s.Restore(std::string(argv[1]));
  auto all = s.AllObjects();
  size_t objs = 0, mock = 0, thiskw = 0, cand = 0, hp = 0, konst = 0, pred = 0;
  auto predicate = [](const std::string& w) {
    size_t p = 0;
    if (w.rfind("this.super.", 0) == 0) p = 11;
    else if (w.rfind("this.", 0) == 0) p = 5;
    else if (w.rfind("super.", 0) == 0) p = 6;
    else return false;
    size_t q = p;
    while (q < w.size() && (isalnum((unsigned char)w[q]) || w[q] == '_' || w[q] == '$')) q++;
    if (q == p) return false;
    return q < w.size() && w[q] == '.';
  };
  for (auto& kv : all) {
    const BaseClass* o = (const BaseClass*)kv.first;
    if (!o) continue;
    objs++;
    if (o->UhdmType() == uhdmconstant) {
      const constant* c = (const constant*)o;
      konst++;
      std::string dc(c->VpiDecompile());
      if (dc == "this") {
        if (c->VpiSize() == 0 && c->VpiConstType() == 0 && !c->Typespec()) {
          mock++;
          if (list) printf("MOCKUP\t%u:%u-%u:%u\tid%u\t%s\n", c->VpiLineNo(),
                           (unsigned)c->VpiColumnNo(), c->VpiEndLineNo(),
                           (unsigned)c->VpiEndColumnNo(), c->UhdmId(),
                           std::string(c->VpiFile()).c_str());
        } else {
          thiskw++;
          if (list) printf("THISKW\t%u:%u-%u:%u\tsize=%d ct=%d\n", c->VpiLineNo(),
                           (unsigned)c->VpiColumnNo(), c->VpiEndLineNo(),
                           (unsigned)c->VpiEndColumnNo(), c->VpiSize(),
                           c->VpiConstType());
        }
      }
    } else if (o->UhdmType() == uhdmhier_path) {
      hp++;
      std::string n(o->VpiName());
      bool rooted = n.rfind("this.", 0) == 0 || n.rfind("super.", 0) == 0;
      size_t dots = 0;
      for (char ch : n) if (ch == '.') dots++;
      if (predicate(n)) {
        pred++;
        if (list) printf("PRED\t%u:%u-%u:%u\t%s\n", o->VpiLineNo(),
                         (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
                         (unsigned)o->VpiEndColumnNo(), n.c_str());
      }
      if (rooted && dots >= 2) {
        cand++;
        if (list) printf("CAND\t%u:%u-%u:%u\t%s\t%s\n", o->VpiLineNo(),
                         (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
                         (unsigned)o->VpiEndColumnNo(), n.c_str(),
                         std::string(o->VpiFile()).c_str());
      }
    }
  }
  printf("CENSUS\t%s\tOBJS=%zu\tCONSTANTS=%zu\tHIERPATHS=%zu\tMOCKUP=%zu\tTHISKW=%zu\tCAND=%zu\tPRED=%zu\n",
         argv[1], objs, konst, hp, mock, thiskw, cand, pred);
  return 0;
}
