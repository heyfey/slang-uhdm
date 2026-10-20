// § classWildcardIdxRefTs414
class C;
  int a[*];
  int b[int];
  int d[string];
endclass
module top;
  C c;
endmodule
