// § defNetClassArrTsDimEnd293
// A declaration whose dimension is on the next line.
package pk;
  class C;
    int idx;
  endclass
endpackage
module top;
  import pk::*;
  C a
    [];
endmodule
