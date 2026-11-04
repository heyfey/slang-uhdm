// § classCallResultMemberRef413
class C;
  int s = 2;
  static function C mk();
    C o = new;
    return o;
  endfunction
endclass
module top(output int r);
  function int f();
    return C::mk().s;
  endfunction
  initial r = f();
endmodule
