// § tfItemInitLocalAtType209 — r11u217 l03: a paren-less CLASS method (in-body) and an out-of-body extern paren-less method declaring initialized locals: an int, a class handle `k h = new;`, a dynamic array `int d[] = '{1, 2};`, a queue `int q[$] = {3};`
package p;
  class k; int v; endclass
  class c;
    int acc;
    function void inb;
      int n = 4;
      k h = new;
      acc = n + h.v;
    endfunction
    extern function void oob;
  endclass
  function void c::oob;
    int d[] = '{1, 2};
    int q[$] = {3};
    automatic int z = 5;
    acc = d[0] + q[0] + z;
  endfunction
endpackage
module top;
  p::c h;
endmodule
