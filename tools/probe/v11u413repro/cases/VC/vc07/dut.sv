// § classCallResultMemberRef413
class C;
  int s = 2;
  function C mk(int a);
    C o = new;
    o.s = a;
    return o;
  endfunction
endclass
module top(output int r);
  C h;
  int z = 3;
  initial begin h = new; r = h.mk(z + 1).s; end
endmodule
