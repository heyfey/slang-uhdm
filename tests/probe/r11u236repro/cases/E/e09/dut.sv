// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: procedural member paths with two parameter indices
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
  typedef struct packed { logic [3:0] a; } g_t;
endpackage
module top import pk::*; (input logic i, output logic o);
  g_t [N:0] gc;
  always_comb begin
    gc = '0;
    gc[N].a[M] = i;
    o = gc[N].a[M];
  end
endmodule
