// § classCallResultMemberRef413
class C;
  int s = 2;
  static function C mk();
    C o = new;
    return o;
  endfunction
endclass
module top(output int r);
  initial if (C::mk().s == 2) r = 1; else r = 0;
endmodule
