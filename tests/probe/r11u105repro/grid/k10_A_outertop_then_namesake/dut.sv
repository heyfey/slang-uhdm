// LAW A: no dut — the outer sub is itself the first top; the ported file-scope namesake is the second top
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
