// § hpTrailIpsNamesByPath218 — x13_pkg_param_base: a package parameter as the base
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
package tb; localparam int PB = 3; endpackage
module m (input tp::req_t tl_i, output logic [7:0] o);
  assign o = tl_i.a_address[tb::PB+:8];
endmodule
module top(input tp::req_t tl_i, output logic [7:0] o);
  m u(.tl_i(tl_i), .o(o));
endmodule
