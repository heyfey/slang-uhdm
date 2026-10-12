// § defNetClassArrTsDimEnd293
// A package parameterized class specialization array.
package pk;
  class C #(int W = 4); logic [W-1:0] x; endclass
endpackage
module top;
  pk::C #(8) a [$];
  int r_o;
  initial r_o = a.size();
endmodule
