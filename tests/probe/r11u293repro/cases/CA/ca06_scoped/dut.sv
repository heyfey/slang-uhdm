// § defNetClassArrTsDimEnd293
// A package-qualified class keeps its pkg:: start.
package pk;
  class C;
    int idx;
  endclass
endpackage
module top;
  pk::C a [];
  pk::C b [2];
endmodule
