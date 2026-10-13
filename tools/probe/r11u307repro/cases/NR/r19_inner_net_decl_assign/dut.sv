// § nestedDefSecondBodyReadsRep307
module outer (input logic a, output logic y);
  module inner (input logic i, output logic o);
    wire w = ~i;
    assign o = w;
  endmodule
  inner u_i (.i(a), .o(y));
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  outer u_o (.a(a[0]), .y(y[0]));
  outer u_p (.a(a[1]), .y(y[1]));
endmodule
