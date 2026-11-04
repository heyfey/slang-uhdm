// § hpIdxCallNameSpan184: a trailing select of a mixed path, a call inside a plain select nested in the index, a class method and a generate scope
module top #(parameter bit P = 1) (input logic clk);
  typedef struct packed { logic [3:0] v; } ps_t;
  typedef struct packed { ps_t [3:0] w; } pm_t;
  pm_t [1:0] pb;
  logic [3:0] arr;
  int k;
  logic [3:0] r1, r2;
  logic r3;
  function automatic int f(int x); return x; endfunction
  class C;
    pm_t q;
    function logic [3:0] g(int j);
      return q.w[f(j)].v;
    endfunction
  endclass
  initial begin
    r3 = pb[k].w[k][f(k)];
    r1 = pb[arr[f(k)]].w[k].v;
  end
  if (P) begin : gg
    always_ff @(posedge clk) r2 <= pb[f(k)].w[1].v;
  end
endmodule
