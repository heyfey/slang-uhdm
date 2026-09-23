// LAW A x LAW B: a late top namesake instantiates the program namesake of another nested name
program inner2 (input logic c); int f; initial f = c; endprogram
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
  module inner2 (); wire [3:0] m = 4'd2; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b);
  inner2 u_p (.c(a[0]));
  assign b = a;
endmodule
