// § suSigningNotInSpan130
// case k03: an inline packed unsigned union with two declarators
module top(output logic [7:0] o);
  union packed unsigned { logic [3:0] a; logic [3:0] b; } x, y;
  assign o = {x, y};
endmodule
