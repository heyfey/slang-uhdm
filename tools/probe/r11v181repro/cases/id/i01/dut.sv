// § incDecBitSelWholeSpan181 § incDecMixedPathIsLvalue181 (v11u181 break: inc/dec with genvar-indexed selects in generate loops, both forms, in always_ff and a generate function)
module top(input logic clk);
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  int cnt [0:3];
  m_t m;
  for (genvar g = 0; g < 2; g++) begin : G
    always_ff @(posedge clk) begin
      cnt[g]++;
      m.w[g+1].v--;
    end
    function automatic int h(int k); cnt[k]++; m.w[k].v++; return k; endfunction
  end
endmodule
