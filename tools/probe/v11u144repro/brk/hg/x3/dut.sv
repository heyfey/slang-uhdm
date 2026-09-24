// § defGenLhsHpBaseAnchor144
module top(input logic [1:0] v, output logic o);
  typedef struct packed { logic f; logic g; } s_t;
  s_t s [2];
  for (genvar i = 0; i < 2; i++) begin: g
    assign s[i].f = v[i];
    assign s[i].g = s[i].f;
  end
  assign o = s[0].g;
endmodule
