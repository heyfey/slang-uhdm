// § genClsNoDefRangeSyntax436
class C #(int N);
  function void f(input logic [N] a, input logic [N-1:0] b);
  endfunction
endclass
module top;
endmodule
