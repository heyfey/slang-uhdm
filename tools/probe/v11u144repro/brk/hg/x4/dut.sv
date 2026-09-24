// § defGenLhsHpBaseAnchor144
module top(input logic [1:0] v, output logic o);
  typedef struct packed { logic [1:0] f; logic g; } s_t;
  s_t [1:0] s;
  for (genvar i = 0; i < 2; i++) begin: g
    assign s[i].f[0] = v[i];
    assign s[i].f[1] = 1'b0;
    assign s[i].g = s[i].f[0];
  end
  assign o = s[0].g;
endmodule
