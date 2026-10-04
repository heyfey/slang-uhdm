// § topPkgTdInstanceTop231 — an interface importing the package
package p;
  typedef enum {A0, A1} a_e;
  typedef a_e b_t;
  class c;
    extern function void set(b_t v);
  endclass
  function void c::set(b_t v);
  endfunction
endpackage
interface ifc;
  import p::*;
  b_t s;
endinterface
module top;
  ifc u();
endmodule
