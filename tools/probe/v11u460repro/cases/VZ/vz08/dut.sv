// § clsArrPatBasedLitElemW460 (package variable and static property)
package p;
  int pa[2] = '{'h1, 'h2};
  class C;
    static int sa[] = '{'h3, 'h4};
  endclass
endpackage
module top;
  import p::*;
  initial begin C c; c = new; end
endmodule
