// g12 — a body local of a CLASS METHOD passed to a call.
package g12p;
  class C;
    function automatic int unsigned w(int unsigned i); return i + 1; endfunction
    function automatic int unsigned f(int unsigned n);
      automatic int unsigned k = n;
      return w(k);
    endfunction
  endclass
endpackage
module g12 (output int unsigned o);
  assign o = 0;
endmodule
