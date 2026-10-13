// § nestedDefSecondBodyReadsRep307
module outer (input logic [3:0] a, output logic y);
  module inner (input logic [1:0] i, output logic o); assign o = &i; endmodule
  inner u_i (.i(a[2:1]), .o(y));
endmodule
module dut (input logic [7:0] a, output logic [1:0] y);
  outer u_o (.a(a[3:0]), .y(y[0]));
  outer u_p (.a(a[7:4]), .y(y[1]));
endmodule
