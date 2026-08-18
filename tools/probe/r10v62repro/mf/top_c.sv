module top62k (input logic clk, output logic [7:0] o);
  logic [1:0] a, b, c;
  mfm62 #(.W(4))  u_a (.clk(clk), .z(a));
  mfm62 #(.W(8))  u_b (.clk(clk), .z(b));
  mfm62 #(.W(16)) u_c (.clk(clk), .z(c));
  assign o = {2'b0, a, b, c};
endmodule
