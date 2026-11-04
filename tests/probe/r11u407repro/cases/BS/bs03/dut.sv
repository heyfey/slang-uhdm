// § pkgRetBitSelParamFold407
package p;
  localparam int RB = 7;
  function automatic logic f(logic [7:0] x);
    return x[RB];
  endfunction
endpackage
module top(input logic [7:0] i, output logic o);
  assign o = p::f(i);
endmodule
