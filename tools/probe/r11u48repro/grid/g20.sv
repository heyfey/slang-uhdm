// g20 — g16's shape but CONSTANT-EVALUATED (called from a range): the other
// half of the split, where the local always has a value and golden is bare.
package g20p;
  function automatic int unsigned g2re(int unsigned e); return e; endfunction
  function automatic int unsigned rem(int unsigned re, int unsigned str); return re + str; endfunction
  function automatic int unsigned ismatch(int unsigned expr, int unsigned str);
    int unsigned s = g2re(expr);
    return rem(s, str);
  endfunction
endpackage
module g20 (output logic [g20p::ismatch(1,2)-1:0] o);
  assign o = '0;
endmodule
