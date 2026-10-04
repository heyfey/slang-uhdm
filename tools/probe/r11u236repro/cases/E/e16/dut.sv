// § hpSelIdxPkgFoldTsOwner236 — an implicit net driven from a member path, a this-free path in a class-typed context is absent; a two-level path
package pk;
  localparam int N = 2;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t [N:0] fs; } r_t;
endpackage
module top import pk::*; (output logic o);
  r_t [N:0] rc;
  assign rc[N].fs[N].q = 2'b10;
  assign rc[N-1:0] = '0;
  assign rc[N].fs[N-1:0] = '0;
  assign w = rc[N].fs[N].q[1];
  assign o = w;
endmodule
