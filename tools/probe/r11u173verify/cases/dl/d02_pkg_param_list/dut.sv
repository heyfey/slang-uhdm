// § caDelayFirstOnly164 § caDelayParamElabFresh164 — a package-parameter delay, two net assignments
package dp;
  parameter int D = 4;
endpackage
module top (input a, output b, output c);
  assign #dp::D b = a, c = ~a;
endmodule
