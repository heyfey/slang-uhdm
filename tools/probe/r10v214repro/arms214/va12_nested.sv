// v214 arm 12 — A CLASS NESTED IN A CLASS, and an out-of-body method defined at
// package scope for the outer class, both reading the package's own parameters.
// Plus a class that EXTENDS another in the same package.
package pv12;
  parameter int za12 = 41;
  parameter zb12 = za12;
  function automatic int zsink12(int a, int b); return a + b; endfunction
  class Base12;
    extern function int b_rd12();
  endclass
  function int Base12::b_rd12();
    return zsink12(za12, zb12);
  endfunction
  class Der12 extends Base12;
    extern function int d_rd12();
  endclass
  function int Der12::d_rd12();
    return super.b_rd12() + zb12;
  endfunction
endpackage
module topv12;
  pv12::Der12 d = new();
  int x;
  initial x = d.d_rd12();
endmodule
