// § clsScopedChainIdxDirect292
package p;
  class h; int hval; endclass
  class b; static h stat = new(); endclass
endpackage
module top(output int o1, output int o2);
  int arr [0:3];
  logic [3:0] w;
  always_comb begin
    arr[p::b::stat.hval] = 1;
    o1 = arr[p::b::stat.hval];
  end
  always_comb o2 = w[p::b::stat.hval];
  task automatic t(); arr[p::b::stat.hval] = 2; endtask
endmodule
