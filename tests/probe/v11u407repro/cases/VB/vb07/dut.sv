// § pkgRetBitSelParamFold407
package p;
  localparam logic signed [3:0] RB = 4'sd3;
  localparam shortint RS = 16'd2;
  function automatic logic f(logic [7:0] x);
    return x[RB] ~^ x[RS];
  endfunction
endpackage
module top(input logic [7:0] i, output logic o);
  assign o = p::f(i);
endmodule
