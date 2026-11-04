// § genClsNoDefRangeSyntax436
class C #(int N = 4);
  function logic [N-1:0] f(input logic [N-1:0] a);
    return a;
  endfunction
endclass
module top;
endmodule
