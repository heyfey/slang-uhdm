// § hpIdxCallNameSpan184: a call in a non-trailing index in a continuous assignment, a generate scope's process, a class method and a package-qualified call
package pk;
  function automatic int g(int x); return x; endfunction
endpackage
module top #(parameter bit P = 1) (input logic clk);
  typedef struct packed { logic [3:0] v; } ps_t;
  typedef struct packed { ps_t [3:0] w; } pm_t;
  pm_t m;
  int k;
  logic [3:0] r1, r2, r3;
  function automatic int g(int x); return x; endfunction
  assign r1 = m.w[g(1)].v;
  if (P) begin : gs
    always_ff @(posedge clk) r2 <= m.w[g(k)].v;
  end
  initial r3 = m.w[pk::g(k)].v;
  class C;
    pm_t cm;
    function logic [3:0] rd(int j); return cm.w[g(j)].v; endfunction
  endclass
endmodule
