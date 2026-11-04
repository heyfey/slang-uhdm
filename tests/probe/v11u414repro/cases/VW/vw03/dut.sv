// § classWildcardIdxRefTs414
package p;
  class C;
    int a[*];
  endclass
endpackage
module top;
  p::C c;
endmodule
