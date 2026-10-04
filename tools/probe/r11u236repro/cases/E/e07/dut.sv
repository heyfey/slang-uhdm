// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: a qualified package parameter index pk::N in a member path
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top (output logic o);
  pk::r_t [2:0] rc;
  assign rc[pk::N].base.q = '0;
  assign o = rc[pk::N].base.q[0];
endmodule
