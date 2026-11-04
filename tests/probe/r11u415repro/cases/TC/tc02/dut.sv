// § thisCallResultMemberDropped415
class C;
  int s = 2;
  function C mk(int v);
    C o = new;
    o.s = v;
    return o;
  endfunction
  function int g(int a);
    return this.mk(a + 1).s;
  endfunction
endclass
module top(output int r);
  C h;
  initial begin h = new; r = h.g(3); end
endmodule
