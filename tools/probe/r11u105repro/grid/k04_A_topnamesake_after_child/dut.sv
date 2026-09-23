// LAW A: the late top namesake owns a child the rest of the design never reaches
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module leaf (input logic c, output logic d); assign d = c; endmodule
module innermod (input logic [3:0] a, output logic [3:0] b);
  logic q;
  leaf u_l (.c(a[0]), .d(q));
  assign b = {3'b0, q};
endmodule
