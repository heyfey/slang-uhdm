// vbuvm9 w7 — the PkgClassTs cell (the one the law REMOVES) pushed into every
// scope that can hold the ONLY reference: a module function, an interface
// function, a program, a qualified-only package, virtual / interface classes,
// and a specialization whose type argument is a package typedef.
package w7p;
  virtual class vc; pure virtual function void v(); endclass
  class dc extends vc; function void v(); endfunction endclass
  interface class ic; pure virtual function void i(); endclass
  class icimp implements ic; virtual function void i(); endfunction endclass
  class pcp #(type T = int); T a; endclass
  typedef struct { int a; } base_s;

  typedef dc     f1_t;   // ONLY reference: a MODULE function nested local
  typedef dc     f2_t;   // ONLY reference: an INTERFACE function nested local
  typedef dc     f3_t;   // ONLY reference: a module-scope VARIABLE
  typedef vc     f4_t;   // VIRTUAL class typedef, oob nested local
  typedef ic     f5_t;   // INTERFACE class typedef, oob nested local
  typedef pcp#(base_s) f6_t; // specialization over a PACKAGE typedef
  typedef dc     f7_t;   // ONLY reference: a PROGRAM's function nested local
  typedef dc     f8_t;   // qualified-only spelling from a second package

  class w7k;
    extern function void g4(int k);
    extern function void g5(int k);
    extern function void g6(int k);
  endclass
  function void w7k::g4(int k); if (k) begin f4_t v; v = null; end endfunction
  function void w7k::g5(int k); if (k) begin f5_t v; v = null; end endfunction
  function void w7k::g6(int k); if (k) begin f6_t v; v = null; end endfunction
endpackage

package w7q;
  class w7qk;
    extern function void h(int k);
  endclass
  function void w7qk::h(int k); if (k) begin w7p::f8_t v; v = null; end endfunction
endpackage

interface w7i;
  function void ifn(int k); if (k) begin w7p::f2_t v; v = null; end endfunction
endinterface

program w7pr;
  function void pfn(int k); if (k) begin w7p::f7_t v; v = null; end endfunction
  initial pfn(1);
endprogram

module w7m;
  import w7p::*;
  w7p::f3_t g_v3;
  function void mfn(int k); if (k) begin w7p::f1_t v; v = null; end endfunction
  initial mfn(1);
endmodule
