module sub ();
  module innermod (output logic [31:0] r); assign r = 32'd2; endmodule
  module pl (); wire z; endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
