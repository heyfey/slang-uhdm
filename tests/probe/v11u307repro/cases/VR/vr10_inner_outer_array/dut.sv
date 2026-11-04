// § nestedDefSecondBodyReadsRep307
module outer (input logic a, output logic y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  inner u_i (.i(a), .o(y));
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  outer u_o [1:0] (.a(a), .y(y));
endmodule
