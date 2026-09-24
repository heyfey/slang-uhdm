// break: three nested names in sub (m1,m2,m3); file-scope late TOP m1, program m2, interface m3 (instantiated by dut)
module sub ();
  module m1 (); wire n1; endmodule
  module m2 (); wire n2; endmodule
  module m3 (); wire n3; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  m3 u_i ();
  assign o = 32'd0;
endmodule
module m1 (input logic a, output logic b); assign b = a; endmodule
program m2 (); int f = 2; endprogram
interface m3 (); logic g; endinterface
