// § topPkgTdInstanceTop231 — a module importing the package declares a variable of the alias
package p;
  typedef enum {A0, A1} a_e;
  typedef a_e b_t;
  class c;
    extern function void set(b_t v);
  endclass
  function void c::set(b_t v);
  endfunction
endpackage
module top(input logic clk);
  import p::*;
  b_t s;
  a_e r;
  always_ff @(posedge clk) s <= A1;
endmodule
