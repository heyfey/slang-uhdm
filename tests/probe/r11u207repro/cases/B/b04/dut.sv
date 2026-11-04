// § parenMethodCallPathSpan207: parenthesized method calls through a handle (one and two pairs, with and without arguments) as an index, an operand and a right-hand side
package p;
class C;
  int m_i[int];
  int v;
  function int gi(int a = 0); return a + v; endfunction
  function int f(C c);
    int y;
    y = (c.gi(1));
    y = ((c.gi(5)));
    if ((c.gi(2)) > 0) y = m_i[(c.gi(4))];
    return (c.gi(3)) + y;
  endfunction
endclass
endpackage
module top; endmodule
