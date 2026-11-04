// § genClsNoDefPropRange436
package p;
class C #(int N);
  logic [N-1:0] v;
  function logic [N-1:0] get();
    return v;
  endfunction
endclass
endpackage
module top;
endmodule
