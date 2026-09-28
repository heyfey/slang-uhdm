// § parenMethodCallPathSpan207: parenthesized method calls as an operand, an if condition, a return value, a call argument, through this, super and two handles
package p;
class A;
  function int gi(int a = 0); return a; endfunction
endclass
class C extends A;
  C nx;
  function int h(int x); return x; endfunction
  function int f(C c);
    int y;
    y = (c.gi(1)) + 1;
    if ((c.gi(2))) y++;
    y += h((c.gi(3)));
    y += (this.gi(4)) + (super.gi(5)) + (c.nx.gi(6));
    return (c.gi(7));
  endfunction
endclass
endpackage
module top; endmodule
