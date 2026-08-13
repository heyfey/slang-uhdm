// g3 — $unit-scope class with an out-of-body method: no package home at all.
class c3;
  extern function bit f3(string kind);
endclass
function bit c3::f3(string kind);
  string loc;
  loc = kind;
  f3 = (loc == "HARD");
endfunction
module top3;
  c3 h;
  initial h = new();
endmodule
