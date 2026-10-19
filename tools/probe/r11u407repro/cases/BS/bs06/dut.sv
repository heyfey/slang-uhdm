// § pkgRetBitSelParamFold407
package p;
  localparam int RH = 7;
  localparam int RL = 4;
  function automatic logic [3:0] f(logic [7:0] x);
    return x[RH:RL] ^ 4'h1;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  assign o = p::f(i);
endmodule
