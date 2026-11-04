// § pkgSelPsBoundColonsElab260 (a parameter in the part-select bound of a variable inside the qualified select's element index)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter int W = 2) (input logic [7:0] d, output logic [15:0] q);
  always_comb q = cp::RC[d[W-1:0]];
endmodule
module top;
  logic [7:0] d; logic [15:0] q;
  m u (.d(d), .q(q));
endmodule
