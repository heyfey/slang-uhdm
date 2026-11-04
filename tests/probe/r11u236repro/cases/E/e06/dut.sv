// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: the member path in a child instance (depth 2)
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
  typedef struct packed { logic [3:0] a; } g_t;
endpackage
module sub import pk::*; (output logic o);
  r_t [N:0] rc;
  assign rc[N].base.q = '0;
  assign o = rc[N].base.q[0];
endmodule
module top (output logic o);
  sub u_s (.o(o));
endmodule
