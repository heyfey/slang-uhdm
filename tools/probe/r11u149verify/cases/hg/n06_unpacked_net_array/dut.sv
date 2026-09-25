// § defGenLhsHpBaseAnchor144
module dut(input logic [1:0] a, output logic [1:0] o);
  typedef struct packed { logic f; logic g; } s_t;
  s_t s [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign s[i].f = a[i];
    assign s[i].g = 1'b0;
    assign o[i] = s[i].f;
  end
endmodule
