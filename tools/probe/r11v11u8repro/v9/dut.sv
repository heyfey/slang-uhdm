// v9 — stringify as an ASSIGNMENT Rhs (the backslash end-column rule) with a
// leak in front.
`define S9(__x) `"__x`"
`define A9(__x) string s = `S9(__x);
module top;
  string t;
  initial begin
    t = `S9(plain);
  end
  `define ASSIGN9(__x) initial t =   \
        `S9(__x);
  `ASSIGN9(leak9)
endmodule
