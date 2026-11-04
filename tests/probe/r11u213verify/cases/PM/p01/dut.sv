// § parenMethodCallPathSpan207 (three pairs of parentheses; a cast around a parenthesized call; in if / while / ternary conditions)
package p;
  class H;
    function int get(int i); return i; endfunction
    function bit ok(int i); return i > 0; endfunction
  endclass
  class F;
    H h;
    function int g(int k);
      int r;
      r = (((h.get(k))));
      r += int'((h.get(2)));
      r += int'(h.get(3));
      if ((h.ok(k))) r++;
      while ((h.ok(r)) && r < 10) r++;
      r += (h.ok(1)) ? 1 : 2;
      return r;
    endfunction
  endclass
endpackage
module top; endmodule
