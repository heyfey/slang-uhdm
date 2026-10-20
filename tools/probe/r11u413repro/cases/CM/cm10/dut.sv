// § classCallResultMemberRef413
class C;
  int s = 2;
  function C mk(int v);
    C o = new;
    o.s = v;
    return o;
  endfunction
endclass
module top(output int r);
  C h;
  initial begin h = new; r = h.mk(3).s + 1; end
endmodule
