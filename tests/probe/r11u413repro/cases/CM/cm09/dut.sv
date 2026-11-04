// § classCallResultMemberRef413
class C;
  int s = 2;
  static function C mk();
    C o = new;
    return o;
  endfunction
endclass
module top(output int r);
  int t;
  initial begin
    t = C::mk().s;
    r = t + C::mk().s;
  end
endmodule
