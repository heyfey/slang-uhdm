// g22 — the MODULE-function twin of g16: never evaluated, the call in the
// RETURN top expression, the actual a body local.  `pkgRetTopExpr8` is a
// PACKAGE window, so this arm says whether the guard's package-only spelling
// can reach a cell golden stamps.
module g22 (input logic c, output logic o);
  function automatic int unsigned g2re(int unsigned e); return e; endfunction
  function automatic int unsigned rem(int unsigned re, int unsigned str); return re + str; endfunction
  function automatic bit ismatch(int unsigned expr, int unsigned str);
    int unsigned s = g2re(expr);
    return (rem(s, str) == 0);
  endfunction
  assign o = c;
endmodule
