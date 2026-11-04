// § clsScopedBoundWholeSpan201
class K;
  localparam int V = 5;
endclass
class U;
  logic [15:0] r;
  function logic [7:0] get();
    return r[K::V:1];
  endfunction
  function logic [7:0] get2(logic [15:0] a);
    return a[K::V-1:0] + r[K::V+2:K::V];
  endfunction
endclass
module top;
  U u;
  initial begin u = new; void'(u.get()); void'(u.get2(3)); end
endmodule
