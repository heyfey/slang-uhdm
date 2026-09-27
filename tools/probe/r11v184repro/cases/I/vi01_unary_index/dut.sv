// § incDecMemberSelIsLvalue184 § incDecSelTopRestore184v: inc/dec member selects whose index is itself a unary operation, in a generate scope, a function and a task
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1) (input logic clk);
  s_t s;
  int k;
  logic b;
  function automatic void bump(int j);
    s.f[~j]++;
    s.f[-j]--;
  endfunction
  task automatic tb(logic c);
    s.f[!c]++;
  endtask
  if (P) begin : gg
    always_ff @(posedge clk) begin
      s.f[~k]++;
      --s.f[!b];
    end
  end
  initial s.f[-k]++;
endmodule
