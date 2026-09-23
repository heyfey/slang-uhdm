module top #(parameter int N = 2) (input logic [3:0] a [8][2], output logic [3:0] y [3]);
  for (genvar i = 0; i < 3; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 1) begin : h
      assign y[i] = a[L+1][L-L];
    end
  end
endmodule
