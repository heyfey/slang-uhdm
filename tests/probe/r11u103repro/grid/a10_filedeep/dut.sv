// LAW A: the file-scope innermod is reached only through a LATER file-scope module other
module innermod (); wire [31:0] f = 32'd9; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module other (); innermod u_o (); endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  other u_t ();
  assign o = 32'd0;
endmodule
