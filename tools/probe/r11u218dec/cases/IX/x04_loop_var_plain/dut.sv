// § hpIpsBaseRefsNamedThroughPath218 — x04_loop_var_plain: the loop-variable base without the conditional
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
module m (input tp::req_t tl_i, output logic [7:0] o);
  logic [31:0] w;
  always_comb begin
    for (int i = 0; i < 4; i++) begin
      w[8*i+:8] = tl_i.a_data[8*i+:8];
    end
  end
  assign o = w[7:0];
endmodule
module top(input tp::req_t tl_i, output logic [7:0] o);
  m u(.tl_i(tl_i), .o(o));
endmodule
