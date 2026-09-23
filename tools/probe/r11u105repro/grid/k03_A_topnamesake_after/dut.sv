// LAW A (pass-102 R0): dut instantiates sub; sub holds a nested innermod; a file-scope
// innermod declared AFTER dut is itself a top with no instantiation (ported)
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
