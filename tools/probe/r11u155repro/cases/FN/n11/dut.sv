// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t;
  class c; function int f(s_t [2:0] v); return int'(v); endfunction endclass
endpackage
module top (output int x); assign x = 0; endmodule
