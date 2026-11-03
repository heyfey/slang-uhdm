// § clsPropSpecFullNameLazy470 (two properties of one specialization in a package)
package p;
  class res #(type T = int, int N = 2); T v; endclass
  class C; res#(byte, 3) a; res#(byte, 3) b; endclass
endpackage
module top; import p::*; C c; endmodule
