// § incDecBitSelWholeSpan181 § incDecMixedPathIsLvalue181 (r11u190: inc/dec in a nested begin of an always_ff and as a for-loop step over a two-select member path, in a package function)
package p;
  typedef struct { int v [4]; } s_t;
  function automatic int cnt(input int n);
    s_t s;
    int c [4];
    for (int i = 0; i < n; s.v[i & 3]++) begin
      c[i & 3]--;
      i++;
    end
    return s.v[0] + c[0];
  endfunction
endpackage
module top(input logic clk);
  int a [4];
  int k;
  always_ff @(posedge clk) begin
    begin
      a[k]++;
      --a[k + 1];
    end
    k <= p::cnt(k);
  end
endmodule
