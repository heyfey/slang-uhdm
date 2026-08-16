// VERIFIER arm v74_edge2 — the LITERAL-DETECTION gate and the location
// arithmetic.  The code's "integer literal" test is on the RAW TEXT
// (`find_first_not_of("0123456789")`), so every literal NOT spelled as bare
// decimal digits takes the emitExpr branch instead of the hand-built one.
`define CALLLEN(q, ix) q[ix].len()

module v74_edge2;
  class user;
    string sq[$];
    int    r;

    function void f(int i);
      // x_based   — a SIZED literal index
      r = sq[4'd2].len();
      // x_hexlit  — a BASED literal index
      r = sq['h2].len();
      // x_trailsp — a bare decimal literal with a TRAILING space
      r = sq[2 ].len();
      // x_plainlit— the control: the hand-built arm
      r = sq[3].len();
      // x_ternary — a conditional index
      r = sq[i ? 0 : 1].len();
      // x_cast    — a cast index
      r = sq[int'(i)].len();
      // x_this    — an EXPLICIT `this.` in the receiver path
      r = this.sq[i].len();
      // x_macro   — the whole call written through a MACRO
      r = `CALLLEN(sq, i);
    endfunction
  endclass

  user u;
  initial begin
    u = new();
    u.f(0);
  end
endmodule
