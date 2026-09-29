// § hpIpsBaseRefsNamedThroughPath218 — x08_deep_path: a three-member path
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
package tq;
  typedef struct packed { tp::req_t q; logic z; } w_t;
endpackage
module m #(parameter int DataBitWidth = 2) (input tq::w_t r, output logic [7:0] o);
  assign o = r.q.a_address[DataBitWidth+:8];
endmodule
module top(input tq::w_t r, output logic [7:0] o);
  m u(.r(r), .o(o));
endmodule
