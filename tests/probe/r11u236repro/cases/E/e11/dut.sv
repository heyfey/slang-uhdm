// § hpSelIdxPkgFoldTsOwner236 — Earlgrey #106660: a member path read in a function body and a three-level instance
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
  typedef struct packed { logic [3:0] a; } g_t;
endpackage
module leaf import pk::*; (output logic o);
  r_t [N:0] rc;
  assign rc[N].base.q = 2'b01;
  function automatic logic rd(r_t [N:0] x);
    return x[N].base.q[0];
  endfunction
  assign o = rd(rc);
endmodule
module mid (output logic o);
  leaf u_l (.o(o));
endmodule
module top (output logic o);
  mid u_m (.o(o));
endmodule
