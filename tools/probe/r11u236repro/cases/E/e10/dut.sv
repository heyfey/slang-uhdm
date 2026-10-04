// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: member paths inside a generate block
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
  typedef struct packed { logic [3:0] a; } g_t;
endpackage
module top import pk::*; (output logic o);
  if (1) begin : g
    r_t [N:0] gr;
    assign gr[N].size.q = '1;
  end
  assign o = g.gr[N].size.q[0];
endmodule
