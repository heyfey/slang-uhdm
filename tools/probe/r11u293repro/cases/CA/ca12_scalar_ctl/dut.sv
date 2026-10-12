// § defNetClassArrTsDimEnd293
// CONTROL: a scalar handle and a handle with an initializer.
package pk;
  class C;
    int idx;
  endclass
endpackage
module top;
  import pk::*;
  C h;
  C g = null;
endmodule
