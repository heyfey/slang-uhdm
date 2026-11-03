// § clsPropSpecFullNameLazy470 (two properties of one specialization in a package class)
package p;
  class res #(type T = int, int N = 2);
    T v;
  endclass
  class C;
    res#(byte, 3) a, b;
  endclass
endpackage
module top; import p::*; C c; endmodule
