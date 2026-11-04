// § pkgSelPsBoundColonsElab260 (both bounds parameters, three levels, two instances overriding one of them)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter int W = 8, parameter int L = 0) (output logic [15:0] q);
  always_comb q = 16'(cp::R3[1][2][W-1:L]);
endmodule
module top;
  logic [15:0] q0, q1;
  m u0 (.q(q0));
  m #(.W(12), .L(4)) u1 (.q(q1));
endmodule
