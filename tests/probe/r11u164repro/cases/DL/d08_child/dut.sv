// § caDelayFirstOnly164 — two net assignments with a delay in an instantiated child
module sub (input a, output b, output c);
  assign #1 b = a, c = ~a;
endmodule
module top (input a, output b, output c);
  sub u (a, b, c);
endmodule
