// § clsArrPatBasedLitElemW460
package p;
  class C;
    int d[] = '{'ha0, 8'h1, 'hx};
    int a[string] = '{"k": 'h3};
  endclass
endpackage
module top;
  import p::*;
  initial begin C c; c = new; end
endmodule
