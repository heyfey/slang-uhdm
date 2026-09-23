// CONTROL: the nested innermod is PORTED (r11u101 LAW A mints it after collection) - no collision at entry
module innermod (); wire [31:0] f = 32'd9; endmodule
module sub ();
  module innermod (output logic r); assign r = 1'b1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  innermod u_f ();
  assign o = 32'd0;
endmodule
