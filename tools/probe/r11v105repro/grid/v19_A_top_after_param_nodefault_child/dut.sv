// break: late namesake top instantiates a leaf with a param override and an unpacked port; plus a second nested outer
module leaf #(parameter int W = 3) (input logic [W-1:0] c [2], output logic [W-1:0] d); assign d = c[0] ^ c[1]; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module sub2 ();
  module innermod (input logic t); wire u = t; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  sub2 u_s2 ();
  assign o = 32'd0;
endmodule
module innermod (input logic [5:0] a [2], output logic [5:0] b);
  leaf #(.W(6)) u_l (.c(a), .d(b));
endmodule
