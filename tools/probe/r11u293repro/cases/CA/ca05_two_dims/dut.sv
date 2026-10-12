// § defNetClassArrTsDimEnd293
// A two-dimension array ends at its first dimension.
package pk;
  class C;
    int idx;
  endclass
endpackage
module top;
  import pk::*;
  C a [2][3];
  C d [][];
endmodule
