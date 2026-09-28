// § memberSelParenIdxSpan184: two-dimensional member selects with a parenthesized first or second index, and a parenthesized index on a member of an unpacked-array element
module top (input logic [1:0] i, input logic [1:0] j, output logic a, output logic b, output logic c);
  typedef struct packed { logic [3:0][3:0] m; logic [3:0] n; } s_t;
  s_t s;
  s_t arr [4];
  always_comb begin
    a = s.m[i][(j)];
    b = s.m[(i)][j];
    c = arr[i].n[(j)];
  end
endmodule
