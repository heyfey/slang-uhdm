// § dirlessFormalTypeAtName155
typedef struct packed { logic a; logic b; } s_t;
module top (input logic [5:0] i, output int x);
  function automatic int f(s_t [2:0] v); return int'(v); endfunction
  assign x = f(i);
endmodule
