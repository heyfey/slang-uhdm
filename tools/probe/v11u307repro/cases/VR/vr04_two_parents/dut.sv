// § nestedDefSecondBodyReadsRep307
module outer (input logic a, output logic y);
  module inner (input logic i, output logic o); always_comb o = ~i; endmodule
  inner u_i (.i(a), .o(y));
endmodule
module p1 (input logic a, output logic y); outer u_o (.a(a), .y(y)); endmodule
module p2 (input logic a, output logic y); outer u_o (.a(a), .y(y)); endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  p1 u_1 (.a(a[0]), .y(y[0]));
  p2 u_2 (.a(a[1]), .y(y[1]));
endmodule
