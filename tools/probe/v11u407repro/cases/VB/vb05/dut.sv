// § pkgRetBitSelParamFold407
package q;
  localparam int RB = 4;
endpackage
package p;
  import q::*;
  localparam int RC = 1;
  function automatic logic f(logic [7:0] x);
    return x[RB] | x[RC];
  endfunction
endpackage
module top(input logic [7:0] i, output logic o);
  assign o = p::f(i);
endmodule
