// § thisCallResultMemberDropped415
class C;
  int s = 2;
  function C mk();
    C o = new;
    return o;
  endfunction
  function int g();
    return this.mk().s;
  endfunction
endclass
module top(output int r);
  C h;
  initial begin h = new; r = h.g(); end
endmodule
