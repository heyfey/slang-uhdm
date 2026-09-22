// LAW A x shadow: file-scope innermod beside a nested PORTED innermod (no instantiation)
module innermod (); wire [31:0] f = 32'd9; endmodule
module sub ();
  module innermod (output logic n); assign n = 1'b1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
