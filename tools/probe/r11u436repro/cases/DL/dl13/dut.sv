// § genClsNoDefPropRange436
class C #(int N, int M = N * 2);
  logic [M-1:0] v;
  function logic [M:0] f();
    return v;
  endfunction
endclass
module top;
endmodule
