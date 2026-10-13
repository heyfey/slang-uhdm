// § nestedDefSecondBodyReadsRep307
module outer #(parameter bit TWO = 1) (input logic a, output logic [1:0] y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  inner u_i (.i(a), .o(y[0]));
  inner u_j (.i(a), .o(y[1]));
endmodule
module dut (input logic [1:0] a, output logic [3:0] y);
  outer u_o (.a(a[0]), .y(y[1:0]));
  outer u_p (.a(a[1]), .y(y[3:2]));
endmodule
