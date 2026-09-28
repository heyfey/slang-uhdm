// § parenMethodCallPathSpan207: decode only (residue) - a parenthesized method call that omits a defaulted argument lists the default in ours (callInvocation167 does not see through the parentheses), golden lists nothing
package p;
class C;
  int v;
  function int gi(int a = 0); return a + v; endfunction
  function int f(C c);
    int y;
    y = ((c.gi()));
    return y;
  endfunction
endclass
endpackage
module top; endmodule
