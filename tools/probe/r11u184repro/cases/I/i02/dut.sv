// § incDecMemberSelIsLvalue184 § genScopeTrailSelNameLate184: the inc/dec operands in a generate scope, a module function, a task, a class method and a for step
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1) (input logic clk);
  s_t s;
  int i;
  function automatic void bump(int k);
    s.f[k]++;
  endfunction
  task automatic tb(int k);
    s.f[k]--;
  endtask
  class C;
    s_t h;
    function void g(int k);
      h.f[k]++;
    endfunction
  endclass
  initial for (int j = 0; j < 2; s.f[j]++) j++;
  if (P) begin : gg
    always_ff @(posedge clk) s.f[i]++;
  end
endmodule
