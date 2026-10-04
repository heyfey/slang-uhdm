// § hpSelIdxPkgFoldTsOwner236 — package index member paths in a port connection, as an index of another select, and through an unpacked array
package pk;
  localparam int N = 2;
  typedef struct packed { logic [2:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module sub (input logic [2:0] i, output logic o);
  assign o = ^i;
endmodule
module top import pk::*; (input logic [7:0] v, output logic o, output logic o2, output logic o3);
  r_t [N:0] rc;
  r_t ru [N+1];
  assign rc = '0;
  assign ru[N].base.q = 3'd5;
  assign ru[N].size.q = 3'd1;
  sub u_s (.i(rc[N].base.q), .o(o));
  assign o2 = v[rc[N].size.q];
  assign o3 = ru[N].base.q[0];
endmodule
