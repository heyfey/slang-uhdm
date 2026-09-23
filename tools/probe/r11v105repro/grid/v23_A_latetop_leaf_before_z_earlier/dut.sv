// control: the other top z sharing the leaf is declared BEFORE the late namesake (z walked first; rep = z's)
module leaf (input logic c, output logic d); assign d = c; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module z (input logic e, output logic f);
  leaf u_z (.c(e), .d(f));
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b);
  logic q;
  leaf u_m (.c(a[1]), .d(q));
  assign b = {q, 3'b0};
endmodule
