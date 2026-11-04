// § genClsNoDefRangeSyntax436
class C #(int N, int M = N + 1);
  function logic [M-1:0] f(input logic [3:0] a);
    return a;
  endfunction
endclass
module top;
endmodule
