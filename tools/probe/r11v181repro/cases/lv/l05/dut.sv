// § procLvIdxCallWholeSpan181 (v11u181 break: call in lvalue index: sys call, method call, nested call, a cont assign control, an always_latch, a function in an interface)
interface ifc;
  logic [7:0] r;
  function automatic int ix(int a); return a & 7; endfunction
  function automatic void wr(int a); r[ix(a)] = 1'b1; endfunction
endinterface
module top(input logic en);
  logic [7:0] a, b;
  wire [7:0] w;
  int q[$];
  function automatic int f(int x); return x + 1; endfunction
  assign w[f(1)] = 1'b0;
  always_latch if (en) b[f(f(2))] = 1'b1;
  initial begin
    a[$clog2(8)] = 1'b1;
    a[q.size()] = 1'b0;
    a[f(1) + f(2)] <= 1'b1;
  end
  ifc u();
endmodule
