// § defNetClassArrTsDimEnd293
// A class declared in the module body.
package pk;
  class C;
    int idx;
  endclass
endpackage
module top;
  class L;
    int k;
  endclass
  L a [];
  L b [2];
endmodule
