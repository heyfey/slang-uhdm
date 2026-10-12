// § defNetClassArrTsDimEnd293
// A declaration written through a macro.
package pk;
  class C;
    int idx;
  endclass
endpackage
`define DECL(n) C n [];
module top;
  import pk::*;
  `DECL(a)
  C b [];
endmodule
