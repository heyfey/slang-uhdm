// § hpTrailIpsNamesByPath218 — x10_gen_scope: inside a generate scope
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
module m #(parameter int B = 2) (input tp::req_t tl_i, output logic [7:0] o);
  if (B > 0) begin : g
    assign o = tl_i.a_address[B+:8];
  end
endmodule
module top(input tp::req_t tl_i, output logic [7:0] o);
  m u(.tl_i(tl_i), .o(o));
endmodule
