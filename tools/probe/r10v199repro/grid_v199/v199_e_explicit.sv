package vpe;
  parameter E_UHEX = 'hf000000;
  parameter E_UDEC = 21;
  parameter E_UNUSED = 'o17;
  localparam E_LHEX = 'h3;
endpackage
import vpe::E_UHEX;
import vpe::E_UDEC;
import vpe::E_UNUSED;
module ve(input logic clk);
  logic q;
  always_ff @(posedge clk) q <= E_UHEX[0];
endmodule
