// FENCE (pass-98 RV1): file-scope innermod + sub holding a nested innermod + an explicit u_i inside sub
module innermod (); wire [31:0] f = 32'd9; endmodule
module sub ();
  module innermod (); wire [31:0] n = 32'd1; endmodule
  innermod u_i ();
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
