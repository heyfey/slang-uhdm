// § genClsNoDefRangeSyntax436
class C #(int N);
  function reg [N-1:0] f(input logic signed [N-1:0] a, input bit signed [N:1] b);
    return a;
  endfunction
endclass
module top;
endmodule
