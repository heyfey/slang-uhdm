// § genHopFoldSelName198
module ch #(parameter int N = 2) (input logic [15:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2 + N;
    if (N > 1) begin : h
      assign y[i] = a[L] ^ a[L-1];
    end
  end
endmodule
module top (input logic [15:0] a, output logic [3:0] y, output logic [3:0] y3);
  ch #(.N(2)) u (.a(a), .y(y));
  ch #(.N(3)) v (.a(a), .y(y3));
endmodule
