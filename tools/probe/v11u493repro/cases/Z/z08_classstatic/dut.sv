// § enumCastChainKeepsInnerCast493
class C;
  typedef int t32;
  static function int f(int s);
    return int'(t32'(s));
  endfunction
endclass
module top(input int a, output int v);
  assign v = C::f(a);
endmodule
