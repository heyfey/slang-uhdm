// § clsScopedChainIdxDirect292
package b;
  class s_t; int hval; int arr[4]; static s_t stat = new(); endclass
  typedef struct { int f; int g; } st_t;
  st_t sv;
endpackage
module top(input logic clk);
  logic [7:0] arr;
  logic [7:0] w;
  always_comb begin
    w[0] = arr[b::s_t::stat.hval];
    w[1] = arr[b::sv.f];
    w[2] = arr[b::sv.f + 1];
    arr[b::sv.g] = 1'b0;
  end
  initial w[3] = arr[b::s_t::stat.arr[1]];
endmodule
