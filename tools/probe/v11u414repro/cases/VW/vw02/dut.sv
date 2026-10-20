// § classWildcardIdxRefTs414
class C;
  static int a[*];
  local int b[*];
endclass
module top;
  C c;
endmodule
