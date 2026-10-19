// § pkgRetBitSelParamFold407
package p;
  parameter int RB = 2;
  localparam logic [7:0] MASK = 8'b1010_0101;
  function automatic logic f(logic [7:0] x);
    return MASK[RB] ^ x[RB];
  endfunction
endpackage
module top(input logic [7:0] i, output logic o);
  assign o = p::f(i);
endmodule
