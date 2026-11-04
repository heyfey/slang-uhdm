// § thisCallResultMemberDropped415
class C;
  int s = 2;
  int t;
  function C mk();
    C o = new;
    return o;
  endfunction
  function void f();
    if (this.mk().s == 2) t = 1;
  endfunction
endclass
module top;
  C h;
  initial begin h = new; h.f(); end
endmodule
