// r10vearl70 adversarial arm: subtraction operand order and root sign.
package vs70_pkg;
  parameter int P = 16;
  parameter int Q = 4;
endpackage
module vs70_leaf(input [127:0] a,b,c,d,e,f,g,h);
endmodule
module vs70_mid import vs70_pkg::*; (input [255:0] sig);
  for (genvar i=0; i<2; i++) begin: g
    vs70_leaf u(
      .a(sig[P-1:0]),
      .b(sig[63:P-1]),
      .c(sig[1-P+31:0]),
      .d(sig[63:1-P+31]),
      .e(sig[P-32+32:0]),
      .f(sig[63:P-32+32]),
      .g(sig[32-P:0]),
      .h(sig[63:32-P])
    );
  end
endmodule
module vs70_top(input [255:0] sig);
  vs70_mid u(.sig(sig));
endmodule
