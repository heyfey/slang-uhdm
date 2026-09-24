module sub ();
  wire [31:0] q = 32'd1;
  module innermod (output logic [31:0] r);
    assign r = q;
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
