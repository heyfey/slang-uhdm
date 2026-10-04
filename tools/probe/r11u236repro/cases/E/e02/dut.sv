// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: a module localparam index in a member path
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; (output logic o);
  localparam int L = 1;
  r_t [2:0] rc;
  assign rc[L].base.q = '0;
  assign o = rc[L].base.q[0];
endmodule
