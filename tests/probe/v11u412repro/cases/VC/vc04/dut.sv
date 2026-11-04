// § classKwParamsLast412
package pk;
  class C #(parameter W = 4, int K = 2);
    logic [W-1:0] v;
  endclass
endpackage
module top;
  pk::C #(8, 3) c;
endmodule
