// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: a package parameter index in an lvalue member path
package pk;
  localparam int N = 2;
  typedef struct packed { logic q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; (output logic o);
  r_t [N:0] rc;
  assign rc[N-1:0] = '0;
  assign rc[N].base.q = '0;
  assign rc[N].size.q = 1'b1;
  assign o = rc[N].base.q;
endmodule
