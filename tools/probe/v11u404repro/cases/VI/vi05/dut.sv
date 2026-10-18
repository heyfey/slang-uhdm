// § varInitOpCastKept404
module top;
  logic [63:0] w = 64'hFFFF_FFFF_FFFF_FFFF + 1;
  logic [99:0] big = 1 + 2;
  logic [7:0] m = 'd300 + 'd2;
  int unsigned u = 32'hFFFF_FFFF + 32'd1;
endmodule
