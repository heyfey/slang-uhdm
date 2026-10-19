// § pkgRetBitSelParamFold407
package p;
  localparam int RB = 7;
  localparam logic [3:0] LB = 4'd2;
  function automatic logic f(logic [7:0] x);
    return x[RB] | x[LB] | x[RB-1];
  endfunction
endpackage
module top(input logic [7:0] i, output logic o);
  assign o = p::f(i);
endmodule
