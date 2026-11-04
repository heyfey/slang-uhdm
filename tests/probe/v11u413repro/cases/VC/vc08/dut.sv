// § classCallResultMemberRef413
class C;
  int s = 2;
  function C mk();
    C o = new;
    return o;
  endfunction
endclass
class D;
  C h;
  int y;
  function void f();
    h = new;
    y = h.mk().s;
  endfunction
endclass
module top;
  D d;
  initial begin d = new; d.f(); end
endmodule
