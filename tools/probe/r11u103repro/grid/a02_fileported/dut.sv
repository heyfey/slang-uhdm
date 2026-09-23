// LAW A: the file-scope innermod is PORTED, the nested one portless (nested reached first)
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  sub u_s ();
  innermod u_f (.a(x), .b(y));
  assign o = 32'd0;
endmodule
