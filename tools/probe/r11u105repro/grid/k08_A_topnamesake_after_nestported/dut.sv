// LAW A control: the NESTED innermod is ported (no implicit instance takes the key); late top namesake
module sub ();
  module innermod (output logic [7:0] r); assign r = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
