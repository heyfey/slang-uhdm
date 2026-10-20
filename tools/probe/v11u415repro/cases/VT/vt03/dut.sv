// § thisCallResultMemberDropped415
class In;
  int s = 5;
endclass
class C;
  In inner = new;
  function C mk();
    C o = new;
    return o;
  endfunction
  function int g();
    return this.mk().inner.s;
  endfunction
endclass
module top(output int r);
  C h;
  initial begin h = new; r = h.g(); end
endmodule
