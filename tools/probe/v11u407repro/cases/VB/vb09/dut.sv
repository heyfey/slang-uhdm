// § pkgRetBitSelParamFold407
package p;
  parameter int RB = 6;
  localparam int RC = RB - 1;
  function automatic logic f(logic [7:0] x);
    return x[RB] && !x[RC];
  endfunction
endpackage
module top(input logic [7:0] i, output logic o);
  assign o = p::f(i);
endmodule
