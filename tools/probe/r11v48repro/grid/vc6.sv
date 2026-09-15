// vc6 — a CLASS-METHOD loop local in an IF-condition call inside a package class.
package vc6p;
  function automatic int unsigned fw(int unsigned i); return i + 1; endfunction
  class C;
    function automatic int unsigned maxw(int unsigned n);
      automatic int unsigned res = 0;
      for (int unsigned i = 0; i < n; i++)
        if (fw(i) > res) res = fw(i);
      return res;
    endfunction
  endclass
endpackage
module vc6 (input logic c, output logic o);
  assign o = c;
endmodule
