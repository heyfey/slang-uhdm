// § caDelayParamElabFresh164 § caDelayFirstOnly164 — an imported (unqualified) package-parameter delay over two net assignments
package dp;
  parameter int D = 4;
endpackage
module top (input a, output b, output c);
  import dp::*;
  assign #D b = a, c = ~a;
endmodule
