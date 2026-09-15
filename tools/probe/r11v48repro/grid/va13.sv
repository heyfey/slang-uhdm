// va13 — a body local passed to a call argument by REF and by OUTPUT.
package va13p;
  function automatic int unsigned wr(ref int unsigned i); return i + 1; endfunction
  function automatic int unsigned wo(output int unsigned i); i = 3; return 1; endfunction
  function automatic int unsigned f(int unsigned n);
    int unsigned k = n;
    int unsigned m;
    return wr(k) + wo(m);
  endfunction
endpackage
module va13 (input logic c, output logic o);
  assign o = c;
endmodule
