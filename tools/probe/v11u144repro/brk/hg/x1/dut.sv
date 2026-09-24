// § defGenLhsHpBaseAnchor144
module top(input logic [1:0] v, output logic o);
  typedef struct packed { logic x; logic y; } in_t;
  typedef struct packed { in_t a; logic g; } s_t;
  s_t [1:0] s;
  for (genvar i = 0; i < 2; i++) begin: g
    assign s[i].a.x = v[i];
    assign s[i].a.y = 1'b0;
    assign s[i].g = 1'b1;
  end
  assign o = s[0].a.x;
endmodule
