module top #(parameter int N = 2) (input logic [7:0] a, output logic y);
  if (N > 1) begin : g
    localparam int unsigned L = N*2;
    assign y = a[L+1];
  end
endmodule
