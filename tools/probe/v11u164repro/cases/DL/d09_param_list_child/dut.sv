// § caDelayFirstOnly164 § caDelayParamElabFresh164 — a parameter delay list in a child with two overrides
module ch #(parameter D = 1) (input a, output b, output c);
  assign #D b = a, c = ~a;
endmodule
module top (input a, output b1, c1, b2, c2);
  ch #(2) u1(a, b1, c1);
  ch #(9) u2(a, b2, c2);
endmodule
