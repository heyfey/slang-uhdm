// § pkgSelPsBoundColonsElab260 (an element index (abstains: the clone keeps the reference))
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  always_comb q = cp::R3[0][W-7];
endmodule
module top;
  logic [7:0] d, q;
  m u (.d(d), .q(q));
endmodule
