// break: sub holds a nested PROGRAM innermod; late file-scope top module innermod
module sub ();
  program innermod (); int n = 1; endprogram
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
