// § defNetClassArrTsDimEnd293
// A module-body dynamic array of a package class.
package pk;
  class C;
    int idx;
  endclass
endpackage
module top;
  import pk::*;
  C a [];
endmodule
