// § classCallResultMemberRef413
class C;
  int s = 2;
  static function int mk();
    return 5;
  endfunction
endclass
module top(output int r);
  initial r = C::mk() + 1;
endmodule
