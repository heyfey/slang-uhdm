// § caDelayParamElabFresh164 — a parameter delay in a child whose parameter an instance overrides
module sub #(parameter D = 3) (input a, output b);
  assign #D b = a;
endmodule
module top (input a, output b, output c);
  sub #(.D(5)) u1(.a(a), .b(b));
  sub u2(.a(a), .b(c));
endmodule
