// break (pass-102 landed road): dut INSTANTIATES the file-scope namesake declared after sub; it shares a ported leaf with a LATER top z
module leaf (input logic c, output logic d); assign d = c; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic [3:0] y;
  sub u_s ();
  innermod u_f (.a(4'd3), .b(y));
  assign o = {28'd0, y};
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b);
  logic q;
  leaf u_m (.c(a[1]), .d(q));
  assign b = {q, 3'b0};
endmodule
module z (input logic e, output logic f);
  leaf u_z (.c(e), .d(f));
endmodule
