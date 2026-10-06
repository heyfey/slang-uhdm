// § pkgSelPsBoundColonsElab260 (instance depth three)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  always_comb begin q = d; q ^= cp::RC[0][W-1:0]; end
endmodule
module mid (input logic [7:0] d, output logic [7:0] q);
  m u (.d(d), .q(q));
endmodule
module top;
  logic [7:0] d, q;
  mid a (.d(d), .q(q));
endmodule
