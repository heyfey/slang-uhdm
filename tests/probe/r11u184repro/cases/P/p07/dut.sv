// § memberSelParenIdxSpan184 § incDecMemberSelIsLvalue184 § lvIdxMemberSelIsRead184 § genScopeTrailSelNameLate184: a parenthesized member select nested in lvalue and rvalue indices, as an inc/dec operand and in a generate scope
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1) (input logic clk);
  s_t s;
  logic [7:0] arr;
  logic y;
  int i;
  initial begin
    arr[s.f[(i)]] = 1'b1;
    y = arr[s.f[(i + 1)]];
    s.f[(i)]++;
  end
  if (P) begin : g
    logic z;
    always_ff @(posedge clk) z <= s.f[(i)];
  end
endmodule
