// § suSigningNotInSpan130
// case k02: an inline packed signed struct with packed dimensions after the body
module top(output logic [7:0] o);
  struct packed signed { logic [1:0] a; logic [1:0] b; } [1:0] x;
  assign o = x;
endmodule
