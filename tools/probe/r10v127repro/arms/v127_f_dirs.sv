// r10v127 VERIFIER grid F — FORMAL DIRECTIONS (input/output/inout/ref/const ref)
// and CONTAINER typespecs (queue, dynamic array, associative array, unpacked
// array, class handle) inside the out-of-body window, plus THREE instances of
// the same module exercising them.  Container formals are not DPI-legal, so the
// callee is an SV function whose own body reaches a DPI import.
// MEASUREMENT ONLY.
package Hollowday;
  import "DPI-C" function int hdProbe(int mote);
  typedef int qint_t[$];
  typedef int dint_t[];
  typedef int aint_t[string];
  typedef int uint4_t[4];

  class Pintle;
    int pv = 1;
  endclass

  function automatic int qSink(qint_t qa);   return hdProbe(qa.size()); endfunction
  function automatic int dSink(dint_t da);   return hdProbe(da.size()); endfunction
  function automatic int aSink(aint_t aa);   return hdProbe(aa.size()); endfunction
  function automatic int uSink(uint4_t ua);  return hdProbe(ua[0]);     endfunction
  function automatic int hSink(Pintle ph);   return hdProbe(ph.pv);     endfunction
  function automatic int oSink(output int ov); ov = hdProbe(1); return ov; endfunction
  function automatic int ioSink(inout int iv); iv = hdProbe(iv); return iv; endfunction
  function automatic int rSink(ref int rv);    rv = hdProbe(rv); return rv; endfunction
  function automatic int crSink(const ref int cv); return hdProbe(cv);  endfunction

  class Ratline;
    qint_t  rq;
    dint_t  rd;
    aint_t  ra;
    Pintle  rh;
    int     rn = 3;
    extern function int useQ ();
    extern function int useD ();
    extern function int useA ();
    extern function int useH ();
    extern function int useOut ();
    extern function int useInout();
    extern function int useRef  ();
    extern function int useConstRef();
  endclass

  function int Ratline::useQ (); return qSink(rq);  endfunction
  function int Ratline::useD (); return dSink(rd);  endfunction
  function int Ratline::useA (); return aSink(ra);  endfunction
  function int Ratline::useH (); return hSink(rh);  endfunction
  function int Ratline::useOut ();
    int slot;
    return oSink(slot);
  endfunction
  function int Ratline::useInout();
    int slot = 2;
    return ioSink(slot);
  endfunction
  function int Ratline::useRef  ();
    int slot = 4;
    return rSink(slot);
  endfunction
  function int Ratline::useConstRef();
    int slot = 6;
    return crSink(slot);
  endfunction
endpackage

module Hollowday_leaf;
  import Hollowday::*;
  Ratline rl;
  int got;
  initial begin
    rl = new();
    got = rl.useQ() + rl.useRef();
  end
endmodule

module Hollowday_top;
  Hollowday_leaf inst1();
  Hollowday_leaf inst2();
  Hollowday_leaf inst3();
endmodule
