// § idxQualCallNameSpan310
package p; function automatic int f(int x); return x; endfunction endpackage
typedef struct packed { logic [3:0] k; logic [3:0][7:0] g; logic [7:0] f; } e_t;
module top(input logic [1:0] i, input logic c, output logic [7:0] r, output logic [7:0] q);
  e_t sa [4];
  assign r = sa[1].g[p::f(i)];
  assign q = sa[c ? p::f(i) : 0].f;
endmodule
