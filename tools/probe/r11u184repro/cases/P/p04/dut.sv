// § memberSelParenIdxSpan184 (controls): lvalue member selects with parenthesized indices, procedural and continuous
typedef struct packed { logic [7:0] f; } s_t;
module top(input logic [2:0] i);
  s_t s, t;
  assign t.f[(1)] = 1'b1;
  initial begin
    s.f[(i)] = 1'b0;
    s.f[((i))] <= 1'b1;
  end
endmodule
