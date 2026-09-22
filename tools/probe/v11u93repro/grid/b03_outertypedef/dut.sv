module sub ();
  typedef logic [3:0] nib_t;
  module innermod (input nib_t a, output logic y);
    assign y = a[0];
  endmodule
  nib_t q;
  assign q = 4'h3;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
