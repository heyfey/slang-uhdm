// § pkgRetBitSelParamFold407
package p;
  localparam int RB = 1;
  function automatic logic f(logic [7:0] x, int RB);
    return x[RB] & x[0];
  endfunction
  function automatic logic g(logic [7:0] x);
    logic [7:0] y;
    y = x;
    return y[RB] & y[p::RB];
  endfunction
endpackage
module top(input logic [7:0] i, output logic o, output logic o2);
  assign o = p::f(i, 3);
  assign o2 = p::g(i);
endmodule
