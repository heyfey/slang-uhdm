// § caDelayFirstOnly164 § caDelayParamElabFresh164 — a header-parameter delay over three net assignments in a child instantiated twice
module sub #(parameter D = 1) (input a, output b, output c, output d);
  assign #D b = a, c = ~a, d = a;
endmodule
module top(input a, output [5:0] o);
  sub #(3) u0(a, o[0], o[1], o[2]);
  sub u1(a, o[3], o[4], o[5]);
endmodule
