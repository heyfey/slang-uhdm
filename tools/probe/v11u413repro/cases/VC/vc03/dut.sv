// § classCallResultMemberRef413
class D;
  int k = 7;
endclass
class C;
  D d;
  static function C mk();
    C o = new;
    o.d = new;
    return o;
  endfunction
endclass
module top(output int r);
  initial r = C::mk().d.k;
endmodule
