// § nestedDefSecondBodyReadsRep307
module outer (input logic [1:0] a, output logic [1:0] y);
  module inner (input logic [1:0] i, output logic [1:0] o);
    for (genvar k = 0; k < 2; k++) begin : g
      assign o[k] = ~i[k];
    end
  endmodule
  inner u_i (.i(a), .o(y));
endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  outer u_o (.a(a[1:0]), .y(y[1:0]));
  outer u_p (.a(a[3:2]), .y(y[3:2]));
endmodule
