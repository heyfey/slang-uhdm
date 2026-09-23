// LAW B (pass-102 R1): a file-scope PROGRAM innermod beside module sub holding a nested module innermod
program innermod (); int f = 9; endprogram
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
