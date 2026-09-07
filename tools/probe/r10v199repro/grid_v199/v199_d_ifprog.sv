package vpd;
  parameter D_UHEX = 'hf000000;
  parameter D_UDEC = 21;
  parameter int D_INT = 3;
  localparam D_LBIN = 'b1010;
endpackage
import vpd::*;
interface vdi(input logic clk);
  logic q;
endinterface
program vdp(input logic clk);
  initial begin end
endprogram
module vd(input logic clk);
  vdi u0(clk);
endmodule
