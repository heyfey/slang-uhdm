// § ovrParamBoundOpSelName198
module ch #(parameter int unsigned P = 10, parameter int N = 2) (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z, output logic [7:0] z2);
  if (N > 1) begin : g
    assign z = w[31:P+18];
  end
endmodule
module top (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z, output logic [7:0] z2);
  ch  u (.a(a), .w(w), .y(y), .z(z), .z2(z2));
endmodule
