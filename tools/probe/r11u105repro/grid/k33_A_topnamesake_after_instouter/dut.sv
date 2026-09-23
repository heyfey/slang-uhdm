// LAW A: the late top namesake itself instantiates the outer that nests its twin
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b);
  sub u_s2 ();
  assign b = a;
endmodule
