// § pkgRetBitSelParamFold407
package p;
  localparam int RB = 7;
  function automatic logic f(logic [7:0] x);
    logic r;
    r = x[RB] & x[0];
    return r;
  endfunction
endpackage
module top(input logic [7:0] i, output logic o);
  assign o = p::f(i);
endmodule
