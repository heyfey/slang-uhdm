// § classCallResultMemberRef413
class C;
  int arr[4];
  static function C mk();
    C o = new;
    return o;
  endfunction
endclass
module top(output int r);
  initial r = C::mk().arr[1];
endmodule
