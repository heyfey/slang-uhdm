module top #(parameter int N = 2) (input logic [3:0] a, output logic [15:0] y);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 1) begin : h
      assign y[L+1] = a[i];
    end
  end
endmodule
