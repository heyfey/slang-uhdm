// g5 — package class, out-of-body method whose BODY declares locals of every
// atom kind the census saw as an owner (string/bit/int/integer), plus a
// foreach-block local (the 48-slot shape).
package p5;
  class c5;
    int q[$];
    extern function int f5(string kind);
  endclass
  function int c5::f5(string kind);
    string s;
    bit    b;
    int    i;
    integer g;
    s = kind;
    b = (s == "HARD");
    i = 0;
    g = 0;
    foreach (q[k]) begin
      string inner;
      inner = kind;
      i += q[k] + inner.len();
    end
    f5 = i + int'(b) + g;
  endfunction
endpackage
module top5;
  import p5::*;
  c5 h;
  initial h = new();
endmodule
