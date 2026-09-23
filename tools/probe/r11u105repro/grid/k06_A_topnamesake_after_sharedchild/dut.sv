// LAW A: the late top namesake instantiates a child dut ALSO instantiates (representative stays dut's)
module leaf (input logic c, output logic d); assign d = c; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic z;
  sub u_s ();
  leaf u_l (.c(1'b1), .d(z));
  assign o = {31'd0, z};
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b);
  logic q;
  leaf u_m (.c(a[1]), .d(q));
  assign b = {q, 3'b0};
endmodule
