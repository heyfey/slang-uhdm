// § suSigningNotInSpan130
module sub(input struct packed signed { logic [3:0] a; logic [3:0] b; } p, output logic [7:0] q);
  assign q = p;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub u(.p(i), .q(o));
endmodule
