// § hpIpsBaseRefsNamedThroughPath218 — x07_ps_params: a simple part select with parameter bounds as the path tail
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
module m #(parameter int H = 9, parameter int L = 2) (input tp::req_t tl_i, output logic [7:0] o);
  assign o = tl_i.a_address[H:L];
endmodule
module top(input tp::req_t tl_i, output logic [7:0] o);
  m u(.tl_i(tl_i), .o(o));
endmodule
