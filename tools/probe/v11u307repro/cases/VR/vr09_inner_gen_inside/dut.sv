// § nestedDefSecondBodyReadsRep307
module outer #(parameter int N = 2) (input logic [3:0] a, output logic [3:0] y);
  module inner #(parameter int M = 2) (input logic [3:0] i, output logic [3:0] o);
    for (genvar k = 0; k < 4; k++) begin : g
      assign o[k] = (k < M) ? i[k] : 1'b0;
    end
  endmodule
  inner #(.M(N)) u_i (.i(a), .o(y));
endmodule
module dut (input logic [7:0] a, output logic [7:0] y);
  outer #(.N(1)) u_o (.a(a[3:0]), .y(y[3:0]));
  outer #(.N(3)) u_p (.a(a[7:4]), .y(y[7:4]));
endmodule
