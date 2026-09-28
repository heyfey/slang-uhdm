// § ovrParamBoundOpSelName198
module ch #(parameter int unsigned P = 10, parameter int N = 2) (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z, output logic [7:0] z2);
  if (N > 1) begin : g
    assign y[0] = w[P+1];
    assign y[1] = w[P];
  end
endmodule
module top (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z, output logic [7:0] z2);
  ch #(.P(5)) u (.a(a), .w(w), .y(y), .z(z), .z2(z2));
endmodule
