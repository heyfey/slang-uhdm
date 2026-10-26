// § genClsNoDefRangeSyntax436
class C #(int N);
  function void f(input logic [N-1:0][3:0] a, output logic [3:0][N:0] b);
    b = a;
  endfunction
endclass
module top;
endmodule
