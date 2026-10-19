// § pkgRetBitSelParamFold407
package p;
  localparam bit [7:0] RB = 8'h6;
  function automatic logic f(logic [7:0] x);
    return !x[RB];
  endfunction
endpackage
module top(input logic [7:0] i, output logic o);
  assign o = p::f(i);
endmodule
