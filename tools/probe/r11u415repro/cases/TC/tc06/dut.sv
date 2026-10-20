// § thisCallResultMemberDropped415
class C;
  int s = 2;
  function C mk();
    C o = new;
    return o;
  endfunction
  function C g();
    return this.mk();
  endfunction
endclass
module top(output int r);
  C h;
  initial begin h = new; h = h.g(); end
endmodule
