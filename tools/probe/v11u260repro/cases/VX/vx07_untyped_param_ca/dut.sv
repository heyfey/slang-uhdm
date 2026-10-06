// § pkgSelPsBoundColonsElab260 (an untyped header parameter, a continuous assignment, depth 2)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter W = 8) (output logic [W-1:0] q);
  assign q = cp::RC[3][W-1:0];
endmodule
module mid (output logic [7:0] q);
  m u (.q(q));
endmodule
module top;
  logic [7:0] q;
  mid x (.q(q));
endmodule
