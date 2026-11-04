// § nestedDefSecondBodyReadsRep307
module outer #(parameter int W = 1) (input logic a, output logic [3:0] y);
  module inner (input logic i, output logic [3:0] o); assign o = W + i; endmodule
  inner u_i (.i(a), .o(y));
endmodule
module dut (input logic [1:0] a, output logic [7:0] y);
  outer #(.W(1)) u_o (.a(a[0]), .y(y[3:0]));
  outer #(.W(2)) u_p (.a(a[1]), .y(y[7:4]));
endmodule
