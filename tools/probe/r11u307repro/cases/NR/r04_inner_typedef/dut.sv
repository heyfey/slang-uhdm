// § nestedDefSecondBodyReadsRep307
module outer (input logic [3:0] a, output logic [3:0] y);
  module inner (input logic [3:0] i, output logic [3:0] o);
    typedef logic [3:0] w_t;
    w_t t;
    assign t = i;
    assign o = t;
  endmodule
  inner u_i (.i(a), .o(y));
endmodule
module dut (input logic [7:0] a, output logic [7:0] y);
  outer u_o (.a(a[3:0]), .y(y[3:0]));
  outer u_p (.a(a[7:4]), .y(y[7:4]));
endmodule
