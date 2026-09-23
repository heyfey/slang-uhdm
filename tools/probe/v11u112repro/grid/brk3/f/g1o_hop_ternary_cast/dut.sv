module top #(parameter int N = 2) (input logic [31:0] a, input logic s, output logic [3:0] y, output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 1) begin : h
      assign y[i] = a[s ? L : L+1];
      assign z[i] = a[int'(L)+1];
    end
  end
endmodule
