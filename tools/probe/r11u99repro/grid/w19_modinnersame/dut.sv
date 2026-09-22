// a nested module whose name also exists at FILE scope
module innermod (); wire [31:0] f = 32'd9; endmodule
module sub ();
  module innermod (); wire [31:0] n = 32'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
