// § lvIdxMemberSelIsRead184 § genScopeTrailSelNameLate184: a class-method lvalue index and a generate-scope nonblocking lvalue index reading a member path ending in a select
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1) (input logic clk, input s_t s);
  class C;
    s_t h;
    logic [7:0] q;
    function void g(int k);
      q[h.f[k]] = 1'b1;
    endfunction
  endclass
  logic [7:0] r;
  if (P) begin : gg
    always_ff @(posedge clk) r[s.f[2]] <= 1'b1;
  end
endmodule
