// § varInitOpCastKept404
module top;
  logic [3:0] a = 8'hFF & 8'h0F;
  logic [3:0] b = 8'b1111_0000 | 4'b0011;
  byte s = 1 << 9;
endmodule
