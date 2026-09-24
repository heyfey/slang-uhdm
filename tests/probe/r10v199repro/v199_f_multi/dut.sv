package vpf;
  parameter F_UHEX = 'hf000000;
  parameter F_UDEC = 21;
  parameter int F_INT = 3;
endpackage
import vpf::*;
module vf(input logic clk);
  import vpf::*;
  logic q;
  always_ff @(posedge clk) q <= F_UHEX[0];
endmodule
