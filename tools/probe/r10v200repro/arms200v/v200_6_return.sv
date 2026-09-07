// r10v200 break arm 6 — the RETURN exemption under stress: a return-only
// range, a return plus formals, an out-of-body method's return, a task (no
// return), and a function whose return type is a typedef.
package pv6;
  parameter W6 = 10;
  typedef logic [W6:0] t6_t;
  function logic [W6:0] r1();
    r1 = '0;
  endfunction
  function logic [W6:0] r2(input logic [W6:0] a);
    logic [W6:0] l6; l6 = a; r2 = l6;
  endfunction
  function t6_t r3(input t6_t a);
    r3 = a;
  endfunction
  class C6;
    extern function logic [W6:0] r4(input logic [W6:0] a);
  endclass
  function logic [W6:0] C6::r4(input logic [W6:0] a);
    logic [W6:0] l64; l64 = a; r4 = l64;
  endfunction
endpackage

package pv6imp;
  import pv6::*;
endpackage

module topv6;
  import pv6::*;
  initial $display(W6);
endmodule
