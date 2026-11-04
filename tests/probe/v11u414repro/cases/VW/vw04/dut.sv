// § classWildcardIdxRefTs414
class C #(type T = int);
  T a[*];
endclass
module top;
  C #(byte) c;
endmodule
