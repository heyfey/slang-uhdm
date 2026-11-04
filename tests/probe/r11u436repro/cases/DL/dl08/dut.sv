// § genClsNoDefRangeSyntax436
package p;
class C #(int N);
  function logic [N-1:0] f(input logic [N-1:0] a);
    return a;
  endfunction
endclass
endpackage
module top;
endmodule
