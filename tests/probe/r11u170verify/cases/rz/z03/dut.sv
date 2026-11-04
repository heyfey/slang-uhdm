// § methodRandomizeCallSpan158
class pkt; rand int x; endclass
class gen;
  pkt p;
  function new(); p = new; endfunction
  function int f(); return p.randomize(); endfunction
  function int g(); int r; r = p.randomize() ? 1 : 0; return r; endfunction
endclass
module top; gen g0; initial begin g0 = new; void'(g0.f()); void'(g0.g()); end endmodule
