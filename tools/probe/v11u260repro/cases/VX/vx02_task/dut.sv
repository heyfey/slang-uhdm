// § pkgSelPsBoundColonsElab260 (a module task body, the compound assignment)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  task automatic t(input logic [W-1:0] x, output logic [W-1:0] r);
    r = x;
    r ^= cp::RC[1][W-1:0];
  endtask
  always_comb t(d, q);
endmodule
module top;
  logic [7:0] d, q;
  m u (.d(d), .q(q));
endmodule
