module sub ();
  module innermod (output logic [31:0] r); assign r = 32'd2; endmodule
  module pmod (); wire pw; endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s1 ();
  sub u_s2 ();
  sub u_s3 ();
  assign o = 32'd0;
endmodule
