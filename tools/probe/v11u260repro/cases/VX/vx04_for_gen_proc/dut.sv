// § pkgSelPsBoundColonsElab260 (an always_comb inside a for-generate, the whole right side)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter int W = 8) (output logic [W-1:0] q [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb q[i] = cp::R3[1][0][W-1:0];
  end
endmodule
module top;
  logic [7:0] q [2];
  m u (.q(q));
endmodule
