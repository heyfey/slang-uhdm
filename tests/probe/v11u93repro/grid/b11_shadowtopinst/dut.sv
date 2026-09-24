module innermod (output logic f); assign f = 1'b1; endmodule
module sub ();
  module innermod (output logic n, input logic m); assign n = m; endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  wire ff;
  sub u_s ();
  innermod u_f (.f(ff));
  assign o = 32'd0;
endmodule
