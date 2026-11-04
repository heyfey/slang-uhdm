// § defNetClassArrTsDimEnd293
// A queue and an associative array.
package pk;
  class C;
    int idx;
  endclass
endpackage
module top;
  import pk::*;
  C q [$];
  C m [string];
  C n [int];
endmodule
