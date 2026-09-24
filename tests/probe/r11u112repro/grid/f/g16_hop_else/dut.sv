module top #(parameter int N = 2) (input logic [15:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 5) begin : h0
      assign y[i] = a[L];
    end else begin : h1
      assign y[i] = a[L+1];
    end
  end
endmodule
