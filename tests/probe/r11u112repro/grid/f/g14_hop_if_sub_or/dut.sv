module top #(parameter int N = 2) (input logic [31:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = 2**(i+1)-1;
    if (N > 1) begin : h
      assign y[i] = a[L] | a[L+1];
    end
  end
endmodule
