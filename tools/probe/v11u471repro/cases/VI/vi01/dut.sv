// § pkgInitImpReadFolds471
// unary minus, ternary and concatenation over an imported parameter in a package init
package a;
  parameter int PA = 3;
  parameter logic [3:0] PB = 4'd2;
endpackage
package b;
  import a::*;
  localparam int L1 = -PA;
  localparam int L2 = (PA > 2) ? PA : 1;
  localparam logic [7:0] L3 = {PB, PB};
endpackage
module top(output int y);
  import b::*;
  assign y = L1 + L2 + L3;
endmodule
