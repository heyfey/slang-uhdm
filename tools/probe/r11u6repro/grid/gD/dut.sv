// gD — NEGATIVE CONTROL, MODULE holder: the view law is package-only, so a
// module-homed typedef + module parameter must be untouched.
module top;
  parameter int W = 20;
  typedef logic [W-1:0][$clog2(W)-1:0] perm_t;
  parameter perm_t V = 100'h0;
  logic [W-1:0] x;
  assign x = V[0];
endmodule
