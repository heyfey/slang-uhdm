// § defNetClassArrTsDimEnd293
// CONTROL: a typedef of the class (a shared listing object): no move.
package pk;
  class C;
    int idx;
  endclass
endpackage
module top;
  import pk::*;
  typedef C ct;
  ct a [];
endmodule
