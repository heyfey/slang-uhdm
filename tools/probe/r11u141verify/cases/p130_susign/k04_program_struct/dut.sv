// § suSigningNotInSpan130
// case k04: an inline packed signed struct variable declared in a sub-module instantiated twice
module sub(output logic [3:0] o);
  struct packed signed { logic [1:0] a; logic [1:0] b; } x;
  assign o = x;
endmodule
module top(output logic [3:0] o1, output logic [3:0] o2);
  sub u1(.o(o1));
  sub u2(.o(o2));
endmodule
