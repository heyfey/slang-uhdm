// § ovrParamBoundOpSelName198
module ch #(parameter int unsigned P = 10, parameter int N = 2) (input logic [3:0] a, output logic [31:0] w);
  if (N > 1) begin : g
    assign w[P+3:P] = a;
  end
endmodule
module top (input logic [3:0] a, output logic [31:0] w);
  ch #(.P(5)) u (.a(a), .w(w));
endmodule
