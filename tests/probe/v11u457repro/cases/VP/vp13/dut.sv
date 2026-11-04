// § pkgRetCallPassArgShare457
package p;
  function logic [7:0] rep(logic [7:0] v); return v; endfunction
  function logic [3:0] f(logic [3:0] a);
    return rep(a);
  endfunction
endpackage
module top;
  import p::*;
  logic [3:0] x;
  initial x = f(4'h2);
endmodule
