// g6 — g2's loop shape whose enclosing function is NEVER constant-evaluated
// (called only from a continuous assign, not from a range).
package g6p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned maxw(int unsigned n);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < n; i++)
      if (w(i) > res) res = w(i);
    return res;
  endfunction
endpackage
module g6 (input int unsigned a, output int unsigned o);
  assign o = g6p::maxw(a);
endmodule
