// § genHopFoldSelName198
module top #(parameter int N = 2, parameter int unsigned P = 3) (input logic [15:0] a, input logic s, input logic [3:0] m [8], input logic [31:0] w, output logic [3:0] y, output logic [1:0] y2 [4], output logic [7:0] z);
  if (N > 1) begin : g
    assign y[0] = a[P];
    assign y[1] = a[P+1];
    assign z[3:0] = w[31:P+28];
  end
endmodule
