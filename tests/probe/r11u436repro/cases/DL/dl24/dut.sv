// § genClsNoDefRangeSyntax436
class C #(int N);
  localparam int W = N;
  function logic [W-1:0] f(input logic [W:0] a);
    return a;
  endfunction
endclass
module top;
endmodule
