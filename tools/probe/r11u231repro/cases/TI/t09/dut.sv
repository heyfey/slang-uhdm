// § topPkgTdInstanceTop231 — a package parameter of the alias type beside the extern method
package p;
  typedef enum logic [1:0] {A0, A1, A2} a_e;
  typedef a_e b_t;
  parameter b_t DEF = A2;
  class c;
    extern function void set(b_t v = DEF);
  endclass
  function void c::set(b_t v = DEF);
  endfunction
endpackage
module top;
  import p::*;
  logic [1:0] o;
  assign o = DEF;
endmodule
