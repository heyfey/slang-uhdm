// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: a member path with two parameter indices
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; (output logic o);
  typedef struct packed { logic [3:0] a; } g_t;
  g_t [N:0] gc;
  assign gc[N].a[M] = 1'b1;
  assign o = gc[N].a[M];
endmodule
