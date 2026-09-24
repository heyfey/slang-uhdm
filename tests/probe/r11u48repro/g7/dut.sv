// g7 — g2 with the loop variable declared OUTSIDE the for header.
package g7p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic int unsigned maxw(int unsigned n);
    automatic int unsigned res = 0;
    automatic int unsigned i;
    for (i = 0; i < n; i++)
      if (w(i) > res) res = w(i);
    return res;
  endfunction
endpackage
module g7 (output logic [g7p::maxw(3)-1:0] o);
  assign o = '0;
endmodule
