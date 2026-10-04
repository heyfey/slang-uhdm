// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: procedural lvalue and rvalue member paths with a package parameter index
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; (input logic i, output logic o);
  r_t [N:0] rc;
  always_comb begin
    rc = '0;
    rc[N].base.q = {i, i};
    o = rc[N].size.q[0];
  end
endmodule
