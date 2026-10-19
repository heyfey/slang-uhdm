// § classKwParamsLast412
package pk;
  class pc #(int W = 3, type T = byte);
    T v;
  endclass
endpackage
module top;
  class mc #(int W = 3, type T = byte);
  endclass
  pk::pc #(4, int) h;
endmodule
