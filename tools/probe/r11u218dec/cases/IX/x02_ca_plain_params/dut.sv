// § hpIpsBaseRefsNamedThroughPath218 — x02_ca_plain_params: the same without the conditional
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
module m #(parameter int DataBitWidth = 2, parameter int SramAw = 8) (input tp::req_t tl_i, output logic [7:0] o);
  assign o = tl_i.a_address[DataBitWidth+:SramAw];
endmodule
module top(input tp::req_t tl_i, output logic [7:0] o);
  m u(.tl_i(tl_i), .o(o));
endmodule
