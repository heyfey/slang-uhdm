// § clsScopedChainIdxDirect292
package p;
  class h; int hval; endclass
  class b; static h stat = new(); static int w = 2; endclass
  class r;
    logic [7:0] v;
    logic [7:0] y;
    function void f1(); v[b::stat.hval +: 2] = 2'b1; endfunction
    function void f3(); y = v[b::stat.hval -: 2]; endfunction
  endclass
endpackage
module top(output logic [1:0] o);
  logic [7:0] v;
  always_comb o = v[p::b::stat.hval +: 2];
  p::r x = new();
endmodule
