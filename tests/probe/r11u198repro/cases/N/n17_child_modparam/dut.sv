// § ovrParamBoundOpSelName198
module ch #(parameter int unsigned P = 10, parameter int N = 2) (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z);
  if (N > 1) begin : g
    assign y[0] = a[P];
    assign y[1] = a[P+1];
    assign z = w[31:P+18];
  end
endmodule
module top (input logic [15:0] a, input logic [31:0] w, output logic [3:0] y, output logic [3:0] z);
  ch #(.P(5)) u (.a(a), .w(w), .y(y), .z(z));
endmodule
