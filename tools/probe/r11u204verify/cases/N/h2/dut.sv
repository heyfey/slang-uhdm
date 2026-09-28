// § genHopFoldSelName198: one-hop folds under index operations (a product plus a constant, a unary minus operand) and under a system call in the index
module top #(parameter int N = 2) (input logic [15:0] a, output logic [2:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i + 1;
    if (N > 1) begin : h
      assign y[i][0] = a[L*2+1];
      assign y[i][1] = a[-L+7];
      assign y[i][2] = a[$clog2(L+1)];
    end
  end
endmodule
