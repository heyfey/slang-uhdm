// § hpSelIdxPkgFoldTsOwner236 — member paths in an interface body and through a modport port
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [3:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
interface ifc import pk::*; ();
  r_t [N:0] rc;
  logic o;
  assign rc[N].base.q = '0;
  assign o = rc[N].base.q[0];
  modport mp (input rc, output o);
endinterface
module sub import pk::*; (ifc.mp m, output logic x);
  assign x = m.rc[N].base.q[1] ^ m.o;
endmodule
module top (output logic x);
  ifc u_i ();
  sub u_s (.m(u_i.mp), .x(x));
endmodule
