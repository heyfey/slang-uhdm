// g14 — g13 with an INTEGRAL body local instead of a string.
package g14p;
  function automatic int unsigned g2re(int unsigned e); return e; endfunction
  function automatic int rem(int unsigned re, int unsigned str); return re == str; endfunction
  function automatic bit ismatch(int unsigned expr, int unsigned str);
    int unsigned s;
    s = g2re(expr);
    return (rem(s, str) == 0);
  endfunction
endpackage
module g14 (input logic c, output logic o);
  assign o = c;
endmodule
