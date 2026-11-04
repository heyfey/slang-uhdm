// § classCallResultMemberRef413
class C;
  int s = 2;
  static function C mk(int a, int b);
    C o = new;
    o.s = a + b;
    return o;
  endfunction
endclass
module top(output int r);
  int z;
  initial begin z = 1; r = C::mk(z, 3).s; end
endmodule
