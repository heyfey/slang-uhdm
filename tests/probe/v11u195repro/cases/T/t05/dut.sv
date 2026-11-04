// § tagPatParenSpan195 — v11u195 fresh: an index-setter pattern with parenthesized values on an unpacked array variable, and a default setter
module top (input logic [3:0] x, output logic [3:0] o);
  logic [3:0] arr [3];
  always_comb arr = '{0: (x), 2: ((x) & 4'h3), default: (4'd7)};
  assign o = arr[2];
endmodule
