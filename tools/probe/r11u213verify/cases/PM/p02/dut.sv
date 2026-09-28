// § parenMethodCallPathSpan207 (a parenthesized call as an operand, (a control), this. and a chained receiver)
package p;
  class H;
    H o;
    function int get(int i); return i; endfunction
  endclass
  class F;
    H h;
    function int g();
      int r;
      r = ((h.get(1)) + 1) * 2;
      r += (this.h.get(3));
      r += (h.o.get(4));
      r = {(h.get(5)), 16'h0};
      return r;
    endfunction
  endclass
endpackage
module top; endmodule
