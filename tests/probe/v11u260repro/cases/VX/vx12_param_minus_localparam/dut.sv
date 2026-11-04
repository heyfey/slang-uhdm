// § pkgSelPsBoundColonsElab260 (a parameter and a localparam in one bound expression)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter int W = 8) (output logic [7:0] q);
  localparam int O = 1;
  always_comb q = 8'(cp::RC[0][W-O:0]);
endmodule
module top;
  logic [7:0] q;
  m u (.q(q));
endmodule
