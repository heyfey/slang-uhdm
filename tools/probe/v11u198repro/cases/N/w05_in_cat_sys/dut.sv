// § ovrParamBoundOpSelName198
module ch #(parameter int unsigned P = 10, parameter int N = 2) (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z, output logic [7:0] z8);
  if (N > 1) begin : g
    assign z8 = {w[P+3:P], w[P+7:P+4]};
    assign z = $countones(w[P+3:P]);
  end
endmodule
module top (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z, output logic [7:0] z8);
  ch #(.P(5)) u (.a(a), .w(w), .y(y), .z(z), .z8(z8));
endmodule
