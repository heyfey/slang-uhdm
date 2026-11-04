// § clsPropSpecFullNameLazy470 (a nested class property specialization)
package p;
  class res #(type T = int); T v; endclass
  class O;
    class I; res#(int) r; endclass
    I i;
  endclass
endpackage
module top; import p::*; O o; endmodule
