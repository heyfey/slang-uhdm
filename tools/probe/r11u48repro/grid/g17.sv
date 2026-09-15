// g17 — g14's never-evaluated shape with the call inside a WHILE loop.
package g17p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  function automatic bit f(int unsigned n);
    automatic int unsigned r = 0;
    automatic int unsigned k = 0;
    while (k < n) begin r = w(k); k = k + 1; end
    return r != 0;
  endfunction
endpackage
module g17 (input logic c, output logic o);
  assign o = c;
endmodule
