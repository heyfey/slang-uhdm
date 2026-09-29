// § hpTrailIpsNamesByPath218 — x12_var_base: a module variable as the base
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
module m (input tp::req_t tl_i, input logic [3:0] k, output logic [7:0] o);
  assign o = tl_i.a_address[k+:8];
endmodule
module top(input tp::req_t tl_i, input logic [3:0] k, output logic [7:0] o);
  m u(.tl_i(tl_i), .k(k), .o(o));
endmodule
