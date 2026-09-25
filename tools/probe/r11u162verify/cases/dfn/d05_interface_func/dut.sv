// § dirlessFormalTypeAtName155
interface ifc;
  typedef struct packed { logic a; logic b; } s_t;
  function automatic int f(s_t [1:0] v); return int'(v); endfunction
endinterface
module top(input logic [3:0] i, output int x); ifc u(); assign x = u.f(i); endmodule
