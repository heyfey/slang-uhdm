// § hpIpsBaseRefsNamedThroughPath218 — x05_port_conn: a port connection reading r.a_address[DataBitWidth +: 8] (flash_ctrl.sv:171)
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
module c (input logic [7:0] a, output logic [7:0] o);
  assign o = a;
endmodule
module m #(parameter int DataBitWidth = 2) (input tp::req_t tl_i, output logic [7:0] o);
  c u_c(.a(tl_i.a_address[DataBitWidth +: 8]), .o(o));
endmodule
module top(input tp::req_t tl_i, output logic [7:0] o);
  m u(.tl_i(tl_i), .o(o));
endmodule
