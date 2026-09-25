// § defGenLhsHpBaseAnchor144
module dut #(parameter int P = 1) (input logic a, output logic [1:0] o);
  typedef struct packed { logic f; logic g; } s_t;
  s_t [1:0] s;
  if (1) begin : g
    assign s[P].f = a;
  end
  assign s[0] = '0;
  assign s[1].g = 1'b0;
  assign o = {s[1].f, s[0].f};
endmodule
