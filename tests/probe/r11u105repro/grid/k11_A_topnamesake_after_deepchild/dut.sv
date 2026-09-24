// LAW A: the late top namesake's child itself holds a nested module (the subtree merge re-keys it)
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module holder ();
  module deep (); wire [1:0] w = 2'd2; endmodule
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b);
  holder u_h ();
  assign b = a;
endmodule
