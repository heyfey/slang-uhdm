// § genClsNoDefRangeSyntax436
class C #(int N, type T = int);
  function logic [N-1:0] f(input T a);
    return a;
  endfunction
endclass
module top;
endmodule
