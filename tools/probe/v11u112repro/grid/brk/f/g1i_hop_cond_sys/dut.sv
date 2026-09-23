module top #(parameter int N = 2) (input logic [31:0] a, output logic [3:0] y, output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 1) begin : h
      assign y[i] = a[(L == 2) ? 1 : L];
      assign z[i] = a[$clog2(L+1)+1];
    end
  end
endmodule
