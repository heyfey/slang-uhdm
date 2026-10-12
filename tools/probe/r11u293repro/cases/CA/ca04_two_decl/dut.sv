// § defNetClassArrTsDimEnd293
// Two declarators in one declaration.
package pk;
  class C;
    int idx;
  endclass
endpackage
module top;
  import pk::*;
  C a [], b [4];
endmodule
