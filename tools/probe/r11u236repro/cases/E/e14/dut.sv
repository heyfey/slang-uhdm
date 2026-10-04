// § hpSelIdxPkgFoldTsOwner236 — a member path whose index is a package parameter, in an if-generate and a for-generate
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [3:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; (output logic [1:0] o);
  r_t [N:0] rc;
  assign rc = '0;
  if (N > 1) begin : g_if
    assign o[0] = rc[N].base.q[0];
  end
  for (genvar k = 0; k < 1; k++) begin : g_for
    assign o[1] = rc[M].size.q[k];
  end
endmodule
