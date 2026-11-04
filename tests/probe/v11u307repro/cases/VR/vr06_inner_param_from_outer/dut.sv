// § nestedDefSecondBodyReadsRep307
module outer #(parameter int W = 2) (input logic [W-1:0] a, output logic [W-1:0] y);
  module inner #(parameter int N = 1) (input logic [N-1:0] i, output logic [N-1:0] o); assign o = ~i; endmodule
  inner #(.N(W)) u_i (.i(a), .o(y));
endmodule
module dut (input logic [4:0] a, output logic [4:0] y);
  outer #(.W(2)) u_o (.a(a[1:0]), .y(y[1:0]));
  outer #(.W(3)) u_p (.a(a[4:2]), .y(y[4:2]));
endmodule
