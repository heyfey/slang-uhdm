// § hpSelIdxPkgFoldTsOwner236 — package index member paths in an interface body and read through the interface instance
package pk;
  localparam int N = 2;
  typedef struct packed { logic q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
interface ifc import pk::*; ();
  r_t [N:0] rc;
  assign rc[N-1:0] = '0;
  assign rc[N].base.q = 1'b1;
  assign rc[N].size.q = 1'b0;
endinterface
module top import pk::*; (output logic o);
  ifc u_i ();
  assign o = u_i.rc[N].base.q;
endmodule
