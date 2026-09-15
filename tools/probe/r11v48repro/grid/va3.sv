// va3 — a CLASS METHOD body local in a package class, in the RETURN expression.
package va3p;
  function automatic int unsigned w(int unsigned i); return i + 1; endfunction
  class C;
    function automatic int unsigned f(int unsigned n);
      int unsigned k = n;
      return w(k) + 1;
    endfunction
  endclass
endpackage
module va3 (input logic c, output logic o);
  assign o = c;
endmodule
