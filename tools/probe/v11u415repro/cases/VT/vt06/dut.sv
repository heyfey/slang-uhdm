// § thisCallResultMemberDropped415
class C;
  int s = 2;
  C nxt;
  function C mk();
    C o = new;
    return o;
  endfunction
  function int g();
    nxt = new;
    return this.nxt.mk().s;
  endfunction
endclass
module top(output int r);
  C h;
  initial begin h = new; r = h.g(); end
endmodule
