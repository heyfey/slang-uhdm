// § pkgRetCallPassArgShare457
package p;
  function logic [7:0] rep(logic [7:0] v); return v; endfunction
  function logic [7:0] f(logic [7:0] a);
    return -rep(a);
  endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  import p::*;
  always_comb o = f(i);
endmodule
