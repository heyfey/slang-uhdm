// § genClsNoDefRangeSyntax436
class C #(parameter N);
  function logic [N-1:0] f(input logic [N-1:0] a);
    return a;
  endfunction
endclass
class D #(int M = 3);
  function logic [M-1:0] f(input logic [M-1:0] a);
    return a;
  endfunction
endclass
module top;
  D d;
endmodule
