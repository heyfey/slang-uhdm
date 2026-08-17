// r10uvm85 — MEASUREMENT-ONLY.  The § thisStmtHandleCall85 census.
//
// Counts, over EVERY object of ONE database (Serializer::AllObjects, so each
// object is counted ONCE — uhdm-dump reprints an object at every reference),
// the populations this pass is about:
//
//   GHEAD    a `method_func_call` named EXACTLY "this" or "super" whose
//            vpiPrefix is a STRING `constant` whose decompile is one of
//            this / super / this.super.  This is Surelog's
//            paConstant_bit_select arm (CompileExpression.cpp:5227) — the
//            STATEMENT-position `this.<member>.<method>(args)` object.  GOLDEN
//            has these; a PRISTINE build of ours has NONE.
//   OHEAD    a `method_func_call` whose vpiPrefix is a `ref_obj` NAMED
//            this / super: the shape our PRISTINE emitter puts in that place
//            (named after the MEMBER, prefix an unbound — and in a hoisting
//            module MIS-BOUND — reference).  This is the PREDICTOR: OHEAD>0 on
//            a pristine database predicts a byte MOVER, OHEAD==0 predicts
//            byte-identity.
//   GARGS    / OARGS  the vpiArgument counts of those two populations, because
//            the DROPPED ARGUMENT is one of the four defects and the arity rule
//            (args survive only ONE name below the handle) is only visible here.
//   THISKW   a `constant` with decompile this/super/this.super AND a nonzero
//            size AND vpiConstType==vpiStringConst(6): the handle compiled as a
//            primary.  GHEAD's prefixes are a SUBSET of it, so this population
//            must grow by EXACTLY the number of converted calls — the bijection
//            uvm84 left open as its THISKW deficit.
//   MOCKUP   a `constant` carrying ONLY VpiDecompile "this" (uvm84's
//            § thisDeepStepMockupConst84 object, EXPRESSION position).  The
//            CONTROL population of this pass: it must not move.
//   THISNET  a `logic_net` NAMED "this" — the phantom net a hoisting module
//            mints for the pristine ref_obj prefix.  Golden has none.
//
// usage: ct85cen <db.uhdm> [--list]
// build: g++ -O2 -std=c++17 ct85cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct85cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
using namespace UHDM;
static bool isHandleText(const std::string& d) {
  return d == "this" || d == "super" || d == "this.super";
}
int main(int argc, char** argv) {
  if (argc < 2) { printf("usage: ct85cen <db.uhdm> [--list]\n"); return 2; }
  bool list = false;
  for (int i = 2; i < argc; i++) if (!strcmp(argv[i], "--list")) list = true;
  Serializer s; s.Restore(std::string(argv[1]));
  auto all = s.AllObjects();
  size_t objs = 0, ghead = 0, ohead = 0, gargs = 0, oargs = 0;
  size_t thiskw = 0, mockup = 0, thisnet = 0;
  for (auto& kv : all) {
    const BaseClass* o = (const BaseClass*)kv.first;
    if (!o) continue;
    objs++;
    if (o->UhdmType() == uhdmconstant) {
      const constant* c = (const constant*)o;
      std::string dc(c->VpiDecompile());
      if (dc == "this" && c->VpiSize() == 0 && c->VpiConstType() == 0 &&
          !c->Typespec()) {
        mockup++;
      } else if (isHandleText(dc) && c->VpiConstType() == vpiStringConst &&
                 c->VpiSize() > 0) {
        thiskw++;
      }
      continue;
    }
    if (o->UhdmType() == uhdmlogic_net) {
      if (std::string(((const logic_net*)o)->VpiName()) == "this") {
        thisnet++;
        if (list) printf("THISNET\t%u:%u-%u:%u\t%s\n",
                         ((const logic_net*)o)->VpiLineNo(),
                         (unsigned)((const logic_net*)o)->VpiColumnNo(),
                         ((const logic_net*)o)->VpiEndLineNo(),
                         (unsigned)((const logic_net*)o)->VpiEndColumnNo(),
                         std::string(((const logic_net*)o)->VpiFullName()).c_str());
      }
      continue;
    }
    if (o->UhdmType() != uhdmmethod_func_call) continue;
    const method_func_call* m = (const method_func_call*)o;
    std::string nm(m->VpiName());
    const any* pfx = m->Prefix();
    size_t na = m->Tf_call_args() ? m->Tf_call_args()->size() : 0;
    if (pfx && pfx->UhdmType() == uhdmconstant) {
      std::string pd(((const constant*)pfx)->VpiDecompile());
      if ((nm == "this" || nm == "super") && isHandleText(pd)) {
        ghead++; gargs += na;
        if (list) printf("GHEAD\t%u:%u-%u:%u\tname=%s\tprefix=%s\targs=%zu\t%s\n",
                         m->VpiLineNo(), (unsigned)m->VpiColumnNo(),
                         m->VpiEndLineNo(), (unsigned)m->VpiEndColumnNo(),
                         nm.c_str(), pd.c_str(), na,
                         std::string(m->VpiFile()).c_str());
      }
    } else if (pfx && pfx->UhdmType() == uhdmref_obj) {
      std::string pn(((const ref_obj*)pfx)->VpiName());
      if (pn == "this" || pn == "super") {
        ohead++; oargs += na;
        if (list) printf("OHEAD\t%u:%u-%u:%u\tname=%s\tprefix=%s\targs=%zu\t%s\n",
                         m->VpiLineNo(), (unsigned)m->VpiColumnNo(),
                         m->VpiEndLineNo(), (unsigned)m->VpiEndColumnNo(),
                         nm.c_str(), pn.c_str(), na,
                         std::string(m->VpiFile()).c_str());
      }
    }
  }
  printf("OBJS %zu GHEAD %zu GARGS %zu OHEAD %zu OARGS %zu THISKW %zu "
         "MOCKUP %zu THISNET %zu PRED %zu %s\n",
         objs, ghead, gargs, ohead, oargs, thiskw, mockup, thisnet, ohead,
         argv[1]);
  return 0;
}
