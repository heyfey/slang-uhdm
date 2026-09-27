// § incDecBitSelWholeSpan181 — break hunt: a packed-vector bit inc/dec, a macro-born inc/dec operand, a two-dimensional element, an inc/dec in an always_ff and a class method
`define INC(x) x++
module top(input logic clk, input int i);
  int cnt [8];
  int m2 [4][4];
  logic [7:0] pv;
  class C; int q [4]; task t(int j); q[j]--; ++q[j+1]; endtask endclass
  always_ff @(posedge clk) cnt[i]++;
  initial begin
    C c = new;
    `INC(cnt[i+1]);
    m2[i][i]++;
    c.t(i);
  end
endmodule
