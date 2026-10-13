// § idxCallTernTrueKeepsSpan310
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [1:0] f; logic [1:0] k; } e_t;
typedef struct packed { e_t [3:0] a; logic [1:0] k; } u_t;
module top(input logic clk, input logic [1:0] i, input logic [1:0] j, input logic c, output logic [1:0] r);
  e_t [3:0] sa; u_t u; logic [1:0] midx [4];
  function automatic logic [1:0] fn(logic [1:0] x); return x; endfunction
  always_comb r = sa[c ? (fn(i) ? j : i) : j].f;
endmodule
