// § defNetClassArrTsDimEnd293
// A specialization of a parameterized class.
package pk;
  class C;
    int idx;
  endclass
  class P #(int W = 4);
    bit [W-1:0] v;
  endclass
endpackage
module top;
  import pk::*;
  P #(8) a [];
  P b [2];
endmodule
