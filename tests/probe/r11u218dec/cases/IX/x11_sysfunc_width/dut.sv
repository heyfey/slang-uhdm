// § hpTrailIpsNamesByPath218 — x11_sysfunc_width: a system call in the base
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
module m #(parameter int W = 4) (input tp::req_t tl_i, output logic [7:0] o);
  assign o = tl_i.a_address[$clog2(W)+:8];
endmodule
module top(input tp::req_t tl_i, output logic [7:0] o);
  m u(.tl_i(tl_i), .o(o));
endmodule
