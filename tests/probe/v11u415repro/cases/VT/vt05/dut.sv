// § thisCallResultMemberDropped415
package p;
  class C;
    int s = 2;
    function C mk(int k);
      C o = new;
      o.s = k;
      return o;
    endfunction
    function int g(int k);
      return this.mk(k).s;
    endfunction
  endclass
endpackage
module top(output int r);
  p::C h;
  initial begin h = new; r = h.g(4); end
endmodule
