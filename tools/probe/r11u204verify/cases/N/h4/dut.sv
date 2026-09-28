// § genHopFoldSelName198: one-hop folds below a unary operator in a select index (a negation, a bitwise not, a logical not, a negated sum) and a binary control
module top #(parameter int N = 2) (input logic [15:0] a, output logic [4:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i + 1;
    if (N > 1) begin : h
      assign y[i][0] = a[-L+7];
      assign y[i][1] = a[~L & 7];
      assign y[i][2] = a[-(L+1)+8];
      assign y[i][3] = a[!L];
      assign y[i][4] = a[L+3];
    end
  end
endmodule
