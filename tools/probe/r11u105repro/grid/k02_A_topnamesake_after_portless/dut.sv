// LAW A: the file-scope namesake is a portless TOP declared AFTER dut
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (); wire [31:0] f = 32'd9; endmodule
