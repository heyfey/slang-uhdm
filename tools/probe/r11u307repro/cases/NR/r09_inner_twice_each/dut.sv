// § nestedDefSecondBodyReadsRep307
module outer (input logic a, output logic y, z);
  module inner (input logic i, output logic o); assign o = i; endmodule
  inner u_i (.i(a), .o(y));
  inner u_j (.i(~a), .o(z));
endmodule
module dut (input logic [1:0] a, output logic [1:0] y, z);
  outer u_o (.a(a[0]), .y(y[0]), .z(z[0]));
  outer u_p (.a(a[1]), .y(y[1]), .z(z[1]));
endmodule
