package vpc;
  parameter C_UHEX = 'hf000000;
  parameter C_UDEC = 21;
  parameter int C_INT = 3;
  localparam C_LHEX = 'hff;
endpackage
module vc(input logic clk);
  import vpc::*;
  logic q;
  always_ff @(posedge clk) q <= C_UHEX[0];
endmodule
