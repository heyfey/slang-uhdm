// § hpSelIdxPkgFoldTsOwner236 — constant slots read: part-select bounds after a member path (e12 without the part-select lvalues)
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [3:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; (input logic [3:0] i, output logic [3:0] o, output logic [1:0] p);
  r_t [N:0] rc;
  assign rc[N-1:0] = '0;
  assign rc[N].size = '0;
  assign o = rc[N].base.q;
  assign p = rc[M].size.q[N-1:0];
endmodule
