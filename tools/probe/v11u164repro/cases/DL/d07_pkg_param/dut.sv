// § caDelayParamElabFresh164 — a package parameter delay
package p;
  parameter D = 7;
endpackage
module top (input a, output b);
  assign #p::D b = a;
endmodule
