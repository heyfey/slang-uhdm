// g16 — g14 with the local INITIALISED in its declaration rather than assigned
// by a later statement.
package g16p;
  function automatic int unsigned g2re(int unsigned e); return e; endfunction
  function automatic int rem(int unsigned re, int unsigned str); return re == str; endfunction
  function automatic bit ismatch(int unsigned expr, int unsigned str);
    int unsigned s = g2re(expr);
    return (rem(s, str) == 0);
  endfunction
endpackage
module g16 (input logic c, output logic o);
  assign o = c;
endmodule
