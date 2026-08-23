// r10vbuvm27 ARM E -- 1..3 INSTANCES of a module carrying the rule
module leafE #(parameter int W = 8) (output logic [31:0] o);
  logic [W-1:0] pk [4];
  byte unsigned be;
  localparam int LP = $bits(pk[1] & 8'h0F);
  int r;
  initial r = $bits(pk[0] & be);
  assign o = LP + r;
endmodule
module vE;
  logic [31:0] o1, o2, o3;
  leafE #(8)  i1 (.o(o1));
  leafE #(16) i2 (.o(o2));
  leafE #(8)  i3 (.o(o3));
  initial $display("%0d %0d %0d", o1, o2, o3);
endmodule
