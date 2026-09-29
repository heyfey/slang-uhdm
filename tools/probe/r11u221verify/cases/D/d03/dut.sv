// § incDecOperandKeepsLvalueForm215 — inc/dec operands as call arguments of a class method called on a member handle, nested in another call, and in a ternary and a case expression
package p;
  class st; int a; int b; endclass
  class sink; function int take(int x); return x; endfunction endclass
  class drv;
    st s;
    sink k;
    function int g(int y); return y; endfunction
    function void run();
      int r;
      r = k.take(g(s.a++));
      r = (s.b > 0) ? k.take(s.b--) : g(++s.a);
      case (s.a++)
        0: r = 1;
        default: r = k.take(--s.b);
      endcase
    endfunction
  endclass
endpackage
module m;
endmodule
