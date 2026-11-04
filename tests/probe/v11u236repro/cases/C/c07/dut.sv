// § hpSelIdxPkgFoldTsOwner236 — package index member paths at instance depths two and three with an lvalue and a read in each
package pk;
  localparam int N = 2;
  typedef struct packed { logic q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module leaf import pk::*; (input logic a, output logic o);
  r_t [N:0] rc;
  assign rc[N-1:0] = '0;
  assign rc[N].base.q = 1'b1;
  assign rc[N].size.q = a;
  assign o = rc[N].base.q;
endmodule
module mid (input logic a, output logic o, output logic o2);
  leaf u_l (.a(a), .o(o));
  leaf u_k (.a(~a), .o(o2));
endmodule
module top (input logic a, output logic o, output logic o2, output logic o3);
  mid u_m (.a(a), .o(o), .o2(o2));
  leaf u_t (.a(a), .o(o3));
endmodule
