// § parenMethodCallPathSpan207: parenthesized method calls spanning two lines, written by a macro, and inside a ternary and a concatenation
`define PC(h, n) (h.gi(n))
package p;
class C;
  function int gi(int a = 0); return a; endfunction
  function int f(C c, bit b);
    int y;
    y = (c.gi(
          1));
    y += `PC(c, 2);
    y += b ? (c.gi(3)) : (c.gi(4));
    y += {(c.gi(5))};
    return y;
  endfunction
endclass
endpackage
module top; endmodule
