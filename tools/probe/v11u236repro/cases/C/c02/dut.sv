// § hpSelIdxPkgFoldTsOwner236 — instance depth three, two package indices in one path, an index expression p::N-1
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic q; } f_t;
  typedef struct packed { f_t [N:0] fs; f_t base; } r_t;
endpackage
module leaf (output logic o);
  pk::r_t [pk::N:0] rc;
  assign rc[pk::N-1:0] = '0;
  assign rc[pk::N].base.q = 1'b1;
  assign rc[pk::N].fs[pk::M].q = 1'b0;
  assign rc[pk::N].fs[0].q = 1'b1;
  assign rc[pk::N].fs[pk::N].q = 1'b0;
  assign o = rc[pk::N - 1].base.q ^ rc[pk::N].fs[pk::M].q;
endmodule
module mid (output logic o);
  leaf u_l (.o(o));
endmodule
module top (output logic o);
  mid u_m (.o(o));
endmodule
